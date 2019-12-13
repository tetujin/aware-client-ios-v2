//
//  ContextCardViewController.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2019/02/27.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class ContextCardViewController: UIViewController {

    @IBOutlet weak var mainStackView: UIStackView!
    var contextCards = Array<ContextCard>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForegroundNotification(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        if contextCards.count == 0 {
            setupContextCards()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        if AWAREUtils.isBackground() {
            self.removeAllContextCards()
        }
    }
    
    
    @objc func willEnterForegroundNotification(notification: NSNotification) {
        let esmManager = ESMScheduleManager.shared()
        let schedules = esmManager.getValidSchedules()
        if(schedules.count > 0){
            if !IOSESM.hasESMAppearedInThisSession(){
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    func removeAllContextCards(){
        for card in contextCards {
            card.baseStackView.isHidden = true
            self.mainStackView.removeArrangedSubview(card)
        }
        contextCards.removeAll()
    }
    
    func setupContextCards(){
        self.removeAllContextCards()
        for name in getCurrentContextCardNames() {
            switch name {
            case SENSOR_ACCELEROMETER:
                addAccelereomterCard()
                break
            case SENSOR_GYROSCOPE:
                addGyroscopeCard()
                break
            case SENSOR_BATTERY:
                addBatteryCard()
                break
            case SENSOR_AMBIENT_NOISE:
                addAmbientNoiseCard()
                break
            case SENSOR_BAROMETER:
                addBarometerCard()
                break
            case SENSOR_IOS_ACTIVITY_RECOGNITION:
                addActivityRecognitionCard()
                break
            case SENSOR_PLUGIN_OPEN_WEATHER:
                addOpenWeatherChart()
                break
            case SENSOR_SCREEN:
                addScreenEventCard()
                break
            case SENSOR_LOCATIONS:
                addLocationCard()
                break
            case SENSOR_PLUGIN_PEDOMETER:
                addPedometerCard()
                break
            case SENSOR_HEALTH_KIT:
                addHealthKitCard()
                break
            case SENSOR_PLUGIN_DEVICE_USAGE:
                addDeviceUsageCard()
                break
            case SENSOR_SIGNIFICANT_MOTION:
                addSignificantMotionCard()
            default:
                break
            }
        }
    }
    
    var possibleContextCards = [SENSOR_BATTERY,
                                 SENSOR_BAROMETER,
                                 SENSOR_AMBIENT_NOISE,
                                 SENSOR_IOS_ACTIVITY_RECOGNITION,
                                 SENSOR_PLUGIN_OPEN_WEATHER,
                                 SENSOR_ACCELEROMETER,
                                 SENSOR_GYROSCOPE, SENSOR_SCREEN,
                                 SENSOR_LOCATIONS,
                                 SENSOR_PLUGIN_PEDOMETER,
                                 SENSOR_HEALTH_KIT,
                                 SENSOR_PLUGIN_DEVICE_USAGE,
                                 SENSOR_SIGNIFICANT_MOTION]
    
    let key = "com.yuukinishiyama.app.aware-client-ios-v2.context-cards"
    
    func setContextCard(name:String){
        if var unwrappedCards = UserDefaults.standard.stringArray(forKey: key) {
            for c in unwrappedCards {
                if c == name {
                    return
                }
            }
            unwrappedCards.append(name)
            UserDefaults.standard.set(unwrappedCards, forKey: key)
            UserDefaults.standard.synchronize()
        }else{
            UserDefaults.standard.set([name], forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    func removeContextCard(name:String){
        if var unwrappedCards = UserDefaults.standard.stringArray(forKey: key) {
            unwrappedCards.removeAll { (string) -> Bool in
                if string == name {
                    return true
                }
                return false
            }
            UserDefaults.standard.set(unwrappedCards, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getCurrentContextCardNames() -> [String] {
        if let unwrappedCards = UserDefaults.standard.stringArray(forKey: key) {
            return unwrappedCards
        }else{
            return Array<String>()
        }
    }
    
    @IBAction func didPushReloadButton(_ sender: UIBarButtonItem) {
        setupContextCards()
    }
    
    @IBAction func didPushAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Which context-card do you add?",
                                      message: "Please select a context-card from the following items.",
                                      preferredStyle: .alert)
        for item in possibleContextCards {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { (action) in
                self.setContextCard(name: item)
                self.setupContextCards()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didPushRemoveButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Which context-card do you remove?",
                                      message: "Please select a context-card from the following items.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Remove All", style: .destructive, handler: { (action) in
            UserDefaults.standard.removeObject(forKey: self.key)
            UserDefaults.standard.synchronize()
            
            self.setupContextCards()
        }))
        
        for item in getCurrentContextCardNames() {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { (action) in
                self.removeContextCard(name: item)
                self.setupContextCards()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func addAccelereomterCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_ACCELEROMETER) {
            let contextCard = ScatterChartCard.init(frame: CGRect.init(x:0, y:0, width: self.view.frame.width, height:250))
            contextCard.yAxisMax = 6
            contextCard.yAxisMin = -6
            contextCard.granularitySecond = 10
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["double_values_0","double_values_1","double_values_2"])
            contextCard.titleLabel.text = "Accelerometer"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addGyroscopeCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_GYROSCOPE) {
            let contextCard = ScatterChartCard.init(frame: CGRect.init(x:0, y:0, width: self.view.frame.width, height:250))
            contextCard.yAxisMax = 6;
            contextCard.yAxisMin = -6;
            contextCard.granularitySecond = 10
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["double_values_0","double_values_1","double_values_2"])
            contextCard.titleLabel.text = "Gyroscope"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addBatteryCard(){
        
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_BATTERY) {
            let contextCard = ScatterChartCard.init(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.yAxisMax = 105;
            contextCard.yAxisMin = 0;
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["battery_level"])
            contextCard.titleLabel.text = "Battery Level"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addBarometerCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_BAROMETER) {
            let contextCard = ScatterChartCard.init(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            //contextCard.yAxisMax = 1300;
            //contextCard.yAxisMin = 800;
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["double_values_0"])
            contextCard.titleLabel.text = "Air Pressure"
            contextCard.granularitySecond = 60
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addScreenEventCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_SCREEN){
            let contextCard = ScatterChartCard.init(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["screen_status"])
            contextCard.titleLabel.text = "Screen"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addActivityRecognitionCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_IOS_ACTIVITY_RECOGNITION) {
            let contextCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.yAxisMax = 1.1
            contextCard.yAxisMin = 0.9
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["stationary","walking","running","automotive","cycling"])
            contextCard.titleLabel.text = "Activity Recognition"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addAmbientNoiseCard() {
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_AMBIENT_NOISE) {
            // double_rms
            let rmsCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            rmsCard.setTodaysChart(sensor: sensor, yKeys: ["double_rms"])
            rmsCard.titleLabel.text = "Ambient Noise | RMS"
            rmsCard.isUserInteractionEnabled = false
            self.contextCards.append(rmsCard)
            self.mainStackView.addArrangedSubview(rmsCard)
            
            // double_decibels
            let dbCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            dbCard.setTodaysChart(sensor: sensor, yKeys: ["double_decibels"])
            dbCard.titleLabel.text = "Ambient Noise | Decibel"
            dbCard.isUserInteractionEnabled = false
            self.contextCards.append(dbCard)
            self.mainStackView.addArrangedSubview(dbCard)
            
            // double_frequency
            let frequencyCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            frequencyCard.setTodaysChart(sensor: sensor, yKeys: ["double_frequency"])
            frequencyCard.titleLabel.text = "Ambient Noise | Frequency"
            frequencyCard.isUserInteractionEnabled = false
            self.contextCards.append(frequencyCard)
            self.mainStackView.addArrangedSubview(frequencyCard)
        }
    }
    
    func addOpenWeatherChart(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_PLUGIN_OPEN_WEATHER) {
            let contextCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.xAxisLabels = ["0","6","12","18","24"];
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["temperature_min","temperature","temperature_max"])
            contextCard.titleLabel.text = "Temperature"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }

    func addDeviceUsageCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_PLUGIN_DEVICE_USAGE) {
            let contextCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.xAxisLabels = ["0","6","12","18","24"];
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["elapsed_device_on"])
            contextCard.titleLabel.text = "Device Usage"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addPedometerCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_PLUGIN_PEDOMETER) {
            // let contextCard = BarChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            let contextCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.xAxisLabels = ["0","6","12","18","24"]
            contextCard.yAxisMin = 0
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["number_of_steps"])
            contextCard.titleLabel.text = "Pedometer"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addSignificantMotionCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_SIGNIFICANT_MOTION) {
            let contextCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.xAxisLabels = ["0","6","12","18","24"];
            contextCard.setTodaysChart(sensor: sensor, yKeys: ["is_moving"])
            contextCard.titleLabel.text = "Significant Motion"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addHealthKitCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_HEALTH_KIT) as? AWAREHealthKit{
            // HKQuantityTypeIdentifierHeartRate
            let quantity = sensor.awareHKHeartRate
            let contextCard = ScatterChartCard(frame: CGRect(x:0, y:0,
                                                             width: self.view.frame.width,
                                                             height:250))
            contextCard.xAxisLabels = ["0","6","12","18","24"];
            contextCard.setTodaysChart(sensor: quantity, xKey:"timestamp_start", yKeys: ["value"])
            contextCard.titleLabel.text = "Heart Rate"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
            
//          HKQuantityTypeIdentifierActiveEnergyBurned
//          HKQuantityTypeIdentifierStepCount
//          HKQuantityTypeIdentifierDistanceWalkingRunning
//          HKQuantityTypeIdentifierBasalEnergyBurned
            
        }
    }
    
    func addLocationCard(){
        
        if let fusedLocationSensor = AWARESensorManager.shared().getSensor(SENSOR_GOOGLE_FUSED_LOCATION) as? FusedLocations{
            let contextCard = MapCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:400))
            contextCard.setMap(locationSensor: fusedLocationSensor.locationSensor)
            contextCard.titleLabel.text = "Location"
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
        
        if let locationSensor = AWARESensorManager.shared().getSensor(SENSOR_LOCATIONS) as? Locations{
            let contextCard = MapCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:400))
            contextCard.setMap(locationSensor: locationSensor)
            contextCard.titleLabel.text = "Location"
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }

}
