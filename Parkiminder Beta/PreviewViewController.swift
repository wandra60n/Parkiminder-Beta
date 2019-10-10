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
    @IBOutlet weak var ibTrashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        self.dismissViewWhenTappedAround()
        if callback_clearCapturedImage == nil {
            self.ibTrashButton.isHidden = true
        }
        ibScrollView.minimumZoomScale = 1.0
        ibScrollView.maximumZoomScale = 4.0
        ibScrollView.zoomScale = 1.0
        ibScrollView.delegate = self as UIScrollViewDelegate
//        ibCapturedView.contentMode = .scaleToFill
        ibCapturedView.makeSquircle()
        ibCapturedView.image = capturedImage
    }
    
    @IBAction func clickDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickClearButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Clear captured image?", message: "This will delete all previously captured image.", preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.dismiss(animated: true) {
                self.callback_clearCapturedImage!()
            }
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
//        dismiss(animated: true, completion: nil)
        
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
