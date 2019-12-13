//
//  ShareViewController.swift
//  ShareImage
//
//  Created by volive solutions on 13/12/19.
//  Copyright © 2019 RamiReddy. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices


class ShareViewController: SLComposeServiceViewController {

    
    
    let sharedKey = "ImageSharePhotoKey"
    
    var selectedImages: [UIImage] = []
    var imagesData: [Data] = []
    
    @IBOutlet weak var imgCollectionView: UICollectionView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgCollectionView.delegate = self
        self.imgCollectionView.dataSource = self
//        let attributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.white,
//                          NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 18)!] as! [String: Any]
//        
//        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.title = "Picked Images"
        self.manageImages()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        self.redirectToHostApp()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    func redirectToHostApp() {
        let url = URL(string: "ShareSuggestionToOurApp://dataUrl=\(sharedKey)")
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")
        
        while (responder != nil) {
            if (responder?.responds(to: selectorOpenURL))! {
                let _ = responder?.perform(selectorOpenURL, with: url)
            }
            responder = responder!.next
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func manageImages() {
        
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        let contentType = kUTTypeImage as String
        
        for (index, attachment) in (content.attachments as! [NSItemProvider]).enumerated() {
            if attachment.hasItemConformingToTypeIdentifier(contentType) {
                
                attachment.loadItem(forTypeIdentifier: contentType, options: nil) { [weak self] data, error in
                    
                    if error == nil, let url = data as? URL, let this = self {
                        do {
                            
                            // GETTING RAW DATA
                            let rawData = try Data(contentsOf: url)
                            let rawImage = UIImage(data: rawData)
                            
                            // CONVERTED INTO FORMATTED FILE : OVER COME MEMORY WARNING
                            // YOU USE SCALE PROPERTY ALSO TO REDUCE IMAGE SIZE
                            let image = UIImage.resizeImage(image: rawImage!, width: 100, height: 100)
                            let imgData = image.pngData()
                            
                            this.selectedImages.append(image)
                            this.imagesData.append(imgData!)
                            
                            if index == (content.attachments?.count)! - 1 {
                                DispatchQueue.main.async {
                                    this.imgCollectionView.reloadData()
                                    let userDefaults = UserDefaults(suiteName: "group.VoliveSolutions.ShareSuggestionToOurApp")
                                    userDefaults?.set(this.imagesData, forKey: this.sharedKey)
                                    userDefaults?.synchronize()
                                }
                            }
                        }
                        catch let exp {
                            print("GETTING EXCEPTION \(exp.localizedDescription)")
                        }
                        
                    } else {
                        print("GETTING ERROR")
                        let alert = UIAlertController(title: "Error", message: "Error loading image", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                            self?.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}


extension ShareViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = UIScreen.main.bounds.size.width
        let width = (viewWidth - 40) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareImageCollectionCell", for: indexPath) as! ShareImageCollectionCell
        cell.configure(image: selectedImages[indexPath.row])
        return cell
    }
}

extension UIImage {
    class func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
