//
//  ItemDetailViewController.swift
//  BCSwap
//
//  Created by Mark Lee on 4/24/19.
//  Copyright © 2019 Mark Lee. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class ItemDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var contactInfoField: UITextField!
    @IBOutlet weak var pickupLocationField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var addImageLabel: UILabel!
    
    var items: Items!
    var item: Item!
    var imagePicker = UIImagePickerController()
    var photos: Photos!
    
    let regionDistance: CLLocationDistance = 750 // 750 meters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // mapView.delegate = self
        imagePicker.delegate = self
        
        if item == nil {
            item = Item()
            
            // editable fields should have a border around them
            itemNameField.addBorder(width: 0.5, radius: 5.0, color: .black)
            priceField.addBorder(width: 0.5, radius: 5.0, color: .black)
            contactInfoField.addBorder(width: 0.5, radius: 5.0, color: .black)
            pickupLocationField.addBorder(width: 0.5, radius: 5.0, color: .black)
        } else {
            // disable text editing
            imageButton.isHidden = true
            addImageLabel.isHidden = true
            itemNameField.isEnabled = false
            priceField.isEnabled = false
            contactInfoField.isEnabled = false
            pickupLocationField.isEnabled = false
            itemNameField.backgroundColor = UIColor.white
            priceField.backgroundColor = UIColor.white
            contactInfoField.backgroundColor = UIColor.white
            pickupLocationField.backgroundColor = UIColor.white
            // "Save" and "Cancel" buttons should be hidden
            saveBarButton.title = ""
            cancelBarButton.title = ""
            // Hide Toolbar so that "Add Pickup Location" isn't available
            navigationController?.setToolbarHidden(true, animated: true)
        }
        
        itemNameField.text! = item.name
        priceField.text! = item.price
        contactInfoField.text! = item.contactInfo
        pickupLocationField.text! = item.pickupLocation
        
        photos = Photos()
        items = Items()
        
        let region = MKCoordinateRegion(center: item.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        items.loadData() {
//            for item in self.items.itemsArray {
//                self.photos.loadData(item: item) {
//                    self.imageView.image =
//                }
//        }
            
            // self.imageView.reloadData()
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateUserInterface()
    }
    
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        saveBarButton.isEnabled = !(itemNameField.text == "")
    }
    
    @IBAction func textFieldReturnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
        updateUserInterface()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUserInterface() {
        item.name = itemNameField.text!
        item.price = priceField.text!
        item.contactInfo = contactInfoField.text!
        pickupLocationField.text! = item.pickupLocation
        updateMap()
    }
    
    func updateMap () {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(item)
        mapView.setCenter(item.coordinate, animated: true)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.accessCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Library", style: .default) { _ in
            self.accessLibrary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        cameraOrLibraryAlert()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        self.updateUserInterface()
        item.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because the data wasn't saved.")
            }
        }
    }
    
    @IBAction func addLocationPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
}

extension ItemDetailViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        item.address = place.name ?? ""
        item.pickupLocation = place.formattedAddress ?? ""
        item.coordinate = place.coordinate
        dismiss(animated: true, completion: nil)
        updateUserInterface()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension ItemDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let photo = Photo()
        photo.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imageButton.isHidden = true
        addImageLabel.isHidden = true
        
        imageView.image = photo.image
        photos.photoArray.append(photo)
        
        dismiss(animated: true, completion: nil)
//        dismiss(animated: true) {
//            photo.saveData(item: self.item) { (success) in
//                }
//            }
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}
