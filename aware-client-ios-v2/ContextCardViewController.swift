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
        setupContextCards()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForegroundNotification(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
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
                    self.tabBarController?.selectedIndex = 2
                }
            }
        }
    }
    
    func removeAllContextCards(){
        for card in contextCards {
            self.mainStackView.removeArrangedSubview(card)
        }
        contextCards.removeAll()
    }
    
    func setupContextCards(){
        addBatteryCard()
        addBarometerCard()
        addAmbientNoiseCard()
        addActivityRecognitionCard()
        addOpenWeatherChart()
        addAccelereomterCard()
        addGyroscopeCard()
        addScreenEventCard()
        addLocationCard()
    }
    
    @IBAction func didPushReloadButton(_ sender: UIBarButtonItem) {
        removeAllContextCards()
        setupContextCards()
    }
    
    func addAccelereomterCard(){
        if let sensor = AWARESensorManager.shared().getSensor(SENSOR_ACCELEROMETER) {
            let contextCard = ScatterChartCard.init(frame: CGRect.init(x:0, y:0, width: self.view.frame.width, height:250))
            contextCard.yAxisMax = 6;
            contextCard.yAxisMin = -6;
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
