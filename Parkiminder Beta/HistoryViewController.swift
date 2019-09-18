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

struct DateGroup {
    var title: String
    var records: [NSManagedObject]
    var collapsed: Bool
    
    init(title: String, records: [NSManagedObject] = [], collapsed: Bool = false) {
        self.title = title
        self.records = records
        self.collapsed = collapsed
    }
}

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var ibDebugLabel: UILabel!
    @IBOutlet weak var ibMapView: GMSMapView!
    @IBOutlet weak var ibHistoryTable: UITableView!
    
    @IBOutlet weak var ibPreviewBUtton: UIButton!
    
    
    var reminders_CD: [NSManagedObject] = []
    var ds: [DateGroup] = []
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchReminders()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchReminders()
        // just for test
        let lastReminder = reminders_CD[0]
        ibDebugLabel.text = (lastReminder.value(forKey: "imageurl_String") as! String)
        
        // create dummy group
        ds.append(DateGroup(title: "Group 1"))
        ds.append(DateGroup(title: "Group 2"))
        ds.append(DateGroup(title: "Group 3"))
        
        ds[0].records.append(reminders_CD[0])
        ds[0].records.append(reminders_CD[1])
        
        ds[1].records.append(reminders_CD[2])
        ds[1].records.append(reminders_CD[3])
        
        for i in 4...self.reminders_CD.count-1 {
            ds[2].records.append(reminders_CD[i])
        }
        
        
        self.ibHistoryTable.dataSource = self
        self.ibHistoryTable.delegate = self
        
        let headerNib = UINib.init(nibName: "FoldingHeaderView", bundle: Bundle.main)
        ibHistoryTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "FoldingHeaderView")
        ibHistoryTable.separatorStyle = .none
        ibHistoryTable.tableFooterView = UIView()
        
        self.ibHistoryTable.rowHeight = UITableView.automaticDimension
        self.ibHistoryTable.estimatedRowHeight = 80.0 // set to whatever your "average" cell height is
        
        ibMapView.bringSubviewToFront(ibPreviewBUtton)
        
//        self.ibMapView.delegate = self
    }
    
    
    func fetchReminders() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("mayday mayday")
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Reminder_CD")
        
        do {
            reminders_CD = try managedContext.fetch(fetchRequest)
            print("\(#function) \(reminders_CD.count)")
//            print("\(reminders[reminders.count-1].value(forKeyPath: "re_title"))")
            reminders_CD.reverse()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func clickDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.ds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.reminders_CD.count
        return ds[section].collapsed ? 0 : ds[section].records.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let historyCell = tableView.dequeueReusableCell(withIdentifier: "reminder_cell", for: indexPath) as! HistoryReminderCell
        guard let historyCell = tableView.dequeueReusableCell(withIdentifier: "reminder_cell", for: indexPath) as? HistoryReminderCell else {
            print("ping ping ping")
            return UITableViewCell()
        }
//        let reminderItem = self.reminders_CD[indexPath.row]
        let reminderItem = self.ds[indexPath.section].records[indexPath.row]
        historyCell.ibDescriptionLabel.text = (reminderItem.value(forKey: "description_String") as! String)
        
        let createdTime = reminderItem.value(forKeyPath: "createdTime_Date") as! Date
        let dueTime = reminderItem.value(forKey: "dueTime_Date") as! Date
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
        //let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? HeaderExpandable ?? HeaderExpandable(reuseIdentifier: "header")
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FoldingHeaderView") as! FoldingHeader
        headerView.ibSectionLabel.text = ds[section].title
        headerView.rotateIcon(ds[section].collapsed)
        headerView.section = section
        headerView.delegate = self
        /**
        header.titleLabel.text = ds[section].title
        header.arrowLabel.text = ">"
        
        header.setCollapsed(ds[section].collapsed)
        
        header.section = section
        header.delegate = self
        **/
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return 100
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//        return 1.0
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.ibMapView.clear()
        
        let selected = self.reminders_CD[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: selected.value(forKey: "latitude_Double") as! Double, longitude: selected.value(forKey: "longitude_Double") as! Double)
        let marker = GMSMarker(position: coordinate)
//        marker.title = "PARKED"
        marker.appearAnimation = .pop
        marker.map = self.ibMapView
        
        self.ibMapView.animate(to: GMSCameraPosition(target: coordinate, zoom: 20, bearing: 0, viewingAngle: 0))
//        self.ibMapView.camera = GMSCameraPosition(target: coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
//        print("PARKED")
    }
}

extension HistoryViewController: UITableViewDelegate {
    
}

extension HistoryViewController: FoldingHeaderDelegate {
    func toggleSection(_ header: FoldingHeader, section: Int) {
        let collapsed = !ds[section].collapsed
        
        ds[section].collapsed = collapsed
        header.rotateIcon(collapsed)
     
        ibHistoryTable.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
//    func toggleSection(_ header: HeaderExpandable, section: Int) {
//        let collapsed = !ds[section].collapsed
//
//        // Toggle collapse
//        ds[section].collapsed = collapsed
//        header.setCollapsed(collapsed)
//
//        ibHistoryTable.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
//    }
}

extension HistoryViewController: GMSMapViewDelegate {
    
}

extension HistoryViewController: CLLocationManagerDelegate {
    
}
