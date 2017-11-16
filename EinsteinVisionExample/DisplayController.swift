//
//  DisplayController.swift
//  EinsteinVisionExample
//
//  Created by Renee Liu on 11/15/17.
//  Copyright © 2017 René Winkelmeyer. All rights reserved.
//

import Foundation
import UIKit

class DisplayController: UICollectionViewController {

    var currCategory: String!
    var photos = Photo.allPhotos()
    
    @IBOutlet weak var headerText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.title = self.currCategory
        
        if let layout = collectionView?.collectionViewLayout as? ApparelLayout {
            layout.delegate = self
        }
        
        if currCategory == "paddling clothing" {
            self.photos = Array(self.photos[0..<6])
        }
        else if currCategory == "swimwear" {
            self.photos = Array(self.photos[6..<12])
        }
        else if currCategory == "travel clothing" {
            self.photos = Array(self.photos[12..<18])
        }
        else {
            print("currCategory is empty")
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension DisplayController: ApparelLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        return photos[indexPath.item].image.size.height
    }
}

extension DisplayController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath as IndexPath) as! AnnotatedPhotoCell
        cell.photo = photos[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
    
}
