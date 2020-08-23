//
//  DateSelectViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/24.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
class DateSelectViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {

    @IBOutlet weak var dateSelectCalendar: FSCalendar!    
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateSelectCalendar.backgroundColor = Const.darkColor
        self.dateSelectCalendar.delegate = self
        self.dateSelectCalendar.dataSource = self
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.white
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.white
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.white
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.white
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor.white
        self.dateSelectCalendar.calendarWeekdayView.weekdayLabels[6].textColor = UIColor.blue
        
        self.dateSelectCalendar.reloadData()
        
        cancelButton.addTarget(self, action: #selector(tabCancelButton(_:)), for: .touchUpInside)
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        //選択した日付を取得
        let selectDay = date
        print("DEBUG:\(getDay(selectDay))")
        //ページを閉じる
        let preVC = self.presentingViewController as! PostViewController
        preVC.selectDate = selectDay
        self.dismiss(animated: true, completion:nil)
    }
    //キャンセルボタン押下時
    @objc func tabCancelButton(_ sender :UIButton){
        dismiss(animated: true, completion: nil)
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
}
