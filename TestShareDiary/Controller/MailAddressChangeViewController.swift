
//
//  MailAddressChangeViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/03.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class MailAddressChangeViewController: UIViewController {
    
    //メールアドレス
    @IBOutlet weak var mailAddress: UITextField!
    //パスワード
    @IBOutlet weak var password: UITextField!
    //アカウント削除ボタン
    @IBOutlet weak var accountDelete: UIButton!
    
    //アカウント削除ボタンから画面遷移したかどうか
    var accountDeleteFlg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        //戻るボタンの戻るの文字を削除
        self.navigationController!.navigationBar.topItem!.title = ""
        let rightFooBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTap))
        self.navigationItem.setRightBarButtonItems([rightFooBarButtonItem], animated: true)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        guard let user = Auth.auth().currentUser else{return}
        //現在のメールアドレスを表示
        self.mailAddress.text = user.email
        
        //アカウント削除ボタン
        self.accountDelete.addTarget(self, action: #selector(accountDeleteButtonTap), for: .touchUpInside)
                        
        
        if self.accountDeleteFlg == true{
            //アカウント削除ボタンを表示
            self.accountDelete.isHidden = false
            //保存ボタンを消す
            self.navigationItem.setRightBarButtonItems([], animated: true)
        }else {
            //アカウント削除ボタンを非表示
            self.accountDelete.isHidden  = true
        }
        
        
        
    }
    private func check(mailAddress:String,password:String) -> Bool{
        if mailAddress.isEmpty {
             //メールアドレスが空の場合
             let dialog = UIAlertController(title: "メールアドレスを入力してください", message: nil, preferredStyle: .actionSheet)
             dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
         //メールアドレスかをチェック
         if !Validation.isValidEmail(mailAddress){
             let dialog = UIAlertController(title: "メールアドレスの書式で入力してください", message: nil, preferredStyle: .actionSheet)
             dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
         if password.isEmpty{
             //パスワードが空の場合
             let dialog = UIAlertController(title: "認証を行うためパスワードを入力してください", message: nil, preferredStyle: .actionSheet)
             dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
         //パスワード桁数
         if password.count < 6{
             //アラート
             let dialog  =  UIAlertController(title: "パスワードは6桁以上で入力してください", message: nil, preferredStyle: .actionSheet)
             //OKボタン
             dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
             self.present(dialog,animated: true,completion: nil)
             return false
         }
        
        //チェックOK
        return true
    }
    //保存ボタン押下時
    @objc private func saveButtonTap(){
        guard let user = Auth.auth().currentUser else{return}

        guard let email = user.email else {return}
        var credential: AuthCredential
        
        if let mailAddress = self.mailAddress.text ,let password = self.password.text {
            //入力チェック
            let checkResult = check(mailAddress:mailAddress,password:password)
            //入力チェックでfalseの場合はreturn
            guard checkResult else {return}
             
            //HUDを表示
            SVProgressHUD.show()

            //再認証を行う
            credential = EmailAuthProvider.credential(withEmail: email, password:password)
            // Prompt the user to re-provide their sign-in credentials
            user.reauthenticate(with: credential) { result ,error in
                if let error = error {
                    // An error happened.
                    print("DEBUG:\(error)")
                    let dialog  =  UIAlertController(title: "認証に失敗しました", message:nil, preferredStyle: .alert)
                    //OKボタン
                    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(dialog,animated: true,completion: nil)
                    //HUDを消す
                    SVProgressHUD.dismiss()
                    return
                } else {
                    // User re-authenticated.
                    print("DEBUG:再認証成功")
                    //メールアドレス更新
                    self.updateMailAddress(user:user)
                }
            }
        }
    }
    
    //メールアドレス更新
    private func updateMailAddress(user:User){
        user.updateEmail(to: self.mailAddress.text!){ error in
            if let error = error {
                print("DEBUG:認証に失敗しました \(error)")
                let dialog  =  UIAlertController(title: "メールアドレスの更新に失敗しました", message:nil, preferredStyle: .alert)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                //HUDを消す
                SVProgressHUD.dismiss()
                return
            }else{
                print("DEBUG:メールアドレス更新完了")
                //HUDを消す
                SVProgressHUD.dismiss()
                //前の画面に戻る
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //アカウント削除ボタン押下時
    @objc private func accountDeleteButtonTap(){
        if let mailAddress = self.mailAddress.text ,let password = self.password.text {
            //入力チェック
            let checkResult = check(mailAddress:mailAddress,password:password)
            //入力チェックでfalseの場合はreturn
            guard checkResult else {return}
            //ダイアログ表示
            let dialog = UIAlertController(title: "アカウントを削除します。削除後データはもとに戻せませんがよろしいですか？", message: nil, preferredStyle: .actionSheet)
            //OKボタン
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                //アカウントの再認証を行う
                //アカウント削除時にしばらく認証していないと失敗することがあるため
                self.reAuthenticate(email:mailAddress,password:password)
            }))
            //キャンセルボタン
            dialog.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { action in}))
            self.present(dialog,animated: true,completion: nil)
        }
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
            let db = Firestore.firestore()
            //トランザクション開始
            let batch = db.batch()
            
            
            //自分の投稿を検索
            self.searchMyDoc(myUid:myUid,db:db,batch:batch)
            //自分がいいねした投稿を検索
            self.searchLike(myUid:myUid,db:db,batch:batch)
            //自分のプロフィール写真を検索
            self.searchMyImage(myUid:myUid,db:db,batch:batch)
            //他のフォロー・フォロワー・フォローリクエストを検索
            self.searchFollowFollowerRequest(myUid:myUid,key:"follow",db:db,batch:batch)
            self.searchFollowFollowerRequest(myUid:myUid,key:"follower",db:db,batch:batch)
            self.searchFollowFollowerRequest(myUid:myUid,key:"followRequest",db:db,batch:batch)

            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                // 10.0秒後に実行したい処理
                //コミット
                batch.commit() { err in
                    if let err = err {
                        print("DEBUG:Error writing batch \(err)")
                    } else {
                        print("DEBUG:Batch write succeeded.")
                        //⑦自分のuid、メールアドレス、パスワード情報などを削除
                        self.deleteAccountInfo()
                    }
                }
            }


            
        }
    }
    //自分のドキュメントを検索
    private func searchMyDoc(myUid:String,db:Firestore,batch:WriteBatch){
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
                //投稿の数繰り返す
                for doc in docArray {
                    //doc.contentImageMaxNumberが0の場合写真はないため、そのまま自分の投稿を削除する
                    if(doc.contentImageMaxNumber == 0){
                        //写真がない場合
                        //②自分の投稿を削除
                        self.deleteDoc(documentId:doc.id,path:Const.PostPath,db:db,batch: batch)
                    }else{
                        //写真がある場合
                        //投稿した写真の枚数で繰り返す
                        for i in 1 ... doc.contentImageMaxNumber{
                            //投稿した写真を削除(文字列に変換したファイル名を渡す)
                            //①自分の投稿写真を削除
                            self.deleteImage(imageName:doc.id + i.description)
                            
                            //最後の写真を削除したら
                            if (i == doc.contentImageMaxNumber){
                                //②自分の投稿を削除
                                self.deleteDoc(documentId:doc.id,path:Const.PostPath,db:db,batch: batch)
                            }
                        }
                    }
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
                print("DEBUG:写真\(imageName)を削除しました")
            }
        }
    }
    
    //ドキュメントの削除
    private func deleteDoc(documentId:String,path:String,db:Firestore,batch:WriteBatch){
        let postsRef = db.collection(path).document(documentId)
        batch.deleteDocument(postsRef)
        print("DEBUG:\(documentId)のドキュメントを削除しました")
    }
    
    //いいねしたドキュメントを検索
    private func searchLike(myUid:String,db:Firestore,batch:WriteBatch){
        let myDocRef = Firestore.firestore().collection(Const.PostPath).whereField("likes", arrayContains:myUid)
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
                //③他ユーザの投稿にあるいいねを削除
                self.deleteLike(docArray:docArray,myUid:myUid,db:db,batch:batch)
                
            }
        }
    }
    //いいねを削除
    private func deleteLike(docArray:[PostData],myUid:String,db:Firestore,batch:WriteBatch){
        for doc in docArray{
            let likeRef = db.collection(Const.PostPath).document(doc.id)
            var deleteLikeValue :FieldValue
            deleteLikeValue = FieldValue.arrayRemove([myUid])
            //いいねを削除
            batch.updateData(["likes":deleteLikeValue], forDocument: likeRef)
            print("DEBUG:\(doc.id)の「いいね」から\(myUid)を削除しました")
        }
    }
    //自分のプロフィール写真を検索
    private func searchMyImage(myUid:String,db:Firestore,batch:WriteBatch){
        let myUserRef = Firestore.firestore().collection(Const.users).document(myUid)
        myUserRef.getDocument{(querySnapshot,error) in
            if let error = error {
                print("DEBUG:imageNumberの取得に失敗しました。\(error)")
            }
            guard let data  = querySnapshot?.data() else { return}
            if let myImageName = data["myImageName"] as? String {
                //④自分のプロフィール写真を削除
                self.deleteImage(imageName: myImageName)
            }
            //⑥自分のユーザ情報を削除
            self.deleteDoc(documentId: myUid, path: Const.users,db:db,batch:batch)
        }
        
    }
    
    //フォロー・フォロワー・フォローリクエストを検索
    private func searchFollowFollowerRequest(myUid:String,key:String,db:Firestore,batch:WriteBatch){
        let userRef = Firestore.firestore().collection(Const.users).whereField(key, arrayContains:myUid)
        userRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                var docArray  :[UserPostData] = []
                docArray = querySnapshot!.documents.map {
                    document -> UserPostData in
                    let userPostData = UserPostData(document:document)
                    return userPostData
                }
                //⑤ユーザのフォロー、フォロワー、フォローリクエストから削除
                self.deleteFFR(fArray:docArray,myUid:myUid,key:key,db:db,batch:batch)
            }
        }
    }
    //フォロー・フォロワー・フォローリクエストを削除
    private func deleteFFR(fArray:[UserPostData],myUid:String,key:String,db:Firestore,batch:WriteBatch){
        for f in fArray{
            let userRef = db.collection(Const.users).document(f.id)
            var deleteLikeValue :FieldValue
            deleteLikeValue = FieldValue.arrayRemove([myUid])
            //いいねを削除
            batch.updateData([key:deleteLikeValue], forDocument: userRef)
        }
    }
    
    //アカウント情報(メールアドレス,パスワードなど)を削除
    private func deleteAccountInfo(){
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print("DEBUG:\(error)")
                // An error happened.
            } else {
                // Account deleted.
                print("DEBUG:アカウント削除完了")
                let dialog = UIAlertController(title: "アカウントの削除が正常に行われました。", message: nil, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    //ログアウト
                    self.logout()
                }))
                self.present(dialog,animated: true,completion: nil)
            }
        }
    }
    private func reAuthenticate(email:String,password:String){
        guard let user = Auth.auth().currentUser else{return}
        var credential: AuthCredential
        //再認証を行う
        credential = EmailAuthProvider.credential(withEmail: email, password:password)
        // Prompt the user to re-provide their sign-in credentials
        user.reauthenticate(with: credential) { result ,error in
            if let error = error {
                // An error happened.
                print("DEBUG:\(error)")
                let dialog  =  UIAlertController(title: "認証に失敗しました", message:nil, preferredStyle: .alert)
                //OKボタン
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog,animated: true,completion: nil)
                //HUDを消す
                //                SVProgressHUD.dismiss()
                return
            } else {
                // User re-authenticated.
                print("DEBUG:再認証成功")
                //アカウント削除
                self.myDocImageDelete()
            }
        }
    }
    private func logout(){
        //スライドメニューのクローズ
        closeLeft()
        guard let myUid = Auth.auth().currentUser?.uid else{return}
        let docData = [
            "lastLogoutDate":FieldValue.serverTimestamp()
            ] as [String : Any]
        //メッセージの保存
        let userRef = Firestore.firestore().collection(Const.users).document(myUid)
        userRef.updateData(docData)
        
        sleep(1)
        // ログアウトする
        try! Auth.auth().signOut()
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        loginViewController?.modalPresentationStyle = .fullScreen
        self.present(loginViewController!, animated: true, completion: nil)
        
        //TODO
        //タブバーを取得する
        let slideViewController = parent as! SlideViewController
        let navigationController = slideViewController.mainViewController as! UINavigationController
        let tabBarController = navigationController.topViewController as! TabBarController
        //listener削除用にタイムライン画面を一度選択する
        tabBarController.selectedIndex = 2//自分が今タイムラインタブ（1）にいた場合用
        tabBarController.selectedIndex = 1
        // ログイン画面から戻ってきた時のためにカレンダー画面（index = 0）を選択している状態にしておく
        tabBarController.selectedIndex = 0
    }
    
}
