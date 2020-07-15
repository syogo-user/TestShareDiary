//
//  LeftViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/06.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class LeftViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.cornerRadius  = 25        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ユーザ情報表示
        userDataShow()
    }
    //画像の表示
    private func userDataShow(){
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
        postUserRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                guard let document = querySnapshot!.data() else {return}
                let myImageName = document["myImageName"] as? String ?? ""
                let myFollow = document["follow"] as? [String] ?? []
                let myFollower = document["follower"] as? [String] ?? []
                //画像の取得
                let imageRef = Storage.storage().reference().child(Const.ImagePath).child(myImageName + ".jpg")
                //名前の表示
                self.userName.text = document["userName"] as? String ?? ""
                //フォロー・フォロワー数の表示
                self.followLabel.text = "フォロー： \(myFollow.count)"
                self.followerLabel.text = "フォロワー：\(myFollower.count)"
                //画像がなければデフォルトの画像表示
                if myImageName == "" {
                    self.imageView.image = UIImage(named: "unknown")
                }else{
                    //取得した画像の表示
                    self.imageView.sd_imageIndicator =
                        SDWebImageActivityIndicator.gray
                    self.imageView.sd_setImage(with: imageRef)
                }
            }
        }
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
