//
//  OnboardingManager.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2019/11/13.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import Onboard
import AWAREFramework

class OnboardingManager: NSObject {
    
    private var onboardingVC:OnboardingViewController? = nil
    
    public static func isFirstTime() -> Bool {
        let key = "com.yuukinishiyama.app.aware-client-ios-v2.onboarding.is-already-done"
        if !UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(true, forKey: key)
            UserDefaults.standard.synchronize()
            return true
        }else{
            return false
        }
    }
    
    func startOnboarding(with viewController:UIViewController){
        
        let icon = UIImage(named: "icon")?.resized(toWidth: 100)
        let background = UIImage(named: "background")?.resized(toWidth: viewController.view.frame.width)
        
        // -- overview
        let overviewPage = OnboardingContentViewController(title: "About AWARE",
                                                           body: "AWARE is a sensing framework dedicated to an instrument, infer, log and share mobile context information, for smartphone users and researchers.",
                                                           image: icon,
                                                           buttonText: "Next") { () -> Void in
                                                            if let page = self.onboardingVC?.pageControl.currentPage {
                                                                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
                                                            }

        }
        overviewPage.bodyLabel.adjustsFontSizeToFitWidth = true
        overviewPage.bodyLabel.font = overviewPage.bodyLabel.font.withSize(18)
        overviewPage.movesToNextViewController = true
        
        // -- overview
        let individualPage = OnboardingContentViewController(title: "Individuals:\n Record your data",
                                                           body: """
AWARE captures hardware-, software-, and human-based data in the background if you allow collecting these data. For instance, you can collect your location data in the background 24/7, and export the data as an SQLite database.
\n
AWARE will request permission to access the data if you need to use a sensors that required permission (e.g., HealthKit, Motion Activity, and Location).
""",
                                                           image: icon,
                                                           buttonText: "Next") { () -> Void in

        }
        individualPage.titleLabel.font = individualPage.titleLabel.font.withSize(30)
        individualPage.bodyLabel.adjustsFontSizeToFitWidth = true
        individualPage.bodyLabel.font = individualPage.bodyLabel.font.withSize(18)
        individualPage.movesToNextViewController = true
        
        // -- scientists
        let scientistPage = OnboardingContentViewController(title: "Scientists: Run studies",
                                                           body: """
Running a mobile-related study has never been easier. Install AWARE on the participants' phone, select the data you want to collect and that is it.
\n
By using the AWARE Dashboard, you can easily enable or disable sensors remotely. Privacy is enforced by design, so AWARE does not log personal information, such as phone numbers or contacts information. Also, the data is saved locally on your mobile phone temporary. AWARE uploads the data to the AWARE server automatically if the device has a Wi-Fi network and is charged battery.
""",
                                                           image: icon,
                                                           buttonText: "Next") { () -> Void in
                                                            if let page = self.onboardingVC?.pageControl.currentPage {
                                                                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
                                                            }
        }
        scientistPage.titleLabel.font = scientistPage.titleLabel.font.withSize(30)
        scientistPage.bodyLabel.adjustsFontSizeToFitWidth = true
        scientistPage.bodyLabel.font = scientistPage.bodyLabel.font.withSize(15)
        scientistPage.movesToNextViewController = true
                
        
        // -- location
        let locationPage = OnboardingContentViewController(title: "Permission: Location",
                                                           body:
"""
For data collection in the background, AWARE needs to access a location sensor on your device always.
\n
(NOTE: AWARE **does not store** your location data until the location-related sensors are enabled.)
""",
                                                           image: icon,
                                                           buttonText: "Allow") { () -> Void in
            if let page = self.onboardingVC?.pageControl.currentPage {
                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
            }
            AWARECore.shared().requestPermissionForBackgroundSensing { (status) in
                // AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"location","status":status])
            }
        }
        locationPage.titleLabel.font = locationPage.titleLabel.font.withSize(30)
        locationPage.bodyLabel.font = locationPage.bodyLabel.font.withSize(18)
        locationPage.movesToNextViewController = true

        
        // -- notification
        let notificationPage = OnboardingContentViewController(title: "Permission: Notification",
                                                               body:
"""
For notifying the latest app information and reminders of mobile surveys, AWARE needs to use Push Notification.
""",
                                                               image: icon, buttonText: "Allow") {
            if let page = self.onboardingVC?.pageControl.currentPage {
                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
            }
            AWARECore.shared().requestPermissionForPushNotification { (status, error) in
                // AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"notification","status":status])
            }
        }
        notificationPage.titleLabel.font = notificationPage.titleLabel.font.withSize(30)
        notificationPage.bodyLabel.font = notificationPage.bodyLabel.font.withSize(18)
        notificationPage.movesToNextViewController = true
        
        // -- welcome
        let welcomePage = OnboardingContentViewController(title: "Welcome to AWARE Framework",
                                                          body: "You can get detail information about AWARE Framework from the following link.\nhttp://www.awareframework.com/",
                                                          image: icon,
                                                          buttonText: "OK") {
            if let page = self.onboardingVC?.pageControl.currentPage {
                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
            }
            self.onboardingVC?.dismiss(animated: true) {
                self.onboardingVC = nil
            }
            
        }
        welcomePage.titleLabel.font = welcomePage.titleLabel.font.withSize(30)
        welcomePage.bodyLabel.font  = welcomePage.bodyLabel.font.withSize(18)
        welcomePage.movesToNextViewController = true
        
        
        // -- setup an Onboarding View Controller
        onboardingVC = OnboardingViewController(backgroundImage: background, contents: [overviewPage, individualPage, scientistPage, locationPage, notificationPage, welcomePage])
//        onboardingVC?.shouldBlurBackground = true;
        onboardingVC?.swipingEnabled = false;
        onboardingVC?.allowSkipping = true;
        onboardingVC?.skipHandler = ({
            if let page = self.onboardingVC?.pageControl.currentPage {
                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"skip","page":page])
            }
            self.onboardingVC?.moveNextPage()
        })
        viewController.present(onboardingVC!, animated: true) {
            
        }
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
