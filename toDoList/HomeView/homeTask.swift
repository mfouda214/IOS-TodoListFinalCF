//
//  ViewController2.swift
//  toDoList
//
//  Created by Mohamed Sobhi  Fouda on 2/15/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Parse
import SVProgressHUD
import SystemConfiguration

class homeTask: UIViewController , UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {

    var tableView: UITableView = UITableView()

    var listTask:[PFObject] = []
    var doneTask:[PFObject] = []
    var allTask:[PFObject] = []
    
    var pickerFrame = UIPickerView()
    var pickerData = ["Choose a category"]
    var alert = UIAlertController()
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let localeLan = NSLocale(localeIdentifier: "en") as Locale?
        formatter.locale = localeLan
        let result = formatter.string(from: date)
        
        self.navigationController?.navigationBar.topItem?.title = "Today,  " + result
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .automatic
            
            let attributes = [
                NSAttributedString.Key.foregroundColor : navigationBarTintColor, NSAttributedString.Key.font: font34base!,
                ]
            
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
            
        } else {
            // Fallback on earlier versions
        }
        
        // setup table
        self.setupTable()

        // picker data
        pickerData.append(contentsOf: categoryList)
        //picker frame
        pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216)) // CGRectMake(left, top, width, height) - left and top are like margins
        pickerFrame.tag = 555
        //set the pickers datasource and delegate
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        
        // In this case, we instantiate the banner with desired ad size.
        if(admobEnable){
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = admobAdUnit
        bannerView.rootViewController = self
        //let request = GADRequest()
        //request.testDevices = [kGADSimulatorID]
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if((PFUser.current()) != nil){
            if(connectedToNetwork() == false){
                SVProgressHUD.showError(withStatus: "No Internet Connection")
            }
            else{
                self.fetchData()
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        //var actionSheet: UIAlertController!
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let logAction = UIAlertAction(title: "Logout", style: .destructive, handler: {
        (alert: UIAlertAction!) -> Void in
            PFUser.logOut()
            _ = PFUser.current() // this will now be nil
            if PFUser.current() == nil {
                let vc = login()
                self.present(vc, animated: true, completion: nil)
            }
            
        })
        actionSheet.addAction(logAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    @objc func doneClick(){
        alert.textFields![1].resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() == nil {
            let vc = login()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)

        alert = UIAlertController(title: "New Task TO DO", message: nil, preferredStyle: .alert)
        alert.view.tintColor = baseColor
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Your Task ..."
            textField.textAlignment = .center
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 40))
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Choose Category"
            textField.textAlignment = .center
            textField.inputView = self.pickerFrame
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 20))

            // ToolBar
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = baseColor
            toolBar.sizeToFit()

            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(homeTask.doneClick))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            doneButton.setTitleTextAttributes([NSAttributedString.Key.font: font18regular!], for: .normal)
            doneButton.tintColor = baseColor
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            
            SVProgressHUD.show()
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let descr = textField?.text
            let categ = alert?.textFields![1].text
            let task = PFObject(className: "Task")
            let currentUser = PFUser.current()!
            task["description"] = descr
            if(categ == "Choose a category") || (categ == ""){
                task["category"] = "Others"
            }else {
                task["category"] = categ
            }
            task["date"] = result
            task["status"] = false
            task["user"] = currentUser
            task.saveInBackground { (success, error) -> Void in
                if error == nil {
                    self.fetchData()
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }}

        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func setupTable(){
        tableView = UITableView(frame: UIScreen.main.bounds, style: UITableView.Style.plain)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.register(UINib(nibName: "taskCell", bundle: nil), forCellReuseIdentifier: "cellTask")
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.frame.size.height = UIScreen.main.bounds.height - (self.navigationController?.navigationBar.bounds.size.height)! - 20
        if(admobEnable){
            tableView.frame.size.height = tableView.frame.size.height - 50
        }
        tableView.allowsSelection = false
        //tableView.backgroundColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1.0)
        self.view.addSubview(self.tableView)
        
    }
    
    @objc func fetchData(){
        SVProgressHUD.show()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateFetch = formatter.string(from: Date())
        
        let query = PFQuery(className: "Task")
        let currentUser = PFUser.current()!
        query.whereKey("user", equalTo: currentUser)
        query.whereKey("date", equalTo: dateFetch)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                //self.hideStatus()
                self.listTask.removeAll()
                self.doneTask.removeAll()
                self.allTask.removeAll()
                _ = deleteAll()
                self.allTask = objects!
                for object in objects! {
                    let statusToDo = object["status"] as! Bool
                    if(statusToDo == false){
                        self.listTask.append(object)
                        _ = addTaskToday(task: object["description"] as! String)
                    }
                    else{
                        self.doneTask.append(object)
                    }
                }
                // setup table
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                SVProgressHUD.dismiss()
            } else {
                
                let status = error as? String
                SVProgressHUD.showError(withStatus: status)
                
            }}
        
    }
    
    func editTask(indexTask : IndexPath){
        
        var taskSelected = PFObject(className: "Task")
        if(indexTask.section == 0){
            taskSelected = self.listTask[indexTask.row]
        } else {
            taskSelected = self.doneTask[indexTask.row]
        }

        alert = UIAlertController(title: "Edit Task TO DO", message: nil, preferredStyle: .alert)
        alert.view.tintColor = baseColor

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Your Task"
            textField.textAlignment = .center
            textField.text = taskSelected["description"] as? String
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 40))
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Choose Category"
            textField.textAlignment = .center
            textField.text = taskSelected["category"] as? String
            textField.inputView = self.pickerFrame
            textField.font = font16regular!
            textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 20))

            // ToolBar
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.sizeToFit()
            toolBar.tintColor = baseColor

            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(homeTask.doneClick))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            doneButton.setTitleTextAttributes([NSAttributedString.Key.font: font18regular!], for: .normal)
            doneButton.tintColor = baseColor
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let descr = textField?.text
            let categ = alert?.textFields![1].text
            
            let query = PFQuery(className: "Task")
            query.getObjectInBackground(withId: taskSelected.objectId!){ (object, error)-> Void in
                if object != nil && error == nil {
                    object!["description"] = descr
                    object!["category"] = categ
                    if(categ == "Choose a category") || (categ == ""){
                        object!["category"] = "Others"
                    }
                    object!.saveInBackground()
                }
                else {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                self.fetchData()
            }
        }))
      
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    // MARK:- UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [listTask.count,doneTask.count][section]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header1 = "TODO (\(listTask.count))"
        let header2 = "Done (\(doneTask.count))"
        
        return [header1,header2][section]
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var task = PFObject(className: "Task")
        if(indexPath.section == 0){
           task = listTask[indexPath.row]
        } else {
           task = doneTask[indexPath.row]
        }
        let descr = task["description"] as! String
        let category = task["category"] as! String
        let status = task["status"] as! Bool
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath) as! taskCell
        cell.category.text = category
        cell.titleTask.text = descr
        
        if(status){
            cell.statusTask.backgroundColor = doneColor
        }else{
            cell.statusTask.backgroundColor = todoColor
        }
        
        return cell
    }
    
    
    // MARK:- UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath, animated: true)
        //        if indexPath.section == 0 {
        //            let scope: FSCalendarScope = (indexPath.row == 0) ? .month : .week
        //            self.calendar.setScope(scope, animated: true)
        //        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var status : Bool!
        var task = PFObject(className: "Task")
        if(indexPath.section == 0){
            task = self.listTask[indexPath.row]
            status = (task["status"] as! Bool)
        }
        else {
           task = self.doneTask[indexPath.row]
            status = (task["status"] as! Bool)
        }
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in

            task.deleteInBackground()
            self.fetchData()
            
        }
        delete.backgroundColor = .red
        
        let updateStatus = UITableViewRowAction(style: .normal, title: (status ? "TODO" : "Done")) { (action, indexPath) in
            // code to implement the status update goes here
            
            var taskSelected = PFObject(className: "Task")
            if(indexPath.section == 0){
                taskSelected = self.listTask[indexPath.row]
            }else {
                taskSelected = self.doneTask[indexPath.row]
            }
            
            let query = PFQuery(className: "Task")
            query.getObjectInBackground(withId: taskSelected.objectId!){ (object, error)-> Void in
                if object != nil && error == nil {
                    if(status){
                        object!["status"] = false
                    }
                    else {
                        object!["status"] = true
                    }
                    object!.saveInBackground()
                }
                else {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                self.fetchData()
            }
            
        }
        
        updateStatus.backgroundColor = (status ? baseColor : UIColor(netHex: 0x00743F))
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            // code to implement the edit task goes here
            self.editTask(indexTask: indexPath)
         
        }
        edit.backgroundColor = UIColor(netHex: 0xF2A104)
        
        return [delete, edit, updateStatus]
    }

    // MARK:- picker view

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        alert.textFields![1].text = pickerData[row]
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


