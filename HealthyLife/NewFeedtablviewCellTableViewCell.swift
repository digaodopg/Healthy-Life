//
//  NewFeedtablviewCellTableViewCell.swift
//  HealthyLife
//
//  Created by admin on 8/4/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class NewFeedtablviewCellTableViewCell: UITableViewCell {
    
    let storageRef = FIRStorage.storage().reference()
    var islandRef = FIRStorageReference()
    let defaults = NSUserDefaults.standardUserDefaults()
    var followedRef = FIRDatabaseReference()
    var followerRef = FIRDatabaseReference()
    var userProfile: UserProfile!
    var selectedUID: String!
    var currentUID = DataService.currentUserID
    var chatKey = String()
    var sellectedUsername = String()
    var currentUserName = DataService.currentUserName
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var talkButton: UIButton!
    
    @IBOutlet weak var HeightLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var weightChangedLabel: NHDCustomItalicFontLabel!
    
    @IBOutlet weak var trainerButton: UIButton!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var backview: UIView!
    
    @IBOutlet weak var followImage: UIImageView!
    
    
    @IBOutlet weak var containerView: UIView!
    
    let ref = DataService.BaseRef
    var trainerUid = String()
    
    
    func configureCell(userProfile: UserProfile, setImage: String) {
        
        self.userProfile = userProfile
        selectedUID = setImage
        

        sellectedUsername = userProfile.username ?? ""
        
        
        trainerButton.hidden = true
        
        contentView.backgroundColor = Configuration.Colors.lightGray
        
        backview.layer.cornerRadius = 10
        backview.clipsToBounds = true

        //Hide talk/follow for current user
        let isCurrentUser = DataService.currentUserID == selectedUID
        talkButton.hidden = isCurrentUser
        followImage.hidden = isCurrentUser
        
        self.avaImage.layer.cornerRadius = self.avaImage.frame.size.width / 2
        self.avaImage.clipsToBounds = true
        
        self.avaImage.layer.borderWidth = 1.0
        self.avaImage.layer.borderColor = UIColor.blackColor().CGColor
        
        
        //MARK: set up labels
        
        
        ref.child("users").child(self.selectedUID).child("results_journal").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            
            let currentWeight = snapshot.value!["CurrentWeight"] as! String
            let startingWeight = userProfile.userSetting?.weightChanged ?? "0"
            
            
            let weightChanged = Double(currentWeight)! - Double(startingWeight)!
            
            if weightChanged > 0 {
                self.weightChangedLabel.text = "gain: \(abs(weightChanged)) kg"
            } else {
                self.weightChangedLabel.text = "lose: \(abs(weightChanged)) kg"
            }
            
            
            
        }
        
        ref.child("users").child(self.selectedUID).child("currentTrainer").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            
            if snapshot.value != nil {
                
                self.trainerButton.hidden = false
                
                let name = snapshot.value!["name"] as! String
                let formattedString = NSMutableAttributedString()
                formattedString.italic("work with: ", fontSize: 13).bold(name, fontSize: 16)
                self.trainerButton.setAttributedTitle(formattedString, forState: .Normal)
                self.trainerUid = snapshot.key
                
            }
            
        }
        
        HeightLabel.text = Helper.parseHeightToMetre(userProfile.userSetting?.height)

        nameLabel.text = sellectedUsername
        let followerCount = userProfile.followerCount ?? 0
        followerCountLabel.text = "\(followerCount) followers"
        
        //MARK: Set up ava Image
        
        avaImage.image = UIImage(named: "defaults")
        ref.child("users/\(setImage)/photoURL").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let photoURL = snapshot.value as? String {
                self.avaImage.kf_setImageWithURL(NSURL(string: photoURL))
            }
        })
        
        
        
        //******************************
        
        followedRef = DataService.dataService.userRef.child("followed").child(setImage)
        
        
        followedRef.observeEventType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                
                // Current user hasn't voted for the joke... yet.
                
                self.followImage.image = UIImage(named: "add")
                
            } else {
                
                // Current user voted for the joke!
                
                self.followImage.image = UIImage(named: "added")
                
            }
            
        })
        
        if sellectedUsername.characters.count > 0 {
            DataService.dataService.chatRoom.child(sellectedUsername).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let dictinary = snapshot.value as? NSDictionary {
                    self.chatKey = dictinary["chatRoomKey"] as? String ?? ""
                } else {
                    self.chatKey =  self.selectedUID + self.currentUID
                }
            })
        } else {
            self.chatKey =  self.selectedUID + self.currentUID
        }
        
    }
    
    
    
    @IBAction func talkAction(sender: AnyObject) {
        DataService.dataService.chatRoom.child(userProfile.username!).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                
                DataService.dataService.chatRoom.child(self.sellectedUsername).setValue(["chatRoomKey": self.chatKey, "id": self.selectedUID])
                DataService.dataService.baseRef.child("users").child(self.selectedUID).child("chatRoom").child(self.currentUserName).setValue(["chatRoomKey": self.chatKey, "id": self.currentUID, "unreadMessage" : 0])
                
            }
            
            
        })
        
        
    }
    
    
    func followTapped(sender: UITapGestureRecognizer) {
        
        followedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                self.followImage.image = UIImage(named: "add")
                
                
                
                self.followerRef =   DataService.dataService.baseRef.child("users").child(self.selectedUID).child("follower").child(self.currentUID)
                
                self.followerRef.child("name").setValue( self.currentUserName)
                self.followedRef.child("name").setValue(self.currentUserName)
                
                self.userProfile.addSubTractFollower(true)
                
                // setValue saves the vote as true for the current user.
                // voteRef is a reference to the user's "votes" path.
                
                
            } else {
                self.followImage.image = UIImage(named: "added")
                
                self.followedRef.removeValue()
                self.followerRef.removeValue()
                
                self.userProfile.addSubTractFollower(false)
            }
            
            let followerCount = self.userProfile.followerCount ?? 0
            self.followerCountLabel.text = "\(followerCount) followers"
        })
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(NewFeedtablviewCellTableViewCell.followTapped(_:)))
        tap.numberOfTapsRequired = 1
        followImage.addGestureRecognizer(tap)
        followImage.userInteractionEnabled = true
        
        containerView.layer.cornerRadius = 4
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
