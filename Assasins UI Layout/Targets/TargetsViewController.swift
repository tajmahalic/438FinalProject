//
//  TargetsViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/22/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase

class TargetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TargetTableViewCellDelegate {
    
    var userID = UserClass.CurrentUserID
    struct targetStruct {
        let target: AssassinPlayer
        let game: Game
        let proPath: String
        let timeRemaining:String
    }
    
    @IBOutlet weak var theTableView: UITableView!
    var yourTargets:[targetStruct] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourTargets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "targetCell",
            for: indexPath) as! TargetTableViewCell
        
        if indexPath.row < yourTargets.count {
        
            let url = yourTargets[indexPath.row].proPath
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
                cell.targetImage.image = image
            }
        
        cell.sessionText.text = "Session: " + yourTargets[indexPath.row].game.name
        cell.targetNameText.text = "Target: " + yourTargets[indexPath.row].target.name
        // cell.timeRemainingText.text = "Time Left: " +  yourTargets[indexPath.row].timeRemaining
        cell.delegate = self
            
        }
        return cell
    }
    //https://medium.com/@aapierce0/swift-using-protocols-to-add-custom-behavior-to-a-uitableviewcell-2c1f09610aa1
    func didTapTrack(_ sender: TargetTableViewCell) {
        guard let tappedIndexPath = theTableView.indexPath(for: sender) else { return }
        print(yourTargets[tappedIndexPath.row].timeRemaining)
        let destinationVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "targetDetailViewController") as! TargetDetailViewController
        destinationVC.game = yourTargets[tappedIndexPath.row].game
        destinationVC.targetProPath = yourTargets[tappedIndexPath.row].proPath
        destinationVC.target = yourTargets[tappedIndexPath.row].target
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theTableView.dataSource = self
        theTableView.delegate = self
        theTableView.rowHeight = 65

        getTargets()
        
        theTableView.backgroundView = UIImageView(image: UIImage(named: "012f5be17ebef29480b35e23fb5c1bdb"))
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func connected(sender: UIButton){
        _ = sender.tag
        print("hello")
    }
    
    func getTargets () {
        print("getting targets")
        
        Database.database().reference().child("users").child(userID!).child("Games").observe(.value, with: { snapshot in
            self.yourTargets.removeAll()
            self.theTableView.reloadData()
            if snapshot.exists() {
                
                
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    print("numGames ", snapshots.count)
                    for game in snapshots {
                        let gameKey = game.key
                        let gameName = game.childSnapshot(forPath: "gameName").value as! String
                        if let targetKey = game.childSnapshot(forPath: "targetKey").value as? String, let targetName = game.childSnapshot(forPath: "targetName").value as? String, let targetUsername = game.childSnapshot(forPath: "targetUsername").value as? String{
                            if targetName != "" {
                            Database.database().reference().child("users").child(targetKey).observeSingleEvent(of: .value, with: { targetSnapshot in
                                let proPath = targetSnapshot.childSnapshot(forPath: "profileImageURL").value as! String
                                
                                print("Game: \(gameKey)  Target: \(targetKey)")
                                
                                let target = AssassinPlayer(id: targetKey, isActive: true, curKills: 0, username: targetUsername, name: targetName)
                                
                                self.theTableView.reloadData()
                                print("target: ", target.name)
                                Database.database().reference().child("games").child(gameKey).observeSingleEvent(of: .value, with: { gameSnapshot in
                                    print("found a game")
                                    let g = Game(gameSnapshot: gameSnapshot)
                                    
                                    self.yourTargets.append(targetStruct(target: target, game: g, proPath: proPath, timeRemaining: "1 hour"))
                                    self.theTableView.reloadData()
                                })
                            })
                            
                                
                                
                                
                            }
                            
                        }
                    }
                }
                
            }
            self.theTableView.reloadData()
        })
    }

}
