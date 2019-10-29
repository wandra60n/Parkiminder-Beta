//
//  HistoryViewController.swift
//  Parkiminder Beta
//
//  Created by dading on 12/9/19.
//  Copyright © 2019 COMP90019. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var ibMapView: GMSMapView!
    @IBOutlet weak var ibHistoryTable: UITableView!
    @IBOutlet weak var ibImagePreview: UIImageView!
    @IBOutlet weak var ibImagePreviewWidth: NSLayoutConstraint!
    @IBOutlet weak var ibImagePreviewHeight: NSLayoutConstraint!
    @IBOutlet weak var ibDismissButton: UIButton!
    
    var reminders_CD: [NSManagedObject] = []
    var ds: [RecordsGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reminders_CD = fetchReminders()
        self.ibMapView.delegate = self
        // create record groups
        ds.append(RecordsGroup(title: constantString.historyGroup1.rawValue, collapsed: false))
        ds.append(RecordsGroup(title: constantString.historyGroup2.rawValue, collapsed: true))
        ds.append(RecordsGroup(title: constantString.historyGroup3.rawValue, collapsed: true))
        
        // load record from core data to groups
        while reminders_CD.count > 0 {
            let tempRecord = reminders_CD.popLast()
            let recordDate = tempRecord!.value(forKey: constantString.attributeCreatedTime.rawValue) as! Date
            if recordDate.isInSameMonth(date: Date()) {
                ds[0].records.append(tempRecord!)
            } else if recordDate.isInPreviousMonths(date: Date(), n: 3) {
                ds[1].records.append(tempRecord!)
            } else {
                ds[2].records.append(tempRecord!)
            }
        }
        // setup the table view
        self.ibHistoryTable.dataSource = self
        self.ibHistoryTable.delegate = self
        // initialize header
        let headerNib = UINib.init(nibName: "FoldingHeaderView", bundle: Bundle.main)
        ibHistoryTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "FoldingHeaderView")
        ibHistoryTable.separatorStyle = .none
        ibHistoryTable.tableFooterView = UIView()
        // assign row height
        self.ibHistoryTable.rowHeight = UITableView.automaticDimension
        // assign tap action on image preview
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previewTapped(tapGestureRecognizer:)))
        self.ibImagePreview.isUserInteractionEnabled = true
        self.ibImagePreview.addGestureRecognizer(tapGestureRecognizer)
        // make dismiss button circle
        ibDismissButton.makeCircle()
    }
    
    // load reminders from core data
    func fetchReminders() -> [NSManagedObject] {
        var tempReminders: [NSManagedObject]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            tempReminders = []
            return tempReminders
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: constantString.entityNameReminder.rawValue)
        // sort records
        let sortDescriptor = NSSortDescriptor(key: constantString.attributeCreatedTime.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // atttach content to attribute
        do {
            tempReminders = try managedContext.fetch(fetchRequest)
//            reminders_CD = try managedContext.fetch(fetchRequest)
//            print("\(#function) \(reminders_CD.count)")
            return tempReminders
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            tempReminders = []
            return tempReminders
        }
    }
    
    @IBAction func clickDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.ds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ds[section].records.count > 0 {
            return ds[section].collapsed ? 0 : ds[section].records.count
        } else {
            return ds[section].collapsed ? 0 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // for no record
        if ds[indexPath.section].records.count <= 0 {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! NoRecordController
            return emptyCell
        }
        
        guard let historyCell = tableView.dequeueReusableCell(withIdentifier: "reminder_cell", for: indexPath) as? HistoryReminderCell else {
            return UITableViewCell()
        }

        // formatting cell content
        let reminderItem = self.ds[indexPath.section].records[indexPath.row]
        historyCell.ibDescriptionLabel.text = (reminderItem.value(forKey: constantString.attributeDescription.rawValue) as! String)
        
        let createdTime = reminderItem.value(forKeyPath: constantString.attributeCreatedTime.rawValue) as! Date
        let dueTime = reminderItem.value(forKey: constantString.attributeDueTime.rawValue) as! Date
        let formatter = DateComponentsFormatter()
        let parkingDuration = dueTime.timeIntervalSince(createdTime)
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        historyCell.ibDurationLabel.text = formatter.string(from: parkingDuration)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        historyCell.ibCreatedDateLabel.text = dateFormatter.string(from: createdTime)
        
        return historyCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FoldingHeaderView") as! FoldingHeader
        headerView.ibSectionLabel.text = ds[section].title
        headerView.rotateIcon(ds[section].collapsed)
        if ds[section].records.count == 0 {
            headerView.ibTrashButton.isEnabled = false
        }
        headerView.section = section
        headerView.delegate = self
        
        return headerView
    }
    
    // determine header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    // update the map when record is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.ibMapView.clear()
        let selected = self.ds[indexPath.section].records[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: selected.value(forKey: constantString.attributeLatitude.rawValue) as! Double, longitude: selected.value(forKey: constantString.attributeLongitude.rawValue) as! Double)
        let marker = GMSMarker(position: coordinate)

        marker.appearAnimation = .pop
        marker.map = self.ibMapView
        
        self.ibMapView.animate(to: GMSCameraPosition(target: coordinate, zoom: 19, bearing: 0, viewingAngle: 0))
        
        let imageURL = selected.value(forKey: constantString.attributeImageURL.rawValue) as! String
        
        if imageURL != constantString.imageUnavailable.rawValue {
            let imageData = Reminder.retrieveImage(imageURL: imageURL)
            let imageFile = UIImage(data: imageData!)
            
            if imageFile != nil {
                self.ibImagePreview.isHidden = false
                self.ibImagePreview.makeSquircle()
                self.ibImagePreview.contentMode = .scaleAspectFill
        
                self.ibImagePreviewWidth.constant = (imageFile?.size.width)! * 0.02
                self.ibImagePreviewHeight.constant = (imageFile?.size.height)! * 0.02
                self.ibImagePreview.image = imageFile
            } else {
                self.ibImagePreview.isHidden = true
            }
        } else {
            self.ibImagePreview.isHidden = true
        }
    }
    // load image from file manager
    func retrieveImage(imageURL: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = documentsPath.appendingPathComponent(imageURL)
        if FileManager.default.fileExists(atPath: imagePath.path) {
            let imageFile = UIImage(contentsOfFile: imagePath.path)
            return imageFile
        } else {
            return nil
        }
    }
    
    @objc func previewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        performSegue(withIdentifier: "segueToPreview", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToPreview" { // for moving to review
            let preview = segue.destination as! PreviewViewController
            let selectedItem = self.ds[ibHistoryTable.indexPathForSelectedRow!.section].records[ibHistoryTable.indexPathForSelectedRow!.row]
            
            let imageURL = selectedItem.value(forKey: constantString.attributeImageURL.rawValue) as! String
            let imageData = Reminder.retrieveImage(imageURL: imageURL)
            preview.capturedImage = UIImage(data: imageData!)
            preview.callback_clearCapturedImage = nil
        }
    }
}

// implement header with delegate pattern
extension HistoryViewController: FoldingHeaderDelegate {
    func clearRecordsInSection(header: FoldingHeader) {
        print("trash  \(header.section) clicked")
        let alert = UIAlertController(title: "Clear records for \(self.ds[header.section].title)?",
            message: "This will delete all records in this group.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if self.ds[header.section].clearRecords() {
                self.ibHistoryTable.reloadSections(NSIndexSet(index: header.section) as IndexSet, with: .automatic)
                self.ibImagePreview.isHidden = true
                print("records for \(self.ds[header.section].title) have been cleared.")
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func toggleSection(_ header: FoldingHeader, section: Int) {
        // negate the status
        let collapsed = !ds[section].collapsed
        // set the status
        ds[section].collapsed = collapsed
        // animation stuff
        header.rotateIcon(collapsed)
        ibHistoryTable.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
}

extension HistoryViewController: GMSMapViewDelegate {
    
}

extension HistoryViewController: CLLocationManagerDelegate {
    
}
