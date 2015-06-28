//
//  RegisterViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 28/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgInputView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()


        self.bgInputView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.bgInputView.layer.cornerRadius = 10
        self.bgInputView.layer.borderWidth = 1
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func animateTextFieldWithKeyboard(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        // baseContraint is your Auto Layout constraint that pins the
        // text view to the bottom of the superview.
        
        if notification.name == UIKeyboardWillShowNotification {
            bottomConstraint.constant = -keyboardSize.height  // move up
        }
        else {
            bottomConstraint.constant = 0 // move down
        }
        
        view.setNeedsUpdateConstraints()
        
        let options = UIViewAnimationOptions(curve << 16)
        UIView.animateWithDuration(duration, delay: 0, options: options,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
        
    }

    func keyboardWillShow(notification: NSNotification) {
        animateTextFieldWithKeyboard(notification)
    }

    func keyboardWillHide(notification: NSNotification) {
        animateTextFieldWithKeyboard(notification)
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
