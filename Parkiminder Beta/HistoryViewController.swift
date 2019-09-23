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

/**struct DateGroup {
    var title: String
    var records: [NSManagedObject]
    var collapsed: Bool
    
    init(title: String, records: [NSManagedObject] = [], collapsed: Bool = false) {
        self.title = title
        self.records = records
        self.collapsed = collapsed
    }
}**/

class HistoryViewController: UIViewController {
    
//    @IBOutlet weak var ibDebugLabel: UILabel!
    @IBOutlet weak var ibMapView: GMSMapView!
    @IBOutlet weak var ibHistoryTable: UITableView!
    
    @IBOutlet weak var ibPreviewBUtton: UIButton!
    @IBOutlet weak var ibDismissButton: UIButton!
    
    var reminders_CD: [NSManagedObject] = []
    var ds: [RecordsGroup] = []
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchReminders()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchReminders()
        // just for test
//        let lastReminder = reminders_CD[0]
//        ibDebugLabel.text = (lastReminder.value(forKey: "imageurl_String") as! String)
        
        // create dummy group
        ds.append(RecordsGroup(title: "This Month", collapsed: false))
        ds.append(RecordsGroup(title: "Last 3 Months", collapsed: true))
        ds.append(RecordsGroup(title: "More", collapsed: true))
        
        while reminders_CD.count > 0 {
            let tempRecord = reminders_CD.popLast()
            let recordDate = tempRecord!.value(forKey: "createdTime_Date") as! Date
            if recordDate.isInSameMonth(date: Date()) {
                ds[0].records.append(tempRecord!)
            } else if recordDate.isInPreviousMonths(date: Date(), n: 3) {
                ds[1].records.append(tempRecord!)
            } else {
                ds[2].records.append(tempRecord!)
            }
        }
        
        /**ds[0].records.append(reminders_CD[0])
        ds[0].records.append(reminders_CD[1])
        
        ds[1].records.append(reminders_CD[2])
        ds[1].records.append(reminders_CD[3])
        
        for i in 4...self.reminders_CD.count-1 {
            ds[2].records.append(reminders_CD[i])
        }**/
        
        
        self.ibHistoryTable.dataSource = self
        self.ibHistoryTable.delegate = self
        
        let headerNib = UINib.init(nibName: "FoldingHeaderView", bundle: Bundle.main)
        ibHistoryTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "FoldingHeaderView")
        ibHistoryTable.separatorStyle = .none
        ibHistoryTable.tableFooterView = UIView()
        
        self.ibHistoryTable.rowHeight = UITableView.automaticDimension
//        self.ibHistoryTable.estimatedRowHeight = 80.0 // set to whatever your "average" cell height is
        ibDismissButton.layer.cornerRadius = 0.5 * ibDismissButton.bounds.size.width
        ibDismissButton.clipsToBounds = true
        
        ibPreviewBUtton.layer.cornerRadius = 0.5 * ibPreviewBUtton.bounds.size.width
        ibPreviewBUtton.clipsToBounds = true
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
//            reminders_CD.reverse()
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
        if ds[section].records.count > 0 {
            return ds[section].collapsed ? 0 : ds[section].records.count
        } else {
            return ds[section].collapsed ? 0 : 1
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let historyCell = tableView.dequeueReusableCell(withIdentifier: "reminder_cell", for: indexPath) as! HistoryReminderCell
        if ds[indexPath.section].records.count <= 0 {
            print("no data in this section")
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! NoRecordController
            return emptyCell
        }
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
        if ds[section].records.count == 0 {
            headerView.ibTrashButton.isEnabled = false
        }
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
        
//        let selected = self.reminders_CD[indexPath.row]
        let selected = self.ds[indexPath.section].records[indexPath.row]
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
    
   /**func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3, animations: {
            self.ibDismissButton.alpha = 0
        }, completion: { (value: Bool) in
            self.ibDismissButton.isHidden = true
        })
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.ibDismissButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.ibDismissButton.alpha = 1
        }, completion: { (value: Bool) in
            self.ibDismissButton.isHidden = false
        })
    }**/
}

extension HistoryViewController: FoldingHeaderDelegate {
    func clearRecordsInSection(header: FoldingHeader) {
        print("trash  \(header.section) clicked")
        let alert = UIAlertController(title: "Clear records for \(self.ds[header.section].title)?", message: "This will delete all records in this group.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            if self.ds[header.section].clearRecords() {
                self.ibHistoryTable.reloadSections(NSIndexSet(index: header.section) as IndexSet, with: .automatic)
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

extension Date {
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    func isInPreviousMonths(date: Date, n: Int) -> Bool {
        var i = 0
        while i <= n {
            let prevMo = Calendar.current.date(byAdding: .month, value: i, to: self)
            if((prevMo?.isInSameMonth(date: date))!) {
                return true
            }
            i += 1
        }
        return false
    }
    func randomDatetimeFrom(prevMos: Int) -> Date {
        let lowerDate = Calendar.current.date(byAdding: .month, value: -1*prevMos, to: self)
        var dc = DateComponents()
        dc.year = Calendar.current.component(.year, from: lowerDate!)
        dc.month = Calendar.current.component(.month, from: lowerDate!)
        let firstDay = Calendar.current.date(from: dc)
        
        let randomInterval = Double.random(in: firstDay!.timeIntervalSince1970...self.timeIntervalSince1970)
        return Date(timeIntervalSince1970: randomInterval)
    }
}
