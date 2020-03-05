//
//  SensorSettingViewController.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2019/03/04.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class SensorSettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    public var selectedContent:TableRowContent?
    
    public var settings = Array<SettingContent>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let content = selectedContent {
            self.title = content.title
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.settings = self.getSettings()
        self.tableView.reloadData()
        self.hideContextViewIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    
    
    func getSettings() -> Array<SettingContent> {
        var settings = Array<SettingContent>()
        if let content = selectedContent{
            switch content.identifier {
            case SENSOR_ACCELEROMETER:
                settings.append(SettingContent(type: .bool ,
                                               key: AWARE_PREFERENCES_STATUS_ACCELEROMETER,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int ,
                                               key: AWARE_PREFERENCES_FREQUENCY_ACCELEROMETER,
                                               defaultValue: "200000",
                                               detail: "200000 (normal), 60000 (UI), 20000 (game), 0 (fastest)."))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_HZ_ACCELEROMETER,
                                               defaultValue: "5"))
                settings.append(SettingContent(type: .double,
                                               key: AWARE_PREFERENCES_THRESHOLD_ACCELEROMETER,
                                               defaultValue: "0"))
                break
            case SENSOR_GYROSCOPE:
                settings.append(SettingContent(type: .bool ,
                                               key: AWARE_PREFERENCES_STATUS_GYROSCOPE,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int ,
                                               key: AWARE_PREFERENCES_FREQUENCY_GYROSCOPE,
                                               defaultValue: "200000",
                                               detail: "200000 (normal), 60000 (UI), 20000 (game), 0 (fastest)."))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_HZ_GYROSCOPE,
                                               defaultValue: "5"))
                break
            case SENSOR_MAGNETOMETER:
                settings.append(SettingContent(type: .bool ,
                                               key: AWARE_PREFERENCES_STATUS_MAGNETOMETER,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int ,
                                               key: AWARE_PREFERENCES_FREQUENCY_MAGNETOMETER,
                                               defaultValue: "200000",
                                               detail: "200000 (normal), 60000 (UI), 20000 (game), 0 (fastest)."))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_HZ_MAGNETOMETER,
                                               defaultValue: "5"))
                break
            case SENSOR_ROTATION:
                settings.append(SettingContent(type: .bool ,
                                               key: AWARE_PREFERENCES_STATUS_ROTATION,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int ,
                                               key: AWARE_PREFERENCES_FREQUENCY_ROTATION,
                                               defaultValue: "200000",
                                               detail: "200000 (normal), 60000 (UI), 20000 (game), 0 (fastest)."))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_HZ_ROTATION,
                                               defaultValue: "5"))
                break
            case SENSOR_LINEAR_ACCELEROMETER:
                settings.append(SettingContent(type: .bool ,
                                               key: AWARE_PREFERENCES_STATUS_LINEAR_ACCELEROMETER,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int ,
                                               key: AWARE_PREFERENCES_FREQUENCY_LINEAR_ACCELEROMETER,
                                               defaultValue: "200000",
                                               detail: "200000 (normal), 60000 (UI), 20000 (game), 0 (fastest)."))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_HZ_LINEAR_ACCELEROMETER,
                                               defaultValue: "5"))
                break
            case SENSOR_IOS_ACTIVITY_RECOGNITION:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_IOS_ACTIVITY_RECOGNITION,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_IOS_ACTIVITY_RECOGNITION,
                                               defaultValue: "300"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PREPERIOD_DAYS_IOS_ACTIVITY_RECOGNITION,
                                               defaultValue: "0"))
                break
            case SENSOR_PLUGIN_PEDOMETER:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_PEDOMETER,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_PEDOMETER,
                                               defaultValue: "180"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PREPERIOD_DAYS_PEDOMETER,
                                               defaultValue: "0"))
                break
            case SENSOR_LOCATIONS:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_LOCATION_GPS,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_GPS,
                                               defaultValue: "180"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_MIN_GPS_ACCURACY,
                                               defaultValue: "300"))
                break
            case SENSOR_BAROMETER:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_BAROMETER,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_BAROMETER,
                                               defaultValue: "1000000", detail: "microsecond"))
                break
            case SENSOR_BATTERY:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_BATTERY,
                                               defaultValue: "false"))
                break
            case SENSOR_NETWORK:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_NETWORK_EVENTS,
                                               defaultValue: "false"))
                break
            case SENSOR_CALLS:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_CALLS,
                                               defaultValue: "false"))
                break
            case SENSOR_BLUETOOTH:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_BLUETOOTH,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_BLUETOOTH,
                                               defaultValue: "300"))
                break
            case SENSOR_PROCESSOR:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_PROCESSOR,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_PROCESSOR,
                                               defaultValue: "2000000"))
                break
            case SENSOR_TIMEZONE:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_TIMEZONE,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_TIMEZONE,
                                               defaultValue: "300"))
                break
            case SENSOR_WIFI:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_WIFI,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_WIFI,
                                               defaultValue: "300"))
                break
            case SENSOR_SCREEN:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_SCREEN,
                                               defaultValue: "false"))
                break
            case SENSOR_AMBIENT_NOISE:
                settings.append(SettingContent(type: .bool,
                                              key: AWARE_PREFERENCES_STATUS_PLUGIN_AMBIENT_NOISE,
                                              defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_PLUGIN_AMBIENT_NOISE,
                                               defaultValue: "5",
                                               detail: "How frequently do we sample the microphone (default = 5) in minutes"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PLUGIN_AMBIENT_NOISE_SAMPLE_SIZE,
                                               defaultValue: "30",
                                               detail: "For how long we listen (default = 30) in seconds"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PLUGIN_AMBIENT_NOISE_SILENCE_THRESHOLD,
                                               defaultValue: "50",
                                               detail: "Silence threshold (default = 50) in dB "))
                break
            case SENSOR_PLUGIN_BLE_HR:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_BLE_HR,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PLUGIN_BLE_HR_INTERVAL_TIME_MIN,
                                               defaultValue: "5"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PLUGIN_BLE_HR_ACTIVE_TIME_SEC,
                                               defaultValue: "30"))
                break
            case SENSOR_PLUGIN_CALENDAR:
                settings.append(SettingContent(type: .bool,
                                               key: "status_plugin_calendar",
                                               defaultValue: "false"))
                break
            case SENSOR_PLUGIN_CONTACTS:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_CONTACTS,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: KEY_PLUGIN_SETTING_CONTACTS_UPDATE_FREQUENCY_DAY,
                                               defaultValue: "1"))
                break
            case SENSOR_PLUGIN_FITBIT:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_FITBIT,
                                               defaultValue: "false"))
                break
            case SENSOR_PLUGIN_GOOGLE_LOGIN:
                settings.append(SettingContent(type: .bool,
                                               key: STATUS_SENSOR_PLUGIN_GOOGLE_LOGIN,
                                               defaultValue: "false"))
                break
            case SENSOR_PLUGIN_NTPTIME:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_NTPTIME,
                                               defaultValue: "false"))
                break
            case SENSOR_PLUGIN_OPEN_WEATHER:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_OPENWEATHER,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .string,
                                               key: AWARE_PREFERENCES_OPENWEATHER_API_KEY))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_OPENWEATHER_FREQUENCY,
                                               defaultValue: "60"))
                break
            case SENSOR_PLUGIN_STUDENTLIFE_AUDIO:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_CONVERSATION,
                                               defaultValue: "false"))
                break
            case SENSOR_PLUGIN_IOS_ESM:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_PLUGIN_IOS_ESM,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .string,
                                               key: AWARE_PREFERENCES_PLUGIN_IOS_ESM_CONFIG_URL,
                                               defaultValue: ""))
                break
            case SENSOR_GOOGLE_FUSED_LOCATION:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_GOOGLE_FUSED_LOCATION,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .items,
                                               key: AWARE_PREFERENCES_ACCURACY_GOOGLE_FUSED_LOCATION,
                                               defaultValue: "102",
                                               items: ["100","102","104","105"],
                                               detail: "* 100 (high power): uses GPS only - works best outdoors, highest accuracy\n* 102 (balanced): uses GPS, Network and Wifi - works both indoors and outdoors, good accuracy (default) \n* 104 (low power): uses only Network and WiFi - poorest accuracy, medium accuracy \n* 105 (no power) - scavenges location requests from other apps"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_FREQUENCY_GOOGLE_FUSED_LOCATION,
                                               defaultValue: "180"))
                break
            case SENSOR_HEALTH_KIT:
                settings.append(SettingContent(type: .bool,
                                               key: STATUS_SENSOR_HEALTH_KIT,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PLUGIN_HEALTHKIT_FREQUENCY,
                                               defaultValue: "1800"))
                settings.append(SettingContent(type: .int,
                                               key: AWARE_PREFERENCES_PLUGIN_HEALTHKIT_PREPERIOD_DAYS,
                                               defaultValue: "0"))
                break
            case SENSOR_PLUGIN_CALENDAR_ESM_SCHEDULER:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_CALENDAR_ESM,
                                               defaultValue: "false"))
                break
            case SENSOR_PLUGIN_DEVICE_USAGE:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_DEVICE_USAGE,
                                               defaultValue: "false"))
                break
            case SENSOR_SIGNIFICANT_MOTION:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_SIGNIFICANT_MOTION,
                                               defaultValue: "false"))
            case SENSOR_PUSH_NOTIFICATION:
                settings.append(SettingContent(type: .bool,
                                               key: AWARE_PREFERENCES_STATUS_PUSH_NOTIFICATION,
                                               defaultValue: "false"))
                settings.append(SettingContent(type: .string,
                                               key: AWARE_PREFERENCES_SERVER_PUSH_NOTIFICATION,
                                               defaultValue: ""))
            default:
                break
            }

        }
        return settings
    }
}

extension SensorSettingViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension SensorSettingViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = self.settings[indexPath.row]
        let alert = UIAlertController(title: content.key, message: content.detail, preferredStyle: .alert)
        switch content.type {
        case .double, .int, .string:
            alert.addTextField(configurationHandler: { textField in
                textField.clearButtonMode = .whileEditing
                textField.placeholder = content.defaultValue
                textField.text = content.currentValue
                textField.keyboardType = UIKeyboardType.numbersAndPunctuation
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { (action) in
                if let textFields = alert.textFields {
                    if textFields.count > 0 {
                        if let textField = textFields.first {
                            if let text = textField.text{
                                let study = AWAREStudy.shared()
                                study.setSetting(content.key, value: text as NSObject)
                                self.restartAllSensors()
                            }
                        }
                    }
                }
            }))
            break
        case .items:
            if let items = content.items {
                for item in items {
                    alert.addAction(UIAlertAction(title: item, style: .default, handler: { (action) in
                        AWAREStudy.shared().setSetting(content.key, value: item as NSObject)
                        self.restartAllSensors()
                    }))
                }
            }
            break
        case .bool:
            let items = ["true", "false"]
            for item in items {
                alert.addAction(UIAlertAction(title: item, style: .default, handler: { (action) in
                    if action.title == "true" {
                        AWAREStudy.shared().setSetting(content.key, value: true as NSObject)
                    }else{
                        AWAREStudy.shared().setSetting(content.key, value: false as NSObject)
                    }
                    self.restartAllSensorsWithPermissionRequest()
                }))
            }
            break
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true) {}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1 , reuseIdentifier: "cell")
        let setting = settings[indexPath.row]
        cell.textLabel?.text = setting.key
        if setting.currentValue != nil && setting.currentValue != ""{
            cell.detailTextLabel?.text = setting.currentValue
        }else{
            cell.detailTextLabel?.text = setting.defaultValue
        }
        return cell
    }
    
    func restartAllSensorsWithPermissionRequest(){
        self.tableView.reloadData()
        AWARECore.shared().requestPermissionForBackgroundSensing { (locationStatus) in
            AWARECore.shared().requestPermissionForPushNotification { (notificationState, error) in
                self.restartAllSensors()
                AWARECore.shared().checkCompliance(with: self, showDetail: true)
            }
        }
    }
    
    func restartAllSensors(){
        AWARECore.shared().activate()
        let manager = AWARESensorManager.shared()
        manager.stopAndRemoveAllSensors()
        manager.addSensors(with: AWAREStudy.shared())
        manager.add([AWAREEventLogger.shared(),AWAREStatusMonitor.shared()])
        manager.createDBTablesOnAwareServer()
        if let fitbit = manager.getSensor(SENSOR_PLUGIN_FITBIT) as? Fitbit {
            fitbit.viewController = self
        }
        manager.startAllSensors()
        
        self.settings = self.getSettings()
        self.tableView.reloadData()
    }
}

struct SettingContent {
    let type:SettingType
    let defaultValue:String?
    let key:String
    let items:Array<String>?
    let title:String?
    let detail:String?
    var currentValue:String?
    
    init(type:SettingType,
         key:String,
         defaultValue:String? = nil,
         items:Array<String>? = nil,
         title:String?=nil,
         detail:String? = nil) {
        self.type = type
        self.key = key
        self.defaultValue = defaultValue
        self.items = items
        self.title = title
        self.detail = detail
        let study = AWAREStudy.shared()
        self.currentValue = study.getSetting(self.key)
    }
}

enum SettingType {
    case int
    case double
    case string
    case items
    case bool
}
