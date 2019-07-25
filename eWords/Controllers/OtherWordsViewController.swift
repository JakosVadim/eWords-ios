//
//  OtherWordViewController.swift
//  eWords
//
//  Created by Марченко Вадим on 20.02.2019.
//  Copyright © 2019 Vadim Marchenko. All rights reserved.
//

import UIKit
import Firebase

class OtherWordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var user: UserData!
    var ref: DatabaseReference!
    var otherRef: DatabaseReference!
    var deckRef: DatabaseReference!
    var words = Array<Word>()
    var deckForSegue: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = UserData(user: currentUser)
        
        ref = Database.database().reference(withPath: "decks").child(String(deckForSegue!)).child("words")
        otherRef = Database.database().reference(withPath: "users").child(String(user.uid)).child("decks").child(String(deckForSegue!)).child("words")
        deckRef = Database.database().reference(withPath: "users").child(String(user.uid)).child("decks")
        
        
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let showViewController = segue.destination as? ShowViewController, let title = sender as? String else { return }
        showViewController.deckForSegue = title
    }
    
    
    @IBAction func addDeckTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Добавить колоду", message: "Вы действительно хотите добавить себе эту колоду? После добавления вам будет доступен просмотр и редактирование колоды.", preferredStyle: .alert)
        
        
        let save = UIAlertAction(title: "Добавить", style: .default) { _ in
            
                
            let deck = Deck(title: self.deckForSegue!, userId: (self.user.uid))
            let deckRef = self.deckRef.child(deck.title.lowercased())
            deckRef.setValue(deck.convertToDictionary())
                
            for i in 0..<self.words.count {
                    
                let title = self.words[i].title
                let translation = self.words[i].translation
                    
                let word = Word(title: title, translation: translation, userId: (self.user.uid))
                let wordRef = self.otherRef.child(word.title.lowercased())
                    wordRef.setValue(word.convertToDictionary())
                    
            }

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
