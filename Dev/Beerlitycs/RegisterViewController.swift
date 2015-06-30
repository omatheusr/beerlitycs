//
//  RegisterViewController.swift
//  Beerlitycs
//
//  Created by Matheus Frozzi Alberton on 28/06/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgInputView: UIView!
    @IBOutlet weak var registerButton: UIButton!

    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputUserName: UITextField!
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputHeight: UITextField!
    @IBOutlet weak var inputWeight: UITextField!
    @IBOutlet weak var inputImage: UIImageView!

    @IBOutlet weak var heightBottomConstraint: NSLayoutConstraint!

    var userControl : UserManager?
    var editView : Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        Util.roundedView(self.bgInputView.layer, border: true, radius: 6)
        Util.roundedView(self.registerButton.layer, border: false, radius: 6)
        Util.roundedView(self.inputImage.layer, border: false, radius: self.inputImage.frame.size.width / 2)
        self.inputImage.clipsToBounds = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false

        if(editView == nil) {
            let color = UIColor(red: 55.0/255.0, green: 61.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            self.navigationController?.navigationBar.barTintColor = color
            self.navigationController?.navigationBar.translucent = true
            self.navigationItem.title = "Cadastro"
        } else {
            self.registerButton.setTitle("Editar", forState: UIControlState.Normal)
        }

        if(self.userControl != nil) {
            self.inputName.text = self.userControl?.name
            self.inputEmail.text = self.userControl?.email
            self.inputHeight.text = self.userControl?.height
            self.inputWeight.text = self.userControl?.weight
            self.userControl!.photo?.getDataInBackgroundWithBlock({ (image, error) -> Void in
                self.inputImage.image = UIImage(data: image!)
            })

            if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
                if(self.userControl?.email != nil) {
                    self.inputEmail.enabled = false
                }
                self.inputPassword.hidden = true
                self.inputUserName.hidden = true
                
                self.heightBottomConstraint.priority = 1000
            } else {
                self.inputUserName.text = self.userControl?.username
            }
        }
    }
    @IBAction func backButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changePhoto(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Tirar foto", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                var imag = UIImagePickerController()
                imag.delegate = self
                imag.sourceType = UIImagePickerControllerSourceType.Camera;
                imag.mediaTypes = [kUTTypeImage]
                imag.allowsEditing = true
                
                self.presentViewController(imag, animated: true, completion: nil)
            }
        })

        let saveAction = UIAlertAction(title: "Escolher foto", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imag.mediaTypes = [kUTTypeImage]
            imag.allowsEditing = true
            
            self.presentViewController(imag, animated: true, completion: nil)
        })

        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })

        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.inputImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            bottomConstraint.constant = 171 // move down
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

    @IBAction func registerUser(sender: AnyObject) {
        if let userControl = self.userControl {

            userControl.name = self.inputName.text
            userControl.email = self.inputEmail.text
            userControl.height = inputHeight.text
            userControl.weight = inputWeight.text

            let imageData = UIImageJPEGRepresentation(self.inputImage.image, 0.6)
            userControl.photo = PFFile(name: userControl.objectId + ".jpg", data: imageData)

            if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
                userControl.password = self.inputPassword.text
                userControl.username = self.inputUserName.text
            }

            userControl.editUser(userControl, callback: { (error) -> () in
                if (error == nil) {
                    if(self.editView == true) {
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            })
        } else {
            let userControl = UserManager()

            userControl.name = inputName.text
            userControl.email = inputEmail.text
            userControl.username = inputUserName.text
            userControl.password = inputPassword.text
            userControl.height = inputHeight.text
            userControl.weight = inputWeight.text
            
            let imageData = UIImageJPEGRepresentation(self.inputImage.image, 0.6)
            userControl.photo = PFFile(name: userControl.objectId + ".jpg", data: imageData)

            userControl.newUser(userControl, callback: { (error) -> () in
                if(error == nil) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
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
