//
//  ESMContextCard.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2020/03/19.
//  Copyright © 2020 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import Charts
import AWAREFramework
import DynamicColor

extension ContextCardViewController {
    func setupESMCard(){
        if (AWARESensorManager.shared().getSensor(SENSOR_IOS_ESM) as? IOSESM) != nil {
            
            // fetch scheduled ESM
            if let schedules = ESMScheduleManager.shared().getESMSchedules() {
                var checkedScheduleIDs:[String] = []
                for schedule in schedules {
                    var isDuplicate = false
                    if let sID = schedule.schedule_id {
                        for cSIDs in checkedScheduleIDs {
                            if cSIDs == sID {
                                isDuplicate = true
                                break
                            }
                        }

                        if isDuplicate {
                            continue
                        }else{
                            checkedScheduleIDs.append(sID)
                        }
                        
                        // fetch esms in the schedule
                        if let esms = schedule.esms {
                           for esm in esms {
                            
                                // generate an ESM card by each esm
                                let card = ESMCard(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
                                card.setup(esm: esm)
                                switch card.esmType {
                                case 1,2,3,4,5,6,9:
                                    self.contextCards.append(card)
                                    self.mainStackView.addArrangedSubview(card)
                                    if let title = esm.esm_title {
                                        card.titleLabel.text = title
                                    }
                                    break
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

enum Period:Int8 {
    case day   = 0
    case week  = 1
    case month = 2
    case threeMonths = 3
    case year  = 4
}

class ESMCard: ContextCard {
    
    var esmType:Int = 0
    var charts:Array<Any> = Array<Any>()
    var period:Period = .week
    
    func removeChartContext(){
        print(self.currentDate)
        if let views = self.charts as? [UIView] {
            for view in views {
                view.removeFromSuperview()
            }
        }
        self.charts.removeAll()
    }
    
    func getDiff(by period:Period) -> Double {
        switch period {
        case .day:
            return 60*60*24
        case .week:
            return 60*60*24*7
        case .month:
            return 60*60*24*7*4
        case .threeMonths:
            return 60*60*24*7*4*3
        case .year:
            return 60*60*24*356
        }
    }
    
    public func setup(esm:EntityESM) {
       // super.setup()
        
        self.backwardHandler = {
            self.removeChartContext()
            self.currentDate = self.currentDate.addingTimeInterval(-1 * self.getDiff(by: self.period))
            let end   = AWAREUtils.getTargetNSDate(self.currentDate, hour: 0, nextDay: true).timeIntervalSince1970 * 1000
            let start = AWAREUtils.getTargetNSDate(self.currentDate.addingTimeInterval(-1 * self.getDiff(by: self.period)), hour: 0, nextDay: true).timeIntervalSince1970 * 1000
            self.setChartContext(esm: esm, start: start, end: end)
            self.setTitleToNavigationView(with: self.period)
        }
        
        self.forwardHandler = {
            self.removeChartContext()
            self.currentDate = self.currentDate.addingTimeInterval(self.getDiff(by: self.period))
            print(self.currentDate)
            let end    = AWAREUtils.getTargetNSDate(self.currentDate, hour: 0, nextDay: true).timeIntervalSince1970 * 1000
            let start = AWAREUtils.getTargetNSDate(self.currentDate.addingTimeInterval(-1 * self.getDiff(by: self.period)), hour: 0, nextDay: true).timeIntervalSince1970 * 1000
            self.setChartContext(esm: esm, start: start, end: end)
            self.setTitleToNavigationView(with: self.period)
        }
        
        self.navigatorTitleButtonHandler = {
            self.period = Period(rawValue: Int8((Int(self.period.rawValue) + 1) % 4))!
            if Int(self.period.rawValue) == 0 {
                self.period = Period(rawValue: 1)!
            }
            
            self.removeChartContext()
           let end    = AWAREUtils.getTargetNSDate(self.currentDate, hour: 0, nextDay: true).timeIntervalSince1970 * 1000
           let start = AWAREUtils.getTargetNSDate(self.currentDate.addingTimeInterval(-1 * self.getDiff(by: self.period)), hour: 0, nextDay: true).timeIntervalSince1970 * 1000
           self.setChartContext(esm: esm, start: start, end: end)
            self.setTitleToNavigationView(with: self.period)
          //print(self.period)
        }
        
        let today    = AWAREUtils.getTargetNSDate(Date(), hour: 0, nextDay: true).timeIntervalSince1970 * 1000
        let aWeekAgo = AWAREUtils.getTargetNSDate(Date().addingTimeInterval(-1*60*60*24*7), hour: 0, nextDay: true).timeIntervalSince1970 * 1000
        self.setChartContext(esm: esm, start: aWeekAgo, end: today)
        self.setTitleToNavigationView(with: self.period)
    }
    
    func setTitleToNavigationView(with period:Period) {
        switch period {
        case .day:
            self.setTitleToNavigationView(with: "Day")
            break
        case .week:
            self.setTitleToNavigationView(with: "Week")
            break
        case .month:
            self.setTitleToNavigationView(with: "Month")
            break
        case .threeMonths:
            self.setTitleToNavigationView(with: "Three Months")
            break
        case .year:
            self.setTitleToNavigationView(with: "Year")
            break
        }
    }
    
    func setChartContext(esm:EntityESM, start:Double, end:Double){
        
        guard let type = esm.esm_type as? Int, let trigger = esm.esm_trigger else {
            return
        }
        
        self.esmType = type
        
        if let context = CoreDataHandler.shared().managedObjectContext {
             context.persistentStoreCoordinator = CoreDataHandler.shared().persistentStoreCoordinator
             let request  = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(EntityESMAnswer.self))
             
             request.predicate = NSPredicate(format: """
                                                         esm_trigger == %@ AND
                                                         double_esm_user_answer_timestamp >= %f AND
                                                         double_esm_user_answer_timestamp <= %f
                                                     """
                 , argumentArray:[trigger, start, end])
             do {
                if let answers = try context.fetch(request) as? [EntityESMAnswer] {
                    
                    switch type {
                    case 1: // text
                        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                        var text = ""
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .short
                        for answer in answers {
                            if let timestamp = answer.double_esm_user_answer_timestamp as? Double, let userAnswer = answer.esm_user_answer {
                                let date = Date(timeIntervalSince1970: timestamp/1000)
                                text.append("[\(formatter.string(from: date))] \(userAnswer)\n")
                            }
                        }
                        textView.text = text
                        textView.isEditable = false
                        textView.isSelectable = false
                        self.indicatorView.isHidden = true
                        self.translatesAutoresizingMaskIntoConstraints = false
                        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
                        self.spaceView.translatesAutoresizingMaskIntoConstraints = false
                        self.baseStackView.insertArrangedSubview(textView, at: 2)
                        break
                    case 2, 3, 5: // radio, checkbox, quick
                        let chart = BarChartView()
                        
                        let blue   = UIColor(hexString: "#3498db")
                        let red    = UIColor(hexString: "#e74c3c")
                        let yellow = UIColor(hexString: "#f1c40f")
                        let gradient = DynamicGradient(colors: [blue, red, yellow])
                        
                        var keys = [String]()
                        
                        if type == 2 {
                            if let strRadios = esm.esm_radios {
                                keys = try JSONDecoder().decode([String].self, from: strRadios.data(using: .utf8)!)
                            }
                        }else if type == 3 {
                            if let strCheckBox = esm.esm_checkboxes {
                                keys = try JSONDecoder().decode([String].self, from: strCheckBox.data(using: .utf8)!)
                            }
                        }else if type == 5 {
                            if let strKeys = esm.esm_quick_answers {
                                keys = try JSONDecoder().decode([String].self, from: strKeys.data(using: .utf8)!)
                            }
                        }
                            
                        let hslPalette = gradient.colorPalette(amount: UInt(keys.count), inColorSpace: .hsl)

                        var dataSets = [BarChartDataSet]()
                        for (i, key) in keys.enumerated() {
                            var entries = Array<BarChartDataEntry>()
                            var count = 0
                            for answer in answers {
                                if let esm_user_answer = answer.esm_user_answer {
                                    if type == 3 { // checkbox
                                        do {
                                            let selectedOptions = try JSONDecoder().decode([String].self, from: esm_user_answer.data(using: .utf8)!)
                                            for option in selectedOptions {
                                                if option == key {
                                                    count = count + 1
                                                }
                                            }
                                        }catch{
                                            print("Error: \(error)")
                                        }
                                    }else{ // others
                                        if esm_user_answer == key {
                                            count = count + 1
                                        }
                                    }
                                }
                            }
                            let entry = BarChartDataEntry(x: Double(i), y: Double(count))
                            entries.append(entry)
                            let dataSet = BarChartDataSet(entries: entries, label: key)
                            dataSet.setColor(hslPalette[i%hslPalette.count], alpha: 0.8)
                            dataSet.drawValuesEnabled = false
                            dataSets.append(dataSet)
                        }
                        chart.data = BarChartData(dataSets: dataSets)
                        
                        let xaxis = XAxis()
                        let formatter = BarChartFormatter()
                        formatter.labels = keys
                        xaxis.valueFormatter = formatter
                        chart.xAxis.setLabelCount(keys.count, force: true)
                        chart.xAxis.valueFormatter = xaxis.valueFormatter
                        chart.xAxis.labelRotationAngle = 45
                        chart.xAxis.enabled = true
                        chart.xAxis.labelPosition = .bottom
                        chart.legend.enabled = false
                        chart.rightAxis.enabled = false
                        chart.leftAxis.drawZeroLineEnabled = true
                        
                        charts.append(chart)
                        self.indicatorView.isHidden = true
                        self.translatesAutoresizingMaskIntoConstraints = false
                        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
                        self.spaceView.translatesAutoresizingMaskIntoConstraints = false
                        self.baseStackView.insertArrangedSubview(chart, at: 2)
                        
                        break
                    case 4, 6, 9: // likert, scale, number
                        // prepare scatter chart
                        let chart = ScatterChartView()
                        chart.xAxis.labelPosition = .bottom
                        chart.rightAxis.enabled   = false

                        // data setup
                        var dataEntries:[ChartDataEntry] = []
                        for i in 0 ..< answers.count {
                            if let strAnswer = answers[i].esm_user_answer, let timestamp = answers[i].double_esm_user_answer_timestamp {
                                if let yVal = Double(strAnswer){
                                    let dataEntry = ChartDataEntry(x: timestamp.doubleValue, y :yVal)
                                    dataEntries.append(dataEntry)
                                }
                            }
                        }
                        
                        let dataSet = ScatterChartDataSet(entries: dataEntries, label: esm.esm_trigger ?? "" )
                        dataSet.setColor(.blue)
                        dataSet.setScatterShape(.circle)
                        chart.data = ScatterChartData(dataSet: dataSet)
                        
                        let formatter = ChartFormatter()
                        formatter.period = period
                        chart.xAxis.valueFormatter = formatter
                        
                        // set max/min of x-axis
                        chart.xAxis.axisMinimum = start
                        chart.xAxis.axisMaximum = end
                        
                        if type == 4 {
                             // set max/min of y-axis
                             if let max = esm.esm_likert_max {
                                 chart.leftAxis.axisMaximum = max.doubleValue + 1
                                 chart.leftAxis.axisMinimum = 0
                             }
                        } else if type == 6 {
                             if let max = esm.esm_scale_max, let min = esm.esm_scale_min {
                                 chart.leftAxis.axisMaximum = max.doubleValue + 1
                                 chart.leftAxis.axisMinimum = min.doubleValue - 1
                             }
                        }

                        if let instruction = esm.esm_instructions {
                            chart.chartDescription.text = instruction
                            // instructionLabel.font = UIFont.systemFont(ofSize: 12)
                            // instructionLabel.textColor = UIColor.systemGray
                        }

                        
                        if #available(iOS 13.0, *) {
                            chart.leftAxis.labelTextColor = UIColor.label
                            chart.xAxis.labelTextColor    = UIColor.label
                            chart.legend.textColor        = UIColor.label
                            chart.chartDescription.textColor = UIColor.label
                        }
                        
                        charts.append(chart)
                        self.indicatorView.isHidden = true
                        self.translatesAutoresizingMaskIntoConstraints = false
                        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
                        self.spaceView.translatesAutoresizingMaskIntoConstraints = false
                        self.baseStackView.insertArrangedSubview(chart, at: 2)
                        
                        break
                    case 7: // datetime
                        break
                    case 8: // PAM
//                        keys = ["afraid","tense","excited","delighted",
//                                "frustrated","angry","happy","glad",
//                                "miserable","sad","calm","satisfied",
//                                "gloomy","tired","sleepy","serene"]
//                        let hslPalette = gradient.colorPalette(amount: UInt(keys.count), inColorSpace: .hsl)
//
//                        var dataSets = [BarChartDataSet]()
//                        for (i, key) in keys.enumerated() {
//                            var entries = Array<BarChartDataEntry>()
//                            var count = 0
//                            for answer in answers {
//                                if let esm_user_answer = answer.esm_user_answer {
//                                    if esm_user_answer == key {
//                                        count = count + 1
//                                    }
//                                }
//                            }
//                            let entry = BarChartDataEntry(x: Double(i), y: Double(count))
//                            entries.append(entry)
//                            let dataSet = BarChartDataSet(entries: entries, label: key)
//                            dataSet.setColor(hslPalette[i%hslPalette.count], alpha: 0.8)
//                            dataSet.drawValuesEnabled = false
//                            dataSets.append(dataSet)
//                        }
//                        chart.data = BarChartData(dataSets: dataSets)
                        break
                    default: //
                        break
                    }
                }

             }catch{
                 print("Failed to fetch employees: \(error)")
             }
         }

    }
}

public class ChartFormatter: IndexAxisValueFormatter {
    
    var dateFormatter = DateFormatter()
    var period:Period? = nil
    
    override init() {
        super.init()
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d", options: 0, locale: Locale.current)
        dateFormatter = formatter
    }
    
    public override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value/1000)
        
        if let period = self.period{
            // https://your3i.hatenablog.jp/entry/2018/06/16/200549
            let formatter = DateFormatter()
            switch period {
            case .week:
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EE", options: 0, locale: Locale.current)
            case .month:
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d", options: 0, locale: Locale.current)
                break
            case .threeMonths:
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d", options: 0, locale: Locale.current)
                break
            case .year:
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM", options: 0, locale: Locale.current)
            case .day:
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "K", options: 0, locale: Locale.current)
            }
            dateFormatter = formatter
        }

        let dateStr = dateFormatter.string(from: date)
        // print(dateStr)
        return dateStr
    }
}

public class BarChartFormatter: IndexAxisValueFormatter {
    
    public var labels:[String]? = nil
    
    public override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if let labels = self.labels {
            if labels.count > Int(value) {
                return labels[Int(value)]
            }
        }
        return String(value)
        
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

//print(Date().startOfMonth())     // "2018-02-01 08:00:00 +0000\n"
//print(Date().endOfMonth())       // "2018-02-28 08:00:00 +0000\n"
