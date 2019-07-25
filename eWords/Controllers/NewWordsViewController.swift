



import UIKit
import Firebase

class NewWordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: UserData!
    var ref: DatabaseReference!
    var words = Array<Word>()
    var deckForSegue: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = deckForSegue!
        guard let currentUser = Auth.auth().currentUser else { return }
        user = UserData(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("decks").child(String(deckForSegue!)).child("words")
        
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let word = words[indexPath.row]
            word.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "showSegue", sender: deckForSegue)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let showViewController = segue.destination as? ShowViewController, let title = sender as? String else { return }
        showViewController.deckForSegue = title
    }
    
    
    @IBAction func addDeckTapped(_ sender: UIBarButtonItem) {
    
    
    
    }
    
    
    
}
