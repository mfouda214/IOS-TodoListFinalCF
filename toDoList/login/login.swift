//
//  login.swift
//  toDoList
//
//  Created by Mohamed Sobhi  Fouda on 2/15/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import SystemConfiguration

class login: UIViewController {

    @IBOutlet weak var emailCase: UITextField!
    @IBOutlet weak var passwordCase: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        loginButton.backgroundColor = baseColor
        loginButton.tintColor = .white
        forgotButton.tintColor = baseColor
        signupButton.backgroundColor = baseColor
        signupButton.tintColor = .white
       
        emailCase.addConstraint(emailCase.heightAnchor.constraint(equalToConstant: 50))
        passwordCase.addConstraint(passwordCase.heightAnchor.constraint(equalToConstant: 50))
        
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

        
        //action to hide Keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(login.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if(connectedToNetwork() == false){
            SVProgressHUD.showError(withStatus: "No Internet Connection")
        }
        
    }
    
    
    @IBAction func loginAction(_ sender: Any) {
    
        if(connectedToNetwork() == false){
            SVProgressHUD.showError(withStatus: "No Internet Connection")
        }
        else{
            SVProgressHUD.show()
            self.dismissKeyboard()
            PFUser.logInWithUsername(inBackground: self.emailCase.text!, password:self.passwordCase.text!) {
                (user: PFUser?, error: Error?) -> Void in
                if let error = error {
                    if let errorString = (error as NSError).userInfo["error"] as? String {
                        SVProgressHUD.showError(withStatus: errorString)
                    }
                } else {
                    
                        SVProgressHUD.dismiss()
                        self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
        
    }
    
    @IBAction func forgotPassword(_ sender: Any) {

        let alert = UIAlertController(title: "Your Email", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = UIKeyboardType.emailAddress
            textField.textAlignment = NSTextAlignment.center
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            
            if(self.connectedToNetwork() == false){
                SVProgressHUD.showError(withStatus: "No Internet Connection")
            }
            else{
            SVProgressHUD.show()
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.

            PFUser.requestPasswordResetForEmail(inBackground: (textField?.text!)!)  { (success, error) -> Void in
                if (error == nil) {
                    SVProgressHUD.showSuccess(withStatus: "Your password has been sent to your email address.")
                }
                else
                {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
            }
            }}))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func registerAction(_ sender: Any) {
        let vc = register()
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}
