//
//  MailboxViewController.swift
//  FakeMailbox
//
//  Created by David Kjelkerud on 8/23/14.
//  Copyright (c) 2014 David Kjelkerud. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var messageOriginalPosition: CGPoint!
    var messageCurrentPosition: CGFloat!
    var messageLeftMostPosition: CGPoint! = CGPointMake(-320, 0)
    var messageRightMostPosition: CGPoint! = CGPointMake(320, 0)
    var messageState: String! = "default"

    let listImage = UIImage(named: "list")
    let snoozeImage = UIImage(named: "reschedule")
    
    let listIcon = UIImage(named: "list_icon")
    let snoozeIcon = UIImage(named: "later_icon")
    let archiveIcon = UIImage(named: "archive_icon")
    let deleteIcon = UIImage(named: "delete_icon")

    var feedOriginalPosition: CGPoint!
    
    // Colors
    let grayColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1)
    let yellowColor = UIColor(red: 0.976, green:0.824, blue:0.263, alpha:1)
    let greenColor = UIColor(red: 0.467, green:0.847, blue:0.404, alpha:1)
    let redColor = UIColor(red: 0.906, green:0.325, blue:0.227, alpha:1)
    let brownColor = UIColor(red: 0.839, green: 0.647, blue:0.471, alpha:1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 320, height: feedImageView.image.size.height + searchImageView.image.size.height + messageView.frame.size.height)

        messageOriginalPosition = messageImageView.frame.origin
        messageView.backgroundColor = grayColor
        
        overlayImageView.alpha = 0
        
        feedOriginalPosition = CGPointMake(0, feedImageView.frame.origin.y)
    }
    
    func messageView(#state: String) {
        messageState = state
        
        if messageState == "list" {
            messageView.backgroundColor = brownColor
            iconImageView.image = listIcon
            iconImageView.frame.origin.x = messageImageView.frame.origin.x + messageImageView.frame.width + 20

        } else if (messageState == "snooze") {
            messageView.backgroundColor = yellowColor
            iconImageView.image = snoozeIcon
            iconImageView.frame.origin.x = messageImageView.frame.origin.x + messageImageView.frame.width + 20
            
        } else if (messageState == "default-right") {
            messageView.backgroundColor = grayColor
            iconImageView.image = snoozeIcon
            iconImageView.alpha = CGFloat(convertValue(Float(messageCurrentPosition), r1Min: 0, r1Max: -60, r2Min: 0, r2Max: 1))
            iconImageView.frame.origin.x = 276
        } else if (messageState == "default-left") {
            messageView.backgroundColor = grayColor
            iconImageView.image = archiveIcon
            iconImageView.alpha = CGFloat(convertValue(Float(messageCurrentPosition), r1Min: 0, r1Max: 60, r2Min: 0, r2Max: 1))
            iconImageView.frame.origin.x = 19
        } else if (messageState == "archive") {
            messageView.backgroundColor = greenColor
            iconImageView.image = archiveIcon
            iconImageView.frame.origin.x = messageImageView.frame.origin.x - 40

        } else if (messageState == "delete") {
            messageView.backgroundColor = redColor
            iconImageView.image = deleteIcon
            iconImageView.frame.origin.x = messageImageView.frame.origin.x - 40
        }
    }
    
    func deleteMessage() {
        overlayImageView.alpha = 0
        scrollView.sendSubviewToBack(messageView)

        UIView.animateWithDuration(0.5, animations: {
            self.feedImageView.center.y -= self.messageView.frame.size.height
        })
    }
    
    func resetMessage() {
        messageView(state: "default")
        self.messageImageView.frame.origin.x = self.messageOriginalPosition.x

        UIView.animateWithDuration(0.5, animations: {
            self.feedImageView.frame.origin = self.feedOriginalPosition
        })
    }
    
    func convertValue(value: Float, r1Min: Float, r1Max: Float, r2Min: Float, r2Max: Float) -> Float {
        var ratio = (r2Max - r2Min) / (r1Max - r1Min)
        return value * ratio + r2Min - r1Min * ratio
    }
    
    @IBAction func onPan(sender: AnyObject) {
        var point = sender.locationInView(view)
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)

        //println("Velocity y: \(velocity.y)")

        if sender.state == UIGestureRecognizerState.Began {
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            messageCurrentPosition = messageOriginalPosition.x + translation.x
            messageImageView.frame.origin.x = messageCurrentPosition
            
            if (messageCurrentPosition <= -240) {
                messageView(state: "list")
            } else if (messageCurrentPosition < -60) {
                messageView(state: "snooze")
            } else if (messageCurrentPosition < 0) {
                messageView(state: "default-right")
            } else if (messageCurrentPosition > 0 && messageCurrentPosition < 60) {
                messageView(state: "default-left")
            } else if (messageCurrentPosition >= 60 && messageCurrentPosition < 240) {
                messageView(state: "archive")
            } else if (messageCurrentPosition >= 240){
                messageView(state: "delete")
            }
            
        
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            if (messageState == "list") {
                overlayImageView.image = listImage
                view.bringSubviewToFront(overlayImageView)
                UIView.animateWithDuration(0.5, animations: {
                    self.messageImageView.frame.origin.x = self.messageLeftMostPosition.x - 40
                    self.iconImageView.frame.origin.x = self.messageImageView.frame.origin.x + self.messageImageView.frame.width - 40
                    self.overlayImageView.alpha = 1
                })
                
            } else if (messageState == "snooze") {
                overlayImageView.image = snoozeImage
                view.bringSubviewToFront(overlayImageView)
                
                UIView.animateWithDuration(0.5, animations: {
                    self.messageImageView.frame.origin.x = self.messageLeftMostPosition.x - 40
                    self.iconImageView.frame.origin.x = self.messageImageView.frame.origin.x + self.messageImageView.frame.width - 40
                    self.overlayImageView.alpha = 1
                })
                
            } else if (messageState == "default-right" || messageState == "default-left") {                
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: nil, animations: {
                        self.messageImageView.frame.origin.x = self.messageOriginalPosition.x
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        self.messageImageView.frame.origin.x = self.messageRightMostPosition.x + 40
                        self.iconImageView.frame.origin.x = self.messageImageView.frame.origin.x - 40
                    },
                    completion: { (Bool) -> Void in
                        self.deleteMessage()
                })
            }
        }
    }
    
    @IBAction func onTap(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.overlayImageView.alpha = 0
        })
        deleteMessage()
    }
    
    @IBAction func onFeedDoubleTap(sender: AnyObject) {
        resetMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
