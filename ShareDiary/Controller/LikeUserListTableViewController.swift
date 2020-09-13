//
//  LikeUserListTableViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/30.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit

class LikeUserListTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
//    var likeUsers :[String] = []
    var userPostArray :[UserPostData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        self.tableView.backgroundColor = Const.darkColor
        self.tableView.dataSource = self
        self.tableView.delegate  = self
        // カスタムセルを登録する
        let nib = UINib(nibName: "LikeUserListTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        //画面下部の境界線を消す
        self.tableView.tableFooterView = UIView()
        self.backButton.addTarget(self, action: #selector(tabBackButton(_:)), for: .touchUpInside)
    }
}

extension LikeUserListTableViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath) as! LikeUserListTableViewCell
        cell.setUserPostData(userPostArray[indexPath.row])
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath ){
        //プロフィール画面に遷移する
        let profileViewController = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
        // 配列からタップされたインデックスのデータを取り出す
        let userData = userPostArray[indexPath.row]
        profileViewController.userData = userData
        profileViewController.modalPresentationStyle = .fullScreen
        //選択後の色をすぐにもとに戻す
        tableView.deselectRow(at: indexPath, animated: true)
        //画面遷移
        self.present(profileViewController, animated: true, completion: nil)
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        
    @objc func tabBackButton(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
