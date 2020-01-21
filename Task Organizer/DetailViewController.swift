//
//  DetailViewController.swift
//  Task Organizer
//
//  Created by otet_tud on 1/19/20.
//  Copyright © 2020 otet_tud. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    var tasksList : [Task]?
    weak var delegate: MasterViewController?
    var isModifyingTask : Bool = false
    @IBOutlet var task: [UITextField]!
    @IBOutlet weak var detailDescriptionLabel: UILabel!

//    func configureView() {
//        // Update the user interface for the detail item.
//        if let detail = detailItem {
//            if let label = detailDescriptionLabel {
//                label.text = detail["url"].stringValue
//                if let url = URL(string: detail["url"].stringValue) {
//                    let request = URLRequest(url: url)
//                    webView.load(request)
//                }
//            }
//        }
//    }
    
    var detailItem: Task? {
        didSet {
            // Update the view.
            print("DEBUG this is called detailItem isEditing mode true")
            isModifyingTask = true
            //configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            print("DEBUG: title is 1 \(detail.getTitle())")
            updateTextFields(updateTask: detail)
            
            if let label = detailDescriptionLabel {
                print("DEBUG: title is 2\(detail.getTitle())")
                label.text = detail.getTitle()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG: Total items in list \(tasksList?.count)")
        for item in tasksList ?? [Task]() {
            print("\(item.getTitle())")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveCoreData()
        delegate?.setList(taskList: tasksList!)
        delegate?.tableView.reloadData()
        print("Segue assignment \(delegate?.tasks?.count)")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //configureView()
        // Do any additional setup after loading the view.
        let appleDelegate = UIApplication.shared.delegate as! AppDelegate
             
        // We need the context.  This context is the manager like location manager, audio manager
        let context = appleDelegate.persistentContainer.viewContext
        
        // Take note of the progress that should be recorded
        for idx in delegate?.progressList ?? [Task]() {
            updateData(context: context, updateTask: idx)
        }
        delegate?.progressList = [Task]()
        
        // Take note of the data that should be deleted
        for idx in delegate?.deleteList ?? [Task]() {
            deleteData(context: context, format: idx.getTitle())
        }
        delegate?.deleteList = [Task]()
        
        loadCoreData()
        NotificationCenter.default.addObserver(self, selector: #selector(saveCoreData), name: UIApplication.willResignActiveNotification, object: nil)
        
        //
        delegate?.tableView.reloadData()
        if isModifyingTask == true {
            configureView()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGesture)
    
    }

    @objc func viewTapped() {
        for textfields in task {
            textfields.resignFirstResponder()
        }
    }
    
    func getFilePath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documentPath.count > 0 {
            let documentDirectory = documentPath[0]
            let filePath = documentDirectory.appending("/data.txt")
            return filePath
        }
        return ""
    }

    @IBAction func addTask(_ sender: UIButton) {
        if isModifyingTask == true {
            for idx in tasksList ?? [Task]() {
                if idx.getTitle() == detailItem?.getTitle() && idx.getInfo() == detailItem?.getInfo() && idx.getDays() == detailItem?.getDays() {
                    idx.setDays(days: Int(task[2].text ?? String(detailItem!.getDays()))!)
                    idx.setInfo(info: task[1].text ?? detailItem!.getInfo())
                    idx.setTitle(title: task[0].text ?? detailItem!.getTitle())
                    break
                }
            }
        } else {
            if checkFields() {
                let newTask = Task(title: task[0].text ?? "New Task", info: task[1].text ?? "", days: Int(task[2].text ?? "0") ?? 0)
                tasksList?.append(newTask)
            } else {
                alertUser(type: "Error", error: "Cannot save task: Complete missing fields")
            }
        }
        print(" Total tasks \(tasksList?.count)")
        delegate?.tableView.reloadData()
        clearTextFields()
    }
    
    func checkFields() -> Bool {
        for textfield in task {
            if textfield.text?.isEmpty ?? true { return false }
        }
        return true
    }
    
    
    func alertUser(type: String, error: String) {
        let alertController = UIAlertController(title: type, message: error, preferredStyle: .alert)
              
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
              alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func resetFields(_ sender: UIButton) {
        clearTextFields()
    }
    
    func clearTextFields() {
        for textField in task {
            textField.text = ""
            textField.resignFirstResponder()
        }
    }
    
    func updateTextFields(updateTask: Task) {
        if task != nil {
        task[0].text = updateTask.getTitle()
        task[1].text = updateTask.getInfo()
        task[2].text = String(updateTask.getDays())
        } else { print("DEBUG : Fields are nil") }
    }
        
    // Accessing Core Data
    @objc func saveCoreData() {
        print("DEBUG: Saving Core Data")
            // call clear core data first
        clearCoreData()
        // create an instance of app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Set the context
        let managedContext = appDelegate.persistentContainer.viewContext
        for item in tasksList! {
            print("DEBUG: Item \(item.getTitle())")
            let taskEntity = NSEntityDescription.insertNewObject(forEntityName: "Task_Organizer", into: managedContext)
                
            taskEntity.setValue(item.title, forKey: "title")
            taskEntity.setValue(item.info, forKey: "info")
            taskEntity.setValue(item.days, forKey: "days")
            taskEntity.setValue(item.used, forKey: "used")
                
            do {
                try managedContext.save()
            } catch { print(error) }
        }
    }
        
    func loadCoreData() {
        print("DEBUG: Loading Data")
        tasksList = [Task]()
        // create an instance of app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Set the context
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task_Organizer")
        do {
            let results = try managedContext.fetch(fetchRequest) // Can cast this into as [NSManagedObject] or
            if results is [NSManagedObject] {
                for result in results as! [NSManagedObject] {
                    let title = result.value(forKey: "title") as! String
                    let info = result.value(forKey: "info") as! String
                    let days = result.value(forKey: "days") as! Int
                    let used = result.value(forKey: "used") as! Int
                        
                    tasksList?.append(Task(title: title, info: info, days: days, used: used))
                }
            }
        } catch { print(error) }
    }
        
    func clearCoreData() {
        print("DEBUG: Clearing data")
        // Create an instance of app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Set the context
        let managedContext = appDelegate.persistentContainer.viewContext
        // Create a fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task_Organizer")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObjects in results {
                if let managedObjectData = managedObjects as? NSManagedObject {
                    managedContext.delete(managedObjectData)
                }
            }
        } catch{ print(error)  }
    }

    func deleteData(context: NSManagedObjectContext, format : String) {
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task_Organizer")
        // Helps filter the query
        deleteRequest.predicate = NSPredicate(format: "title=%@", format)
        deleteRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(deleteRequest)
            if results.count > 0 {
                for idx in results as! [NSManagedObject] {
                    // Delete the user or entity
                    if let name = idx.value(forKey: "title") as? String {
                        if let info = idx.value(forKey: "info") as? String {
                            print("DEBUG: Deleting with name \(format)")
                            context.delete(idx)
                            do {
                                try context.save()
                            } catch { print(error) }
                            print(name)
                            break
                        }
                        
                    }
                }
            }
        } catch { print(error) }
    }
    
    func updateData(context: NSManagedObjectContext, updateTask : Task) {
        let addDay = NSFetchRequest<NSFetchRequestResult>(entityName: "Task_Organizer")
        // Helps filter the query
        addDay.predicate = NSPredicate(format: "title=%@", updateTask.getTitle())
        addDay.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(addDay)
            if results.count > 0 {
                for idx in results as! [NSManagedObject] {
                    //
                    if isModifyingTask == true {
                    } else {
                        // This is when adding days
                        if let used = idx.value(forKey: "used") {
                            print("DEBUG \(idx.value(forKey: "used"))")
                            let used = used as! Int
                           idx.setValue(used + 1, forKey: "used")
                        }
                    do { try context.save() } catch { print(error) }
                    }
                }
            }
        } catch { print(error) }
    }
    

}

