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
  
    }
    
    //フォロワーボタンが押された時
    @IBAction func followerButtonAction(_ sender: Any) {
        print("フォロワーボタンタップ")
    }
    //フォロリクエストボタンが押された時
    @IBAction func followRequestAction(_ sender: Any) {
        print("フォローリクエストボタンタップ")
                
        let followListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowList") as! FollowListTableViewController
        self.present(followListTableViewController, animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
