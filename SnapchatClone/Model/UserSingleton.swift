//
//  UserSingleton.swift
//  SnapchatClone
//
//  Created by Yağız Ata Özkan on 3.04.2021.
//

import Foundation

class UserSingleton {
    
    static let sharedUserInfo = UserSingleton()
    
    var email = ""
    var username = ""
    
    private init(){
        
    }
}

