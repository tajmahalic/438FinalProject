//
//  LoginViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/20/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func actionLogin(_ sender: Any) {
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!){(user, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Login Failed", message: "Invalid Email or Password", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                {
                    (UIAlertAction) -> Void in
                    
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true)
                {
                    () -> Void in
                }
                print(error!)
                print("Not signed in")
            }else{
                UserClass.CurrentEmail = user?.user.email
                UserClass.CurrentUserID = user?.user.uid
                
                Database.database().reference().child("users").child(UserClass.CurrentUserID).observe(.value, with: { snapshot in
                    
                    UserClass.CurrentUsername = snapshot.childSnapshot(forPath: "username").value as! String
                    UserClass.CurrentName = snapshot.childSnapshot(forPath: "fullName").value as! String
                    UserClass.CurrentProPicPath = snapshot.childSnapshot(forPath: "profileImageURL").value as! String
                })
                
                
                print("signed in.")
                let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
                appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
               
            }
        }
    }
    
    /*
     TODO: Check user credientials with Firebase
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
