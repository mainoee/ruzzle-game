//
//  ViewController.swift
//  Ruzzle
//
//  Created by Marie-Noëlle  on 16/01/2020.
//  Copyright © 2020 Marie-Noëlle . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
        
    @IBOutlet var wordFound: UILabel!

    @IBOutlet var finalScore: UILabel!
    
    @IBOutlet var labelsDice: [UILabel]!
    
    var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    var finalWord = String()
    
    var listOfWords = [String]()
                    
    var labelsSelected = [UILabel]()
    
    var score = 0
    
    var validWord = Bool()
                
    override func viewDidLoad() {
        super.viewDidLoad()
                
        startNewGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        getLetters(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        getLetters(touches)
    }
    
    func getLetters(_ touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: view)
  
            for label in labelsDice {
                if label.isUserInteractionEnabled {
                    if label.frame.contains(location) {
                        if finalWord.isEmpty {
                            updateGame(label)
                        } else {
                            guard let lastLabelSelected = labelsSelected.last else { return }
                            if (lastLabelSelected.center.x == label.center.x && lastLabelSelected.center.y - label.center.y == 100) || (lastLabelSelected.center.y == label.center.y && lastLabelSelected.center.x - label.center.x == 100) || (lastLabelSelected.center.x == label.center.x && lastLabelSelected.center.y - label.center.y == -100) || (lastLabelSelected.center.y == label.center.y && lastLabelSelected.center.x - label.center.x == -100) {
                                updateGame(label)
                            }
                        }
                    }
                }
            }
        }
    }
  
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if finalWord.count < 3 {
            let title = "Sorry!"
            let message = "A word must be at least 3 characters long!"
            let action = "Continue"
            showAlert(title, message, action)
        } else {
            wordChecked(finalWord) { [weak self] (success) in
                if success {
                    self!.validWord = true
                } else {
                    self!.validWord = false
                }
            }
            perform(#selector(sendMessages), with: nil, afterDelay: 1)
        }
    }
    
    @objc func sendMessages() {
        if !validWord {
            let title = "Sorry!"
            let message = "That word doesn't exist!"
            let action = "Continue"
            showAlert(title, message, action)
        } else if listOfWords.contains(finalWord) {
            let title = "Oops!"
            let message = "You've already picked that word!"
            let action = "Continue"
            showAlert(title, message, action)
        } else {
            score += finalWord.count
            listOfWords.append(finalWord)
            wordFound.text = finalWord
            finalScore.text = "Total score: \(score)"

            let title = "Congrats"
            let message = "Your score is \(finalWord.count)!"
            let action = "Continue"
            showAlert(title, message, action)
        }
    }
    
    func updateGame(_ label: UILabel) {
        label.isUserInteractionEnabled = false
        label.backgroundColor = .lightGray
        
        guard let letter = label.text else { return }
        finalWord += letter
        
        labelsSelected.append(label)
    }
    
    func startNewRound() {
        finalWord = ""
        labelsSelected = []
        
        for label in labelsDice {
            label.isUserInteractionEnabled = true
            label.backgroundColor = .link
        }
    }
    
    @IBAction func startNewGame() {
        score = 0
        finalScore.text = "Total score: \(score)"
        finalWord = ""
        listOfWords = []
        labelsSelected = []
        wordFound.text = "Play now!"

        for label in labelsDice {
            label.isUserInteractionEnabled = true
            label.backgroundColor = .link
            label.font = label.font.withSize(28)
            label.text = alphabet.randomElement()?.uppercased()
        }
    }
    
    func wordChecked(_ word: String, completionHandler: @escaping (_ success: Bool) -> ())  {
        let appId = "9d248acf"
        let appKey = "3bef9b8a4d4113e061dedb2238b75117"
        let language = "en-gb"
        let word_id = finalWord.lowercased()
        let strictMatch = "false"
        
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v2/entries/\(language)/\(word_id)?strictMatch=\(strictMatch)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let _ = response,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                print(jsonData)
                guard let results = jsonData as? [String: Any] else { return }
                if let wordInDictionary = results["id"] as? String {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } else {
                print("Error serializing")
            }
        }).resume()
    }
    
    func showAlert(_ title: String, _ message: String, _ action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: action, style: .default, handler:  {
            action in
            self.startNewRound()
        })
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
}
