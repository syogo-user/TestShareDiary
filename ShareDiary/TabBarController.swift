//
//  TabBarController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/24.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
//        //ナビゲーションバーを作る
//        let navBar = UINavigationBar()
//        //xとyで位置を、widthとheightで幅と高さを指定する
//        navBar.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
//
//        //ナビゲーションアイテムのタイトルを設定
//        let navItem : UINavigationItem = UINavigationItem(title: "タイトル")
//
//        //ナビゲーションバー右のボタンを設定
//        navItem.rightBarButtonItem = UIBarButtonItem(title: "遷移", style: UIBarButtonItem.Style.plain, target: self, action:#selector(self.myAction))
//
//        //ナビゲーションバーにアイテムを追加
//        navBar.pushItem(navItem, animated: true)
//
//        //Viewにナビゲーションバーを追加
//        self.view.addSubview(navBar)
        
        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        // タブバーの背景色
        self.tabBar.barTintColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            //タブ切り替え時は全て遷移する
            return true
    }
    @objc func myAction(){

    }

    

}
