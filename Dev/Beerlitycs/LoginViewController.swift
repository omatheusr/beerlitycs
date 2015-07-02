//
//  LoginViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 28/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var inputBgLogin: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginFBButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var inputUsername: UITextField!
    @IBOutlet weak var inputPassword: UITextField!

    var permissions = ["public_profile", "email", "user_friends"]
    var userLogged : UserManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        Util.roundedView(self.inputBgLogin.layer, border: true, colorHex: "E6DCD7", borderSize: 1.0, radius: 6)
        Util.roundedView(self.loginButton.layer, border: false, colorHex: nil, borderSize: nil, radius: 6)
        Util.roundedView(self.loginFBButton.layer, border: false, colorHex: nil, borderSize: nil, radius: 6)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newAccount(sender: AnyObject) {
//        self.performSegueWithIdentifier("registerSegue", sender: nil)
    }

    
    @IBAction func fbLoginButton(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            let userControl = UserManager()

            if let loggedUser = user {
                if loggedUser.isNew {
                    println("User signed up and logged in through Facebook!")
                    userControl.returnUserData(loggedUser, callback: { (error) -> () in
                        if(error == nil) {
                            PushNotifications.associateDeviceWithCurrentUser()
                            self.userLogged = UserManager(dictionary: loggedUser)
                            self.performSegueWithIdentifier("registerSegue", sender: nil)
                        }
                    })
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
            
            if error != nil {
                println(error);
            }
            
        }
    }

    @IBAction func loginButton(sender: AnyObject) {
        let userControl = UserManager()
        
        userControl.username = inputUsername.text
        userControl.password = inputPassword.text
        
        userControl.login(userControl) { (error) -> () in
            if(error == nil) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func animateTextFieldWithKeyboard(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        // baseContraint is your Auto Layout constraint that pins the
        // text view to the bottom of the superview.
        
        if notification.name == UIKeyboardWillShowNotification {
            bottomConstraint.constant = bottomConstraint.constant + keyboardSize.height  // move up
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "registerSegue") {
            let rVC : RegisterViewController = segue.destinationViewController as! RegisterViewController
            rVC.userControl = self.userLogged!
        }
    }

    @IBAction func btnEsconder(sender: AnyObject) {
        self.resignFirstResponder()
    }

    

}
