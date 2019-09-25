//
//  AdvancedSettingsViewController.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2019/03/04.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class AdvancedSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var advancedSettings = Array<TableRowContent>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        advancedSettings = self.getAdvancedSettings()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        advancedSettings = self.getAdvancedSettings()
        self.tableView.reloadData()
        hideContextViewIfNeeded()
    }

}

enum AdvancedSettingsIdentifiers:String {
    case debugMode = "DEBUG_MODE"
    // case autoRefreshTime = "AUTO_REFRESH_TIME"
    case uploadInterval  = "UPLOAD_INTERVAL"
    case wifiOnly        = "WIFI_ONLY"
    case batteryChargingOnly = "BATTERY_CHARGING_ONLY"
    case dbCleanInterval = "DB_CLEAN_INTERVAL"
    case dbFetchCount    = "DB_FETCH_COUNT"
    case autoSync        = "AUTO_SYNC"
    case export          = "EXPORT"
    case version         = "VERSION"
    case quit            = "QUIT"
    case team            = "TEAM"
    case aboutAware      = "ABOUT_AWARE"
    case uiMode          = "UI_MODE"
    case contextView     = "CONTEXT_VIEW"
}


extension AdvancedSettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return advancedSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cell = UITableViewCell(style: .value1 , reuseIdentifier: "cell")
        
        let setting = advancedSettings[indexPath.row]
        cell.textLabel?.text = setting.title
        cell.detailTextLabel?.text = setting.details
        
        cell.detailTextLabel?.isHidden = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension AdvancedSettingsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = self.advancedSettings[indexPath.row]
        
        switch row.identifier {
        // debug mode
        case AdvancedSettingsIdentifiers.debugMode.rawValue:
            let alert = UIAlertController(title: row.title, message: "Turn On or Off the debug mode?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "On", style: .default, handler: { (action) in
                AWAREStudy.shared().setDebug(true)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Off", style: .default, handler: { (action) in
                AWAREStudy.shared().setDebug(false)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        // upload interval
        case AdvancedSettingsIdentifiers.uploadInterval.rawValue:
            let alert = UIAlertController(title: row.title, message: "Set an upload interval by minute.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.clearButtonMode = .whileEditing
                textField.text = row.details
                textField.keyboardType = UIKeyboardType.numberPad
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
                if let textFields = alert.textFields {
                    if textFields.count > 0 {
                        if let textField = textFields.first {
                            if let text = textField.text{
                                let study = AWAREStudy.shared()
                                study.setAutoDBSyncIntervalWithMinutue( Int32(text) ?? 60 )
                                self.refresh()
                            }
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        // wifi only
        case AdvancedSettingsIdentifiers.wifiOnly.rawValue:
            let alert = UIAlertController(title: "Turn On or Off WiFi only mode?", message: "If the mode is On, data upload processes are executed only when this phone has a WiFi connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "On", style: .default, handler: { (action) in
                AWAREStudy.shared().setAutoDBSyncOnlyWifi(true)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Off", style: .default, handler: { (action) in
                AWAREStudy.shared().setAutoDBSyncOnlyWifi(false)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        // battery only
        case AdvancedSettingsIdentifiers.batteryChargingOnly.rawValue:
            let alert = UIAlertController(title: "Turn On or Off Battery only mode?", message: "If the mode is On, data upload processes are executed only when this phone is charged the battery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "On", style: .default, handler: { (action) in
                AWAREStudy.shared().setAutoDBSyncOnlyBatterChargning(true)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Off", style: .default, handler: { (action) in
                AWAREStudy.shared().setAutoDBSyncOnlyBatterChargning(false)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        // fetch count
        case AdvancedSettingsIdentifiers.dbFetchCount.rawValue:
            let alert = UIAlertController(title: row.title, message: "Set the maximum number of fetch records one-time from the local database.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.clearButtonMode = .whileEditing
                textField.text = row.details
                textField.keyboardType = UIKeyboardType.numberPad
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
                if let textFields = alert.textFields {
                    if textFields.count > 0 {
                        if let textField = textFields.first {
                            if let text = textField.text{
                                let study = AWAREStudy.shared()
                                study.setMaximumNumberOfRecordsForDBSync( Int(text) ?? 1000 )
                                self.refresh()
                            }
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        // db clean
        case AdvancedSettingsIdentifiers.dbCleanInterval.rawValue:
            let alert = UIAlertController(title: row.title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Always", style: .default, handler: { (action) in
                AWAREStudy.shared().setCleanOldDataType(cleanOldDataTypeAlways)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Daily", style: .default, handler: { (action) in
                AWAREStudy.shared().setCleanOldDataType(cleanOldDataTypeDaily)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Weekly", style: .default, handler: { (action) in
                AWAREStudy.shared().setCleanOldDataType(cleanOldDataTypeWeekly)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Monthly", style: .default, handler: { (action) in
                AWAREStudy.shared().setCleanOldDataType(cleanOldDataTypeMonthly)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Never", style: .default, handler: { (action) in
                AWAREStudy.shared().setCleanOldDataType(cleanOldDataTypeNever)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        // quit
        case AdvancedSettingsIdentifiers.quit.rawValue:
            let alert = UIAlertController(title: row.title, message: "Are you sure to quit this study? If you quit this study, all of the study settings will be removed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Quit", style: .destructive, handler: { (action) in
                AWAREStudy.shared().clearSettings()
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case AdvancedSettingsIdentifiers.export.rawValue:
            var documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            documentPath.append(contentsOf: "/AWARE.sqlite")
            var activityItems = Array<URL>();
            activityItems.append(URL(fileURLWithPath: documentPath))
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityVC.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)?.contentView
                activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            }
            self.present(activityVC, animated: true, completion: nil)
            break
        case AdvancedSettingsIdentifiers.uiMode.rawValue:
            let alert = UIAlertController(title: row.title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Normal", style: .default, handler: { (action) in
                AWAREStudy.shared().setUIMode(AwareUIModeNormal)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Hide Sensors", style: .default, handler: { (action) in
                AWAREStudy.shared().setUIMode(AwareUIModeHideSensors)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Hide Settings", style: .destructive, handler: { (action) in
                AWAREStudy.shared().setUIMode(AwareUIModeHideSettings)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Hide All", style: .destructive , handler: { (action) in
                AWAREStudy.shared().setUIMode(AwareUIModeHideAll)
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        case AdvancedSettingsIdentifiers.contextView.rawValue:
            let alert = UIAlertController(title: "Hide Context View from TabBar?", message: "If you set Yes, the context view will be hidden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                super.setHideContextView(status: true)
                if UserDefaults.standard.synchronize(){
                    super.hideContextViewIfNeeded()
                }
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                super.setHideContextView(status: false)
                if UserDefaults.standard.synchronize() {
                    super.hideContextViewIfNeeded()
                }
                self.refresh()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func refresh(){
        AWAREStudy.shared().refreshStudySettings()
        self.viewDidAppear(false)
    }
}

extension AdvancedSettingsViewController {
    func getAdvancedSettings() -> Array<TableRowContent>{
        let study = AWAREStudy.shared()
        let settings = [TableRowContent(type: .setting,
                                        title: "Debug Mode",
                                        details: study.isDebug() ? "On":"Off",
                                        identifier: AdvancedSettingsIdentifiers.debugMode.rawValue),
                        TableRowContent(type: .setting,
                                        title: "Upload Interval",
                                        details: "\(study.getAutoDBSyncIntervalSecond()/60)",
                                        identifier: AdvancedSettingsIdentifiers.uploadInterval.rawValue),
                        TableRowContent(type: .setting,
                                        title: "WiFi Only",
                                        details: study.isAutoDBSyncOnlyWifi() ? "On":"Off",
                                        identifier: AdvancedSettingsIdentifiers.wifiOnly.rawValue),
                        TableRowContent(type: .setting,
                                        title: "Battery Charging Only",
                                        details: study.isAutoDBSyncOnlyBatterChargning() ? "On":"Off",
                                        identifier: AdvancedSettingsIdentifiers.batteryChargingOnly.rawValue),
                        TableRowContent(type: .setting,
                                        title: "UI Mode",
                                        details: self.getUIModeAsString(),
                                        identifier: AdvancedSettingsIdentifiers.uiMode.rawValue),
                        TableRowContent(type: .setting,
                                        title: "Hide Context",
                                        details: isHideContextView() ? "Yes":"No",
                                        identifier: AdvancedSettingsIdentifiers.contextView.rawValue),
                        TableRowContent(type: .setting,
                                        title: "DB Fetch Count",
                                        details: "\(study.getMaximumNumberOfRecordsForDBSync())",
                                        identifier: AdvancedSettingsIdentifiers.dbFetchCount.rawValue),
                        TableRowContent(type: .setting,
                                        title: "DB Clean Interval",
                                        details: getDBCleanModeAsString(),
                                        identifier: AdvancedSettingsIdentifiers.dbCleanInterval.rawValue),
                        TableRowContent(type: .setting,
                                        title: "Export DB",
                                        details: "",
                                        identifier: AdvancedSettingsIdentifiers.export.rawValue),
                        TableRowContent(type: .setting,
                                        title: "Quit Study",
                                        identifier: AdvancedSettingsIdentifiers.quit.rawValue),
                        TableRowContent(type: .setting,
                                        title: "Version",
                                        details: "\(getAppVersion()) (\(getAppBuildNumber()))"),
                        TableRowContent(type: .setting,
                                        title: "About AWARE",
                                        identifier: AdvancedSettingsIdentifiers.aboutAware.rawValue),
                        TableRowContent(type: .setting,
                                        title: "Team",
                                        identifier: AdvancedSettingsIdentifiers.team.rawValue)
        ]
        return settings;
    }
    
    func getDBCleanModeAsString() -> String {
        let study = AWAREStudy.shared()
        switch study.getCleanOldDataType(){
        case cleanOldDataTypeDaily:
            return "Daily"
        case cleanOldDataTypeNever:
            return "Never"
        case cleanOldDataTypeAlways:
            return "Always"
        case cleanOldDataTypeWeekly:
            return "Weekly"
        case cleanOldDataTypeMonthly:
            return "Monthly"
        default:
            break
        }
        return ""
    }
    
    func getUIModeAsString() -> String {
        let uiMode = AWAREStudy.shared().getUIMode()
        switch uiMode {
        case AwareUIModeNormal:
            return "Normal"
        case AwareUIModeHideSettings:
            return "Hide Settings"
        case AwareUIModeHideSensors:
            return "Hide Sensors"
        case AwareUIModeHideAll:
            return "Hide All"
        default:
            return "Unknown"
        }
    }
    
    func getAppVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    func getAppBuildNumber() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}

extension AdvancedSettingsIdentifiers {
    
    func getFiles() -> Array<URL>{
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var activityItems = Array<URL>();
    
        var fileNames: [String] {
            do {
                return try FileManager.default.contentsOfDirectory(atPath: documentPath)
            } catch {
                return []
            }
        }
        for name in fileNames {
            activityItems.append(URL(fileURLWithPath: "\(documentPath)/\(name)" ))
        }
        return activityItems;
    }
}

extension UIViewController{
    func hideContextViewIfNeeded(){
        if isHideContextView() {
            if let items = self.tabBarController?.tabBar.items {
                items[1].isEnabled = false
                items[1].image = nil
                items[1].title = nil
            }
        }else{
            if let items = self.tabBarController?.tabBar.items {
                items[1].isEnabled = true
                items[1].image = UIImage(named: "line_chart")
                items[1].title = "Context"
            }
        }
    }
    
    func isHideContextView() -> Bool{
        let status = AWAREStudy.shared().getSetting("client_ios_hide_context_view")
        if status == "1" {
            return true
        }else{
            return false
        }
    }
    
    func setHideContextView(status:Bool){
        let key = "client_ios_hide_context_view"
        if status{
            AWAREStudy.shared().setSetting(key, value: "1" as NSObject)
        }else{
            AWAREStudy.shared().setSetting(key, value: "0" as NSObject)
        }
        // print(AWAREStudy.shared().getSensorSettings())
    }
}
