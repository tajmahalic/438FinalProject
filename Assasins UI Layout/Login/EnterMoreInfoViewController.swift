//
//  EnterMoreInfoViewController.swift
//  Assassins Firebase
//
//  Created by Matthew Padgett on 12/1/18.
//  Copyright © 2018 Matthew Padgett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EnterMoreInfoViewController: UIViewController {
    

    @IBOutlet weak var last: UITextField!
    @IBOutlet weak var first: UITextField!
    
  
    @IBAction func actionEnterPressed(_ sender: Any) {
        if(first.text == nil || last.text == nil){
            print("You need to fill out both fields")
            return
        }else{
            let data = Database.database().reference()
            Auth.auth().addStateDidChangeListener{auth, user in
                if let user = user{
                    let id = user.uid
                    UserClass.CurrentUserID = id
                    UserClass.CurrentEmail = user.email
                    
                    let nameString = "\(self.first.text!) \(self.last.text!)"
                    
                    UserClass.CurrentName = nameString
                    
                    Database.database().reference().child("users").child(UserClass.CurrentUserID).observe(.value, with: { snapshot in
                        
                        UserClass.CurrentUsername = snapshot.childSnapshot(forPath: "username").value as! String
                        UserClass.CurrentProPicPath = snapshot.childSnapshot(forPath: "profileImageURL").value as! String
                    })
                    
                    data.child("users").child(id).child("fullName").setValue(nameString)
                    self.performSegue(withIdentifier: "toHomeSegue", sender: nil)
                }else{
                    print("No Current User")
                }
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
