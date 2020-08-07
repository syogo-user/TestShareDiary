//
//  CustomUIDelegate.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/08/07.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import DKImagePickerController

class CustomUIDelegate: DKImagePickerControllerBaseUIDelegate {
    override func createDoneButtonIfNeeded() -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setTitle("選択", for: .normal)
        button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.imagePickerController.navigationBar.tintColor, for: .normal)
        button.addTarget(self, action: #selector(DKImagePickerController.done), for: .touchUpInside)
        return button
    }

    //写真選択超過時のアラートのカスタマイズ
    override func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
        let alert = UIAlertController.init(title: "注意", message: "これ以上選択できません!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okAction)
        imagePickerController.present(alert, animated: true, completion: nil)
    }

    //cancelボタンのカスタマイズ
    override func imagePickerController(_ imagePickerController: DKImagePickerController, showsCancelButtonForVC vc: UIViewController) {
        let cancelButton = UIBarButtonItem()
        cancelButton.title = "戻る"
        cancelButton.style = .plain
        cancelButton.action = #selector(imagePickerController.dismiss as () -> Void)
        cancelButton.target = imagePickerController
        vc.navigationItem.leftBarButtonItem = cancelButton
    }
}
