//
//  InputTextView.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/07/11.
//  Copyright © 2020 syogo-user. All rights reserved.
//


import UIKit
class InputTextView :UIView{
    
    @IBOutlet weak var inputText: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    override init(frame:CGRect){
        super.init(frame:frame)
        nibinit()
        setView()
        //テキストの高さを可変にする
        autoresizingMask = .flexibleHeight
    }
    private func setView(){
        inputText.layer.cornerRadius = 15
        inputText.layer.borderColor = UIColor.rgbColor(red: 220, green: 225, blue: 225).cgColor
        inputText.layer.borderWidth = 1
        
        submitButton.layer.cornerRadius = 15
        submitButton.imageView?.contentMode = .scaleAspectFill
        submitButton.contentHorizontalAlignment = .fill
        submitButton.contentVerticalAlignment = .fill
        submitButton.isEnabled = false
        
    
    }
    //テキストの高さを可変にする
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    
    private func nibinit(){
        let nib = UINib(nibName: "InputTextView", bundle:nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
