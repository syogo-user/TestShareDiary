//
//  postData.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String = ""
    var uid :String
    var documentUserName: String?
    var content: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var backgroundColor :String?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let postDic = document.data()
        
        self.uid = ""
        if let postUid = postDic["uid"] {
            self.uid = postUid as! String
        }
        
        self.documentUserName = postDic["documentUserName"] as? String
        self.backgroundColor = postDic["backgroundColor"] as? String
        
        self.content = postDic["content"] as? String

        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }

    }
}
