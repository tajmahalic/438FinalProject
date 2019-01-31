//
//  CreateGameViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 12/1/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase

class CreateGameViewController: UIViewController {

    var currUser:UserClass!
    var userID:String?
    
    @IBOutlet weak var gameNameText: UITextField!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var maxPlayerText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionCreateGame(_ sender: Any) {
        
        print("started Creating Game")
        let ref = Database.database().reference()
        
        let newGameRef = ref.child("games").childByAutoId()
        
        let newGameKey = newGameRef.key!
        
        var publicStr:String
        if (publicSwitch.isOn) {
            publicStr = "Public"
        } else {
            publicStr = "Private"
        }
        
        let g = Game(uniqueID: newGameKey, name: gameNameText.text!, capacity: Int(maxPlayerText.text!)!, type: publicStr, status: Game.Status.Inactive)
        
        //Add user to game tree
        let playerData = ["name": UserClass.CurrentName, "username": UserClass.CurrentUsername, "kills": 0, "isAlive": true] as [String : Any]
        
        let playerNode = [UserClass.CurrentUserID: playerData] as [String : Any]
        
        let gameData = ["capacity": g.maxCapacity, "name": g.name, "type": g.type, "numPlayers": 1, "players": playerNode, "status": Game.Status.Inactive, "adminID": UserClass.CurrentUserID] as [String : Any]
        print("about to set game data")
        newGameRef.setValue(gameData)
        print("set game data")
        //Add game to user tree
        let userGamesRef = ref.child("users").child(UserClass.CurrentUserID).child("Games")
        let userGameData = ["gameName": g.name, "targetKey": "", "targetUsername": "", "targetName": "", "status": Game.Status.Inactive] as [String : Any]
        userGamesRef.child(g.uniqueID).setValue(userGameData)
        print("set user data")
        
        //Switch View
        let destinationVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "gameViewController") as! GameViewController
        destinationVC.game = g
        navigationController?.pushViewController(destinationVC, animated: true)
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
