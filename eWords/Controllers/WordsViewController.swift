//
//  WordsViewController.swift
//  eWords
//
//  Created by Марченко Вадим on 02.01.2019.
//  Copyright © 2019 Vadim Marchenko. All rights reserved.
//

import UIKit
import Firebase

class WordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: UserData!
    var ref: DatabaseReference!
    var otherRef: DatabaseReference!
    var words = Array<Word>()
    var otherWords = Array<Word>()
    var deckForSegue: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.title = deckForSegue!
        guard let currentUser = Auth.auth().currentUser else { return }
        user = UserData(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("decks").child(String(deckForSegue!)).child("words")
        otherRef = Database.database().reference(withPath: "decks")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { [weak self] (snapshot) in
            var _words = Array<Word>()
            for item in snapshot.children {
                let word = Word(snapshot: item as! DataSnapshot)
                _words.append(word)
            }
            
            self?.words = _words
            self?.tableView.reloadData()
            
        })
        
        otherRef.child(String(self.deckForSegue!)).child("words").observe(.value, with: { [weak self] (snapshot) in
            for item in snapshot.children {
                let word = Word(snapshot: item as! DataSnapshot)
                self?.otherWords.append(word)
            }
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
        otherRef.removeAllObservers()
        otherRef.child(String(deckForSegue!)).child("words").removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        let word = words[indexPath.row]
        let wordTitle = word.title + " - " + word.translation
        cell.textLabel?.text = wordTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let word = words[indexPath.row]
            word.ref?.removeValue()
            
            
            self.otherRef.child(self.deckForSegue!).child("words").child(word.title).observeSingleEvent(of: .value, with: { (snapshot) in
                let changeUid = snapshot.childSnapshot(forPath: "userId").value
                
                if ((changeUid as? String) == self.user.uid) {
                    self.otherRef.child(self.deckForSegue!).child("words").child(word.title).removeValue()
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSegue", sender: deckForSegue)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let showViewController = segue.destination as? ShowViewController, let title = sender as? String else { return }
        showViewController.deckForSegue = title
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Новое слово", message: "Добавить новое слово", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Введите слово"
        })
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Введите перевод"
        })
        
        let save = UIAlertAction(title: "Добавить", style: .default) { _ in
            guard let wordTextField = alertController.textFields?.first, wordTextField.text != "" else { return }
            guard let translationTextField = alertController.textFields?[1], translationTextField.text != "" else { return }
            
            let word = Word(title: wordTextField.text!, translation: translationTextField.text!, userId: (self.user.uid))
            let wordRef = self.ref.child(word.title.lowercased())
            wordRef.setValue(word.convertToDictionary())
            
            
            self.otherRef.child(self.deckForSegue!).observeSingleEvent(of: .value, with: { (snapshot) in
                let changeUid = snapshot.childSnapshot(forPath: "userId").value
                
                if ((changeUid as? String) == self.user.uid) || ((changeUid as? String) == nil) {
                    
                    if ((changeUid as? String) == nil) {
                        
                        let deck = Deck(title: self.deckForSegue!, userId: (self.user.uid))
                        let deckRef = self.otherRef.child(deck.title.lowercased())
                        deckRef.setValue(deck.convertToDictionary())

                        
                        for i in 0..<self.words.count {

                            let title = self.words[i].title
                            let translation = self.words[i].translation

                            let word = Word(title: title, translation: translation, userId: (self.user.uid))
                            let wordRef = self.otherRef.child(self.deckForSegue!).child("words").child(title)
                            
                            wordRef.setValue(word.convertToDictionary())

                        }
                        
                    }
                    
                    let otherWordRef = self.otherRef.child(String(self.deckForSegue!)).child("words").child(word.title.lowercased())
                    otherWordRef.setValue(word.convertToDictionary())
                }
            })
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func decksTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
}
