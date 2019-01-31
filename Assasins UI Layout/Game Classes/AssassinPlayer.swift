//
//  AssassinPlayer.swift
//  Assasins UI Layout
//
//  Created by labuser on 11/18/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import Foundation
import CoreLocation

//this object describes a player involved in an assassin game
//contains a user member variable
//kill/death methods will affect this class
class AssassinPlayer {
    
    var target:AssassinPlayer!
    var isActive:Bool
    var username:String
    var uniqueID:String
    var name:String
    
    var deathLocation:CLLocation?
    
    var curKills:Int
    
    init(id: String, isActive: Bool, curKills: Int, username:String, name:String) {
        self.uniqueID = id
        self.isActive = isActive
        self.curKills = curKills
        self.username = username
        self.name = name
    }
    
    func setTarget(tar: AssassinPlayer) {
        target = tar
    }
    
    func failedAssassination(errorMsg: String) {
        //print("\(user.name): \(errorMsg)")
    }
    
    func successfulAssasination() {
        //print("\(user.name) killed \(target.user.name)!")
        curKills += 1
    }
    
    func die() {
        isActive = false
        //user.addDeath()
        //user.addKills(x: curKills)
        //deathLocation = someGetCurrentLocationMethod from ViewController
    }
}
