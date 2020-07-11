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
    
    //辞書型[String:CGColor]の配列
    static let color  = [
        ["startColor":UIColor(red:255/255,green:255/255,blue:153/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:173/255,green:255/255,blue:255/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:255/255,green:0/255,blue:0/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:0/255,green:255/255,blue:0/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:238/255,green:228/255,blue:113/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:111/255,green:228/255,blue:211/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:211/255,blue:253/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:235/255,green:222/255,blue:232/255,alpha:1.0).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:228/255,blue:233/255,alpha:0.3).cgColor,
         "endColor":UIColor(red:235/255,green:228/255,blue:233/255,alpha:0.3).cgColor,
        ],
        ["startColor":UIColor(red:255/255,green:111/255,blue:111/255,alpha:0.3).cgColor,
         "endColor":UIColor(red:235/255,green:228/255,blue:233/255,alpha:0.3).cgColor,
        ],
        ["startColor":UIColor(red:35/255,green:228/255,blue:133/255,alpha:0.3).cgColor,
         "endColor":UIColor(red:115/255,green:228/255,blue:213/255,alpha:0.3).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:228/255,blue:233/255,alpha:0.3).cgColor,
         "endColor":UIColor(red:175/255,green:168/255,blue:233/255,alpha:0.3).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:228/255,blue:233/255,alpha:0.3).cgColor,
         "endColor":UIColor(red:55/255,green:199/255,blue:133/255,alpha:0.3).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:100/255,blue:233/255,alpha:0.3).cgColor,
         "endColor":UIColor(red:238/255,green:208/255,blue:233/255,alpha:0.3).cgColor,
        ],
        ["startColor":UIColor(red:235/255,green:211/255,blue:123/255,alpha:0.3).cgColor,
         "endColor":UIColor(red:235/255,green:228/255,blue:21/255,alpha:0.3).cgColor,
        ],
        ["startColor":UIColor(red:255/255,green:255/255,blue:153/255,alpha:1.0).cgColor,
         "endColor":UIColor(red:173/255,green:255/255,blue:255/255,alpha:1.0).cgColor,
        ]
    ]

    
}
