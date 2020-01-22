//
//  MasterViewController.swift
//  Task Organizer
//
//  Created by otet_tud on 1/19/20.
//  Copyright © 2020 otet_tud. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var sortLabel: UILabel!
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var tasks : [Task]?
    var sortIndex : Int = 0
    var sortedTasks = [Task]()
    
    //For the searchbar
    var resultSearchController : UISearchController!
    var filteredTableData = [Task]()

    override func viewDidLoad() {
      
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsSelection = true
        load_init()

//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //Set searchbar
            resultSearchController = ({
                let controller = UISearchController(searchResultsController: nil)
                controller.searchResultsUpdater = self
                controller.definesPresentationContext = true
                controller.searchBar.placeholder = "Search task"
                controller.obscuresBackgroundDuringPresentation = false
                controller.searchBar.sizeToFit()
                controller.searchBar.autocapitalizationType = .none
                return controller
                })()

                navigationItem.searchController = resultSearchController
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        sortLabel.text = ""
        filteredTableData.removeAll()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.resultSearchController.isActive {
                let DeleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, success) in
                    let deleteTask = self.filteredTableData[indexPath.row]
                    self.filteredTableData.remove(at: indexPath.row)
                    let index = self.getTaskIndex(selectedTask: deleteTask)
                    print("DEBUG: deleting at index \(self.getTaskIndex(selectedTask: deleteTask))")
                    self.tasks?.remove(at: index)
                    self.saveModifications()
                    self.deleteData(format: deleteTask.getTitle())
                    tableView.deleteRows(at: [indexPath], with: .fade)})
                    
                let AddDayAction = UIContextualAction(style: .normal, title: "Add day", handler: { (action, view, success) in
                    self.setDays(task: self.filteredTableData[indexPath.row])
                    self.saveModifications()})
            
                return UISwipeActionsConfiguration(actions: [DeleteAction, AddDayAction])
            } else {
                let DeleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, success) in
                    self.deleteData(format: (self.tasks?[indexPath.row].getTitle())!)
                    self.tasks?.remove(at: indexPath.row)
                    self.saveModifications()
                    tableView.deleteRows(at: [indexPath], with: .fade)})
                    
                    let AddDayAction = UIContextualAction(style: .normal, title: "Add day", handler: { (action, view, success) in
                        self.setDays(task: self.tasks![indexPath.row])
                        self.saveModifications()})
    
                    return UISwipeActionsConfiguration(actions: [DeleteAction, AddDayAction])
        }
        return UISwipeActionsConfiguration(actions: [])
    }
    
    func getTaskIndex(selectedTask : Task) -> Int {
        var index : Int = 0
        for idx in self.tasks ?? [Task]() {
            if idx.getTitle() == selectedTask.getTitle() && idx.getInfo() == selectedTask.getInfo() && idx.getDays() == selectedTask.getDays() {
                print("DEBUG: Deleting task at index : \(index) from \(self.tasks?.count)")
                break
            }
            index += 1
        }
        return index
    }
    
    func setDays(task: Task) {
        if task.getDaysConsumed() < task.getDays() {
            task.setDaysConsumed()
        }
        tableView.reloadData()
    }
    func loadList() {
        
    }

    @objc
    func insertNewObject(_ sender: Any) {
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = resultSearchController.isActive ?  filteredTableData[indexPath.row] : tasks?[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
        
        if let delegate = (segue.destination as! UINavigationController).topViewController as! DetailViewController? {
                  delegate.delegate = self
              }
    }
    

    func setList(taskList: [Task]) {
        print("DEBUG: Setting tasks List")
        self.tasks = taskList
    }
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (resultSearchController.isActive) ? filteredTableData.count : tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasks", for: indexPath)
        let currTask = resultSearchController.isActive ? filteredTableData[indexPath.row] : tasks![indexPath.row]
        cell.textLabel?.text = currTask.getTitle()
        if currTask.getDaysConsumed() == currTask.getDays() {
            cell.detailTextLabel?.text = "Task Completed"
            cell.contentView.backgroundColor = UIColor.lightGray
        } else {
            cell.detailTextLabel?.text = "Progress: " + String(currTask.getDaysConsumed()) + "/" + String(currTask.getDays())
            cell.contentView.backgroundColor = UIColor.white
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        for idx in tasks ?? [Task]() {
            if idx.getTitle().localizedCaseInsensitiveContains(searchController.searchBar.text!) || idx.getInfo().localizedCaseInsensitiveContains(searchController.searchBar.text!) {
                filteredTableData.append(idx)
            }
        }

        self.tableView.reloadData()
    }
    
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        sortIndex += 1
        print("DEBUG: Sorting by \(sortIndex)")
        if tasks?.count ?? 0 > 0 {
            switch(sortIndex) {
            case 1:
                // Sort By Name
                sortedTasks = tasks!.sorted { $0.title < $1.title }
                tasks = sortedTasks
                sortLabel.text = "Sorted By Name △"
            case 2:
                // Sort By Date
                // This will use the existing array tasks[]
                // But will just divide the section
                sortedTasks = tasks!.sorted { $0.title > $1.title }
                tasks = sortedTasks
                sortLabel.text = "Sorted By Name ▽"
            case 3:
                sortedTasks = tasks!.sorted { $0.date < $1.date }
                tasks = sortedTasks
                sortLabel.text = "Sorted By Date Created △"
            case 4:
                sortedTasks = tasks!.sorted { $0.date > $1.date }
                tasks = sortedTasks
                sortIndex = 0
                sortLabel.text = "Sorted By Date Created ▽"
            default:
                sortIndex = 0
                sortedTasks = tasks ?? [Task]()
                break
            }
            tableView.reloadData()
        }
    }
    
    func load_init() {
        print("DEBUG: Loading Initial Data")
        tasks = [Task]()
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
                    let date = result.value(forKey: "created") as! String
                    
                    tasks?.append(Task(title: title, info: info, days: days, used: used, date: date))
                }
            }
        } catch { print(error) }
    }
    
    func saveModifications() {
        print("DEBUG: Saving Modifications")
            // call clear core data first
        clearCoreData()
        // create an instance of app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Set the context
        let managedContext = appDelegate.persistentContainer.viewContext
        for item in tasks! {
            let taskEntity = NSEntityDescription.insertNewObject(forEntityName: "Task_Organizer", into: managedContext)
                
            taskEntity.setValue(item.title, forKey: "title")
            taskEntity.setValue(item.info, forKey: "info")
            taskEntity.setValue(item.days, forKey: "days")
            taskEntity.setValue(item.used, forKey: "used")
            taskEntity.setValue(item.date, forKey: "created")
                
            do {
                try managedContext.save()
            } catch { print(error) }
        }
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
    
    func deleteData(format : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
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
    
}

