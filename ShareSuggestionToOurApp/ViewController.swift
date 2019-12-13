//
//  ViewController.swift
//  ShareSuggestionToOurApp
//
//  Created by volive solutions on 13/12/19.
//  Copyright © 2019 RamiReddy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imgCollectionView: UICollectionView!
    var cellItems: [CellModel] = []
    var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgCollectionView.delegate = self
        self.imgCollectionView.dataSource = self
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.sourceType = .photoLibrary
        self.imagePicker?.delegate = self
    }

    
    //MARK:- OPEN GALLERY
    @IBAction func addGalleryBtnAction(_ sender: Any) {
        self.present(self.imagePicker!, animated: true, completion: nil)
        
    }
    
}


//MARK:- IMAGE PICKER DELEGATE METHODS

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage {
           
            let model = CellModel(image: chosenImage)
            self.cellItems.append(model)
            self.imgCollectionView.reloadData()
            picker.dismiss(animated: true, completion: nil)
            
        } else{
            print("Something went wrong")
        }
    }
    
    
    
}


//MARK:- COLLECTIONVIEW DELEGATE METHODS

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionCell", for: indexPath) as! ImageCollectionCell
        cell.item = self.cellItems[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let dimension = (self.view.frame.size.width - 40)/3
        return CGSize(width: dimension, height: dimension)
    }
    
}
