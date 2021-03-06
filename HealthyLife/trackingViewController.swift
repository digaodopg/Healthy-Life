//
//  trackingViewController.swift
//  HealthyLife
//
//  Created by admin on 8/6/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class trackingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    

    
    var trackUsers = [Tracking]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.dataService.userRef.child("tracking").observeEventType(.Value, withBlock: { snapshot in
            
            self.trackUsers = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let user = Tracking(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.trackUsers.insert(user, atIndex: 0)
                    }
                }
                
            }
            
            
            self.tableView.reloadData()
            
        })
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tracking") as! TrackingCellTableViewCell
        
        cell.tracking = trackUsers[indexPath.row]
        
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
//            let cell = sender as! UITableViewCell
//            let indexPath = tableView.indexPathForCell(cell)
//            let uid = trackUsers[indexPath!.row].UserID as! String
//            let nameTitle = trackUsers[indexPath!.row].name as! String
//        
//            let detailViewController = segue.destinationViewController as! DetailsActivitiesDoneViewController
//            detailViewController.uid = uid
//            detailViewController.titleName = nameTitle
//
        
        
        
        if segue.identifier == "journal" {
            let controller = segue.destinationViewController as! journalViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! TrackingCellTableViewCell
                controller.currentUserID = cell.ID
            }
            
        } else if segue.identifier == "acitivitiesDone" {
            let controller = segue.destinationViewController as! DetailsActivitiesDoneViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! TrackingCellTableViewCell
                controller.uid = cell.ID
            }
        }
        
    }
    
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
