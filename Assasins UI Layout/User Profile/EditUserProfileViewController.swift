//
//  EditUserProfileViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 12/1/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit

class EditUserProfileViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionEdit(_ sender: Any) {
        performSegue(withIdentifier: "unwindToUserProfile", sender: self)
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("tapped")
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.profileImageView.image = image
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
