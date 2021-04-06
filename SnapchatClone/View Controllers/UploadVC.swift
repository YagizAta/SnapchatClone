//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Yağız Ata Özkan on 31.03.2021.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var UploadImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        UploadImageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
        UploadImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    @objc func choosePicture(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        UploadImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func UploadClicked(_ sender: Any) {
        
        //Storage
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = UploadImageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.MakeAlert(title: "Error", message:error?.localizedDescription ?? "Error" )
                } else {
                    imageReference.downloadURL { (url, error) in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            //Firestore
                            let fireStore = Firestore.firestore()
                            
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { (snapShot, error) in
                                if error != nil {
                                    self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Errror")
                                } else {
                                    if snapShot?.isEmpty == false && snapShot != nil {
                                        for document in snapShot!.documents {
                                            let documentId=document.documentID
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                                imageUrlArray.append(imageUrl!)
                                                
                                                let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                                fireStore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { (error) in
                                                    if error == nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.UploadImageView.image = UIImage()
                                                    }
                                                }
                                                
                                            }
                                            
                                            
                                            
                                        }
                                    } else {
                                        let snapDictionary = ["imageUrlArray": [imageUrl!], "snapOwner" : UserSingleton.sharedUserInfo.username, "date": FieldValue.serverTimestamp()] as [String : Any]
                                        
                                        fireStore.collection("Snaps").addDocument(data: snapDictionary) { (error) in
                                            if error != nil {
                                                self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            } else {
                                                self.tabBarController?.selectedIndex = 0
                                                self.UploadImageView.image = UIImage()
                                            }
                                    }
                                }
                            }
                            
                           
                            }
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
    
    
    
}
