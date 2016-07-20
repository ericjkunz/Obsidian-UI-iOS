//
//  AFLCameraViewController.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/13/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import MobileCoreServices

protocol ALFCameraViewControllerDelegate {
    
    /// Tells the delegate that the close button was tapped.
    func didCancelImageCapture(cameraController: ALFCameraViewController)
    
    /// Tells the delegate that an image has been selected.
    func cameraControllerDidSelectImage(camera: ALFCameraViewController, image: UIImage)
}

/**
 Provides a camera for still image capture. Customizaton is available for the capture
 button (captureButton), flash control button (flashButton), resolution (sessionPreset),
 and which camera to use (devicePosition).
 
 After an image is captured the user is presented with buttons to accept or reject the photo.
 
 */
class ALFCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     The delegate of a AFLCameraViewController must adopt the AFLCameraViewControllerDelegate protocol.
     Methods of the protocol allow the delegate to respond to an image selection or cancellation.
     */
    var delegate: ALFCameraViewControllerDelegate?
    
    private var camera: Camera
    
    ///Flash firing control. false by defualt.
    var flashOn = false
    
    /// The resolution to set the camera to.
    var sessionPreset = AVCaptureSessionPreset640x480
    
    /// Determines if image is saved to photo library on capture. Default is false.
    var savesToPhotoLibrary = false
    
    /// The tint color of the photo library picker's navigation bar
    var pickerNavigationBarTintColor = UIColor.white()
    
    /// The button that is pressed to capture an image.
    @IBOutlet weak var captureButton: UIButton?
    
    /// The button that determines whether the flash fires while capturing an image.
    @IBOutlet weak var flashButton: UIButton?
    
    /// The view for live camera preview
    @IBOutlet weak var cameraPreview: UIView?
    
    /// Where the camera capture animation happens
    @IBOutlet weak var flashView: UIView?
    
    /// View for image review post image capture
    @IBOutlet weak private var capturedImageReview: UIImageView?
    
    /// User taps this to pass photo to delegate
    @IBOutlet weak var acceptButton: UIButton?
    
    /// Tapping this returns the user to capturing an image.
    @IBOutlet weak var rejectButton: UIButton?
    
    /// A button that dismisses the camera.
    @IBOutlet weak var exitButton: UIButton?
    
    /// Title at the top of the view.
    @IBOutlet weak var titleLabel: UILabel?
    
    /// A Label shown after image capture -
    /// e.g. Would you like to use this photo? or. May I take your hat, sir?
    @IBOutlet weak var questionLabel: UILabel?
    
    /// An instruction label below the camera preview
    @IBOutlet weak var hintDescriptionLabel: UILabel?
    
    /// Opens the photo library
    @IBOutlet weak var photoLibraryButton: UIButton?
    
    private var capturedImage: UIImage?
    private var inputCameraConnection: AVCaptureConnection?
    
    init(useFrontCamera: Bool) {
        camera = Camera(useFrontCamera: useFrontCamera, sessionPreset: sessionPreset)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        flashButton?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        teardownSession()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func teardownSession() {
        camera.tearDownSession()
    }
    
    // MARK: Actions
    
    private func showAcceptOrRejectView(show: Bool) {
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.captureButton?.isHidden = show
            self.flashButton?.isHidden = show
            self.cameraPreview?.isHidden = show
            
            self.capturedImageReview?.isHidden = !show
            self.acceptButton?.isHidden = !show
            self.rejectButton?.isHidden = !show
        })
    }
    
    private func didPressAcceptPhotoButton() {
        delegate?.cameraControllerDidSelectImage(camera: self, image: capturedImage!)
        teardownSession()
    }
    
    private func didPressRejectPhotoButton() {
        capturedImage = nil
        showAcceptOrRejectView(show: false)
    }
    
    private func didPressExitButton() {
        delegate?.didCancelImageCapture(cameraController: self)
        teardownSession()
    }
    
    private func takePicture() {
        camera.captureImage { (capturedImage) -> Void in
            self.displayCapturedImage(capturedImage)
        }
    }
    
    private func displayCapturedImage(_ image: UIImage) {
        capturedImageReview?.image = image
        showAcceptOrRejectView(show: true)
    }
    
    private func flashCamera() {
        let key = "opacity"
        let flash = CABasicAnimation(keyPath: key)
        flash.fromValue = 0
        flash.toValue = 1
        flash.autoreverses = true
        flash.isRemovedOnCompletion = true
        flash.duration = 0.15
        flashView?.layer.add(flash, forKey: key)
    }
    
    // MARK: Photo Library
    
    private func didTapPhotoLibraryButton() {
        presentPhotoLibraryPicker()
    }
    
    private func loadPhotoLibraryPreviewImage() {
        if let libraryButton = photoLibraryButton {
            Photos.latestAsset(size: libraryButton.frame.size, contentMode: .aspectFill, completion: { (image: UIImage?) -> Void in
                libraryButton.imageView?.image = image
            })
        }
    }
    
    private func configurePhotoLibraryButtonForNoAccess() {
        photoLibraryButton?.backgroundColor = UIColor.black()
    }
    
    private func presentPhotoLibraryPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        // let availableTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePicker.sourceType)
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        imagePicker.navigationBar.barTintColor = pickerNavigationBarTintColor
        imagePicker.navigationBar.isTranslucent = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        dismiss(animated: true, completion: { () -> Void in
            self.capturedImage = image
            self.displayCapturedImage(image)
            UIApplication.shared().setStatusBarStyle(.lightContent, animated: true)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: { () -> Void in
            UIApplication.shared().setStatusBarStyle(.lightContent, animated: true)
        })
    }
    
    // MARK: Navigation Controller Delegate
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.shared().setStatusBarStyle(.lightContent, animated: true)
    }
    
}
