//
//  UserPostData.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/05.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class UserPostData: NSObject {
    var id :String
    var uid:String?
    var userName:String?
    var myImageName :String?
    var profileMessage:String?
    var follow :[String]?
    var follower:[String]?
    var followRequest:[String]?
    var keyAccountFlg :Bool?
    

    init(document:QueryDocumentSnapshot){
        self.id = document.documentID
        let postDic = document.data()
        self.uid = postDic["uid"] as? String
        self.userName = postDic["userName"] as? String
        self.myImageName = postDic["myImageName"] as? String
        self.profileMessage = postDic["profileMessage"] as? String
        self.follow  = postDic["follow"] as? [String]
        self.follower  = postDic["follower"] as? [String]
        self.followRequest = postDic["followRequest"] as? [String]
        self.keyAccountFlg = postDic["keyAccountFlg"] as? Bool
    }
    
    init(document:DocumentSnapshot?){
        self.id = document?.documentID ?? ""
        let postDic = document?.data() ?? [:]
        self.uid = postDic["uid"] as? String
        self.userName = postDic["userName"] as? String
        self.myImageName = postDic["myImageName"] as? String
        self.profileMessage = postDic["profileMessage"] as? String
        self.follow  = postDic["follow"] as? [String]
        self.follower  = postDic["follower"] as? [String]
        self.followRequest = postDic["followRequest"] as? [String]
        self.keyAccountFlg = postDic["keyAccountFlg"] as? Bool
    }
    
}
