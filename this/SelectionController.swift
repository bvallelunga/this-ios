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
    private var selected: [PHAsset: UIImage] = [:]
    private var selectedOrder: NSMutableArray = []
    private var date: NSDate!
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
            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(size.width, size.height - (itemSize * 2))
            layout.itemSize = CGSizeMake(itemSize, itemSize)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
            layout.parallaxHeaderAlwaysOnTop = false
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
        
        if self.date != nil {
            options.predicate = NSPredicate(format: "creationDate > %@", self.date)
        }
        
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        
        let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)

        results.enumerateObjectsUsingBlock { (object, _, _) in
            if let asset = object as? PHAsset {
                self.assets.insert(asset, atIndex: 0)
            }
        }
        
        self.manager.startCachingImagesForAssets(assets,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .AspectFill,
            options: nil
        )
        
        self.date = NSDate()
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
            
            cell.upload = self.selected[asset] != nil
            cell.layer.borderColor = Colors.green.CGColor
            cell.layer.borderWidth = cell.upload ? 3 : 0
            
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
        cell.layer.borderWidth = cell.upload ? 3 : 0
        
        if cell.upload {
            self.manager.requestImageDataForAsset(asset, options: options) { (imageData, dataUTI, orientation, info) -> Void in
                if let image = UIImage(data: imageData!) {
                    self.selectedOrder.insertObject(asset, atIndex: 0)
                    self.selected[asset] = image
                    self.updateHeader()
                }
            }
        } else  {
            self.selectedOrder.removeObject(asset)
            self.selected.removeValueForKey(asset)
            self.updateHeader()
        }
    }
    
    func updateHeader() {
        var images: [UIImage] = []
        
        for asset in self.selectedOrder {
            images.append(self.selected[asset as! PHAsset]!)
        }
        
        self.header.imagesSelected(images)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        self.getAssests()
    }
    
    // MARK: UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
