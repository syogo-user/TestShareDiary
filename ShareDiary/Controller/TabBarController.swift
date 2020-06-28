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
        
        let gradientLayer = CAGradientLayer()
//        if let statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame {
//            gradientLayer.frame = statusBarFrame
//
//
//            let color = Const.color[0]
//            let color1 = color["startColor"] ?? UIColor().cgColor
//            let color2 = color["endColor"] ?? UIColor().cgColor
//            //３色にするか迷う
//            //CAGradientLayerにグラデーションさせるカラーをセット
//            gradientLayer.colors = [color1,color2]
//            gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
//            gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
//            navigationController?.navigationBar.layer.insertSublayer(gradientLayer, at:0)
//        }
        
        
        if let navBar = self.navigationController?.navigationBar {
            var bounds = navBar.bounds
            bounds.size.height += self.additionalSafeAreaInsets.top
            gradientLayer.frame = bounds
                

            let color = Const.color[0]
            let color1 = color["startColor"] ?? UIColor().cgColor
            let color2 = color["endColor"] ?? UIColor().cgColor
            //３色にするか迷う
            //CAGradientLayerにグラデーションさせるカラーをセット
            gradientLayer.colors = [color1,color2]
            gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
            gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
            if let image = getImageFromGradientLayer(gradientLayer: gradientLayer) {
                // navigationBarにグラデーションの画像を設定
                navBar.setBackgroundImage(image, for: .default)
            }
//            navigationController?.navigationBar.layer.insertSublayer(gradientLayer, at:0)
        }


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
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            loginViewController?.modalPresentationStyle = .fullScreen
            self.present(loginViewController!, animated: true, completion: nil)
        } else {
            guard let myUid = Auth.auth().currentUser?.uid else {return}
            let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
            postUserRef.getDocument() {
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
//                    if let document = querySnapshot!.data(){
//                        let myImageName = document["myImageName"] as? String ?? ""
//                        //画像の取得
//                        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(myImageName + ".jpg")
//                        //画像がなければデフォルトの画像表示
//                        if myImageName == "" {
//
//                        }else{
//
//
//                            //TODO fireStorage取得した画像を表示したい
//                            let leftBarButton:UIBarButtonItem = UIBarButtonItem(title: "button1", style: .done, target: self, action: #selector(self.addTapped))
//
//                            leftBarButton.image = UIImage(named: "Oval")
//                            let uiImage :UIImageView = UIImageView(image: leftBarButton.image)
//
//                            //取得した画像の表示
//                            uiImage.sd_setImage(with: imageRef)
//                            self.navigationItem.setLeftBarButtonItems([leftBarButton], animated: true)
//                            //self.navigationItem.titleView = uiImage
//
//
                    //                        }
                    //                    }
                    let leftBarButton:UIBarButtonItem = UIBarButtonItem(title: "button1", style: .done, target: self, action: #selector(self.addTapped))
                    leftBarButton.image = UIImage(named: "leftButton")
                    self.navigationItem.setLeftBarButtonItems([leftBarButton], animated: true)

                }
            }
            
 
            
//           let image = UIImage(named: "menu")!
////            let imageView = UIImageView(image:image)
////            imageView.contentMode = .scaleAspectFill
////            imageView.clipsToBounds = true
////            imageView.layer.cornerRadius = imageView.frame.height / 2.0
//
//            addLeftBarButtonWithImage(image)
            
        }
    }
    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            //タブ切り替え時は全て遷移する
            return true
    }
    @objc func myAction(){

    }

    @objc func addTapped(){
        //スライドを開く
        openLeft()
    }

}
