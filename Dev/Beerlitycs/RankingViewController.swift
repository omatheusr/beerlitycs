//
//  RankingViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 20/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

class RankingViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet var fbLoginButton: UIButton!
    
    var permissions = ["public_profile", "email", "user_friends", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var currentUser = PFUser.currentUser()?.objectId
        
        if currentUser != nil {
            fbLoginButton.enabled = false
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook UIButton Action --------------------------------------------------------------------

    @IBAction func fbLoginButtonTapped(sender: UIButton) {
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if let loggedUser = user {
                if loggedUser.isNew {
                    println("User signed up and logged in through Facebook!")
                    self.returnUserData(loggedUser)
                    
                } else {
                    println("User logged in through Facebook!")
                    self.returnUserData(loggedUser)
                }
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
            
            if error != nil {
                println(error);
            }
            
        }
        
    }
    
    // Facebook Functions -------------------------------------------------------------------------
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    // ---------------------------------------------------------------------------------------------
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    // ---------------------------------------------------------------------------------------------
    
    func returnUserData(user: PFUser)
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                //println("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                let userEmail : NSString = result.valueForKey("email") as! NSString
                
                var currentUser = UserManager()
                currentUser.objectId = user.objectId
                currentUser.name = userName as String
                currentUser.email = userEmail as String
                
                currentUser.editUser(currentUser, callback: { (error) -> () in
                    
                    if (error != nil) {
                        println(error);
                    }
                })
            }
        })
    }
    
    // ---------------------------------------------------------------------------------------------

}
