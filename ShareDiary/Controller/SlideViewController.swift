//
//  SlideViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/05/06.
//  Copyright © 2020 syogo-user. All rights reserved.
//


import SlideMenuControllerSwift

class SlideViewController: SlideMenuController {
    
    
    override func awakeFromNib() {
        
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "tabbar")
        let leftVC = storyboard?.instantiateViewController(withIdentifier: "Left")
        //UIViewControllerにはNavigationBarは無いためUINavigationControllerを生成しています。 //NavigationBarを追加すことでtabbarを呼び出す
        let navigationController = UINavigationController(rootViewController: mainVC!)
        //ライブラリ特有のプロパティにセット
        mainViewController = navigationController
        leftViewController = leftVC
        //スライドメニューの幅
        SlideMenuOptions.leftViewWidth = 250
        //スライドが表示された時のMainの縮み率 1は縮まない
        SlideMenuOptions.contentViewScale = 1     
        super.awakeFromNib()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
