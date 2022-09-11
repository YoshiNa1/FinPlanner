//
//  ListViewController.swift
//  FinancePlanner
//
//  Created by Anastasiia on 26.08.2022.
//

import UIKit
import RealmSwift

class ListItems: Object {
    var items = List<String>()
}

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var newNoteField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let previewParameters: UIDragPreviewParameters = {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }()
    
    let realm = try! Realm()
    var list : Array<String> {
        get {
            if let list = self.realm.objects(ListItems.self).first?.items {
                return Array(list)
            }
            return Array<String>()
        }
        set {
            try! self.realm.write {
                self.realm.deleteAll()
                let list = ListItems()
                list.items.append(objectsIn: newValue)
                self.realm.add(list)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addButton.isEnabled = false
        self.newNoteField.addTarget(self, action: #selector(noteFieldDidChange), for: .editingChanged)
        self.doneButton.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listTableViewCell")
      
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tableView.addGestureRecognizer(tapGesture)

        updateUI()
    }
    
    func updateUI() {
        tableView.reloadData()
    }
    
    @IBAction func didAddNewNote(_ sender: Any) {
        if let newNoteString = self.newNoteField.text {
            self.list.append(newNoteString)
            self.newNoteField.text = ""
            self.addButton.isEnabled = false
            updateUI()
        }
    }
    
    @IBAction func didEndEditing(_ sender: Any) {
        view.endEditing(true)
        doneButton.isHidden = true
    }

    @objc func keyboardDidShow() {
        doneButton.isHidden = false
    }
    
    @objc func noteFieldDidChange() {
        self.addButton.isEnabled = (newNoteField.text?.isEmpty == false)
    }
 
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let gestureLocation = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: gestureLocation) else { return }
        let cell = tableView.cellForRow(at: indexPath) as! ListTableViewCell

        let cellIconFrame = tableView.convert(cell.iconView.frame, from:cell)
        if cellIconFrame.contains(gestureLocation) {
            if(gesture.state == .ended) {
                let item = list[indexPath.item]

                var newItem = item
                if item.contains("<done>") {
                    newItem = item.replacingOccurrences(of:"<done>", with:"")
                } else {
                    newItem = item + "<done>"
                }
                list.remove(at: indexPath.item)
                list.insert(newItem, at: indexPath.item)
                updateUI()
            }
        }
    }
}

extension ListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listTableViewCell", for: indexPath) as! ListTableViewCell
        let item = list[indexPath.row]
        cell.configureCell(with: item)
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
            self.list.remove(at: indexPath.row)
            self.updateUI()
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
}

extension ListViewController: UITableViewDragDelegate, UITableViewDropDelegate  {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = list[sourceIndexPath.row]
        list.remove(at: sourceIndexPath.item)
        list.insert(item, at: destinationIndexPath.row)
        updateUI()
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = list[indexPath.row]
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters
    }
    
    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}

extension ListViewController: ListTableViewCellDelegate {
    func textFieldDidChange(_ textField: UITextField, at indexPath: IndexPath) {
        if indexPath.item < list.count {
            guard let text = textField.text else { return }
            list[indexPath.item] = text
            
            if text == "" {
                self.list.remove(at: indexPath.row)
                UIView.transition(with: tableView, duration: 0.4) {
                    self.updateUI()
                }
            }
        }
    }
}
