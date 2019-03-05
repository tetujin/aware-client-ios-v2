//
//  SensorTableViewCell.swift
//  aware-client-ios-v2
//
//  Created by Yuuki Nishiyama on 2019/02/27.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class AwareTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var syncStatusIcon: UIImageView!
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconLeftConstraint: NSLayoutConstraint!
    
    public static let cellName = "AwareTableCell"
    
    var syncStatus:SyncStatus = .unknown
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func hideIcon(){
        iconWidthConstraint.constant = 0 // 30
        iconLeftConstraint.constant  = 3 // 12
        icon.isHidden = true
    }
    
    func showIcon(){
        iconWidthConstraint.constant = 30
        iconLeftConstraint.constant  = 12
        icon.isHidden = false
    }
    
    func hideSyncProgress(){
        progress.isHidden = true
        syncStatusIcon.isHidden = true
    }
    
    func showSyncProgress(){
        progress.isHidden = false
        syncStatusIcon.isHidden = false
        setSyncStatus(.unknown)
    }
    
    func rotateSyncingIcon(){
        if self.syncStatus == .syncing {
            let timestamp = Int(Date().timeIntervalSince1970 * 100)
            let degree = timestamp%360
            if let icon = syncStatusIcon.image {
                syncStatusIcon.image = icon.rotatedBy(degree: CGFloat(-1 * degree) )
            }
        }
    }
    
    func setSyncStatus(_ status:SyncStatus){
        self.syncStatus = status
        switch status {
        case .done:
            syncStatusIcon.image = UIImage.init(named: "done")
            break
        case .syncing:
            syncStatusIcon.image = UIImage.init(named: "syncing")
            rotateSyncingIcon()
            break
        case .error:
            syncStatusIcon.image = UIImage.init(named: "error")
            break
        case .unknown:
            syncStatusIcon.image = nil
            break
        }
    }
}

public enum SyncStatus {
    case done
    case syncing
    case error
    case unknown
}

extension UIImage {
    
    func rotatedBy(degree: CGFloat) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
}
