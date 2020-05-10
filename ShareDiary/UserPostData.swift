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
    var uid:String?
    var userName:String?
    
    
    init(document:QueryDocumentSnapshot){
        let postDic = document.data()
        self.uid = postDic["uid"] as? String
        self.userName = postDic["userName"] as? String
    }
    
    init(document:[String:Any]){
        self.uid = document["uid"] as? String
        self.userName = document["userName"] as? String
    }

}
