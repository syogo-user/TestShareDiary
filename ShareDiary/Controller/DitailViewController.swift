//
//  DitailViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
class DitailViewController: UIViewController {
    @IBOutlet weak var viewLayer: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var diaryDate: UILabel!
    @IBOutlet weak var diaryText: UITextView!
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var postDeleteButton: UIButton!
    
    var postData :PostData?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //戻るボタンの戻るの文字を削除
        navigationController!.navigationBar.topItem!.title = ""
        self.imageView.layer.cornerRadius = 30

        guard let post = postData else {return}
        //画面項目を設定
        contentSet(post:post)

        //自分のuidではなかった時は削除ボタンを非表示
        if post.uid != Auth.auth().currentUser?.uid {
            self.postDeleteButton.isHidden = true//非表示
            self.postDeleteButton.isEnabled = false//非活性
        }else {
            self.postDeleteButton.isHidden = false//表示
            self.postDeleteButton.isEnabled = true//活性
        }
        //削除ボタン押下時
        postDeleteButton.addTarget(self, action: #selector(postDelete(_:)), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    //画面項目の設定
    private func contentSet(post:PostData){
        
        //ユーザ名
        self.userName.text = post.documentUserName ?? ""
        // いいねボタンの表示
        if post.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        // いいね数の表示
        let likeNumber = post.likes.count
        self.likeCount.text = likeNumber.description //文字列変換
        
        // 日時の表示
        self.diaryDate.text = ""
        if let date = post.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.diaryDate.text = dateString
        }
        // コンテントの表示
        self.diaryText.text = ""
        if let content = post.content{
            self.diaryText.text! = content
        }
        // 投稿画像表示
         contentImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
         let imageRef2 = Storage.storage().reference().child(Const.ImagePath).child(post.id + ".jpg")
         contentImageView.sd_setImage(with: imageRef2)
        //プロフィール写真を設定
        setPostImage(uid:post.uid)
        //背景色を設定
        setBackgroundColor(colorIndex:post.backgroundColorIndex ?? 0)
        
    }
    private func setPostImage(uid:String){
        let userRef = Firestore.firestore().collection(Const.users).document(uid)
        
        userRef.getDocument() {
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                if let document = querySnapshot!.data(){
                    let imageName = document["myImageName"] as? String ?? ""
                    
                    //画像の取得
                    let imageRef = Storage.storage().reference().child(Const.ImagePath).child(imageName + ".jpg")
                    
                    //画像がなければデフォルトの画像表示
                    if imageName == "" {
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
    }
    //背景色設定
    private func setBackgroundColor(colorIndex:Int){
        //背景色を変更する
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.viewLayer.layer.bounds
        let color = Const.color[colorIndex]
        let color1 = color["startColor"] ?? UIColor.white.cgColor
        let color2 = color["endColor"] ?? UIColor.white.cgColor
        //CAGradientLayerにグラデーションさせるカラーをセット
        gradientLayer.colors = [color1,color2]
        gradientLayer.startPoint = CGPoint.init(x:0.1,y:0.1)
        gradientLayer.endPoint = CGPoint.init(x:0.9,y:0.9)
        
        if self.viewLayer.layer.sublayers![0] is CAGradientLayer {
            self.viewLayer.layer.sublayers![0].removeFromSuperlayer()
            self.viewLayer.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            self.viewLayer.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    @objc func postDelete(_ sender:UIButton){
         print("削除ボタンを押下")
        guard let post = postData else {return}
        //確認メッセージ出力
        let alert : UIAlertController = UIAlertController(title: "この投稿を削除してもよろしいですか？", message :nil, preferredStyle: UIAlertController.Style.alert)
        
        //OKボタン押下時
        let defaultAction :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (action :UIAlertAction! ) -> Void in
            //以下OKボタンが押された時の動作
            //・firestoreからドキュメントを削除
            let postsRef = Firestore.firestore().collection(Const.PostPath).document(post.id)
            postsRef.delete()
            
            //・firestorageから写真を削除
            let imageRef = Storage.storage().reference().child(Const.ImagePath).child(post.id + ".jpg")
            imageRef.delete{ error in
                if let error = error {
                    print("DEBUG_PRINT: \(error)")
                } else {
                    print("DEBUG_PRINT: 画像の削除が成功しました。")
                    //画面を一つ前に戻る
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        })
        
        //キャンセルボタン押下時 → 何もしない
        let cancelAction : UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:nil)
        //UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        //Alertを表示
        present(alert,animated: true)
        

    }

}
