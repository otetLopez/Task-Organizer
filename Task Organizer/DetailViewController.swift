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
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.getTitle()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.setList(taskList: tasksList!)
        print("Segue assignment \(self.tasksList!.count)")
        //delegate?.tasks = self.tasksList ?? [Task]()
         print("Segue assignment \(delegate?.tasks.count)")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        loadCoreData()
        NotificationCenter.default.addObserver(self, selector: #selector(saveCoreData), name: UIApplication.willResignActiveNotification, object: nil)
    }

    var detailItem: Task? {
        didSet {
            // Update the view.
            configureView()
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
//
//        func loadData() {
//            let filePath = getFilePath()
//            tasksList = [Task]()
//            if FileManager.default.fileExists(atPath: filePath) {
//                do {
//                    // Extract Data
//                    let fileContents = try String(contentsOfFile: filePath)
//                    let contentArray = fileContents.components(separatedBy: "\n")
//                    for content in contentArray {
//                        let bookContent = content.components(separatedBy: ",")
//                        if bookContent.count == 4 {
//                            let newTask = Task(title: task[0].text ?? "New Task", info: task[1].text ?? "", days: Int(task[2].text ?? "0")!)
//                            tasksList?.append(newTask)
//                        }
//                    }
//
//                } catch { print(error) }
//            }
//        }
    @IBAction func addTask(_ sender: UIButton) {
        let title = task[0].text ?? ""
        let info = task[1].text ?? ""
        let days = Int(task[2].text ?? "0") ?? 0
        
        let newTask = Task(title: task[0].text ?? "New Task", info: task[1].text ?? "", days: Int(task[2].text ?? "0") ?? 0)
        tasksList?.append(newTask)
        
        print(" Total tasks \(tasksList?.count)")
           
        clearTextFields()
    }
    
    @IBAction func resetFields(_ sender: UIButton) {
        clearTextFields()
    }
    
    func clearTextFields() {
        for textField in task {
            textField.text = ""
            //textField.resignFirstResponder()
        }
    }
        
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let TaskTable = segue.destination as? MasterViewController {
//            print("Segue assignment \(self.tasksList!.count)")
//            TaskTable.tasks = self.tasksList
//        }
//    }
        
        // Accessing Core Data
        
        @objc func saveCoreData() {
            // call clear core data first
            clearCoreData()
            // create an instance of app delegate
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // Set the context
            let managedContext = appDelegate.persistentContainer.viewContext
            for item in tasksList! {
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
    

}

