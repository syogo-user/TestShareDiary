//
//  UsersTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/05.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!        
    @IBOutlet weak var followRequestButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserPostData(_ userPostData:UserPostData){
        //userNameをセット
        self.userName.text = userPostData.userName

        //ボタンのテキスト変更
        if let myid = Auth.auth().currentUser?.uid {
            self.followRequestButton.setTitle("フォロー申請", for: .normal)
            self.followRequestButton.isEnabled = true
            
            if let followRequestArray = userPostData.followRequest {
                for followRequest in followRequestArray{
                    //フォローリクエストに今ログインしている自分のuidがあったら
                    if followRequest == myid {
                        self.followRequestButton.setTitle("申請済", for: .normal)
                        self.followRequestButton.isEnabled = false
                    }
                }
            }
            
            if let followerArray = userPostData.follower {
                for follower in followerArray {
                    //フォロワーに今ログインしている自分のuidがあったら
                    self.followRequestButton.setTitle("フォロー済", for: .normal)
                    self.followRequestButton.isEnabled = false
                }
            }
        }
        
    }
    
}
