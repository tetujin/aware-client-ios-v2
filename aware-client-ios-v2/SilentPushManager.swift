//
//  SilentPushManager.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2019/11/18.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class SilentPushManager: NSObject {

    func executeOperations(_ request:[String:Any]){
        let version = self.getVersion(request)
        if version > 0 {
            let ops = self.getOperations(request)
            executeV1(with: ops)
        }
        print(request)
        AWAREEventLogger.shared().logEvent(["class":"SilentPushManager",
                                            "event":"executeOperations",
                                            "request":request])
    }

    func getVersion(_ request:[String:Any]) -> Double {
        if let aware = request["aware"] as? [String:Any]{
            if let version = aware["v"] as? Double{
                return version
            }
        }
        return 0
    }
    
    func getOperations(_ request:[String:Any]) -> [[String:Any]] {
        if let aware = request["aware"] as? [String:Any]{
            if let ops = aware["ops"] as? [[String:Any]]{
                return ops
            }
        }
        return [[String:Any]]()
    }
    
    private func executeV1(with operations:[[String:Any]]){
        for op in operations {
            if let cmd = op["cmd"] as? String{
                if cmd == "sync-all-sensors" {
                    AWARESensorManager.shared().syncAllSensorsForcefully()
                }else if cmd == "sync-sensor"{
                    if let targets = op["targets"] as? [String]{
                        for target in targets {
                            if let sensor = AWARESensorManager.shared().getSensor(target) {
                                sensor.startSyncDB()
                            }
                        }
                    }else{
                        AWARESensorManager.shared().syncAllSensorsForcefully()
                    }
                }else if cmd == "start-all-sensors" {
                    AWARESensorManager.shared().startAllSensors()
                }else if cmd == "stop-all-sensors" {
                    AWARESensorManager.shared().stopAllSensors()
                }else if cmd == "reactivate-core" {
                    AWARECore.shared().reactivate()
                }else if cmd == "push-msg" {
                    if let msg = op["msg"] as? [String:String]{
                        let title = msg["title"]
                        let body  = msg["body"]
                        AWAREUtils.sendLocalPushNotification(withTitle: title, body: body, timeInterval: 0.1, repeats: false)
                    }
                }else if cmd == "sync-config" {
                    AWAREStudy.shared().refreshStudySettings()
                }
            }
        }
    }
}

