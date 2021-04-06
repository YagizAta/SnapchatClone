//
//  ViewController.swift
//  SnapchatClone
//
//  Created by Yağız Ata Özkan on 31.03.2021.
//

import UIKit
import Firebase


class SignInVC: UIViewController {

    @IBOutlet weak var EmailText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func SignInClicked(_ sender: Any) {
        if passwordText.text != "" && EmailText.text != "" {
            
            Auth.auth().signIn(withEmail: EmailText.text!, password: passwordText.text!) { (result, error) in
                if error != nil {
                    self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        } else {
            self.MakeAlert(title: "Error", message: "Email/Password ? ")

        }
        
    }
    
    @IBAction func SignUpClicked(_ sender: Any) {
        if userNameText.text != "" && passwordText.text != "" && EmailText.text != "" {
            Auth.auth().createUser(withEmail: EmailText.text!, password: passwordText.text!) { (auth, error) in
                if error != nil{
                    self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    let fireStore = Firestore.firestore()
                    
                    let userDictionary = ["email" : self.EmailText.text!, "username" : self.userNameText.text!] as! [String : Any]
                    
                    fireStore.collection("UserInfo").addDocument(data: userDictionary) {
                        (error) in
                        if error != nil {
                            
                        } else {
                            
                        }
                    }
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
            
        } else {
            self.MakeAlert(title: "Error", message: "Username/Email/Password ? ")
        }
        
        
    }
    
    
    func MakeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
}

