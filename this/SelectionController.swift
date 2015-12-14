//
//  SelectionController.swift
//  this
//
//  Created by Brian Vallelunga on 12/13/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import Photos
import IOStickyHeader

private let photoIdentifier = "photo"
private let cameraIdentifier = "camera"

class SelectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate, SelectionHeaderDelegate {
    
    private let manager = PHCachingImageManager()
    private var assets: [PHAsset] = []
    private var selected: [Int: UIImage] = [:]
    private var shift: Int = 0
    private var header: SelectionHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Globals.selectionController = self
        
        // Navigation Controller
        self.navigationController?.navigationBarHidden = true
        self.edgesForExtendedLayout = .None
        
        self.setupCollectionView()
        self.getAssests()
    }

    func setupCollectionView() {
        let size = self.view.frame.size
        let itemSize = size.width/3 - 1
        let headerNib = UINib(nibName: "SelectionHeader", bundle: NSBundle.mainBundle())
        
        if let layout = self.collectionView?.collectionViewLayout as? IOStickyHeaderFlowLayout {
            layout.parallaxHeaderReferenceSize = CGSizeMake(size.width, size.height - (itemSize * 2))
            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(size.width, 0)
            layout.itemSize = CGSizeMake(itemSize, itemSize)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
            layout.parallaxHeaderAlwaysOnTop = true
            layout.disableStickyHeaders = true
        }
            
        self.collectionView?.registerClass(SelectionPhotoCell.self, forCellWithReuseIdentifier: photoIdentifier)
        self.collectionView?.registerClass(SelectionCameraCell.self, forCellWithReuseIdentifier: cameraIdentifier)
        
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.collectionView?.registerNib(headerNib, forSupplementaryViewOfKind: IOStickyHeaderParallaxHeader,
            withReuseIdentifier: "header")
    }
    
    func getAssests() {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        let currentCount = self.assets.count
        
        self.assets.removeAll()

        results.enumerateObjectsUsingBlock { (object, _, _) in
            if let asset = object as? PHAsset {
                self.assets.append(asset)
            }
        }
        
        self.manager.startCachingImagesForAssets(assets,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .AspectFill,
            options: nil
        )
        
        if currentCount > 0 {
            self.shift = self.assets.count - currentCount
            
            print(self.assets.count, currentCount, self.shift)
        }
        
        self.collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count + 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row > 0 {
            let asset = self.assets[indexPath.row-1]
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoIdentifier,
                forIndexPath: indexPath) as! SelectionPhotoCell
            let options = PHImageRequestOptions()
            
            options.deliveryMode = .Opportunistic
            
            cell.upload = self.selected[indexPath.row + self.shift] != nil
            cell.layer.borderColor = Colors.green.CGColor
            cell.layer.borderWidth = cell.upload ? 2 : 0
            
            cell.tag = Int(self.manager.requestImageForAsset(asset,
                targetSize: cell.frame.size,
                contentMode: .AspectFill,
                options: options) { (result, _) in
                    cell.imageView.image = result
            })
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cameraIdentifier,
            forIndexPath: indexPath) as! SelectionCameraCell
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case IOStickyHeaderParallaxHeader:
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! SelectionHeader
            
            cell.delegate = self
            self.header = cell
            
            return cell
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = ["public.image"]
            self.presentViewController(imagePicker, animated: true, completion: nil)
            return
        }
        
        let asset = self.assets[indexPath.row-1]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SelectionPhotoCell
        let options = PHImageRequestOptions()
        
        options.deliveryMode = .HighQualityFormat
        
        cell.upload = !cell.upload
        cell.layer.borderWidth = cell.upload ? 2 : 0
        
        self.manager.requestImageDataForAsset(asset, options: options) { (imageData, dataUTI, orientation, info) -> Void in
            if let image = UIImage(data: imageData!) {
                if cell.upload {
                    self.selected[indexPath.row + self.shift] = image
                } else {
                    self.selected.removeValueForKey(indexPath.row + self.shift)
                }
                
                self.header.imagesSelected(Array(self.selected.values))
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        self.getAssests()
    }
    
    // MARK: UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
