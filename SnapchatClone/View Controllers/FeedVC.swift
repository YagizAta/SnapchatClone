//
//  FeedVC.swift
//  SnapchatClone
//
//  Created by Yağız Ata Özkan on 31.03.2021.
//

import UIKit
import Firebase
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate , UITableViewDataSource {
   
    

    @IBOutlet var tableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    var chosenSnap : Snap?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        
        getSnapsFromFirebase()
        getUserInfo()
        // Do any additional setup after loading the view.
    }
    
    func getUserInfo()
    {
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser?.email).getDocuments { (snapShot, error) in
            
            if error != nil {
                self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            } else {
                if snapShot?.isEmpty == false && snapShot != nil {
                    for document in snapShot!.documents {
                        if let username = document.get("username") as? String {
                            UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUserInfo.username=username
                        }
                    }
                }
            }
            
            
            
        }
    }

    func MakeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func getSnapsFromFirebase() {
        fireStoreDatabase.collection("Snaps").order(by: "date" , descending: true).addSnapshotListener { (snapShot, error) in
            if error != nil {
                self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            } else {
                if snapShot?.isEmpty == false && snapShot != nil {
                    self.snapArray.removeAll()
                    for document in snapShot!.documents {
                        
                        let documentID=document.documentID
                        if let username = document.get("snapOwner") as? String {
                            if let imageUrlArray = document.get("imageUrlArray")as? [String]{
                                if let date = document.get("date") as? Timestamp {
                                    
                                    if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour {
                                        if difference >= 24 {
                                            //Delete
                                            self.fireStoreDatabase.collection("Snaps").document(documentID).delete { (error) in
                                                
                                            }
                                        } else {
                                            let snap = Snap(username: username, imageUrlArray: imageUrlArray, data: date.dateValue(), timeDifference: 24-difference)
                                            self.snapArray.append(snap)
                                        }
                                        //self.timeLeft = 24-difference
                                       
                                    }
                                   
                                    
                                }
                            }
                        }
                        
                        
                        
                        
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
        cell.feedUsernameLabel.text = snapArray[indexPath.row].username
        cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC" {
            let destinationVC = segue.destination as! SnapViewController
            destinationVC.selectedSnap = chosenSnap
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenSnap = self.snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
}
