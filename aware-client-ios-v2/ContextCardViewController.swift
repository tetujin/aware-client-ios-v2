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
    
    
    @objc func willEnterForegroundNotification(notification: NSNotification) {
        let esmManager = ESMScheduleManager.shared()
        let schedules = esmManager.getValidSchedules()
        if let unwrappedSchedules = schedules {
            if(unwrappedSchedules.count > 0){
                if !IOSESM.hasESMAppearedInThisSession(){
                    self.tabBarController?.selectedIndex = 0
                }
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
                                 SENSOR_LOCATIONS]
    
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
            contextCard.setTodaysChart(sensor: sensor, keys: ["double_values_0","double_values_1","double_values_2"])
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
            contextCard.setTodaysChart(sensor: sensor, keys: ["double_values_0","double_values_1","double_values_2"])
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
            contextCard.setTodaysChart(sensor: sensor, keys: ["battery_level"])
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
            contextCard.setTodaysChart(sensor: sensor, keys: ["double_values_0"])
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
            contextCard.setTodaysChart(sensor: sensor, keys: ["screen_status"])
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
            contextCard.setTodaysChart(sensor: sensor, keys: ["stationary","walking","running","automotive","cycling"])
            contextCard.titleLabel.text = "Activity Recognition"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addAmbientNoiseCard() {
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_AMBIENT_NOISE) {
            let contextCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.setTodaysChart(sensor: sensor, keys: ["double_rms"])
            contextCard.titleLabel.text = "Ambient Noise"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addOpenWeatherChart(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_PLUGIN_OPEN_WEATHER) {
            let contextCard = ScatterChartCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:250))
            contextCard.xAxisLabels = ["0","6","12","18","24"];
            contextCard.setTodaysChart(sensor: sensor, keys: ["temperature_min","temperature","temperature_max"])
            contextCard.titleLabel.text = "Temperature"
            contextCard.isUserInteractionEnabled = false
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
    }
    
    func addLocationCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_GOOGLE_FUSED_LOCATION) {
            let contextCard = MapCard(frame: CGRect.init(x:0,y:0, width: self.view.frame.width, height:400))
            contextCard.setMap(sensor: sensor as! FusedLocations )
            contextCard.titleLabel.text = "Location"
            self.contextCards.append(contextCard)
            self.mainStackView.addArrangedSubview(contextCard)
        }
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
