//
//  ViewController.swift
//  toDoList
//
//  Created by Mohamed Sobhi  Fouda on 2/15/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//


import UIKit
import FSCalendar
import Parse
import SVProgressHUD
import SystemConfiguration

class calendarTask: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    var listTask:[PFObject] = []
    var pickerFrame = UIPickerView()
    var pickerData = ["Choose a category"]
    var alert = UIAlertController()
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        self.calendar.select(Date())
       
        self.navigationController?.navigationBar.topItem?.title = "All Task"
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
        //self.view.addGestureRecognizer(self.scopeGesture)
        //self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        
        // calendar color
        //self.calendar.appearance.todayColor = UIColor(netHex: 0x1D65A6)
        self.calendar.appearance.headerTitleColor = baseColor
        self.calendar.appearance.weekdayTextColor = baseColor
        
        // calendar font
        self.calendar.appearance.titleFont = font18regular!
        self.calendar.appearance.weekdayFont = font18regular!
        self.calendar.appearance.subtitleFont = font18regular!
        self.calendar.appearance.headerTitleFont = font18regular!
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        //picker Data
        pickerData.append(contentsOf: categoryList)
        //Picker Frame
        pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216)) // CGRectMake(left, top, width, height) - left and top are like margins
        //pickerFrame.tag = 555
        //set the pickers datasource and delegate
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        
        tableView.register(UINib(nibName: "taskCell", bundle: nil), forCellReuseIdentifier: "cellTask")
        
    }
    

    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if((PFUser.current()) != nil){
//            self.fetchData()
//        }
        if((PFUser.current()) != nil){
            if(connectedToNetwork() == false){
                SVProgressHUD.showError(withStatus: "No Internet Connection")
            }
            else{
                self.fetchData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() == nil {
            let vc = login()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func doneClick(){
        alert.textFields![1].resignFirstResponder()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //print("did select date \(self.dateFormatter.string(from: date))")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        //print(formatter.string(from: date))
        //let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        //print("selected dates is \(selectedDates)")
        self.fetchData()
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    func fetchData(){
        SVProgressHUD.show()
        listTask.removeAll()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateFetch = formatter.string(from: calendar.selectedDate!)
        
        let query = PFQuery(className: "Task")
        let currentUser = PFUser.current()!
        query.whereKey("user", equalTo: currentUser)
        query.whereKey("date", equalTo: dateFetch)
        //query.limit = 10
        query.order(byAscending: "status")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                //self.hideStatus()
                self.listTask.removeAll()
                for object in objects! {
                    self.listTask.append(object)
                }
                // setup table
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                SVProgressHUD.dismiss()
            } else
            {
                let status = error?.localizedDescription
                SVProgressHUD.showError(withStatus: status)
                
            }}
    }
    
    func saveTask(date : Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        
        alert = UIAlertController(title: "New Task TO DO", message: nil, preferredStyle: .alert)
        alert.view.tintColor = baseColor
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Your Task"
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
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(calendarTask.doneClick))
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
    
    func editTask(indexTask : IndexPath){
        
        let taskSelected = self.listTask[indexTask.row]
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let task = listTask[indexPath.row]
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let status = listTask[indexPath.row]["status"] as! Bool
        let task = self.listTask[indexPath.row]

        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            // code to delete the todo goes here
            task.deleteInBackground()
            self.fetchData()
        }
        delete.backgroundColor = .red

        let updateStatus = UITableViewRowAction(style: .normal, title: (status ? "TODO" : "Done")) { (action, indexPath) in
            // code to implement the status update goes here

            let query = PFQuery(className: "Task")
            query.getObjectInBackground(withId: task.objectId!){ (object, error)-> Void in
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
    
    // MARK:- Target actions
    
    @IBAction func toggleClicked(sender: AnyObject) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        let date = calendar.selectedDate
        saveTask(date: date!)
    }
}
