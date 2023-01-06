//
//  BarChartContextCardView.swift
//  Vita
//
//  Created by Yuuki Nishiyama on 2018/06/26.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework
import Charts

class BarChartCard: ContextCard {

    var barChart:BarChartView?
    
    public typealias BarChartFilterHadler = (_ data:Dictionary<String, Any>) -> Bool
    var filterHandler:BarChartFilterHadler?
    
    override func setup() {
        super.setup()
        let chartHeight = frame.height - titleLabel.frame.height - spaceView.frame.height
        self.barChart = BarChartView.init(frame:CGRect(x:0, y:0,  width:0, height:chartHeight))
        
        if let sc = self.barChart{
            sc.isHidden = true
            self.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.spaceView.translatesAutoresizingMaskIntoConstraints = false
            // insert the chart-view into the bottom of navigation-view
            self.baseStackView.insertArrangedSubview(sc, at: 2)
            
        }
    }
    
    public func setFilterHandler(_ handler:@escaping BarChartFilterHadler){
        self.filterHandler = handler
    }
    
    public func setTodaysChart(sensor:AWARESensor, keys:Array<String>){
        activityIndicatorView.isHidden = false;
        
        self.titleLabel.text = sensor.getName()
        
        sensor.storage?.fetchTodaysData(handler: { (name, result, start, end, error) in
            if let results = result as? Array<Dictionary<String, Any>>{
                self.setChart(sensor,
                              keys:  keys,
                              name:  name,
                              results: results,
                              start: start,
                              end:   end,
                              error: error)
            }
            
        })
    }
    
    public func setWeeklyChart(sensor:AWARESensor, keys:Array<String>){
        activityIndicatorView.isHidden = false
        self.titleLabel.text = sensor.getName()
        let now = Date()
        let weekAgo = now.addingTimeInterval(-1*60*60*24*7)
        sensor.storage?.fetchDataBetweenStart(weekAgo, andEnd: now) { (name, results, start, end, error) in
            if let unwrappedResults = results as? Array<Dictionary<String, Any>>{
                self.setChart(sensor, keys: keys, name: name, results: unwrappedResults, start: start, end: end, error: error)
            }
        }
    }
    

    
    public func setChart(_ sensor:AWARESensor, keys:Array<String>, name:String, results:Array<Dictionary<String, Any>>, start:Date?, end:Date?, error:Error?){
        let results = sensor.storage?.fetchTodaysData() as! Array<Dictionary<String, Any>>
        var datasets = Array< ChartDataSet>()
        var entries = Array<BarChartDataEntry>()
        
        for key in keys {
            for (index, result) in zip(results.indices, results) {

                // filter the value if a handler exist
                var isPassedFilter = true;
                if let unwrappedFilterHadler = filterHandler {
                    isPassedFilter = unwrappedFilterHadler(result)
                }
                
                if isPassedFilter{
                    if let value = result[key] as? Double {
                        // data.append(ChartDataEntry(x:result["timestamp"] as! Double, y:value))
                        // let value = result[key] as! Double
                        entries.append(BarChartDataEntry(x: Double(index), y:value))
                    }else if let value = result[key] as? String {
                        if let doubleVal = Double(value){
                            entries.append(BarChartDataEntry(x: Double(index), y:doubleVal))
                            // data.append(ChartDataEntry(x:result["timestamp"] as! Double, y:doubleVal))
                        }
                    }
                }
            }
            let set = BarChartDataSet(entries: entries, label: key)
            datasets.append(set)
        }
        let data:BarChartData = BarChartData(dataSets: datasets)
        
        DispatchQueue.main.async {
            
            // data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.6
            self.barChart?.data = data
            
            self.barChart?.isHidden = false
            self.indicatorView.isHidden = true
            
            self.barChart?.chartDescription.text = ""
            
            self.barChart?.xAxis.drawLabelsEnabled = false
            self.barChart?.xAxis.drawGridLinesEnabled = false
        }
    }
}
