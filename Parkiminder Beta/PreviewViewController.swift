//
//  PreviewViewController.swift
//  Parkiminder Beta
//
//  Created by dading on 29/8/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var callback_clearCapturedImage: (() -> Void)?
    var capturedImage: UIImage?
    
    @IBOutlet weak var ibCapturedView: UIImageView!
    @IBOutlet weak var ibScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        ibScrollView.minimumZoomScale = 1.0
        ibScrollView.maximumZoomScale = 4.0
        ibScrollView.zoomScale = 1.0
        ibScrollView.delegate = self as UIScrollViewDelegate
//        ibCapturedView.contentMode = .scaleToFill
        ibCapturedView.image = capturedImage
    }
    
    @IBAction func clickDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickClearButton(_ sender: UIButton) {
        callback_clearCapturedImage!()
        dismiss(animated: true, completion: nil)
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

extension PreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return ibCapturedView
    }
}
