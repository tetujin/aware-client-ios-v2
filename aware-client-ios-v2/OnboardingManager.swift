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
        let overviewPage = OnboardingContentViewController(title: NSLocalizedString("onbording_overview_title", comment: ""),
                                                           body:  NSLocalizedString("onbording_overview_body",  comment: ""),
                                                           image: icon,
                                                           buttonText: NSLocalizedString("Next", comment: "") ) { () -> Void in
                                                            if let page = self.onboardingVC?.pageControl.currentPage {
                                                                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
                                                            }

        }
        overviewPage.bodyLabel.adjustsFontSizeToFitWidth = true
        overviewPage.bodyLabel.font = overviewPage.bodyLabel.font.withSize(18)
        overviewPage.movesToNextViewController = true
        
        // -- overview
        let individualPage = OnboardingContentViewController(title: NSLocalizedString("onbording_data_title", comment: ""),
                                                           body: NSLocalizedString("onbording_data_body", comment: ""),
                                                           image: icon,
                                                           buttonText:  NSLocalizedString("Next", comment: "") ) { () -> Void in

        }
        individualPage.titleLabel.font = individualPage.titleLabel.font.withSize(30)
        individualPage.bodyLabel.adjustsFontSizeToFitWidth = true
        individualPage.bodyLabel.font = individualPage.bodyLabel.font.withSize(18)
        individualPage.movesToNextViewController = true
        
        // -- scientists
        let scientistPage = OnboardingContentViewController(title: NSLocalizedString("onbording_study_title", comment: ""),
                                                           body: NSLocalizedString("onbording_study_body", comment: ""),
                                                           image: icon,
                                                           buttonText:  NSLocalizedString("Next", comment: "") ) { () -> Void in
                                                            if let page = self.onboardingVC?.pageControl.currentPage {
                                                                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
                                                            }
        }
        scientistPage.titleLabel.font = scientistPage.titleLabel.font.withSize(30)
        scientistPage.bodyLabel.adjustsFontSizeToFitWidth = true
        scientistPage.bodyLabel.font = scientistPage.bodyLabel.font.withSize(15)
        scientistPage.movesToNextViewController = true
                
        
        // -- location
        let locationPage = OnboardingContentViewController(title: NSLocalizedString("onboarding_permission_loc_title", comment: ""),
                                                           body:NSLocalizedString("onboarding_permission_loc_body", comment: ""),
                                                           image: icon,
                                                           buttonText: NSLocalizedString("Allow", comment: "") ) { () -> Void in
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
        let notificationPage = OnboardingContentViewController(title: NSLocalizedString("onboarding_permission_notif_title", comment: ""),
                                                               body: NSLocalizedString("onboarding_permission_notif_body", comment: ""),
                                                               image: icon,
                                                               buttonText: NSLocalizedString("Allow", comment: "")) {
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
        let welcomePage = OnboardingContentViewController(title: NSLocalizedString("onboarding_welcome_title", comment: ""),
                                                          body: NSLocalizedString("onboarding_welcome_body",   comment: ""),
                                                          image: icon,
                                                          buttonText: "OK") {
            if let page = self.onboardingVC?.pageControl.currentPage {
                AWAREEventLogger.shared().logEvent(["class":"OnboardingManager","event":"next","page":page])
            }
            self.onboardingVC?.dismiss(animated: true) {
                self.onboardingVC = nil
                _ = LocationPermissionManager().isAuthorizedAlways(with: viewController)
            }
            
        }
        welcomePage.titleLabel.font = welcomePage.titleLabel.font.withSize(30)
        welcomePage.bodyLabel.font  = welcomePage.bodyLabel.font.withSize(18)
        welcomePage.movesToNextViewController = false
        
        
        // -- setup an Onboarding View Controller
        onboardingVC = OnboardingViewController(backgroundImage: background, contents: [overviewPage, individualPage, scientistPage, locationPage, notificationPage, welcomePage])
        onboardingVC?.shouldBlurBackground = false;
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

