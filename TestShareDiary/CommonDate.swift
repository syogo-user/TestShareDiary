//
//  Date.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/08/29.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import Foundation
import CalculateCalendarLogic
struct CommonDate {
        
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    static func judgeHoliday(_ date : Date) -> Bool {
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
    
    //曜日判定(日曜日:1 〜 土曜日:7)
    static func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    //年月日を取得
    static func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    //Dateを時間なしの文字列に変換
    static func dateFormat(date:Date?) -> String {
        var strDate:String = ""
        if let day = date {
            let format  = DateFormatter()
            format.dateFormat = "yyyy年MM月dd日"
            strDate = format.string(from:day)
        }
        return strDate
    }
}
