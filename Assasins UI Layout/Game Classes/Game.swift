//
//  Game.swift
//  Assasins UI Layout
//
//  Created by labuser on 11/18/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import Foundation
import Firebase

//holds all the players
//controls most of the logic
//multiple players are in the same game
//deals with network

class Game {
    
    struct Status {
        static let Inactive = "Inactive"
        static let Active = "Active"
        static let Completed = "Completed"
    }
    
    let ref = Database.database().reference()
    let gameRef:DatabaseReference!
    
    var uniqueID:String
    var name:String
    var maxCapacity:Int
    var players:[AssassinPlayer]!
    var alivePlayers:[AssassinPlayer]?
    var numPlayers:Int = 0
    var type:String
    var status:String!
    
    var userID = UserClass.CurrentUserID
    
    var killedPlayers:[AssassinPlayer]!
    
    init(uniqueID:String, name:String, capacity:Int, type:String, status:String) {
        self.uniqueID = uniqueID
        self.name = name
        self.maxCapacity = capacity
        self.type = type
        self.status = status
        self.gameRef = ref.child("games").child(self.uniqueID)
    }
    
    init(gameSnapshot:DataSnapshot) {
        self.uniqueID = gameSnapshot.key
        self.gameRef = ref.child("games").child(self.uniqueID)
        self.maxCapacity = gameSnapshot.childSnapshot(forPath: "capacity").value as! Int
        self.name = gameSnapshot.childSnapshot(forPath: "name").value as! String
        self.type = gameSnapshot.childSnapshot(forPath: "type").value as! String
        
        self.numPlayers = Int(gameSnapshot.childSnapshot(forPath: "players").childrenCount) as! Int
        self.status = gameSnapshot.childSnapshot(forPath: "status").value as! String
        
        gameRef.updateChildValues(["numPlayers": self.numPlayers])
        
    }
    
    func setNumPlayers(x:Int) {
        self.numPlayers = x
    }
    
    func setPlayers(x:[AssassinPlayer]) {
        players = x
    }
    
    
    func startGame() {
        
        var players:[AssassinPlayer] = []
        
        gameRef.child("players").observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for playerShot in snapshots {
                    let id = playerShot.key
                    let username = playerShot.childSnapshot(forPath: "username").value as! String
                    let name = playerShot.childSnapshot(forPath: "name").value as! String
                    
                    players.append(AssassinPlayer(id: id, isActive: true, curKills: 0, username: username, name: name))
                }
                
                print("this many children of snapshots \(snapshots.count)")
                
                self.players = players
                
                let targets = self.setTargets()
                print("targets: ", targets)
                
                
                for id in targets.keys {
                    let tar = targets[id]!
                    print("iterating through players again")
                    self.gameRef.child("players").child(id).child("target").updateChildValues(["/username": tar.username])
                    
                    let userGamesRef = self.ref.child("users").child(id).child("Games")
                    let userGameData = ["gameName": self.name, "targetKey": tar.uniqueID, "targetUsername": tar.username, "targetName": tar.username, "status": Status.Active] as [String : Any]
                    userGamesRef.child(self.uniqueID).updateChildValues(userGameData)
                }
            }
            
            //Change game status from inactive to active
            self.gameRef.updateChildValues(["status": Status.Active])
        })
    }
    
    
    func setTargets() -> [String : AssassinPlayer] {
        
        var targets:[String : AssassinPlayer] = [:]
        
        
        //temporarily sets the target of each player to be the player beind them
        print("this many players: \(players.count)")
        players[0].setTarget(tar: players[players.count-1])
        for i in 1..<players.count {
            print(i)
            players[i].setTarget(tar: players[i-1])
        }
        
        for i in 0..<players.count {
            targets[players[i].uniqueID] = players[i].target
        }
        
        return targets
        
        
    }
    
    //TODO depnds on what our method of killing is
    //could use location services, image recog
    func checkIfValidKill(target: AssassinPlayer, killer:AssassinPlayer) -> Bool {
        return true
    }
    
    func killPlayer (target: AssassinPlayer, killer:AssassinPlayer) {
        
        addKill()
        
        //Update Targets in User Tree
        let targetRef = ref.child("users").child(target.uniqueID).child("Games").child(uniqueID)
        let killerRef = ref.child("users").child(killer.uniqueID).child("Games").child(uniqueID)
        
        let targetGameRef = ref.child("games").child(uniqueID).child("players").child(target.uniqueID).child("target")
        let killerGameRef = ref.child("games").child(uniqueID).child("players").child(killer.uniqueID).child("target")
        
        targetRef.observeSingleEvent(of: .value, with: { snapshot in
            print(target.uniqueID)
            let key = snapshot.childSnapshot(forPath: "targetKey").value as! String
            let name = snapshot.childSnapshot(forPath: "targetName").value as! String
            let username = snapshot.childSnapshot(forPath: "targetUsername").value as! String
            
            //Null out target's target
            targetRef.updateChildValues(["targetKey": "", "targetName": [], "targetUsername": []])
            targetGameRef.updateChildValues(["username": []])
            
            //If the target didn't have the user as a target, there are still other players in the game
            if key != UserClass.CurrentUserID {
                killerRef.updateChildValues(["targetKey": key, "targetName": name, "targetUsername": username])
                killerGameRef.updateChildValues(["username": username])
            } else {
                //else the current player is the last player and the game is over
                killerRef.updateChildValues(["targetKey": "", "targetName": [], "targetUsername": []])
                killerGameRef.updateChildValues(["username": []])
                self.endGame()
            }
            
        })
        
        //Add Kill to list
        let gameKillsRef = ref.child("games").child(uniqueID).child("kills")
        
        let killInfo = ["killer": killer.uniqueID, "killee": target.uniqueID, "killerUsername": killer.username, "killeeUsername": target.username, "timestamp": ServerValue.timestamp()] as [String : Any]
 
        gameKillsRef.childByAutoId().setValue(killInfo)
        
        //Actually kill the other player
        addDeathToPlayer(target: target)
        
    }
    
    func joinGame () {
        
        //Add game to user tree
        let userGamesRef = ref.child("users").child(userID!).child("Games").child(uniqueID)
        
        let gameData = ["gameName": name, "targetKey": "", "targetUsername": "", "targetName": "", "status": Status.Inactive] as [String : Any]
        userGamesRef.setValue(gameData)
        
        //Add user to game tree
        let gamePlayerRef = ref.child("games").child(uniqueID).child("players").child(userID!)
        
        var playerData = ["name": UserClass.CurrentName, "username": UserClass.CurrentUsername, "kills": 0, "isAlive": true] as [String : Any]
        
        
        gamePlayerRef.updateChildValues(playerData)
        
        //Increment numPlayers
        ref.child("games").child(uniqueID).observeSingleEvent(of: .value, with: { snapshot in
            
            let oldNumPlayers = snapshot.childSnapshot(forPath: "numPlayers").value as! Int
            
            self.ref.child("games").child(self.uniqueID).updateChildValues(["numPlayers": oldNumPlayers+1])
        })
    }
    
    func addKill () {
        ref.child("games").child(uniqueID).child("players").child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            
            let oldKills = snapshot.childSnapshot(forPath: "kills").value as! Int
            
            self.ref.child("games").child(self.uniqueID).child("players").child(self.userID!).updateChildValues(["kills": oldKills+1])
        })
        let userKillsRef = ref.child("users").child(userID!)
        userKillsRef.observeSingleEvent(of: .value, with: { snapshot in
            
            let oldKills = snapshot.childSnapshot(forPath: "kills").value as! Int
            userKillsRef.updateChildValues(["kills": oldKills+1])
        })
    }
    
    func addDeathToPlayer (target: AssassinPlayer) {
        //Update in game tree
        ref.child("games").child(uniqueID).child("players").child(target.uniqueID).updateChildValues(["isAlive": false])
        
        
        //Update in user tree
        let userDeathsRef = ref.child("users").child(target.uniqueID)
        userDeathsRef.observeSingleEvent(of: .value, with: { snapshot in
            
            let oldDeaths = snapshot.childSnapshot(forPath: "deaths").value as! Int
            userDeathsRef.updateChildValues(["deaths": oldDeaths+1])
        })
    }
    
    
    func endGame() {
        //Change game status from active to completed
        self.gameRef.updateChildValues(["status": Status.Completed])
        
        let userRef = ref.child("users")
        
        ref.child("games").child(uniqueID).child("players").observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for player in snapshots {
                    let playerID = player.key
                     userRef.child(playerID).child("Games").child(self.uniqueID).updateChildValues(["status": Game.Status.Completed])
                }
            }
        })
        
        //Add game to history node
        ref.child("history").child(uniqueID).setValue(["gameName": name, "winnerKey": UserClass.CurrentUserID, "winnerUsername": UserClass.CurrentUsername])
        
    }
}



