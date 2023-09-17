//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Jimmy Ghelani on 2023-09-16.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingId: UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var configuration = cell.defaultContentConfiguration()
        configuration.text = nameArray[indexPath.row]
        cell.contentConfiguration = configuration
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let paintingName = nameArray[indexPath.row]
        let paintingID = idArray[indexPath.row]
        selectedPainting = paintingName
        selectedPaintingId = paintingID
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectedPainting = selectedPainting
            destinationVC.selectedArt = selectedPaintingId
        }
    }
    
    @objc func addButtonClicked() {
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    @objc func getData() {
        nameArray.removeAll()
        idArray.removeAll()
        
        let paintings = AppData.getData()
        if let paintings = paintings {
            for painting in paintings {
                if let name = painting.name {
                    
                    nameArray.append(name)
                }
                if let id = painting.id {
                    
                    idArray.append(id)
                }
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let results = AppData.getDataWithContext(with: "id == %@", for: idArray[indexPath.row].uuidString)
            if let paintings = results?.results, let context = results?.context {
                
                if paintings.count > 0 {
                    for painting in paintings {
                        let id = painting.id
                        
                        if id == idArray[indexPath.row] {
                            context.delete(painting)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            tableView.reloadData()
                            
                            do {
                                try context.save()
                            } catch {
                                print("Couldn't delete/save the data: \(error)")
                            }
                            
                            break
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let controller = storyboard.instantiateViewController(withIdentifier: "MainVC") as! ViewController
    return UINavigationController(rootViewController: controller)
}
