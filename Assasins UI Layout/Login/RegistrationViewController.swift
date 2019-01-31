//
//  RegistrationViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/20/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegistrationViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func actionCreateAccount(_ sender: Any) {
        var errorText = validateFields()
        if errorText != "" {
            errorText = String(errorText.dropLast())
            let alert = UIAlertController(title: "Creation Failed", message: errorText, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            {
                (UIAlertAction) -> Void in
                
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true)
            {
                () -> Void in
            }
            return
        }
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {(user,error) in
            if error != nil {
                print(error!)
                return
            }
            if(self.profileImageView.image == nil){
                print("You need to upload an image!")
                return
            }
            else{
                
                let currUser = Auth.auth().currentUser!
                
                let username = self.usernameTextField.text!
                
                
                self.uploadImage(self.profileImageView.image!, username, completion: {(hasFinished, url) in
                    if(hasFinished) {
                        let userData = ["username": username, "deaths": 0, "kills": 0, "gamesPlayed": 0, "profileImageURL": url] as [String : Any]
                        Database.database().reference().child("users").child(currUser.uid).setValue(userData)
                        
                    }
                    else{
                        return
                    }
                    
                })
                self.performSegue(withIdentifier: "toMoreInfo", sender: nil)
                
            }
        }
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("tapped")
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.profileImageView.image = image
        }
    }
    
    func uploadImage(_ image: UIImage, _ userID: String,
                     completion: @escaping (_ hasFinished: Bool, _ url: String) -> Void) {
        let data: Data = UIImageJPEGRepresentation(image, 1.0)!
        let unicId = CFUUIDCreateString(nil, CFUUIDCreate(nil))
        // ref should be like this
        let ref = Storage.storage().reference(withPath: "media/" + userID + "/" + String(unicId!))
        ref.putData(data, metadata: nil,
                    completion: { (meta , error) in
                        if error == nil {
                            // return url
                            completion(true, (meta?.path)!)
                        } else {
                            print(error!)
                            completion(false, "")
                        }
        })
    }
    
    func validateFields() -> String {
        var errorText = ""
        if (profileImageView.image == nil){
            errorText = "Image must be provided\n"
        }
        if (usernameTextField.text == ""){
            errorText += "Username must be provided\n"
        }
        if (emailTextField.text == ""){
            errorText += "Email must be provided\n"
        }
        else if (emailTextField.text!.range(of: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .regularExpression) == nil) {
            errorText += "Invalid Email \n"
        }
        if let passwordText = passwordTextField.text {
            let match = passwordText.range(of: "^.*(?=.{6,})(?=.*[A-Z])(?=.*[a-zA-Z])(?=.*\\d)|(?=.*[!#$%&? \"]).*$", options: .regularExpression)
            if(match == nil) {
                errorText += "Password must have at least 8 characters\n"
                errorText += "Password must be strong\n"
            }
            else if let retypePasswordText = retypeTextField.text{
                if(passwordText != retypePasswordText){
                    errorText += "Passwords must match\n"
                }
            }
            
        }
        return errorText
    }
    
    /*
     TODO:
     */
    func createUser() -> Bool {
        return true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

