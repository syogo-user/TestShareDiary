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
    var likeUsers :[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.darkColor
        self.tableView.backgroundColor = Const.darkColor
        tableView.dataSource = self
        tableView.delegate  = self
        // カスタムセルを登録する
        let nib = UINib(nibName: "LikeUserListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        //画面下部の境界線を消す
        tableView.tableFooterView = UIView()
        backButton.addTarget(self, action: #selector(tabBackButton(_:)), for: .touchUpInside)
    }
}

extension LikeUserListTableViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likeUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath) as! LikeUserListTableViewCell
        cell.setUserPostData(likeUsers[indexPath.row])
        return cell
    }
    //高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        
    @objc func tabBackButton(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
