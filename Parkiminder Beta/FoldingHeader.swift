//
//  FoldingHeader.swift
//  Parkiminder Beta
//
//  Created by dading on 18/9/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit

class FoldingHeader: UITableViewHeaderFooterView {

    var delegate: FoldingHeaderDelegate?
    var section: Int = 0
    
    @IBOutlet weak var ibSectionLabel: UILabel!
    @IBOutlet weak var ibFoldIcon: UIImageView!
    @IBOutlet weak var ibBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ibBackgroundView.layer.cornerRadius = 10
        self.ibBackgroundView.clipsToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader)))
    }
    
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let tapped = gestureRecognizer.view as? FoldingHeader else {
            return
        }
        delegate?.toggleSection(self, section: tapped.section)
    }
    /**override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? FoldingHeader else {
            return
        }
        delegate?.toggleSection(self, section: cell.section)
        print("tapped")
    }**/
    
    func rotateIcon(_ collapsed: Bool) {
        ibFoldIcon.rotate(collapsed ? 0.0 : -.pi / 2)
    }
    
}


protocol FoldingHeaderDelegate {
    func toggleSection(_ header: FoldingHeader, section: Int)
}


extension UIView {
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")

        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}
