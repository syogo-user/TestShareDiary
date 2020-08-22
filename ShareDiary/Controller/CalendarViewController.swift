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

class CalendarViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    var dateArray :[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.calendar.backgroundColor = Const.darkColor
        self.view.backgroundColor = Const.darkColor
        self.calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        self.calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        self.calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        self.calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        self.calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        self.calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        self.calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        
        self.calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.orange
        self.calendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.orange
        self.calendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.orange
        self.calendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.orange
        self.calendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.orange
        self.calendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor.orange
        self.calendar.calendarWeekdayView.weekdayLabels[6].textColor = UIColor.orange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateArray = []
        calendar.reloadData()
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
    //追加ボタン押下
    @IBAction func addButton(_ sender: Any) {
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
            format.locale = Locale(identifier: "ja_JP")
            format.dateStyle = .short
            format.timeStyle = .none
            strDate = format.string(from:day)
        }
        return strDate
    }
    
}
