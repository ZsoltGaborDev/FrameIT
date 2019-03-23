//
//  ViewController.swift
//  FrameIT
//
//  Created by zsolt on 16/01/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var creationFrame: UIView!
    @IBOutlet weak var creationImageView: UIImageView!
    @IBOutlet weak var creationUnicornView: UIImageView!
    @IBOutlet weak var startOverButton: UIButton!
    @IBOutlet weak var colorLaber: UILabel!
    @IBOutlet weak var colorsContainer: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    var localImages = [UIImage].init()
    var unicornImages = [UIImage].init()
    var defaults = UserDefaults.standard
    var colorSwatches = [ColorSwatch].init()
    var creation = Creation.init()
    var initialImageViewOffset = CGPoint()
    var initialUnicornViewOffset = CGPoint()
    let colorUserDefaultKey = "ColorIndex"
    var savedColorSwatchIndex: Int {
        get {
            let savedIndex = defaults.value(forKey: colorUserDefaultKey)
            if savedIndex == nil {
                defaults.set(colorSwatches.count - 1, forKey: colorUserDefaultKey)
            }
            return defaults.integer(forKey: colorUserDefaultKey)
        }
        set {
            if newValue >= 0 && newValue < colorSwatches.count {
                defaults.set(newValue, forKey: colorUserDefaultKey)
            }
        }
    }
    @IBAction func startOver(_ sender: Any) {
        creation.reset(colorSwatch: colorSwatches[savedColorSwatchIndex])
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [],  animations: {
            self.creationImageView.transform = .identity
        }) {(success) in
            self.animateImageChange()
            self.creationFrame.backgroundColor = self.creation.colorSwatch.color
            self.colorLaber.text = self.creation.colorSwatch.caption
        }
    }
    @objc func changeImage(_ sender: UITapGestureRecognizer) {
        displayImagePickingOptions()
    }
    @objc func moveImageView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: creationImageView.superview)
        if sender.state == .began {
            initialImageViewOffset = creationImageView.frame.origin
        }
        let position = CGPoint(x: translation.x + initialImageViewOffset.x - creationImageView.frame.origin.x, y: translation.y + initialImageViewOffset.y - creationImageView.frame.origin.y)
        creationImageView.transform = creationImageView.transform.translatedBy(x: position.x, y: position.y)
    }
    @objc func rotateImageView(_ sender: UIRotationGestureRecognizer) {
        creationImageView.transform = creationImageView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    @objc func scaleImageView(_ sender: UIPinchGestureRecognizer) {
        creationImageView.transform = creationImageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            // simultaneous gesture recognition will only be supported for creationImageView
            if gestureRecognizer.view != creationImageView {
                return false
            }
            // neither of the recognized gestures should not be tap gesture
            if gestureRecognizer is UITapGestureRecognizer
                || otherGestureRecognizer is UITapGestureRecognizer
                || gestureRecognizer is UIPanGestureRecognizer
                || otherGestureRecognizer is UIPanGestureRecognizer {
                return false
            }
            return true
    }
    func collectLocalImageSet() {
        localImages.removeAll()
        let imageNames = ["Boat", "Car", "Crocodile", "Park", "TShirts"]
        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImages.append(image)
            }
        }
    }
    func collectLocalUnicornSet() {
        unicornImages.removeAll()
        let unicornNames = ["Unicorn", "Unicorn2", "Unicorn3", "Unicorn4"]
        for name in unicornNames {
            if let unicorn = UIImage.init(named: name) {
                unicornImages.append(unicorn)
            }
        }
    }
    func collectColors() {
        colorSwatches = [
            ColorSwatch.init(caption: "Ocean", color: UIColor.init(red: 44/255, green: 151/255, blue: 222/255, alpha: 1)),
            ColorSwatch.init(caption: "Shamrock", color: UIColor.init(red: 28/255, green: 188/255, blue: 100/255, alpha: 1)),
            ColorSwatch.init(caption: "Candy", color: UIColor.init(red: 221/255, green: 51/255, blue: 27/255, alpha: 1)),
            ColorSwatch.init(caption: "Violet", color: UIColor.init(red: 136/255, green: 20/255, blue: 221/255, alpha: 1)),
            ColorSwatch.init(caption: "Sunshine", color: UIColor.init(red: 242/255, green: 197/255, blue: 0/255, alpha: 1))
        ]
        if colorSwatches.count == colorsContainer.subviews.count {
            for i in 0 ..< colorSwatches.count {
                colorsContainer.subviews[i].backgroundColor = colorSwatches[i].color
            }
        }
    }
    @IBAction func applyColor(_ sender: UIButton) {
        if let index = colorsContainer.subviews.index(of: sender) {
            creation.colorSwatch = colorSwatches[index]
            creationFrame.backgroundColor = creation.colorSwatch.color
            colorLaber.text = creation.colorSwatch.caption
        }
    }
    @IBAction func share(_ sender: Any) {
        displaySharingOptions()
        if let index = colorSwatches.index(where: {$0.caption == creation.colorSwatch.caption}) {
            savedColorSwatchIndex = index
        }
    }
    func displaySharingOptions() {
        //prepare content to share
        let note = "I Framed IT!"
        let image = composeCreationImage()
        let items = [image as Any, note as Any]
        //create activity view controller
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        //adapt for iPad
        activityViewController.popoverPresentationController?.sourceView = view
        //present activity view controller
        present(activityViewController, animated: true, completion: nil)
    }
    func composeCreationImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(creationFrame.bounds.size, false, 0)
        creationFrame.drawHierarchy(in: creationFrame.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return screenshot
    }
    func displayImagePickingOptions() {
        let alertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        //create camera action
        let cameraAction = UIAlertAction(title: "Take photo", style: .default)
            {(action) in
            self.displayCamera()
        }
        // add camera action to alert controller
        alertController.addAction(cameraAction)
        
        //create action for library pick
        let libraryAction = UIAlertAction(title: "Pick from Library", style: .default) {
            (action) in
            self.displayLibrary()
        }
        //add library pick action to alert controller
        alertController.addAction(libraryAction)
        
        //create random action
        let randomAction = UIAlertAction(title: "Random", style: .default) {
            (action) in
            self.pickRandom()
        }
        //add library pick action to alert controller
        alertController.addAction(randomAction)
        
        //create cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        //add cancel action to alert controler
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {
        //code to execute after the controller finished presenting
        }
    }
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "Looks like FrameIT haven't acces to your camera :( Please use Setting app on your device to permit FrameIT accessing your camera"
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            }
        }
        else {
            troubleAlert(message: "Sincere apologise, it looks like we can't access your camera at this time")
        }
    }
    func displayLibrary() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionStatusMessage = "Looks like FrameIT haven't access to your photos :( Please use Setting app on your device to permit FrameIT accessing your library"
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionStatusMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionStatusMessage)
            }
        }
        else {
            troubleAlert(message: "Sincere apologise, it looks like we can't access your photo library at this time")
        }
    }
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    func troubleAlert(message: String?) {
        let alertController = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Got it.", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // got an image
        picker.dismiss(animated: true, completion: nil)
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        processPicked(image: newImage)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //canceled
    }
    func animateImageChange() {
        UIView.transition(with: self.creationImageView, duration: 0.4, options: .transitionCrossDissolve, animations : {
            self.creationImageView.image = self.creation.image }, completion: nil)
    }
    func processPicked(image: UIImage?) {
        if let newImage = image {
            creation.image = newImage
            animateImageChange()
        }
        //random option for make unicorn fly
        let unicornAppearRandom = Int(arc4random_uniform(UInt32(2)))
        if unicornAppearRandom == 0 {
            flyingUnicorn()
        }
    }
    func flyingUnicorn() {
        //picking random unicorn image
        let unicornImage = randomUnicorn()
        creationUnicornView.image = unicornImage
        initialUnicornViewOffset = self.creationUnicornView.frame.origin
        self.view.layoutIfNeeded()
        // make unicorn visible,move it to the center of the image, return to the initial position and at the end make it dissapear.
        UIView.animate(withDuration: 3, delay: 1.5, options: .curveEaseInOut, animations: {
            self.creationUnicornView.isHidden = false
            self.creationUnicornView.center = self.view.center
            self.view.layoutIfNeeded()})
            {_ in
            UIView.animate(withDuration: 3, delay: 1, options: .curveEaseInOut, animations: {
                self.creationUnicornView.frame.origin = self.initialUnicornViewOffset
                self.view.layoutIfNeeded()})
                {_ in
                self.creationUnicornView.isHidden = true
                self.creationUnicornView.frame.origin = self.initialUnicornViewOffset
                    self.view.layoutIfNeeded()}}
    }
    func pickRandom() {
        processPicked(image: randomImage())
    }
    func randomImage() -> UIImage? {
        let currentImage = creationImageView.image
        if localImages.count > 0 {
            while true {
                let randomIndex = Int(arc4random_uniform(UInt32(localImages.count)))
                let newImage = localImages[randomIndex]
                if newImage != currentImage {
                    return newImage
                }
            }
        }
        return nil
    }
    func randomUnicorn() -> UIImage? {
        let currentUnicorn = creationUnicornView.image

        if unicornImages.count > 0 {
            while true {
                let randomIndex = Int(arc4random_uniform(UInt32(unicornImages.count)))
                let newUnicorn = unicornImages[randomIndex]
                if newUnicorn != currentUnicorn {
                    return newUnicorn
                }
            }
        }
        return nil
    }
    func configure() {
        //hide unicorn image
        creationUnicornView.isHidden = true
        //collect images
        collectLocalImageSet()
        //collect colors
        collectColors()
        //collect unicorn images
        collectLocalUnicornSet()
        
        //set creation data object
        creation.colorSwatch = colorSwatches[savedColorSwatchIndex]
        
        //apply creation data to the view
        creationUnicornView.image = creation.unicorn
        creationImageView.image = creation.image
        creationFrame.backgroundColor = creation.colorSwatch.color
        colorLaber.text = creation.colorSwatch.caption
        
        //create tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
        creationImageView.addGestureRecognizer(tapGestureRecognizer)
        
        //create pan gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
        panGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(panGestureRecognizer)
        
        //create rotation gesture recognizer
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
        rotationGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(rotationGestureRecognizer)
        
        //create pinch gesture recognizer
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
        pinchGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configure()
    }
}

