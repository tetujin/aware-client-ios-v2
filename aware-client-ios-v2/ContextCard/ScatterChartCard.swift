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
    
    var xAxisKey      = "timestamp";
    var xAxisLabels   = Array<String>();
    
    public typealias ScatterChartFilterHadler = (_ data:Dictionary<String, Any>) -> Bool
    var filterHandler:ScatterChartFilterHadler?
    
    override func setup() {
        super.setup()
        let chartHeight = frame.height - titleLabel.frame.height - spaceView.frame.height
        self.scatterChart = ScatterChartView.init(frame:CGRect(x:0, y:0,  width:0, height:chartHeight))
        
        if let sc = self.scatterChart{
            sc.isHidden = true
            self.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.spaceView.translatesAutoresizingMaskIntoConstraints = false
            self.baseStackView.insertArrangedSubview(sc, at: 1)

        }
    }
    
    public func setFilterHandler(_ handler:@escaping ScatterChartFilterHadler){
        self.filterHandler = handler
    }
    
    public func setChart(dataSets:[IChartDataSet], title:String){

        self.titleLabel.text = title

        let data = ScatterChartData(dataSets: dataSets )
        data.setValueFont(.systemFont(ofSize: 3, weight: .light))

        self.scatterChart?.data = data

    }

    public func setTodaysChart(sensor:AWARESensor, keys:Array<String>){

        activityIndicatorView.isHidden = false;
        self.titleLabel.text = sensor.getName()
        
        DispatchQueue.global().async {
            sensor.storage.fetchTodaysData(handler: { (name, results, start, end, error) in
                if let unwrappedResults = results as? Array<Dictionary<String, Any>>,
                    let unwrappedName = name{
                    DispatchQueue.main.async {
                        self.setChart(sensor, keys: keys, name: unwrappedName, results: unwrappedResults, start: start, end: end, error: error)
                    }
                }
            })
        }
    }
    
    public func setWeeklyChart(sensor:AWARESensor, keys:Array<String>){
        activityIndicatorView.isHidden = false
        self.titleLabel.text = sensor.getName()
        let now = Date()
        let weekAgo = now.addingTimeInterval(-1*60*60*24*7)
        DispatchQueue.global().async {
            sensor.storage.fetchDataBetweenStart(weekAgo, andEnd: now) { (name, results, start, end, error) in
                if let unwrappedResults = results as? Array<Dictionary<String, Any>>,
                    let unwrappedName = name{
                    DispatchQueue.main.async {
                        self.setChart(sensor, keys: keys, name: unwrappedName, results: unwrappedResults, start: start, end: end, error: error)
                    }
                }
            }
        }
    }
    
    public func setChart(_ sensor:AWARESensor, keys:Array<String>, name:String, results:Array<Dictionary<String, Any>>, start:Date?, end:Date?, error:Error?){
        // let results = sensor.storage.fetchTodaysData()
        var dataSets = Array<ScatterChartDataSet>()
        
        if self.needsComposite && keys.count > 1 {
            var data = Array<ChartDataEntry>()
            
            var keyName = "composit("
            for key in keys {
                keyName = keyName + " " + key;
            }
            keyName += ")"
            
            for result in results {
                var composedValue = 0.0
                for key in keys {
                    if let tempVal = result[key] as? Double{
                        composedValue += pow(tempVal, 2)
                    }
                }
                
                composedValue = sqrt(composedValue)
                data.append(ChartDataEntry(x:result[xAxisKey] as! Double, y:composedValue))
            }
            let set = ScatterChartDataSet(values: data, label: keyName)

            set.setScatterShape(scatterShape) //.square
            set.scatterShapeSize = scatterSize
            if let color = scatterColor{
                set.setColor(color)
            }else{
                set.setColor(ChartColorTemplates.colorful()[0])
            }
            dataSets.append(set)
        }else{
            for (index, key) in zip(results.indices, keys) {
                var data = Array<ChartDataEntry>()
                
                for result in results {
                    // filter the value if a handler exist
                    var isPassedFilter = true;
                    if let unwrappedFilterHadler = filterHandler {
                        isPassedFilter = unwrappedFilterHadler(result)
                    }
                    
                    if isPassedFilter{
                        if let value = result[key] as? Double {
                            data.append(ChartDataEntry(x:result["timestamp"] as! Double, y:value))
                        }else if let value = result[key] as? String {
                            if let doubleVal = Double(value){
                                data.append(ChartDataEntry(x:result["timestamp"] as! Double, y:doubleVal))
                            }
                        }
                    }
                }
                
                let set = ScatterChartDataSet(values: data, label: key)
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
            if let sc = self.scatterChart{
                
                sc.data = data
                sc.xAxis.axisMaximum = AWAREUtils.getUnixTimestamp(end)   as! Double
                sc.xAxis.axisMinimum = AWAREUtils.getUnixTimestamp(start) as! Double
                if let yMin = self.yAxisMin, let yMax = self.yAxisMax{
                    sc.leftAxis.axisMaximum = yMax
                    sc.leftAxis.axisMinimum = yMin
                }
                self.indicatorView.isHidden = true
                sc.isHidden = false
            
                // hide right label
                sc.rightAxis.drawLabelsEnabled = false
                
                // hide description text
                sc.chartDescription?.text = ""
                
                if self.xAxisLabels.count > 0 {
//                    let chartFormatter =  (labels: self.xAxisLabels)
//                    let xAxis = XAxis()
//                    xAxis.valueFormatter = chartFormatter
//                    self.xAxis.valueFormatter = xAxis.valueFormatter
////                     sc.xAxis.labelCount = Int(self.xAxisLabels.count)
                    sc.xAxis.valueFormatter = IndexAxisValueFormatter(values:self.xAxisLabels)
                    sc.xAxis.setLabelCount(self.xAxisLabels.count, force: true)
                    sc.xAxis.drawLabelsEnabled = true
                }else{
                    sc.xAxis.drawLabelsEnabled = false
                }

            }
        }
    }
}
