//
//  UsersTableViewCell.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/05.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit

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
                      
//        if let flg = userPostData.followRequestFlg{
//            if flg {
//                 //followRequestFlgがtrue(申請済)の場合
//                self.followRequestButton.setTitle("申請済", for: .normal)
//            }
//        }
    }
    
}
