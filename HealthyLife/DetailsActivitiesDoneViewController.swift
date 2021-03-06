//
//  DetailsActivitiesDoneViewController.swift
//  HealthyLife
//
//  Created by admin on 8/17/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class ActivitiesDone: NSObject {
    var key: String?
    var activityName: String?
    var nameOfPlan: String?
    var time: NSDate?
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        activityName = dictionary["activityName"] as? String
        nameOfPlan = dictionary["nameOfPlan"] as? String
        
        if let T = dictionary["time"] as? Double {
            time = NSDate(timeIntervalSince1970: T/1000)
        }
        
    }
    
    
}




class DetailsActivitiesDoneViewController: BaseTableViewController {
    
    var uid = String()
    var titleName = String()
    var activitiesDone = [ActivitiesDone]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = titleName
        
        DataService.dataService.userRef.child("tracking").child(uid).child("activitiesDone").observeEventType(.Value, withBlock: { snapshot in
            self.activitiesDone = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let activity = ActivitiesDone(key: key, dictionary: postDictionary)
                        
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.activitiesDone.insert(activity, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.dataArray = self.activitiesDone
            

        })
        // Do any additional setup after loading the view.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivitiesDone") as! ActivitiesDoneCellTableViewCell
        
        cell.activity = activitiesDone[indexPath.row]
        
        return cell
    }
}
