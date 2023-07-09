//
//  ViewController.swift
//  CoreData-Demo
//
//  Created by Pushkar Deshmukh on 09/07/23.
//

import UIKit

class ViewController: UIViewController {
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()
    
    private var todoService: TodoServiceProtocol = TodoService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoreData - To Do List"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        getAllItems()
    }
    
    @objc func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
            
            self?.createItem(name: text)
            
        }))
        present(alert, animated: true)
    }
    
    func getAllItems() {
        todoService.getAllItems { [weak self] result in
            switch result {
                case .success(let items):
                self?.models = items
                self?.tableView.reloadData()
                
            case .failure:
                break
            }
        }
    }
//
    func createItem(name: String) {
        todoService.createItem(name: name)
        getAllItems()
    }

    func deleteItem(item: ToDoListItem) {
        todoService.deleteItem(item: item)
        getAllItems()

    }

    func update(item: ToDoListItem, newName: String) {
        todoService.update(item: item, newName: newName)
        getAllItems()
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            let alert = UIAlertController(title: "Edit", message: "Edit item", preferredStyle: .alert)
            alert.addTextField()
            alert.addAction(UIAlertAction(title: "Edit", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
                
                self?.update(item: item, newName: text)
            }))
            
            self?.present(alert, animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }
}


