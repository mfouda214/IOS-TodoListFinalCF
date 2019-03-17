//
//  register.swift
//  toDoList
//
//  Created by Mohamed Sobhi  Fouda on 2/15/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import SystemConfiguration

class register: UIViewController {
    @IBOutlet weak var emailCase: UITextField!
    @IBOutlet weak var passwordCase: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loginButton.backgroundColor = baseColor
        loginButton.tintColor = .white
        registerButton.backgroundColor = baseColor
        registerButton.tintColor = .white
        
        emailCase.addConstraint(emailCase.heightAnchor.constraint(equalToConstant: 50))
        passwordCase.addConstraint(passwordCase.heightAnchor.constraint(equalToConstant: 50))
        passwordConfirm.addConstraint(passwordConfirm.heightAnchor.constraint(equalToConstant: 50))
        
        // email case border
        emailCase.borderStyle = .none
        emailCase.layoutIfNeeded()
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = baseColor.cgColor
        border.frame = CGRect(x: 0, y: emailCase.frame.size.height - width, width:  emailCase.frame.size.width, height: emailCase.frame.size.height)
        border.borderWidth = width
        emailCase.layer.addSublayer(border)
        emailCase.layer.masksToBounds = true

        let imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image1 = UIImage(named: "at.png")
        imageView1.image = image1?.withRenderingMode(.alwaysTemplate)
        imageView1.tintColor = baseColor
        emailCase.leftView = imageView1
        emailCase.leftViewMode = .always

        // password case border
        passwordCase.borderStyle = .none
        passwordCase.layoutIfNeeded()
        let border2 = CALayer()
        let width2 = CGFloat(2.0)
        border2.borderColor = baseColor.cgColor
        border2.frame = CGRect(x: 0, y: passwordCase.frame.size.height - width2, width:  passwordCase.frame.size.width, height: passwordCase.frame.size.height)
        border2.borderWidth = width2
        passwordCase.layer.addSublayer(border2)
        passwordCase.layer.masksToBounds = true

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "pass.png")
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = baseColor
        passwordCase.leftView = imageView
        passwordCase.leftViewMode = .always

        // password confirm border
        passwordConfirm.borderStyle = .none
        passwordConfirm.layoutIfNeeded()
        let border3 = CALayer()
        let width3 = CGFloat(2.0)
        border3.borderColor = baseColor.cgColor
        border3.frame = CGRect(x: 0, y: passwordConfirm.frame.size.height - width3, width:  passwordConfirm.frame.size.width, height: passwordConfirm.frame.size.height)
        border3.borderWidth = width3
        passwordConfirm.layer.addSublayer(border3)
        passwordConfirm.layer.masksToBounds = true

        let imageView3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image3 = UIImage(named: "pass.png")
        imageView3.image = image3?.withRenderingMode(.alwaysTemplate)
        imageView3.tintColor = baseColor
        passwordConfirm.leftView = imageView3
        passwordConfirm.leftViewMode = .always

        
        //action to hide Keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(register.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if(connectedToNetwork() == false){
            SVProgressHUD.showError(withStatus: "No Internet Connection")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        if(connectedToNetwork() == false){
            SVProgressHUD.showError(withStatus: "No Internet Connection")
        }
        else {
        SVProgressHUD.show()
        self.dismissKeyboard()
        if(passwordCase.text == passwordConfirm.text){
          let user = PFUser()
          user.username = self.emailCase.text
          user.password = self.passwordCase.text
          user.email = self.emailCase.text
        
          user.signUpInBackground {
            (success, error) -> Void in
            if let error = error {
                SVProgressHUD.showError(withStatus: "")
                if let errorString = (error as NSError).userInfo["error"] as? String {
                    SVProgressHUD.showError(withStatus: errorString)
                }
            } else {
                // Hooray! Let them use the app now.
                SVProgressHUD.showSuccess(withStatus: "successfully registered")
                self.dismiss(animated: true, completion: nil)
            }
          }
        } else {
            SVProgressHUD.showError(withStatus: "Verify your password.")
        }
        }
    }
    
    
    @IBAction func loginAction(_ sender: Any) {
        self.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
