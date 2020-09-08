//
//  TabBarController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/24.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
protocol TabBarDelegate{
    func didSelectTab(tabBarController:TabBarController)
}

class TabBarController: UITabBarController, UITabBarControllerDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        // タブアイコンの色
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor =  .white
        self.tabBar.barTintColor = Const.darkColor
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
        //NavigationBarが半透明かどうか
        self.navigationController?.navigationBar.isTranslucent = false
        //ヘッダーの文字（バッテリーマークなども）白くなる
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = Const.darkColor
        self.navigationController?.navigationBar.tintColor = Const.navigationButtonColor
    }
    // CAGradienstLayerから画像を作成
    func  getImageFromGradientLayer(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        // gradientLayerと同サイズの描画環境CurrentContextに設定
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        // 作成した描画環境があるか
        if let context = UIGraphicsGetCurrentContext() {
            // レイヤーをcontextに描画する
            gradientLayer.render(in: context)
            // 描画されたcontextをimageに変換してresize
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        // 最初に設定したCurrentContextをスタックメモリー上から解放
        UIGraphicsEndImageContext()
        // UIImageをreturn
        return gradientImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            loginViewController?.modalPresentationStyle = .fullScreen
            self.present(loginViewController!, animated: true, completion: nil)
        } else {
            guard let myUid = Auth.auth().currentUser?.uid else {return}
            let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
            postUserRef.getDocument() {
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    let leftBarButton:UIBarButtonItem = UIBarButtonItem(title: "button1", style: .done, target: self, action: #selector(self.addTapped))
                    leftBarButton.image = UIImage(named: "leftButton")
                    self.navigationItem.setLeftBarButtonItems([leftBarButton], animated: true)
                }
            }
        }
    }
    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //タブ切り替え時は全て遷移する
        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is TabBarDelegate {
            let v = viewController as! TabBarDelegate
            v.didSelectTab(tabBarController: self)
        }
    }
    @objc func addTapped(){
        //スライドを開く
        openLeft()
    }

}
