//
//  File.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/05.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import Firebase
class CommentData :NSObject{
    var uid :String = ""
    var message :String = ""
    var createdAt :Timestamp
    var userName = ""
    
    init(document: [String: Any]){
        self.uid = document["uid"] as?  String ?? ""
        self.message = document["message"] as? String ?? ""
        self.createdAt = document["createdAt"] as? Timestamp ?? Timestamp()                
    }
    
    
}
