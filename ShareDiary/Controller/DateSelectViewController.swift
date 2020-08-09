//
//  DateSelectViewController.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/06/24.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import FSCalendar
class DateSelectViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource {

    @IBOutlet weak var dateSelectCalendar: FSCalendar!
    
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        dateSelectCalendar.delegate = self
        dateSelectCalendar.dataSource = self
        dateSelectCalendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        dateSelectCalendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        dateSelectCalendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        dateSelectCalendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        dateSelectCalendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        dateSelectCalendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        dateSelectCalendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        
        cancelButton.addTarget(self, action: #selector(tabCancelButton(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.

    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        //選択した日付を取得
        let selectDay = date
        print(getDay(selectDay))
        
        //ページを閉じる
        let preVC = self.presentingViewController as! PostViewController
//        let preNC = self.navigationController?.presentingViewController  as! UINavigationController
//        let preVC = preNC.viewControllers[preNC.viewControllers.count - 1] as! PostViewController
        //        preVC.backgroundColor = .blue
        preVC.selectDate = selectDay
        self.dismiss(animated: true, completion:nil)
        
    }
    //キャンセルボタン押下時
    @objc func tabCancelButton(_ sender :UIButton){
        dismiss(animated: true, completion: nil)
    }
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
