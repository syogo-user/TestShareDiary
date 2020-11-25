//
//  TimeLineViewController.swift
// ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class TimeLineViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate ,TabBarDelegate{
        
    @IBOutlet weak var tableView: UITableView!
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    let refreshCtl = UIRefreshControl()
    // Firestoreのリスナー
    var userListener: ListenerRegistration!
    var postListenerArray: [ListenerRegistration] = []
    //フォローと自分のuid配列
    var followAndMyUidArray : [String] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // カスタムセルを登録する



        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        //tableViewの境界線を消す
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        //リフレッシュ
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)                                
        
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        //削除済みのユーザ出ないかを判断する　自分自身のviewContorllerを渡す
        CommonUser.JudgDeleteUid(myUid: myUid,viewController:self)
        //削除フラグが設定されている人を取得し、その後タイムラインを表示する
        self.accountDeleteStateGet(myUid: myUid)    
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for postListener in postListenerArray{
            postListener.remove()
        }
        postListenerArray = []
        postArray = []
        tableView.reloadData()

        if userListener != nil{
            userListener.remove()
            userListener = nil
            postArray = []
            tableView.reloadData()
        }
    }
        
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        //セルを選択した時に選択状態の表示にしない（セルを選択した時に選択状態の表示にしない）
        //(つまりセルが選択された時にUITableViewCellSelectedBackgroundを使用しない)
        cell.selectionStyle = .none

        cell.setPostData(postArray[indexPath.row])

        //いいねボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(tapLikeButton(_:forEvent:)), for: .touchUpInside)
        //コメントボタンを押下時
        cell.commentButton.addTarget(self, action:#selector(tapCommnetButton(_:forEvent:)), for: .touchUpInside)
        
        //variousボタン押下時
        cell.variousButton.addTarget(self, action:#selector(tapVariousButtion(_:forEvent:)), for: .touchUpInside)
        
        //自作のデリゲート
        cell.postTableViewCellDelegate = self
        
        return cell
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 800 //セルの高さ
        return UITableView.automaticDimension
    }
    //セルを選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //詳細画面に遷移する
        let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath.row]
        
        detailViewController.postData = postData
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    //ドキュメント表示
    func documentShow(myUid:String,accountDeleteArray:[String]){
        //◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆
        let postUserRef = Firestore.firestore().collection(Const.users).document(myUid)
        userListener = postUserRef.addSnapshotListener() {
            (querySnapshot2,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                //                    if self.initialDisplayFlg {
                //                        SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                //                    }
                return
            } else {
                let document = querySnapshot2?.data()
                guard let doc = document else{return}
                if let docFollow = doc["follow"] {
                    self.followAndMyUidArray = []
                    self.followAndMyUidArray = docFollow as! [String]
                    //自分のuidも追加
                    self.followAndMyUidArray.append(myUid)
                    //初期化
                    self.postArray = []
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                    //フォローしている人の配列でループ（自分含み）
                    for uid in self.followAndMyUidArray{
                        let postsRef = Firestore.firestore().collection(Const.PostPath).whereField("uid",isEqualTo:uid)//.order(by: "date", descending: true)
                        //スナップショットリスナーを追加
                        self.postListenerArray.append(postsRef.addSnapshotListener(){ (querySnapshot, error) in
                            //nillの場合は処理を飛ばす
                            guard querySnapshot != nil  else{return}
                            querySnapshot!.documents.forEach{
                                document in
                                let postData = PostData(document: document)
                                //配列に存在するかどうか
                                if self.postArray.firstIndex(where: {post -> Bool in return post.id == postData.id}) == nil {
                                    //存在しない場合
                                    //そのまま追加
                                    self.postArray.append(postData)
                                }else{
                                    //存在する場合
                                    for (index,post) in self.postArray.enumerated(){
                                        if post.id == postData.id {
                                            //存在するデータを削除してから追加
                                            self.postArray.remove(at: index)
                                            self.postArray.append(postData)
                                        }
                                    }
                                }
                                
                                //日付順に入れ替える
                                self.postArray.sort{ (d0 ,d1) -> Bool in
                                    if let date0 = d0.date, let date1 = d1.date{
                                        //２つの日付が両方ともnilでないとき
                                        return date0  > date1
                                    }else{
                                        return false
                                    }
                                }
                                
                                //削除ステータスが0より大きいユーザは除外する
                                for (index,post) in self.postArray.enumerated(){
                                    if accountDeleteArray.firstIndex(of: post.uid) != nil{
                                        self.postArray.remove(at:index)
                                    }
                                }                                
                                // TableViewの表示を更新する
                                self.tableView.reloadData()
                            }
                            
                        })
                    }
                }
            }
        }
        

    }
    
    //いいねボタンがタップされた時に呼ばれるメソッド
    @objc func tapLikeButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    @objc func refresh( sender: UIRefreshControl){
        tableView.reloadData()
        //通信終了後、endRefreshingを実行することでロードインジケータ（くるくる）が終了する
        sender.endRefreshing()
    }
    //コメントボタン押下時
    @objc func tapCommnetButton(_ sender: UIButton, forEvent event: UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        //詳細画面に遷移する
        let detailViewController = self.storyboard?.instantiateViewController(identifier: "DitailViewController") as! DitailViewController
        detailViewController.postData = postData
        detailViewController.scrollFlg = true //画面遷移後すぐに下にスクロールを行う
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    //ブロックor通報
    @objc func tapVariousButtion(_ sender : UIButton,forEvent event:UIEvent){
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        guard let myUid = Auth.auth().currentUser?.uid else{return}

        let dialog = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        dialog.addAction(UIAlertAction(title: "このユーザをブロックします", style: .default, handler: { action in
            if myUid == postData.uid{
                self.myAlert()
                return
            }
            //ブロック
            self.userBlock(postData:postData)
        }))
        dialog.addAction(UIAlertAction(title: "このユーザを通報します", style: .default, handler: { action in
            if myUid == postData.uid{
                self.myAlert()
                return
            }
            //通報
            self.userReportQuestion(postData:postData)
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: { action in
            print("DEBUG:キャンセル")
        }))
        self.present(dialog,animated: true,completion: nil)
        
    }
    
    //タブボタンがタップされた場合
    func didSelectTab(tabBarController: TabBarController) {
        print("DEBUG:タイムラインタブがタップされました。")
        //最上部にスクロール
        let contentOffset = CGPoint(x: 0.0, y: 0.0)
        self.tableView.setContentOffset(contentOffset, animated: true)
    }
    
    //ブロック処理
    private func userBlock(postData:PostData){
        let userName = postData.documentUserName ?? ""
        let dialog = UIAlertController(title: "\(userName)をブロックしてもよろしいですか？", message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            guard let myUid = Auth.auth().currentUser?.uid else{return}
            print("DEBUG: myUid\(myUid)")
            print("DEBUG: postData.uid\(postData.uid)")
            let db = Firestore.firestore()
            //トランザクション開始
            let batch = db.batch()
            
            let userRef = db.collection(Const.users).document(myUid)
            var updateValue: FieldValue
            updateValue = FieldValue.arrayUnion([postData.uid])
            //自分のblockListにブロックしたいユーザのuidを書き込む
            batch.updateData(["blockList": updateValue],forDocument: userRef)
            
            
            //自分のフォローのリストから相手のuidを削除
            updateValue = FieldValue.arrayRemove([postData.uid])
            batch.updateData(["follow":updateValue], forDocument: userRef)
            
            //相手のフォロワーのリストからmyUidを削除
            let userRef2 = db.collection(Const.users).document(postData.uid)
            updateValue = FieldValue.arrayRemove([myUid])
            batch.updateData(["follower":updateValue], forDocument: userRef2)
            //トランザクション終了
            //コミット
            batch.commit(){ error in
                if let err = error {
                    print("DEBUG:Error writing batch \(err)")
                }else{
                    print("DEBUG:Batch write succeeded.")
                }
            }
        }))
        dialog.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: nil))
        self.present(dialog,animated: true,completion: nil)
    }
    //通報処理
    private func userReportQuestion(postData:PostData){
        let dialog = UIAlertController(title: "通報の詳細をお知らせ願います。", message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "不審な内容またはスパムです", style: .default, handler:{ action in
            self.userReport(postData: postData, reportKind: 1)
        }))
        dialog.addAction(UIAlertAction(title: "不適切な内容を含んでいる", style: .default, handler: { action in
            self.userReport(postData: postData, reportKind: 2)
        }))
        dialog.addAction(UIAlertAction(title: "攻撃的な内容を含んでいる", style: .default, handler: { action in
            self.userReport(postData: postData, reportKind: 3)
        }))
        self.present(dialog,animated: true,completion:nil)
    }
    //通報処理
    private func userReport(postData :PostData,reportKind:Int){
        let userName = postData.documentUserName ?? ""
        let dialog = UIAlertController(title: "\(userName)を通報してもよろしいですか？", message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            guard let myUid = Auth.auth().currentUser?.uid else{return}
            //データをまとめる
            /*reportUid 通報された人のuid
              reportDocumentId 通報された投稿のID
              reportKind 通報の種類 1:不審な内容またはスパムです 2:不適切な内容を含んでいる 3:攻撃的な内容を含んでいる
              senderUid 通報した人のuid
              date 通報の日時
            */
            let reportRef = Firestore.firestore().collection(Const.report).document()
            let reportDic = [
                "reportUid":postData.uid,
                "reportDocumentId":postData.id,
                "reportKind":reportKind,
                "senderUid":myUid,
                "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
            //データを登録
            reportRef.setData(reportDic)
            print("DEBUG:通報データを登録")
            //ご連絡ありがとうございます
            let dialog2 = UIAlertController(title: "ご連絡ありがとうございます。確認が取れ次第対応を行います。", message: nil, preferredStyle: .alert)
            dialog2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog2,animated:true,completion: nil)
        }))
        dialog.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: nil))
        self.present(dialog,animated: true,completion: nil)
    }
    
    
    //自分だった場合
    private func myAlert(){
        let dialog = UIAlertController(title: "自分の投稿です", message: nil, preferredStyle: .actionSheet)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(dialog,animated: true,completion: nil)
    }
    //削除フラグのあるアカウントを取得
    private func accountDeleteStateGet(myUid:String){
        //削除ステータスが0よりも大きいもの
        let userRef = Firestore.firestore().collection(Const.users).whereField("accountDeleteState",isGreaterThan:0)
        userRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                var accountDeleteArray  :[String] = []
                accountDeleteArray = querySnapshot!.documents.map {
                    document -> String in
                    let userUid = UserPostData(document:document).uid ?? ""
                    return userUid
                }
                
                //ドキュメント表示
                self.documentShow(myUid: myUid,accountDeleteArray:accountDeleteArray)
            }
        }
        
    }
}

extension TimeLineViewController:PostTableViewCellDelegate{
    //PostTablViewCellの投稿写真をタップしたときに呼ばれる
    func imageTransition(_ sender:UITapGestureRecognizer) {
        //タップしたUIImageViewを取得
        let tappedUIImageView = sender.view! as? UIImageView
        //  UIImage を取得
        guard let tappedImageView = tappedUIImageView  else {return}
        guard let tappedImageviewImage = tappedImageView.image else {return}
        let tappedImage = tappedImageviewImage
        
        let fullsizeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullsizeImageViewController") as! FullsizeImageViewController
        fullsizeImageViewController.modalPresentationStyle = .fullScreen
        fullsizeImageViewController.image = tappedImage
        self.present(fullsizeImageViewController, animated: true, completion: nil)
    }
}
