//
//  DecksViewController.swift
//  eWords
//
//  Created by Марченко Вадим on 28.11.2018.
//  Copyright © 2018 Vadim Marchenko. All rights reserved.
//

import UIKit
import Firebase

class DecksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: UserData!
    var ref: DatabaseReference!
    var otherRef: DatabaseReference!
    var decks = Array<Deck>()
    var otherDecks = Array<Deck>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = UserData(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("decks")
        otherRef = Database.database().reference(withPath: "decks")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { [weak self] (snapshot) in
            var _decks = Array<Deck>()
            for item in snapshot.children {
                let deck = Deck(snapshot: item as! DataSnapshot)
                _decks.append(deck)
            }
            
            self?.decks = _decks
            self?.tableView.reloadData()
            
        })
        
        otherRef.observe(.value, with: { [weak self] (snapshot) in
            var _decks = Array<Deck>()
            for item in snapshot.children {
                let deck = Deck(snapshot: item as! DataSnapshot)
                if deck.userId != self?.user.uid {
                    _decks.append(deck)
                }
            }
            
            self?.otherDecks = _decks
            self?.tableView.reloadData()
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
        otherRef.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        if indexPath.row < decks.count {
            let deck = decks[indexPath.row]
            cell.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.5647058824, blue: 0.8117647059, alpha: 1)
            let deckTitle = deck.title
            cell.textLabel?.text = deckTitle
        } else {
            let deck = otherDecks[indexPath.row - decks.count]
            let deckTitle = deck.title
            cell.textLabel?.text = deckTitle
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count + otherDecks.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < decks.count {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deck = decks[indexPath.row]
            deck.ref?.removeValue()
            
            let delRef = Database.database().reference(withPath: "decks")
            
            delRef.child(deck.title).observeSingleEvent(of: .value, with: { (snapshot) in
                let delUid = snapshot.childSnapshot(forPath: "userId").value
                
                if ((delUid as? String) == self.user.uid) {
                    delRef.child(deck.title).removeValue()
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < decks.count {
            let title = decks[indexPath.row].title
            self.performSegue(withIdentifier: "wordsSegue", sender: title)
            return
        } else {
            let title = otherDecks[indexPath.row - decks.count].title
            self.performSegue(withIdentifier: "otherWordsSegue", sender: title)
            return
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let wordViewController = segue.destination as? WordsViewController, let title = sender as? String else {
            
            guard let secondWordViewController = segue.destination as? OtherWordsViewController, let title = sender as? String else { return }
                secondWordViewController.deckForSegue = title
            
            return
        }
        wordViewController.deckForSegue = title
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Новая колода", message: "Добавить новую колоду", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Введите название"
        })
        
        let save = UIAlertAction(title: "Добавить", style: .default) { _ in
            guard let textField = alertController.textFields?.first, textField.text != "" else { return }
            
            let deck = Deck(title: textField.text!, userId: (self.user.uid))
            let deckRef = self.ref.child(deck.title.lowercased())
            deckRef.setValue(deck.convertToDictionary())
                
            let otherDeckRef = self.otherRef.child(deck.title.lowercased())
            otherDeckRef.setValue(deck.convertToDictionary())
            
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
}
