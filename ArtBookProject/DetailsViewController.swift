//
//  DetailsViewController.swift
//  ArtBookProject
//
//  Created by Jimmy Ghelani on 2023-09-16.
//

import UIKit
import PhotosUI
import CoreData

class DetailsViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var artist: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedPainting = ""
    var selectedArt: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedPainting != "" {
            //MARK: - Get Data
            getData()
        } else {
            name.text = ""
            artist.text = ""
            year.text = ""
            saveButton.isEnabled = false
        }
        
        name.isEnabled = selectedPainting == ""
        artist.isEnabled = selectedPainting == ""
        year.isEnabled = selectedPainting == ""
        saveButton.isHidden = selectedPainting != ""
        saveButton.isEnabled = selectedPainting != ""
        
        if(selectedPainting == "") {
            
            //MARK: - Hide Keyboard Gesture
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(gestureRecognizer)
            
            //MARK: - Image Gesture
            imageView.isUserInteractionEnabled = true
            let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            imageView.addGestureRecognizer(imageTapRecognizer)
        }

    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration )
        picker.delegate = self
        
        present(picker, animated: true)
        
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        AppData.saveData(for: name.text, by: artist.text, in: year.text, with: imageView)
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        let previousImage = imageView.image
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    self.imageView.image = image
                    self.saveButton.isEnabled = true
                }
            }
        }
    }
    
    func getData() {
        let results = AppData.getData()
        
        if let results = results {
            
            if results.count > 0 {
                for painting in results {
                    name.text = painting.name
                    artist.text = painting.artist
                    year.text = String(painting.year)
                    imageView.image = UIImage(data: painting.image!)
                }
                
            }
        }
    }
    
}

#Preview {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let controller = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
    return controller
}
