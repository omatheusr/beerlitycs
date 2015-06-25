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

    var permissions = ["public_profile", "email", "user_friends", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if (FBSDKAccessToken.currentAccessToken() != nil)
//        {
//            // User is already logged in, do work such as go to next view controller.
//            println("logado")
//            returnUserData()
//            
//            let loginView : FBSDKLoginButton = FBSDKLoginButton()
//            self.view.addSubview(loginView)
//            loginView.center = self.view.center
//            loginView.delegate = self
//        }
//        else
//        {
//            let loginView : FBSDKLoginButton = FBSDKLoginButton()
//            self.view.addSubview(loginView)
//            loginView.center = self.view.center
//            loginView.readPermissions = ["public_profile", "email", "user_friends"]
//            loginView.delegate = self
//        }
        
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
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                println("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                println("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                println("User Email is: \(userEmail)")
                
                var currentUser = UserManager()
                currentUser.objectId = user.objectId
                currentUser.name = userName as String
                currentUser.email = userEmail as String
                
                currentUser.editUser(currentUser, callback: { (error) -> () in
                    
                    println(currentUser)
                    
                    if (error != nil) {
                        println(error);
                    }
                })
            }
        })
    }
    
    // ---------------------------------------------------------------------------------------------

}
