//
//  ViewController.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2019/02/27.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let sensorManager = AWARESensorManager.shared()
    
    var refreshTimer:Timer?
    var refreshInterval = 0.5
    
    var googleLoginRequestObserver:NSObjectProtocol?
    var contactUpdateRequestObserver:NSObjectProtocol?
    
    var selectedRowContent:TableRowContent?
    
    @IBOutlet weak var uploadButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        AWARECore.shared().checkCompliance(with: self, showDetail: true)
        
        settings = getSettings()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true, block: { (timer) in
            self.tableView.reloadData()
        })
        
        googleLoginRequestObserver = NotificationCenter.default.addObserver(forName: Notification.Name(ACTION_AWARE_GOOGLE_LOGIN_REQUEST),
                                               object: nil, queue: .main) { (notification) in
                                                self.login()
        }
        self.login()
        
        contactUpdateRequestObserver = NotificationCenter.default.addObserver(forName: Notification.Name(ACTION_AWARE_CONTACT_REQUEST),
                                               object: nil, queue: .main) { (notification) in
                                                
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.checkESMSchedules()
        
        if AWAREStudy.shared().getURL() != "" {
            uploadButton.tintColor = UIColor.system
        }else{
            uploadButton.tintColor = UIColor(white: 0, alpha: 0)
        }
        
        self.hideContextViewIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        refreshTimer?.invalidate()
        refreshTimer = nil
        NotificationCenter.default.removeObserver(googleLoginRequestObserver as Any)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func willEnterForegroundNotification(notification: NSNotification) {
        self.checkESMSchedules()
        if refreshTimer == nil {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true, block: { (timer) in
                self.tableView.reloadData()
            })
        }
    }
    
    @objc func didEnterBackgroundNotification(notification: NSNotification){
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func checkESMSchedules(){
        let esmManager = ESMScheduleManager.shared()
        let schedules = esmManager.getValidSchedules()
        if(schedules.count > 0){
            if !IOSESM.hasESMAppearedInThisSession(){
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    func login(){
        let glogin = AWARESensorManager.shared().getSensor(SENSOR_PLUGIN_GOOGLE_LOGIN)
        if let login = glogin as? GoogleLogin{
            if login.isNeedLogin(){
                let loginViewController = AWAREGoogleLoginViewController()
                loginViewController.googleLogin = login
                self.present(loginViewController, animated: true, completion: {
                    
                })
            }
        }
    }
    
    /// This method will be called when move to another UIViewController by segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let next = segue.destination as? SensorSettingViewController,
           let content = self.selectedRowContent {
            next.selectedContent = content            
        }
    
    }

    
    @IBAction func didPushUploadButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Do you upload stored sensor data manually?",
                                    message: "This upload process is executed without WiFi connection and battery charging. Please check these conditions again.",
                                    preferredStyle: .alert)
        let execute = UIAlertAction.init(title: "Execute", style: .default) { (action) in
            self.startManualUpload()
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(execute)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didPushRefreshButton(_ sender: UIBarButtonItem) {
        let study = AWAREStudy.shared()
        let manager = AWARESensorManager.shared()
        
        manager.stopAndRemoveAllSensors()
        if study.getURL() == "" {
            manager.addSensors(with: study)
            manager.add(AWAREEventLogger.shared())
            manager.add(AWAREStatusMonitor.shared())
            manager.createDBTablesOnAwareServer()
            manager.startAllSensors()
        } else {
            if let studyURL = study.getURL() {
                study.join(withURL: studyURL) { (settings, status, error) in
                    DispatchQueue.main.async {
                        manager.addSensors(with: study)
                        manager.add(AWAREEventLogger.shared())
                        manager.add(AWAREStatusMonitor.shared())
                        manager.createDBTablesOnAwareServer()
                        manager.startAllSensors()
                        self.showReloadCompletionAlert()
                    }
                }
            }
        }
        
        for sensor in self.sensors {
            sensor.syncProgress = 0
            sensor.syncStatus = .unknown
        }
        
    }

    let sections = ["Study","Sensors"]
    
    var settings = Array<TableRowContent>()
    
    func getSettings() -> [TableRowContent] {
         return [TableRowContent(type: .setting,
                         title: "Study URL",
                         details: AWAREStudy.shared().getURL() ?? "",
                         identifier: TableRowIdentifier.studyId.rawValue),
         TableRowContent(type: .setting,
                         title: "Device ID",
                         details: AWAREStudy.shared().getDeviceId(),
                         identifier: TableRowIdentifier.deviceId.rawValue),
         TableRowContent(type: .setting,
                         title: "Device Name",
                         details: AWAREStudy.shared().getDeviceName(),
                         identifier: TableRowIdentifier.deviceName.rawValue),
         TableRowContent(type: .setting,
                         title: "Advanced Settings",
                         details: "",
                         identifier: TableRowIdentifier.advancedSettings.rawValue)]
    }
    
    lazy var sensors: [TableRowContent] = {
        let bundleUrl = Bundle.main.url(forResource: "AWAREFramework", withExtension: "bundle")
        if let url = bundleUrl {
            let bundle = Bundle.init(url: url)
            var contents = [
                TableRowContent(type: .sensor,
                                title: "Accelerometer",
                                details: "Acceleration, including the force of gravity",
                                identifier: SENSOR_ACCELEROMETER,
                                icon: UIImage(named: "ic_action_accelerometer", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Gyroscope",
                                details: "Rate of rotation of device",
                                identifier: SENSOR_GYROSCOPE,
                                icon: UIImage(named: "ic_action_gyroscope", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Magnetometer",
                                details: "Geomagnetic field strength around the device",
                                identifier: SENSOR_MAGNETOMETER,
                                icon: UIImage(named: "ic_action_magnetometer", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Rotation",
                                details: "Orientation of the device in all axis",
                                identifier: SENSOR_ROTATION,
                                icon: UIImage(named: "ic_action_rotation", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Linear Accelerometer",
                                details: "Acceleration applied to the sensor built-in into the device, excluding the force of gravity",
                                identifier: SENSOR_LINEAR_ACCELEROMETER,
                                icon: UIImage(named: "ic_action_linear_acceleration", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Activity Recognition",
                                details: "iOS Activity Recognition",
                                identifier: SENSOR_IOS_ACTIVITY_RECOGNITION,
                                icon: UIImage(named: "ic_action_running", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Pedometer",
                                details: "This plugin collects user's daily steps.",
                                identifier: SENSOR_PLUGIN_PEDOMETER,
                                icon: UIImage(named: "ic_action_steps", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Location",
                                details: "User's estimated location",
                                identifier: SENSOR_LOCATIONS,
                                icon: UIImage(named: "ic_action_locations", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Barometer",
                                details: "Atomospheric air pressure",
                                identifier: SENSOR_BAROMETER,
                                icon: UIImage(named: "ic_action_barometer", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Battery",
                                details: "Battery and power event",
                                identifier: SENSOR_BATTERY,
                                icon: UIImage(named: "ic_action_battery", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Network",
                                details: "Network usage and traffic",
                                identifier: SENSOR_NETWORK,
                                icon: UIImage(named: "ic_action_network", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Communication",
                                details: "The Communication sensor logs communication events such as calls, performed by or received by the user.",
                                identifier: SENSOR_CALLS,
                                icon: UIImage(named: "ic_action_communication", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Bluetooth",
                                details: "Bluetooth sensing",
                                identifier: SENSOR_BLUETOOTH,
                                icon: UIImage(named: "ic_action_bluetooth", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Processor",
                                details: "CPU workload for user, system and idle(%)",
                                identifier: SENSOR_PROCESSOR,
                                icon: UIImage(named: "ic_action_processor", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Timezone",
                                details: "The timezone sensor keeps track of the user’s current timezone",
                                identifier: SENSOR_TIMEZONE,
                                icon: UIImage(named: "ic_action_timezone", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "WiFi",
                                details: "Wi-Fi sensing",
                                identifier: SENSOR_WIFI,
                                icon: UIImage(named: "ic_action_wifi", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Screen",
                                details: "Screen events (on/off, locked/unlocked)",
                                identifier: SENSOR_SCREEN,
                                icon: UIImage(named: "ic_action_screen", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Ambient Noise",
                                details: "Anbient noise sensing by using a microphone on a smartphone.",
                                identifier: SENSOR_AMBIENT_NOISE,
                                icon: UIImage(named: "ic_action_ambient_noise", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Heart Rate",
                                details: "Collect heart rate data from an external heart rate sensor via BLE.",
                                identifier: SENSOR_PLUGIN_BLE_HR,
                                icon: UIImage(named: "ic_action_heartrate", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Calendar",
                                details: "This plugin gathers calendar events from Calendar",
                                identifier: SENSOR_PLUGIN_CALENDAR,
                                icon: UIImage(named: "ic_action_google_cal", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Contacts",
                                details: "This plugin get your contacts",
                                identifier: SENSOR_PLUGIN_CONTACTS,
                                icon: UIImage(named: "ic_action_contacts", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Fitbit",
                                details: "This plugin collects Fitbit",
                                identifier: SENSOR_PLUGIN_FITBIT,
                                icon: UIImage(named: "ic_action_fitbit", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Google Login",
                                details: "Multi-device management using Google Account",
                                identifier: SENSOR_PLUGIN_GOOGLE_LOGIN,
                                icon: UIImage(named: "google_logo", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "NTP Time",
                                details: "Measure device's clock drift from an NTP server",
                                identifier: SENSOR_PLUGIN_NTPTIME,
                                icon: UIImage(named: "ic_action_ntptime", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Weather",
                                details: "Weather information by OpenWeatherMap API",
                                identifier: SENSOR_PLUGIN_OPEN_WEATHER,
                                icon: UIImage(named: "ic_action_openweather", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Conversation",
                                details: "",
                                identifier: SENSOR_PLUGIN_STUDENTLIFE_AUDIO,
                                icon: UIImage(named: "ic_action_conversation", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Fused Location",
                                details: "Locations API provider. This plugin provides the user's current location in an energy efficient way.",
                                identifier: SENSOR_GOOGLE_FUSED_LOCATION,
                                icon: UIImage(named: "ic_action_google_fused_location", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "HealthKit",
                                details: "Collecting health related data from HealthKit API",
                                identifier: SENSOR_HEALTH_KIT,
                                icon: UIImage(named: "ic_action_health_kit", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Device Usage",
                                details: "Device usage information based on smartphone lock/unlock events.",
                                identifier: SENSOR_PLUGIN_DEVICE_USAGE,
                                icon: UIImage(named: "ic_action_device_usage", in:bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "iOS ESM",
                                details: "Setup ESM based on JSON confiugration on any URL",
                                identifier: SENSOR_PLUGIN_IOS_ESM,
                                icon: UIImage(named: "ic_action_web_esm", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Google Calendar ESM",
                                details: "Schedule ESM based on configurations on Google Calendar",
                                identifier: SENSOR_PLUGIN_CALENDAR_ESM_SCHEDULER,
                                icon: UIImage(named: "ic_action_google_cal", in: bundle, compatibleWith: nil)),
                TableRowContent(type: .sensor,
                                title: "Significant Motion",
                                details: "This sensor is used to track device significant motion",
                                identifier: SENSOR_SIGNIFICANT_MOTION,
                                icon: UIImage(named: "ic_action_significant", in: bundle, compatibleWith: nil))
                
            ]
            return contents
        }
        return Array<TableRowContent>()
    }()
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            switch AWAREStudy.shared().getUIMode(){
            case AwareUIModeNormal:
                return self.settings.count
            case AwareUIModeHideSettings:
                return self.settings.count - 1
            case AwareUIModeHideAll:
                break
            case AwareUIModeHideSensors:
                return self.settings.count
            default:
                break
            }
        } else if section == 1 {
            switch AWAREStudy.shared().getUIMode(){
            case AwareUIModeNormal:
                return self.sensors.count
            case AwareUIModeHideSettings:
                break
            case AwareUIModeHideAll:
                break
            case AwareUIModeHideSensors:
                break
            default:
                break
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AwareTableViewCell.cellName) as! AwareTableViewCell

        if indexPath.section == 0 {
            let setting = settings[indexPath.row]
            cell.title.text  = setting.title
            cell.detail.text = setting.details
            cell.icon.isHidden = true
            cell.progress.isHidden = true
            cell.hideIcon()
            cell.hideSyncProgress()
            
        } else if indexPath.section == 1 {
            let sensor =  sensors[indexPath.row]
            cell.title.text  = sensor.title
            cell.showIcon()
            cell.showSyncProgress()
            cell.icon.image  = sensor.icon?.withRenderingMode(.alwaysTemplate)

            if (sensorManager.isExist(sensor.identifier)){
                cell.icon.tintColor = .systemBlue
                let latestData = sensorManager.getLatestSensorValue(sensor.identifier)
                if let data = latestData {
                    cell.detail.text = data
                }
                cell.progress.progress = sensor.syncProgress

            }else{
                cell.icon.tintColor = .dynamicColor(light: .black, dark: .white)
                cell.detail.text = sensor.details
                cell.hideSyncProgress()
            }
            
            cell.setSyncStatus(sensor.syncStatus)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // return sections.count
        switch AWAREStudy.shared().getUIMode(){
        case AwareUIModeNormal:
            return sections.count
        case AwareUIModeHideSettings:
            return 1
        case AwareUIModeHideAll:
            return 0
        case AwareUIModeHideSensors:
            return 1
        default:
            return sections.count
        }
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(indexPath.section, indexPath.row)
        if indexPath.section == 0 {
            let setting = settings[indexPath.row]
            switch setting.identifier {
            case TableRowIdentifier.studyId.rawValue:
                showAlertForSettingStudyId()
                break
            case TableRowIdentifier.deviceName.rawValue:
                showAlertForSettingDeviceName()
                break
            case TableRowIdentifier.advancedSettings.rawValue:
                // advancedSettingsView
                self.performSegue(withIdentifier: "toAdvancedSettings", sender: self)
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            self.selectedRowContent = sensors[indexPath.row]
            self.performSegue(withIdentifier: "toSensorSetting", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 20
    }
    
    
}

extension ViewController {
    func showReloadCompletionAlert(){
        let study = AWAREStudy.shared()
        let alert = UIAlertController(title: "Completed reloading the study configuration from AWARE server.",
                                      message: study.getURL(),
                                      preferredStyle: .alert)
        let close = UIAlertAction(title: "Close",
                                   style: .default,
                                   handler: { (action) in
                                    for sensor in self.sensors {
                                        sensor.syncProgress = 0
                                        sensor.syncStatus = .unknown
                                    }
        })
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    func startManualUpload(){
        let manager = AWARESensorManager.shared()
        
        let callback = { (sensorName:String?, syncState:AwareStorageSyncProgress, progress:Double, error:Error?) -> Void in
            
            DispatchQueue.main.async {
                var flag = false
                            
                for sensor in self.sensors {
                    let name = sensor.identifier
                    if name == sensorName! {
                        flag = true
                    } else if name == "location_gps" || name == "google_fused_location" {
                        if sensorName! == "locations" {
                            flag = true
                        }
                    } else if name == "health_kit" {
                        if sensorName! == "\(SENSOR_HEALTH_KIT)_heartrate"{
                            flag = true
                            print(sensorName!)
                        }
                    }
                    
                    if flag {
                        sensor.syncProgress = Float(progress)
                        if syncState == .complete {
                            sensor.syncStatus = .done
                        }else if syncState == .error {
                            sensor.syncStatus = .error
                        }else if (syncState == .locked || syncState == .unknown) {
                            sensor.syncStatus = .unknown
                        }else{
                            sensor.syncStatus = .syncing
                        }
                        
                        if let _ = error {
                            sensor.syncStatus = .error
                        }
                        if name == "location_gps" || name == "google_fused_location" {
                            flag = false
                            continue
                        } else if name == "\(SENSOR_HEALTH_KIT)_heartrate" {
                            flag = false
                            continue
                        }else{
                            break
                        }
                    }
                }
                
                // completion check
                var complete = true
                for sensor in self.sensors {
                    if manager.isExist(sensor.identifier){
                        // print(sensor.sensorName, sensor.syncProgress)
                        if sensor.syncProgress < 1 {
                            complete = false
                            break
                        }
                    }
                }
                
                if complete {
                    let alert = UIAlertController(title: "Data upload is completed", message: nil, preferredStyle: .alert)
                    let close = UIAlertAction(title: "Close", style: .default, handler: { (action) in
                        for sensor in self.sensors {
                            sensor.syncProgress = 0
                            sensor.syncStatus = .unknown
                        }
                    })
                    alert.addAction(close)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        /// setcallback into each sensor storage
        for sensor in manager.getAllSensors(){
            if let storage = sensor.storage {
                storage.syncProcessCallBack = callback
            }
        }
        // manager.setSyncProcessCallbackToAllSensorStorages()
        
        for sensor in self.sensors {
            sensor.syncProgress = 0
            sensor.syncStatus = .syncing
        }
        manager.syncAllSensorsForcefully()
    }
}

/// alerts
extension UIViewController {
    func showAlertForSettingStudyId(){
        let alert = UIAlertController(title:"Study URL", message:nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "https://url.for.aware.server"
            textField.clearButtonMode = .whileEditing
            textField.text = AWAREStudy.shared().getURL()
        })
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
            if let textFields = alert.textFields {
                if textFields.count > 0 {
                    if let textField = textFields.first {
                        if let text = textField.text{
                            let study = AWAREStudy.shared()
                            study.setStudyURL(text)
                            study.join(withURL: text, completion: { (settings, study, error) in
                                let sensorManager = AWARESensorManager.shared()
                                sensorManager.addSensors(with: AWAREStudy.shared())
                                sensorManager.createDBTablesOnAwareServer()
                                sensorManager.startAllSensors()
                            })
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: {})
    }
    
    func showAlertForSettingDeviceName(){
        let alert = UIAlertController(title:"Device Name", message:nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.clearButtonMode = .whileEditing
            textField.text = AWAREStudy.shared().getDeviceName()
        })
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
            if let textFields = alert.textFields {
                if textFields.count > 0 {
                    if let textField = textFields.first {
                        if let text = textField.text{
                            let study = AWAREStudy.shared()
                            study.setDeviceName(text)
                            study.refreshStudySettings()
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: {})
    }
}

class TableRowContent {
    let identifier:String
    var height:CGFloat = 60
    let icon:UIImage?
    var title:String
    var details:String
    let type:TableRowType
    var syncProgress:Float = 0
    var syncStatus:SyncStatus = .unknown
    
    init(type:TableRowType,
         title:String="",
         details:String="",
         identifier:String="",
         icon:UIImage? = nil) {
        self.type = type
        self.title = title
        self.details = details
        self.identifier = identifier
        self.icon = icon
    }
}

enum TableRowType {
    case sensor
    case setting
}

enum TableRowIdentifier:String {
    case studyId          = "STUDY_URL"
    case deviceId         = "DEVICE_ID"
    case deviceName       = "DEVICE_NAME"
    case advancedSettings = "ADVANCED_SETTINGS"
}

extension UIColor {
    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                } else {
                    return light
                }
            }
        }
        return light
    }
}
