//
//  SettingViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//
import UIKit
import Firebase
class SettingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mailAddressButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var accountDeleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        self.mailAddressButton.addTarget(self, action: #selector(tapMailAddressButton(_:)), for: .touchUpInside)
        self.passwordButton.addTarget(self, action: #selector(tapPasswordButton(_:)), for: .touchUpInside)
        self.accountDeleteButton.addTarget(self,action:#selector(tapAccountDeleteButton(_:)),for:.touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mailAddress = Auth.auth().currentUser?.email else {return}
        self.titleLabel.text = "アカウント設定"
        self.titleLabel.textColor = UIColor.white
        self.mailAddressButton.setTitle("メールアドレス： \(mailAddress)" , for: .normal)
        self.mailAddressButton.setTitleColor(UIColor.white, for: .normal)
        self.passwordButton.setTitle("パスワード： ●●●●●●●●" , for: .normal)
        self.passwordButton.setTitleColor(UIColor.white, for: .normal)

    }
    //メールアドレスボタン押下時
    @objc private func tapMailAddressButton(_ sender : UIButton){        
        let mailAddressChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MailAddressChangeViewController") as! MailAddressChangeViewController
        self.navigationController?.pushViewController(mailAddressChangeViewController, animated: true)
    }
    //パスワードボタン押下時
    @objc private func tapPasswordButton(_ sender : UIButton){
        let passwordChangeViewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordChangeViewController") as! PasswordChangeViewController
        self.navigationController?.pushViewController(passwordChangeViewController, animated: true)
    }
    //アカウント削除ボタン押下時
    @objc private func tapAccountDeleteButton(_ sender:UIButton){
        //ダイアログ表示
        let dialog = UIAlertController(title: "アカウントを削除します。削除後データはもとに戻せませんがよろしいですか？", message: nil, preferredStyle: .actionSheet)
        //OKボタン
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //アカウント削除
            self.myDocImageDelete()
        }))
        //キャンセルボタン
        dialog.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { action in}))
        self.present(dialog,animated: true,completion: nil)
    }
    //アカウント削除処理
    private func myDocImageDelete(){
        /*
         ①自分の投稿写真を削除
         ②自分の投稿を削除
         ③他ユーザの投稿にあるいいねを削除
         ④自分のプロフィール写真を削除
         ⑤ユーザのフォロー、フォロワー、フォローリクエストから削除
         ⑥自分のユーザ情報を削除
         ⑦自分のuid、メールアドレス、パスワード情報などを削除
         */
        //ログインしている自分のuidを取得する
        if let myUid = Auth.auth().currentUser?.uid {
            //自分の投稿を検索
            let myDocRef = Firestore.firestore().collection(Const.PostPath).whereField("uid", isEqualTo: myUid)
            myDocRef.getDocuments(){
                (querySnapshot,error) in
                if let error = error {
                    print("DEBUG: snapshotの取得が失敗しました。\(error)")
                    return
                } else {
                    var docArray  :[PostData] = []
                    docArray = querySnapshot!.documents.map {
                        document -> PostData in
                        let postData = PostData(document:document)
                        return postData
                    }
                    for doc in docArray {
                        //投稿した写真の枚数で繰り返す
                        for i in 0 ..< doc.contentImageMaxNumber{
                            //投稿した写真を削除(文字列に変換したファイル名を渡す)
                            //①自分の投稿写真を削除
                            self.deleteImage(imageName:doc.id + i.description)
                            
                            //最後の写真を削除したら
                            if (i == doc.contentImageMaxNumber - 1){
                                 //②自分の投稿を削除
                                self.deleteDoc(documentId:doc.id,path:Const.PostPath)                                
                            }
                         }
                    }
                    //TODO ③
                    
                }
            }
        }
    }
    
    //写真を削除
    private func deleteImage(imageName:String){
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(imageName + ".jpg")
        imageRef.delete{
            error in
            if let  error = error {
                print("DEBUG:\(error)")
            }else {
                print("DEBUG:\(imageName)を削除しました")
            }
        }
    }
    
    //ドキュメントの削除
    private func deleteDoc(documentId:String,path:String){
        let postsRef = Firestore.firestore().collection(path).document(documentId)
        postsRef.delete()
    }
    
}
