//
//  CalendarViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import CalculateCalendarLogic

class CalendarViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var diaryAddButton: UIButton!
    var dateArray :[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.calendar.backgroundColor = Const.darkColor
        self.view.backgroundColor = Const.darkColor
        
        diaryAddButton.addTarget(self, action: #selector(tapDiaryAddButton), for:.touchUpInside)
        self.calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        self.calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        self.calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        self.calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        self.calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        self.calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        self.calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        
        self.calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red
        self.calendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.white
        self.calendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.white
        self.calendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.white
        self.calendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.white
        self.calendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor.white
        self.calendar.calendarWeekdayView.weekdayLabels[6].textColor = UIColor.blue
        //ボタンの設定
        buttonSet()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateArray = []
        self.calendar.reloadData()
        //投稿の中から自分のものだけを取得する
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        let postRef = Firestore.firestore().collection(Const.PostPath).whereField("uid", isEqualTo: myUid)
        postRef.getDocuments(){
            (querySnapshot,error) in
            if let error = error {
                print("DEBUG: snapshotの取得が失敗しました。\(error)")
                return
            } else {
                self.dateArray = []
                querySnapshot!.documents.forEach{
                    document in
                    self.dateArray.append(PostData(document: document).selectDate ?? "")
                    self.calendar.reloadData()
                }
            }
        }
    }
    //ボタンの設定
    private func buttonSet(){
//        diaryAddButton.setTitle("", for: .normal)
//        diaryAddButton.titleLabel?.baselineAdjustment = .alignCenters
        //文字色
        diaryAddButton.setTitleColor(UIColor.white, for: .normal)
        diaryAddButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        // 角丸
        diaryAddButton.layer.cornerRadius = diaryAddButton.bounds.midY
        //影
        diaryAddButton.layer.shadowColor = Const.buttonStartColor.cgColor
        diaryAddButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        diaryAddButton.layer.shadowOpacity = 0.4//追加ボタンのみ影多めに設定
        diaryAddButton.layer.shadowRadius = 10
        // グラデーション
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = diaryAddButton.bounds
        gradientLayer.cornerRadius = diaryAddButton.bounds.midY
        gradientLayer.colors = [Const.buttonStartColor.cgColor, Const.buttonEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        diaryAddButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    //追加ボタン押下
    @objc private func tapDiaryAddButton(){
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        postViewController.modalPresentationStyle = .fullScreen
        self.present(postViewController, animated: true, completion: nil)
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        //選択した日付を取得
        let strDate = dateFormat(date:date)
        //選択した日の自分の投稿を表示
        let myDiaryViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyDiaryFromCalendar") as! MyDiaryFromCalendar
        myDiaryViewController.diaryDate = strDate
        self.navigationController?.pushViewController(myDiaryViewController, animated: true)
    }
    //点の表示
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int{
        var count = 0
        for i in self.dateArray {
            if i == dateFormat(date:date) && i != "" {
                count = count+1
            }
        }
        return count //ここに入る数字によって点の数が変わる
    }
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)

        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)

        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()

        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }

    // 土日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }

        return nil
    }
    
    
    //曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    //Dateを時間なしの文字列に変換
    func dateFormat(date:Date?) -> String {
        var strDate:String = ""
        
        if let day = date {
            let format  = DateFormatter()
            format.dateFormat = "yyyy年MM月dd日"
//            format.locale = Locale(identifier: "ja_JP")
//            format.dateStyle = .short
//            format.timeStyle = .none
            strDate = format.string(from:day)
        }
        return strDate
    }
    
}
