//
//  ScatterContextCardView.swift
//  Vita
//
//  Created by Yuuki Nishiyama on 2018/06/23.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import Charts
import AWAREFramework

class ScatterChartCard: ContextCard {

    var scatterChart:ScatterChartView?
    
    var xAxisMin:Double?
    var xAxisMax:Double?
    var yAxisMin:Double?
    var yAxisMax:Double?
    
    var scatterShape:ScatterChartDataSet.Shape = .circle
    var scatterSize:CGFloat    = 3
    var scatterColor:UIColor?
    
    var needsComposite = false
    var granularitySecond:Double = 0
    
    var xAxisKey      = "timestamp";
    var xAxisLabels   = Array<String>()
    
    var sensor:AWARESensor?
    var yKeys:Array<String>?
    
    public typealias ScatterChartFilterHadler = (_ key:String, _ data:Dictionary<String, Any>) -> Dictionary<String,Any>?
    var filterHandler:ScatterChartFilterHadler?
    
    override func setup() {
        super.setup()
        let chartHeight = frame.height - titleLabel.frame.height - spaceView.frame.height
        self.scatterChart = ScatterChartView(frame:CGRect(x:0, y:0,  width:0, height:chartHeight))
        
        if let sc = self.scatterChart{
            sc.isHidden = true
            self.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.spaceView.translatesAutoresizingMaskIntoConstraints = false
            /// insert the chart-view into the bottom of navigation-view
            self.baseStackView.insertArrangedSubview(sc, at: 2)
        }
        
        self.backwardHandler = {
            let targetDateTime = self.currentDate.addingTimeInterval(-1*24*60*60)
            self.setTitleToNavigationView(with: targetDateTime)
            let fromDate:Date = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: false)
            let toDate:Date   = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: true)
            if let sensor = self.sensor, let yKeys = self.yKeys{
                self.setScatterChart(sensor:sensor, from:fromDate, to:toDate, xKey:self.xAxisKey, yKeys:yKeys)
            }
        }
        
        self.forwardHandler = {
            let targetDateTime = self.currentDate.addingTimeInterval(24*60*60)
            self.setTitleToNavigationView(with: targetDateTime)
            let fromDate:Date = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: false)
            let toDate:Date   = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: true)
            if let sensor = self.sensor, let yKeys = self.yKeys {
                self.setScatterChart(sensor:sensor, from:fromDate, to:toDate, xKey:self.xAxisKey, yKeys:yKeys)
            }
        }
    }
    
    func setScatterChart(sensor:AWARESensor, from fromDate:Date, to toDate:Date, xKey:String="timestamp", yKeys:Array<String>){
        
        self.scatterChart?.scatterData?.clearValues()
        DispatchQueue.global().async {
            sensor.storage?.fetchData(from: fromDate, to: toDate, handler: { (name, result, start, end, error) in
                if let unwrappedResults = result as? Array<Dictionary<String, Any>>{
                    self.setChart(sensor,
                                  xKey: xKey,
                                  yKeys: yKeys,
                                  name: name,
                                  results: unwrappedResults,
                                  start:   start, end: end, error: error)
                }
            })
        }
    }
    
    public func setFilterHandler(_ handler:@escaping ScatterChartFilterHadler){
        self.filterHandler = handler
    }
    
    public func setChart(dataSets:[ChartDataSet], title:String){

        self.titleLabel.text = title

        let data = ScatterChartData(dataSets: dataSets )
        data.setValueFont(.systemFont(ofSize: 3, weight: .light))

        self.scatterChart?.data = data
        self.scatterChart?.isUserInteractionEnabled = false

    }

    public func setTodaysChart(sensor:AWARESensor, xKey:String="timestamp", yKeys:Array<String>){
        self.sensor = sensor
        
        activityIndicatorView.isHidden = false;
        self.titleLabel.text = sensor.getName()
        
        DispatchQueue.global().async {
            sensor.storage?.fetchTodaysData(handler: { (name, results, start, end, error) in
                if let unwrappedResults = results as? Array<Dictionary<String, Any>>{
                    self.setChart(sensor,
                                  xKey: xKey,
                                  yKeys: yKeys,
                                  name: name,
                                  results: unwrappedResults,
                                  start:   start, end: end, error: error)
                }
            })
        }
    }
    
    public func setWeeklyChart(sensor:AWARESensor, xKey:String="timestamp", yKeys:Array<String>){
        activityIndicatorView.isHidden = false
        self.titleLabel.text = sensor.getName()
        let now = Date()
        let weekAgo = now.addingTimeInterval(-1*60*60*24*7)
        //DispatchQueue.global().async {
        sensor.storage?.fetchDataBetweenStart(weekAgo, andEnd: now) { (name, results, start, end, error) in
            if let unwrappedResults = results as? Array<Dictionary<String, Any>>{
                self.setChart(sensor, xKey: xKey, yKeys: yKeys, name: name, results: unwrappedResults, start: start, end: end, error: error)
            }
        }
        //}
    }
    
    public func setChart(_ sensor:AWARESensor, xKey:String="timestamp", yKeys:Array<String>, name:String, results:Array<Dictionary<String, Any>>, start:Date?, end:Date?, error:Error?){
        // let results = sensor.storage.fetchTodaysData()
        
        self.yKeys = yKeys
        self.xAxisKey = xKey
        
        var dataSets = Array<ScatterChartDataSet>()
        
        if self.needsComposite && yKeys.count > 1 {
            var data = Array<ChartDataEntry>()
            
            var keyName = "composit("
            for key in yKeys {
                keyName = keyName + " " + key;
            }
            keyName += ")"
            
            for result in results {
                var composedValue = 0.0
                for key in yKeys {
                    if let tempVal = result[key] as? Double{
                        composedValue += pow(tempVal, 2)
                    }
                }
                
                composedValue = sqrt(composedValue)
                data.append(ChartDataEntry(x:result[xAxisKey] as! Double, y:composedValue))
            }
            
            // data.sort(by: { $0.x < $1.x })
            
            let set = ScatterChartDataSet(entries: data, label: keyName)

            set.setScatterShape(scatterShape) //.square
            set.scatterShapeSize = scatterSize
            if let color = scatterColor{
                set.setColor(color)
            }else{
                set.setColor(ChartColorTemplates.colorful()[0])
            }
            dataSets.append(set)
        }else{
            for (index, key) in zip(results.indices, yKeys) {
                var data = Array<ChartDataEntry>()
                
                var lastTimestamp:Double  = 0
                
                for result in results {
                    // filter the value if a handler exist
                    var fliteredData:Dictionary<String,Any>? = result;
                    if let unwrappedFilterHadler = filterHandler {
                        fliteredData = unwrappedFilterHadler(key, result)
                    }
                    
                    if let fd = fliteredData{
                        if let value = fd[key] as? Double, let timestamp = fd[xKey] as? Double {
                            if granularitySecond > 0 {
                                if let timestamp = fd[xKey] as? Double {
                                    if timestamp > lastTimestamp + granularitySecond * 1000.0 {
                                        lastTimestamp = timestamp
                                        data.append(ChartDataEntry(x:timestamp, y:value))
                                    }
                                }
                            }else{
                                data.append(ChartDataEntry(x:timestamp, y:value))
                            }
                        }else if let value = fd[key] as? String, let timestamp = fd[xKey] as? Double  {
                            if let doubleVal = Double(value){
                                data.append(ChartDataEntry(x:timestamp, y:doubleVal))
                            }
                        }
                    }
                }
                
                data.sort(by: { $0.x < $1.x })
                
                let set = ScatterChartDataSet(entries: data, label: key)
                set.setScatterShape(scatterShape) //.square
                set.scatterShapeSize = scatterSize
                if let color = scatterColor{
                    set.setColor(color)
                }else{
                    set.setColor(ChartColorTemplates.colorful()[index])
                }
                dataSets.append(set)
            }
        }
        
        let data = ScatterChartData(dataSets: dataSets)
        data.setValueFont(.systemFont(ofSize: 3, weight: .light))
        
        DispatchQueue.main.async {
            if let chart = self.scatterChart{
                chart.data = data
                chart.xAxis.axisMaximum = AWAREUtils.getUnixTimestamp(end)   as! Double
                chart.xAxis.axisMinimum = AWAREUtils.getUnixTimestamp(start) as! Double
                if let yMin = self.yAxisMin, let yMax = self.yAxisMax{
                    chart.leftAxis.axisMaximum = yMax
                    chart.leftAxis.axisMinimum = yMin
                }
                
                // set x-axis format
                let formatter = DateFormatter()
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
                let format = ChartFormatter()
                format.dateFormatter = formatter
                chart.xAxis.valueFormatter = format
                
                // hide the indicator view
                self.indicatorView.isHidden = true
                chart.isHidden = false
                
                // hide right label
                chart.rightAxis.drawLabelsEnabled = false
                
                // hide description text
                chart.chartDescription.text = ""
                
                chart.xAxis.labelPosition = .bottom
                chart.xAxis.setLabelCount(5, force: true)
                chart.xAxis.drawLabelsEnabled = true
                
                if #available(iOS 13.0, *) {
                    chart.leftAxis.labelTextColor = UIColor.label
                    chart.xAxis.labelTextColor = UIColor.label
                    chart.legend.textColor = UIColor.label
                }
            }
        }
    }
}
