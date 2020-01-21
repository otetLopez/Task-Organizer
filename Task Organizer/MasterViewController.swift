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

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var deleteList = [Task]()
    var progressList = [Task]()
    var tasks : [Task]?
    
    //For the searchbar
    var resultSearchController : UISearchController!
    var filteredTableData = [Task]()

    override func viewDidLoad() {
      
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem
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
                    self.deleteList.append(deleteTask)
                    self.filteredTableData.remove(at: indexPath.row)
                    //self.tasks?.remove(at: self.getTaskIndex(selectedTask: deleteTask))
                    let index = self.getTaskIndex(selectedTask: deleteTask)
                    print("DEBUG: deleting at index \(self.getTaskIndex(selectedTask: deleteTask))")
                    self.tasks?.remove(at: index)
                tableView.deleteRows(at: [indexPath], with: .fade)})
                    
                        
                let AddDayAction = UIContextualAction(style: .normal, title: "Add day", handler: { (action, view, success) in
                    self.setDays(task: self.filteredTableData[indexPath.row])
                    //self.setDays
                    self.progressList.append(self.filteredTableData[indexPath.row])})
                        
                return UISwipeActionsConfiguration(actions: [DeleteAction, AddDayAction])
            } else {
            let DeleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, success) in
                    self.deleteList.append(self.tasks![indexPath.row])
                    self.tasks?.remove(at: indexPath.row)
                
                    tableView.deleteRows(at: [indexPath], with: .fade)})
                    
                    let AddDayAction = UIContextualAction(style: .normal, title: "Add day", handler: { (action, view, success) in
                        self.setDays(task: self.tasks![indexPath.row])
                        self.progressList.append(self.tasks![indexPath.row])})
                    
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
                        
                    tasks?.append(Task(title: title, info: info, days: days, used: used))
                }
            }
        } catch { print(error) }
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            deleteList.append(tasks![indexPath.row])
//            tasks?.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }

//    func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
//        cell.textLabel!.text = event.timestamp!.description
//    }
//
//    // MARK: - Fetched results controller
//
//    var fetchedResultsController: NSFetchedResultsController<Event> {
//        if _fetchedResultsController != nil {
//            return _fetchedResultsController!
//        }
//
//        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
//
//        // Set the batch size to a suitable number.
//        fetchRequest.fetchBatchSize = 20
//
//        // Edit the sort key as appropriate.
//        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
//
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        // Edit the section name key path and cache name if appropriate.
//        // nil for section name key path means "no sections".
//        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
//        aFetchedResultsController.delegate = self
//        _fetchedResultsController = aFetchedResultsController
//
//        do {
//            try _fetchedResultsController!.performFetch()
//        } catch {
//             // Replace this implementation with code to handle the error appropriately.
//             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//             let nserror = error as NSError
//             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//
//        return _fetchedResultsController!
//    }
//    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//            case .insert:
//                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//            case .delete:
//                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//            default:
//                return
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//            case .insert:
//                tableView.insertRows(at: [newIndexPath!], with: .fade)
//            case .delete:
//                tableView.deleteRows(at: [indexPath!], with: .fade)
//            case .update:
//                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
//            case .move:
//                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
//                tableView.moveRow(at: indexPath!, to: newIndexPath!)
//            default:
//                return
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

