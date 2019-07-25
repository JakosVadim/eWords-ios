//
//  ShowViewController.swift
//  eWords
//
//  Created by Марченко Вадим on 09.01.2019.
//  Copyright © 2019 Vadim Marchenko. All rights reserved.
//

import UIKit
import Firebase

class ShowViewController: UIViewController, UITextFieldDelegate {

    var user: UserData!
    var ref: DatabaseReference!
    var words = Array<Word>()
    var tempWord: Word!
    var deckForSegue: String?
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var translationTextField: UITextField!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.translationTextField.delegate = self
        warnLabel.alpha = 0
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
            self?.showWord()
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == translationTextField {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func displayWarningLabel(withText text: String, answer: Bool) {
        if answer == true {
            self.warnLabel.textColor = hexStringToUIColor(hex: "#61BD4F")
        }
        else {
            self.warnLabel.textColor = hexStringToUIColor(hex: "#EB5A46")
        }
        self.warnLabel.text = text
        self.warnLabel.alpha = 1
    }
    
    func showWord() {
        let id = Int.random(in: 0..<self.words.count)
        self.tempWord = self.words[id]
        self.wordLabel.text = self.tempWord.title
        if ((self.wordLabel.text?.count)! > 10) {
            self.wordLabel.font = self.wordLabel.font.withSize(25)
        }
        else {
            self.wordLabel.font = self.wordLabel.font.withSize(35)
        }
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        guard let translation = translationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), translation.lowercased() == tempWord.translation.lowercased()  else {
            
            displayWarningLabel(withText: "Ответ неверный", answer: false)
            
            return
        }
        
        displayWarningLabel(withText: "Верный ответ", answer: true)
        self.translationLabel.text = tempWord.translation
        self.nextButton.setTitle("Далее", for: .normal)
        
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        showWord()
        self.warnLabel.alpha = 0
        self.translationTextField.text = ""
        self.translationLabel.text = "Перевод:"
        self.nextButton.setTitle("Пропустить", for: .normal)
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        self.translationLabel.text = tempWord.translation
    }
    
    
}
