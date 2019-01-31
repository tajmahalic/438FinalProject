//
//  GameViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/22/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currUser:UserClass!
    var game:Game!
    @IBOutlet weak var sessionNameText: UILabel!
    @IBOutlet weak var theTableView: UITableView!
    
    @IBOutlet weak var topAssassinText: UILabel!
    
    let ref = Database.database().reference()
    

    var players:[AssassinPlayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theTableView.dataSource = self
        theTableView.delegate = self
        
        //sessionStatusText.text = game.type
        sessionNameText.text = game.name
        
        
        currUser = UserClass(name: UserClass.CurrentName, email: UserClass.CurrentEmail, username: UserClass.CurrentUsername, pathToPic: "blah")
        
        getPlayersInGame()
        setUpBackButton()
        getTopPlayer()
        
        theTableView.backgroundView = UIImageView(image: UIImage(named: "012f5be17ebef29480b35e23fb5c1bdb"))
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "gamePlayerCell",
            for: indexPath) as! GamePlayerTableViewCell
        cell.nameText.text = players[indexPath.row].username
        
        if players[indexPath.row].isActive {
            cell.statusText.text = "Alive"
        } else {
            cell.statusText.text = "Assassinated"
        }
        
        
        return cell
    }
    func setUpBackButton() {
        self.navigationItem.hidesBackButton = true
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(#imageLiteral(resourceName: "Back"), for: .normal) // Image can be downloaded from here below link
        backbutton.setTitle("Lobby", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal) // You can change the TitleColor
        let spacing = CGFloat(-12)
        backbutton.imageEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0)
        //        backbutton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0)
        backbutton.addTarget(self, action: #selector(GameViewController.back(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
    }
    
    @objc func back(sender: UIButton) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        performSegue(withIdentifier: "unwindSegueToLobby", sender: self)
        //        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTopPlayer() {
        ref.child("games").child(game.uniqueID).child("players").observe(.value, with: { snapshot in
            var topPlayerName = ""
            var topKills = -1
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                for child in snapshots {
                    //print("Child: ", child)
                    let n = child.childSnapshot(forPath: "name").value as! String
                    let a = child.childSnapshot(forPath: "kills").value as! Int
                    
                    if a > topKills {
                        topKills = a
                        topPlayerName = n
                    }
                    
                    //print("Name: \(n)  Kills: \(a)")
                }
            }
            
            self.topAssassinText.text = "Top Assassin: \(topPlayerName)"
            
        })
        
        //print("finisehed")
        
    }
    
    func getPlayersInGame() {
        print("getting players")
        let gameRef = ref.child("games").child(game.uniqueID)
        
        Database.database().reference().child("games").child(game.uniqueID).child("players").observe( .value, with: { snapshot in
            var newPlayers:[AssassinPlayer] = []
            var alivePlayers:[AssassinPlayer] = []
            print("got here")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                print("now here")
                print(snapshots.count)
                for player in snapshots {
                    let playerKey = player.key
                    let username = player.childSnapshot(forPath: "username").value as! String
                    let name = player.childSnapshot(forPath: "name").value as! String
                    let kills = player.childSnapshot(forPath: "kills").value as! Int
                    let isAlive = player.childSnapshot(forPath: "isAlive").value as! Bool
                    
                    
                    print("Player: \(username)  Kills: \(kills)")
                    let p = AssassinPlayer(id: playerKey, isActive: isAlive, curKills: kills, username: username, name: name)
                    newPlayers.append(p)
                    if isAlive {
                        alivePlayers.append(p)
                    }
                    
                }
            }
            self.players = newPlayers
            self.game.setPlayers(x: newPlayers)
            self.game.alivePlayers = alivePlayers
            if alivePlayers.count == 1 && self.game.status == Game.Status.Active{
                //self.game.endGame()
            }
            self.theTableView.reloadData()
            print(self.players)
            
        })
    }
    
    
    @IBAction func pressStartGame(_ sender: Any) {
        
        if self.players.count <= 1 {
            let alert = UIAlertController(title: "Wait...", message: "You need at least two players!", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.default)
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
        ref.child("games").child(game.uniqueID).observe(.value, with: { snapshot in
            let adminID = snapshot.childSnapshot(forPath: "adminID").value as! String
            if(UserClass.CurrentUserID != adminID){
                let alert = UIAlertController(title: "Wait...", message: "You are not the game creator - you cannot start the game!", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.default)
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
        })
        
        game.startGame()
    }
    

    @IBAction func pressJoinGame(_ sender: Any) {
        if (game.numPlayers < game.maxCapacity) {
            game.joinGame()
        } else {
            let alert = UIAlertController(title: "Max Capacity!", message: "There are already \(game.maxCapacity) players!", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.default)
            {
                (UIAlertAction) -> Void in
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true)
            {
                () -> Void in
            }
        }
    }    
    
    func checkIfInGame() {
        let userGamesRef = ref.child("users").child("KChen").child("Games")
        userGamesRef.observeSingleEvent(of: .value, with:  { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for game in snapshots {
                    if game.key == self.game.uniqueID {
                        //self.isInGame = true
                    }
                }
            }
            //self.isInGame = false
        })
    }

}
