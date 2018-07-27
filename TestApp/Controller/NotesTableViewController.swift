//
//  NoteTableViewController.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

private let noteCellId = "NoteCell";
class NotesTableViewController: FetchedResultsTableViewController, AlertDelegate {
    
    lazy var searchButton: UIButton = {
        let button = UIButton(type: .custom);
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 32);
        button.backgroundColor = .clear;
        button.setImage(#imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate), for: .normal);
        button.imageView?.tintColor = Style.mainColor;
        button.addTarget(self, action: #selector(searchTapped), for: .touchUpInside);
        return button;
    }();
    
    lazy var statusSegment: UISegmentedControl = {
        let items = ["Active", "Done"];
        let segment = UISegmentedControl(items: items);
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged);
        segment.tintColor = Style.mainColor;
        segment.selectedSegmentIndex = 0;
        segment.translatesAutoresizingMaskIntoConstraints = false;
        return segment;
    }();
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer;
    fileprivate var fetchedResultsController: NSFetchedResultsController<Note>?
    
    let searchController = UISearchController(searchResultsController: nil);
    
    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.backgroundColor = .white;
        tableView.separatorStyle = .none;
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: noteCellId);
        
        // Search controller
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.delegate = self;
        self.searchController.searchResultsUpdater = self;
        self.searchController.dimsBackgroundDuringPresentation = false;
        self.definesPresentationContext = false;
        self.searchController.searchBar.showsCancelButton = true;
        self.searchController.searchBar.placeholder = "search".localized;
        
        let searchBarButton = UIBarButtonItem(customView: searchButton);
        let addNotBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteTapped));
        self.navigationItem.leftBarButtonItem = searchBarButton;
        self.navigationItem.rightBarButtonItem = addNotBarButton;
        self.navigationItem.titleView = statusSegment;
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlertsStatus), name: Notification.Name(rawValue: "updateAlertStatus"), object: nil);
        
        self.checkIfEmpty();
    
    }

    // Load data from Core Data and update the UI
    @objc private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Note> = Note.fetchRequest();
            let selector = #selector(NSString.caseInsensitiveCompare(_:));
            request.sortDescriptors = [NSSortDescriptor(key: "updatedDate", ascending: false, selector: selector)];
            if(self.searchController.isActive) {
                let searchedText = self.searchController.searchBar.text != nil ? self.searchController.searchBar.text! : "";
        
                let titlePredicate = NSPredicate(format: "title CONTAINS [c] %@", searchedText);
                 let detailsPredicate = NSPredicate(format: "details CONTAINS [c] %@", searchedText);
                let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, detailsPredicate]);
                request.predicate = compoundPredicate;
                
            } else {
                request.predicate = NSPredicate(format: "isDone == %@", NSNumber(value: self.statusSegment.selectedSegmentIndex != 0));
            }
        
            fetchedResultsController = NSFetchedResultsController<Note>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            fetchedResultsController?.delegate = self;
            try? fetchedResultsController?.performFetch();
            self.updateTableView();
        }
    }
    
    var selectedSegmentIndex = 0;
    @objc private func updateAlertsStatus() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Note> = Note.fetchRequest();
            let selector = #selector(NSString.caseInsensitiveCompare(_:));
            request.sortDescriptors = [NSSortDescriptor(key: "updatedDate", ascending: false, selector: selector)];
            request.predicate = NSPredicate(format: "isDone == %@", NSNumber(value: selectedSegmentIndex != 0));
            fetchedResultsController = NSFetchedResultsController<Note>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
    
            fetchedResultsController?.delegate = self;
            try? fetchedResultsController?.performFetch();
            DispatchQueue.main.async {
                self.updateTableView();
            }
            self.scheduleNotifications(notes: fetchedResultsController?.fetchedObjects);
        }
    }
    
    private func updateTableView() {
         self.tableView.reloadData();
        self.checkIfEmpty();
    }
    
    private func checkIfEmpty(){
        if let context = container?.viewContext {    // context == main context on main thread
            context.perform {
                let req: NSFetchRequest<Note> = Note.fetchRequest()
                req.predicate = NSPredicate(format: "isDone == %@", NSNumber(value: self.statusSegment.selectedSegmentIndex != 0));
                if let noteCount = (try? context.fetch(req))?.count {
                    if (noteCount > 0) {
                        self.tableView.backgroundView = nil;
                    } else {
                        let message = self.statusSegment.selectedSegmentIndex == 0 ? "There is no notes to show. Please tap + icon to add a new one.".localized : "There is no done notes to show. When you mark a note as done, it will appear here.".localized;
                        self.tableView.backgroundView = EmptyStateView(message: message);
                    }
                }
            }
        }
    }
    
    @objc private func segmentChanged() {
        self.updateUI();
    }
    
    @objc private func addNoteTapped() {
        let newNoteController = NewNoteViewController();
        let newNoteNavigationController = ParentNavigationController(rootViewController: newNoteController);
        self.present(newNoteNavigationController, animated: true, completion: nil);
    }
    
    private func scheduleNotifications(notes: [Note]?) {
        guard let notes = notes else { return }
        for note in notes {
            if note.alertDate != nil && note.alertDate! > Date() {
                createNotificationFor(note: note);
            }
        }
    }
    
    private func createNotificationFor(note: Note) {
        let notificationContent = UNMutableNotificationContent();
  
        notificationContent.title = "Sepehr Note";
        notificationContent.body = "\(note.title!) is overdue.";
        
        let timeInterval = note.alertDate!.timeIntervalSince(Date());
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false);
        
        let notificationRequest = UNNotificationRequest(identifier: "sepehr-not-\(Int(timeInterval))" , content: notificationContent, trigger: notificationTrigger);
    
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))");
            }
        }
    }
    
    // MARK: AlertDelegate
    
    func reloadNotes() {
        self.selectedSegmentIndex = self.statusSegment.selectedSegmentIndex;
        self.updateAlertsStatus();
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteCellId, for: indexPath) as! NoteTableViewCell;
        if let note = fetchedResultsController?.object(at: indexPath) {
            cell.note = note;
        }
        cell.alertDelegate = self;
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let note = fetchedResultsController?.object(at: indexPath) {
            if(note.alertDate != nil){
                return 86;
            }
        }
        return 70;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let note = fetchedResultsController?.object(at: indexPath) {
            let noteDetailsController = NoteDetailsViewController();
            noteDetailsController.note = note;
            self.navigationController?.pushViewController(noteDetailsController, animated: true);
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]?{
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { _, index in
            let alertController = UIAlertController(title: "Delete", message: "Are you sure for deleting this note?", preferredStyle: .alert);
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                if let note = self.fetchedResultsController?.object(at: editActionsForRowAt) {
                    if let context = self.container?.viewContext {
                        note.delete(in: context);
                        self.updateUI();
                    }
                }
            })
            
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil);
            
            alertController.addAction(yesAction);
            alertController.addAction(noAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
        
        delete.backgroundColor = Style.errorColorRed;
        
        let done = UITableViewRowAction(style: .normal, title: "Done") { action, index in
            if let note = self.fetchedResultsController?.object(at: editActionsForRowAt) {
                note.setDone();
            }
        }
        done.backgroundColor = Style.mainColor;
        
        if(self.statusSegment.selectedSegmentIndex == 0){
            return [delete, done];
        } else {
            return [delete];
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
}

extension NotesTableViewController {
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects;
        } else {
            return 0;
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name;
        } else {
            return nil;
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles;
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0;
    }
}



extension NotesTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        updateUI();
    }
    
    @objc private func dissmissSearch() {
        self.searchController.dismiss(animated: true, completion: nil);
    }
    
    @objc fileprivate func searchTapped() {
        self.present(searchController, animated: true, completion: nil);
    }
}
