//
//  displayResultViewController.swift
//  HealthyLife
//
//  Created by admin on 8/18/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase 

class displayResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
        
    var currentUserID = String()
    
    var results = [Result]()
    
    var resultRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        
        let ref = DataService.BaseRef
       
        
        
        showLoading()
        
        resultRef = ref.child("users").child(currentUserID).child("results_journal")
        resultRef.queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in
            
            // The snapshot is a current look at our jokes data.
            
            print(snapshot.value)
            
            self.results = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let result = Result(key: key, dictionary: postDictionary)
                        
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.results.insert(result, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            self.hideLoading()
        })
        
         tableView.allowsMultipleSelectionDuringEditing = true
        
        
        // Do any additional setup after loading the view.
    }
    
    
   
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        
        
            resultRef.child(results[indexPath.row].resultKey as! String).removeValue()
        
        
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // 1. set the initial state of the cell
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = transform
        // 2. UIView Animation method to the final state of the cell
        UIView.animateWithDuration(1.0) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("result") as! displayCellTableViewCell
        cell.result = results[indexPath.row]
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
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
