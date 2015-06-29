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
    @IBOutlet var fbProfileImage: UIImageView!
    @IBOutlet var fbUserName: UILabel!
    
    var permissions = ["public_profile", "email", "user_friends"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var facebookProfileUrl = String()
        let user = PFUser.currentUser()
        
        // Verify is user is logged with Facebook
        isLoggedWithFacebook()
        
        // Users profile image
        
        if let userID: AnyObject = PFUser.currentUser()?.valueForKey("id") {
            facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
        }
        
        // Rounded profile image
        
        if(PFUser.currentUser() != nil){
            let userControl = UserManager(dictionary: user!)
            
            userControl.photo?.getDataInBackgroundWithBlock({ (image, error) -> Void in
                self.fbProfileImage.image = UIImage(data: image!)
            })
        } else {
            fbProfileImage.image = UIImage(named: "profiledefault")
        }
            
        fbProfileImage.layer.borderWidth = 4.0
        fbProfileImage.layer.masksToBounds = false
        fbProfileImage.layer.borderColor = hexStringToUIColor("#9D8C70").CGColor
        fbProfileImage.layer.cornerRadius = fbProfileImage.frame.size.width/2
        fbProfileImage.clipsToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        isLoggedWithFacebook()
    }
    
    
    func isLoggedWithFacebook() {
        var currentUser = PFUser.currentUser()?.objectId
        
        if currentUser != nil {
            fbLoginButton.enabled = false
        } else {
            fbLoginButton.enabled = true
        }
    }
    
    // Function to convert HEX to UIColor -------------------------------------------------------------------------------------------
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Facebook UIButton Action --------------------------------------------------------------------

    @IBAction func fbLoginButtonTapped(sender: UIButton) {
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if let loggedUser = user {
                if loggedUser.isNew {
                    self.fbLoginButton.enabled = false
                    
                    println("User signed up and logged in through Facebook!")
                    self.returnUserData(loggedUser)

                } else {
                    self.fbLoginButton.enabled = false
                    
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
                println("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                let userEmail : NSString = result.valueForKey("email") as! NSString
                let userID: NSString = result.valueForKey("id") as! NSString
                
                var currentUser = UserManager()
                currentUser.objectId = user.objectId
                currentUser.name = userName as String
                currentUser.email = userEmail as String
        
                // Get users image from facebook ans save on parse
                let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=large")!
                let urlRequest = NSURLRequest(URL: url)
                
                NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                    let image = UIImage(data: data)
                    self.fbProfileImage.image = image
                    
                    var jpegImage = UIImageJPEGRepresentation(image, 1.0)
                    let file = PFFile(name:"profileImage.jpg" , data: jpegImage)
                    currentUser.photo = file
                })
                
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
