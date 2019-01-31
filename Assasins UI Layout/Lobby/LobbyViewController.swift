//
//  LobbyViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/21/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

var leadersArray : [(name: String, kills: Int)] = []
class LobbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var sessionSearchBar: UISearchBar!
    @IBOutlet weak var theTableView: UITableView!
    var sessions:[Game] = []
    var filteredSessions:[Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theTableView.dataSource = self
        theTableView.delegate = self
        sessionSearchBar.delegate = self
        
        
        updateData()
        filteredSessions = sessions
        
        theTableView.reloadData()
        // Do any additional setup after loading the view.
        
        theTableView.backgroundView = UIImageView(image: UIImage(named: "012f5be17ebef29480b35e23fb5c1bdb"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "lobbyCell",
            for: indexPath) as! LobbyTableViewCell
        cell.sessionNameText.text = filteredSessions[indexPath.row].name
        cell.numPlayersText.text = String(filteredSessions[indexPath.row].numPlayers)
        cell.capacityText.text = String(filteredSessions[indexPath.row].maxCapacity)
        cell.sessionTypeText.text = filteredSessions[indexPath.row].type
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "gameViewController") as! GameViewController
        destinationVC.game = filteredSessions[indexPath.row]
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return sessionSearchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBarIsEmpty() {
            filteredSessions = sessions
        }
        else {
            filteredSessions = sessions.filter({( session : Game) -> Bool in
                return session.name.lowercased().contains(searchBar.text!.lowercased())
            })
        }
        theTableView.reloadData()
    }
    
    @IBAction func unwindToLobby(segue:UIStoryboardSegue) {
        
    }
    
    func updateData() {
        
        Database.database().reference().child("games").observe(.value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self.sessions.removeAll()
                for gameSnapshot in snapshots {
                    
                    let g = Game(gameSnapshot: gameSnapshot)
                    if g.status != Game.Status.Completed {
                        self.sessions.append(g)
                    }
                }
            }
            self.filteredSessions = self.sessions
            self.theTableView.reloadData()
        })
    }
}
