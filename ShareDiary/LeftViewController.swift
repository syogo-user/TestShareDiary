//
//  LeftViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/06.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //フォローボタンが押された時
    @IBAction func followButtonAction(_ sender: Any) {
        print("フォローボタンタップ")
      let followFollowerListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowerList") as! FollowFollowerListTableViewController
        followFollowerListTableViewController.fromButton = Const.Follow
      self.present(followFollowerListTableViewController, animated: true, completion: nil)
    }
    
    //フォロワーボタンが押された時
    @IBAction func followerButtonAction(_ sender: Any) {
        print("フォロワーボタンタップ")
        let followFollowerListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowerList") as! FollowFollowerListTableViewController
           followFollowerListTableViewController.fromButton = Const.Follower
         self.present(followFollowerListTableViewController, animated: true, completion: nil)
        
    }
    //フォロリクエストボタンが押された時
    @IBAction func followRequestAction(_ sender: Any) {
        print("フォローリクエストボタンタップ")
                
        let followRequestListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowRequestList") as! FollowRequestListTableViewController
        
        self.present(followRequestListTableViewController, animated: true, completion: nil)
    }
    
    


}
