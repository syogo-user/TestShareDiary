//
//  Validation.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/10/04.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
struct Validation{
    //メールの書式チェック
     static func isValidEmail(_ string: String) -> Bool {
         //大文字小文字英数字と._%+-
         //大文字小文字英数字.-
         //.を一つ
         //末尾に2文字から4文字の大文字小文字英数字
         let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
         let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
         let result = emailTest.evaluate(with: string)
         //正しい書式の場合trueを返却
         return result
     }
}
