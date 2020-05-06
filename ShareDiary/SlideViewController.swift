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
        super.awakeFromNib()
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "tabbar")
        let leftVC = storyboard?.instantiateViewController(withIdentifier: "Left")
        //UIViewControllerにはNavigationBarは無いためUINavigationControllerを生成しています。
        let navigationController = UINavigationController(rootViewController: mainVC!)
        //ライブラリ特有のプロパティにセット
        mainViewController = navigationController
        leftViewController = leftVC
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
