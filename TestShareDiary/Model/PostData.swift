//
//  postData.swift
// ShareDiary
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
    var backgroundColorIndex :Int = 0
    var selectDate :String?
    var contentImageMaxNumber : Int = 0
    var isCommented:Bool = false //自分のコメントがあるかどうか
    var comments:[String] = []//コメントした人
    var commentsId:[String] = []
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        let postDic = document.data()
        self.uid = ""
        if let postUid = postDic["uid"] {
            self.uid = postUid as! String
        }
        self.documentUserName = postDic["documentUserName"] as? String
        self.backgroundColorIndex = postDic["backgroundColorIndex"] as? Int ?? 0
        self.content = postDic["content"] as? String
        //更新日付
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        //いいね配列
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        //コメントuid配列
        if let comments = postDic["comments"] as? [String] {
            self.comments = comments
        }
        //コメントID配列
        if let commentsId = postDic["commentsId"] as? [String] {
            self.commentsId = commentsId
        }
        
        
        //投稿写真の枚数
        self.contentImageMaxNumber = postDic["contentImageMaxNumber"] as? Int ?? 0
        //日記日付
        self.selectDate =  postDic["selectDate"] as? String
        
        if let myid = Auth.auth().currentUser?.uid {
            //いいね
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }                        
            //コメント
            // commentsの配列の中にmyidが含まれているかチェックすることで、自分がコメントしているかを判断
            if self.comments.firstIndex(of: myid) != nil {
                // myidがあれば、コメントをしていると認識する。
                self.isCommented = true
            }
        }
        
        

    }

}
