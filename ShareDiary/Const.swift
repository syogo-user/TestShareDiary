//
//  Const.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import UIKit
struct Const {
    static let ImagePath = "images"
    static let PostPath = "posts"
    static let users = "users"//ユーザ
    static let Follow = "follow" //フォロー
    static let Follower = "follower"//フォロワー
    static let FollowRequest = "followRequest"//フォローリクエスト
    
    static let FollowShowButton = "followShowButton"
    static let FollowerShowButton = "followerShowButton"
    
    static let darkColor = UIColor(red:30/255,green:40/255,blue:54/255,alpha:1.0)
    static let lightOrangeColor = UIColor(red:255/255,green:245/255,blue:229/255,alpha:1.0)
    //辞書型[String:CGColor]の配列
    static let color  = [
        ["startColor":UIColor(red:255/255,green:255/255,blue:153/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:173/255,green:255/255,blue:255/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:252/255,green:229/255,blue:207/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:255/255,green:172/255,blue:214/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:255/255,green:172/255,blue:214/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:100/255,green:216/255,blue:255/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:211/255,blue:253/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:10/255,green:222/255,blue:232/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:249/255,green:212/255,blue:35/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:248/255,green:54/255,blue:0/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:150/255,green:230/255,blue:161/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:10/255,green:222/255,blue:232/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:249/255,green:240/255,blue:71/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:15/255,green:216/255,blue:120/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:250/255,green:112/255,blue:154/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:255/255,green:207/255,blue:255/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:250/255,green:112/255,blue:154/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:254/255,green:225/255,blue:64/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:100/255,blue:233/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:238/255,green:208/255,blue:233/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:253/255,green:180/255,blue:163/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:235/255,green:228/255,blue:21/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:224/255,green:195/255,blue:252/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:142/255,green:197/255,blue:252/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:42/255,green:245/255,blue:152/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:142/255,green:197/255,blue:252/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:224/255,green:195/255,blue:252/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:0/255,green:158/255,blue:253/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:179/255,green:255/255,blue:171/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:209/255,green:253/255,blue:255/255,alpha:1.0).cgColor,
        ]



    ]
    
    
}
