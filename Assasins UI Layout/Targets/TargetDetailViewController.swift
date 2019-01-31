//
//  TargetDetailViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/25/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase

class TargetDetailViewController: UIViewController {

    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var sessionText: UILabel!
    @IBOutlet weak var targetNameText: UILabel!
    
    var game: Game!
    var targetProPath: String!
    
    var userID = UserClass.CurrentUserID!
    
    var target: AssassinPlayer!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let url = targetProPath!
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
            self.targetImageView.image = image
        }
        
        
        sessionText.text = "Session Name: " + game.name
        targetNameText.text = "Target Name: " + target.name
        
        //let currUser = Auth.auth().currentUser!
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pressKillTarget(_ sender: Any) {
        killTarget()
    }
    
    func killTarget() {
        //Make user assassinplayer and get user id
        let userPlayer = AssassinPlayer(id: userID, isActive: true, curKills: 0, username: "anyUsername", name: "anyName")
        
        game.killPlayer(target: target, killer: userPlayer)
    }
    
    @IBAction func AssasinateAction(_ sender: Any) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            let destinationVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "cameraViewController") as! CameraViewController
            destinationVC.image = image
            destinationVC.target = self.target
            destinationVC.game = self.game
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
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
