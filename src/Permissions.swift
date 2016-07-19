//
//  Permissions.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/14/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import AddressBook
import EventKit
import CoreLocation
import AVFoundation
import Photos

/// Easily acces the app's permissions to
public class Permissions {

    public enum PermissionStatus {
        case Authorized, Unauthorized, Unknown, Disabled
    }

    // MARK: Constants

    private let AskedForNotificationsDefaultsKey = "AskedForNotificationsDefaultsKey"

    // MARK: Managers

    lazy var locationManager = CLLocationManager()

    // MARK:- Permissions
    // MARK: Contacts

    /// The authorization status of access to the device's contacts.
    public func authorizationStatusContacts() -> PermissionStatus {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .authorized:
            return .Authorized
        case .restricted, .denied:
            return .Unauthorized
        case .notDetermined:
            return .Unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    public func askAuthorizationContacts() -> Bool {
        switch authorizationStatusContacts() {
        case .Unknown:
            ABAddressBookRequestAccessWithCompletion(nil) { (completed: Bool, error: CFError!) -> Void in
                return true
            }
        case .Unauthorized:
            return false
        case .Disabled:
            return false
        default:
            break
        }
        return false
    }

    // MARK: Location Always

    /// The authorization status of access to the device's location at all times.
    public func authorizationStatusLocationAlways() -> PermissionStatus {
        if !CLLocationManager.locationServicesEnabled() {
            return .Disabled
        }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            return .Authorized
        case .restricted, .denied:
            return .Unauthorized
        case .notDetermined, .authorizedWhenInUse:
            return .Unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    public func askAuthorizationLocationAlways() -> Bool {
        switch authorizationStatusLocationAlways() {
        case .Unknown:
            locationManager.requestAlwaysAuthorization()
            return true
        case .Unauthorized, .Authorized, .Disabled:
            return false
        }
    }

    // MARK: Location While In Use

    /// The authorization status of access to the device's location.
    public func authorizationStatusLocationInUse() -> PermissionStatus {
        if !CLLocationManager.locationServicesEnabled() {
            return .Disabled
        }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return .Authorized
        case .restricted, .denied:
            return .Unauthorized
        case .notDetermined:
            return .Unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    public func askAuthorizationLocationInUse() -> Bool {
        switch authorizationStatusLocationAlways() {
        case .Unknown:
            locationManager.requestAlwaysAuthorization()
            return true
        case .Unauthorized, .Authorized, .Disabled:
            return false
        }
    }

    // MARK: Notifications

    /// The authorization status of the app receiving notifications.
    public func authorizationStatusNotifications() -> PermissionStatus {
        let settings = UIApplication.shared().currentUserNotificationSettings()
        if settings?.types != UIUserNotificationType.none {
            return .Authorized
        } else {
            if UserDefaults.standard.bool(forKey: AskedForNotificationsDefaultsKey) {
                return .Unauthorized
            } else {
                return .Unknown
            }
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    public func askAuthorizationNotifications() -> Bool {
        switch authorizationStatusNotifications() {
        case .Unknown:
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            return true
        case .Unauthorized, .Authorized, .Disabled:
            return false
        }
    }

    // MARK: Photos

    /// The authorization status for access to the photo library.
    public func authorizationStatusPhotos() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return .Authorized
        case .denied, .restricted:
            return .Unauthorized
        case .notDetermined:
            return .Unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    public func askAuthorizationStatusPhotos() -> Bool {
        let status = authorizationStatusPhotos()
        switch status {
        case .Unknown:
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in

            }
            return true
        case .Authorized, .Disabled, .Unauthorized:
            return false
        }
    }

    // MARK: Camera

    /// The authorization status for use of the camera.
    public func authorizationStatusCamera() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            return .Authorized
        case .denied, .restricted:
            return .Unauthorized
        case .notDetermined:
            return .Unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    public func askAuthorizationStatusCamera() -> Bool {
        let status = authorizationStatusCamera()
        switch status {
        case .Unknown:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in

            })
            return true
        case .Disabled, .Unauthorized, .Authorized:
            return false
        }
    }

    // MARK: System Settings

    /**
    Opens the app's system settings
    If the app has its own settings bundle they will be opened, else the main settings view will be presented.

    */
    public func openAppSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)!
        if UIApplication.shared().canOpenURL(url as URL) {
            UIApplication.shared().openURL(url as URL)
        }
    }

}
