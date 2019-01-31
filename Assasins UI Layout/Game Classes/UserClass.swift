//
//  User.swift
//  Assasins UI Layout
//
//  Created by labuser on 11/18/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import Foundation
import Firebase

//Contains basic information about users
//name, email and so on
//this will be uploaded to database on registration and downloaded on login
//also contains lifelong stats (kills, deaths)

class UserClass {
    
    static var CurrentUserID:String!
    static var CurrentUsername:String!
    static var CurrentEmail:String!
    static var CurrentName:String!
    static var CurrentProPicPath:String!
    
    var name:String
    var email:String
    var username:String
    var pathToPic:String
    
    var totalKills:Int
    var totalDeaths:Int
    var totalGames:Int
    
    init(name:String, email:String, username:String, pathToPic:String) {
        
        self.name = name
        self.email = email
        self.username = username
        self.pathToPic = pathToPic
        
        totalKills = 0
        totalDeaths = 0
        totalGames = 0
    }
    
    func addDeath() {
        totalDeaths += 1
    }
    
    func addKills(x: Int) {
        totalKills += x
    }
    
    func increaseGames() {
        totalGames += 1
    }
}
