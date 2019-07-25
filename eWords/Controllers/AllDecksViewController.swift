//
//  newDecksViewController.swift
//  eWords
//
//  Created by Марченко Вадим on 19.02.2019.
//  Copyright © 2019 Vadim Marchenko. All rights reserved.
//

import UIKit
import Firebase

class AllDecksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: UserData!
    var ref: DatabaseReference!
    var decks = Array<Deck>()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = UserData(user: currentUser)
        ref = Database.database().reference(withPath: "decks")
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        let deck = decks[indexPath.row]
        let deckTitle = deck.title
        cell.textLabel?.text = deckTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deck = decks[indexPath.row]
            deck.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = decks[indexPath.row].title
        self.performSegue(withIdentifier: "newWordsSegue", sender: title)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let wordViewController = segue.destination as? WordsViewController, let title = sender as? String else { return }
        wordViewController.deckForSegue = title
    }
    
    

    @IBAction func myDecksTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "decksSegue", sender: nil)
        return
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        //        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    
    }
}
