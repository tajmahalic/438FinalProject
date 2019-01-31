//
//  HistoryViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 11/26/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
import Firebase

class leaderTableViewCell: UITableViewCell{

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var kills: UILabel!
    
}
class LeaderBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var theTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leadersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier : String = "leaderCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? leaderTableViewCell else{
            fatalError("Dequeued cell isnt a leaderTableViewCell!")
        }
        let info = leadersArray[indexPath.row]
        cell.name.text = info.name
        cell.kills.text = String(info.kills)
        
        return cell
    }
    
    func arrayPopulate(){
        Database.database().reference().child("users").observe(.value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for child in snapshots{
                    let n = child.childSnapshot(forPath: "fullName").value as! String
                    let k = child.childSnapshot(forPath: "kills").value as! Int
                    
                    if let index = leadersArray.index(where: {$0.name == n}){
                        leadersArray[index].kills = k
                    }else{
                        leadersArray.append((name: n, kills: k))
                    }
                }
            }
            self.sortTuple()
            self.printArray()
            self.theTableView.reloadData()
        })
    }
    
    func sortTuple(){
        leadersArray = leadersArray.sorted(by: {$0.1 > $1.1})
    }
    
    func printArray(){
        for element in leadersArray{
            print("\(element.name) \(element.kills)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        theTableView.dataSource = self
        theTableView.delegate = self
        arrayPopulate()
        // Do any additional setup after loading the view.
        
        theTableView.backgroundView = UIImageView(image: UIImage(named: "012f5be17ebef29480b35e23fb5c1bdb"))
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
