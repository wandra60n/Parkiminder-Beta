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
    @IBOutlet weak var ibTrashButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ibBackgroundView.layer.cornerRadius = 10
        self.ibBackgroundView.clipsToBounds = true
//        self.ibFoldIcon.tintColor = .white
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
        ibFoldIcon.rotate(collapsed ? 0.0 : -.pi)
        
//        UIView.animate(withDuration: 2.0, animations: {
//            self.imageView.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
//        })
    }
    
    @IBAction func clickTrashButton(_ sender: UIButton) {
        delegate?.clearRecordsInSection(header: self)
    }
}


protocol FoldingHeaderDelegate {
    func toggleSection(_ header: FoldingHeader, section: Int)
    func clearRecordsInSection(header: FoldingHeader)
}



