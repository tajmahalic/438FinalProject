//
//  UserProfileViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 12/1/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    
    var url : String!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var a: UILabel!
    @IBOutlet weak var d: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfile()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadImageUserFromFirebase(url: String) {
        let storage = Storage.storage()
        var reference: StorageReference!
        reference = storage.reference(withPath: url)
        reference.downloadURL { (url, error) in
            guard let imageURL = url, error == nil else {
                //handle error here if returned url is bad or there is error
                return
            }
            guard let data = NSData(contentsOf: imageURL) else {
                //same thing here, handle failed data download
                return
            }
            let image = UIImage(data: data as Data)
            self.profileImageView.image = image
        }
    }
    
    func setProfile() {
        print("set")
        if let currUser = Auth.auth().currentUser {
            let uid = currUser.uid
            Database.database().reference().child("users").child(uid).observe(.value, with: { snapshot in
                let fullName = snapshot.childSnapshot(forPath: "fullName").value as! String
                let kills = snapshot.childSnapshot(forPath: "kills").value as! Int
                let deaths = snapshot.childSnapshot(forPath: "deaths").value as! Int
                self.url = snapshot.childSnapshot(forPath: "profileImageURL").value as! String
                self.downloadImageUserFromFirebase(url: self.url)
                self.nameLabel.text = fullName
                self.a.text = String("Assassinations: \(kills)")
                self.d.text = String("Deaths: \(deaths)")
                
            })
        }
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
