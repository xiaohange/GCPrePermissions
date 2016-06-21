//
//  GCPrePermissions.h
//  GCPrePermissions
//
//  Created by HanJunqiang on 17/6/16.
//  Copyright (c) 2016 HaRi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCPrePermissions : NSObject

/**
 * A general descriptor for the possible outcomes of a dialog.
 */
typedef NS_ENUM(NSInteger, GCDialogResult) {
    /// User was not given the chance to take action.
    /// This can happen if the permission was
    /// already granted, denied, or restricted.
    GCDialogResultNoActionTaken,
    /// User declined access in the user dialog or system dialog.
    GCDialogResultDenied,
    /// User granted access in the user dialog or system dialog.
    GCDialogResultGranted,
    /// The iOS parental permissions prevented access.
    /// This outcome would only happen on the system dialog.
    GCDialogResultParentallyRestricted
};

/**
 * A general descriptor for the possible outcomes of Authorization Status.
 */
typedef NS_ENUM(NSInteger, GCAuthorizationStatus) {
    /// Permission status undetermined.
    GCAuthorizationStatusUnDetermined,
    /// Permission denied.
    GCAuthorizationStatusDenied,
    /// Permission authorized.
    GCAuthorizationStatusAuthorized,
    /// The iOS parental permissions prevented access.
    GCAuthorizationStatusRestricted
};

/**
 * Authorization methods for the usage of location services.
 */
typedef NS_ENUM(NSInteger, GCLocationAuthorizationType) {
    /// the “when-in-use” authorization grants the app to start most
    /// (but not all) location services while it is in the foreground.
    GCLocationAuthorizationTypeWhenInUse,
    /// the “always” authorization grants the app to start all
    /// location services
    GCLocationAuthorizationTypeAlways,
};

/**
 * Authorization methods for the usage of event services.
 */
typedef NS_ENUM(NSInteger, GCEventAuthorizationType) {
    /// Authorization for events only
    GCEventAuthorizationTypeEvent,     // 日历
    /// Authorization for reminders only
    GCEventAuthorizationTypeReminder   // 提醒事项
};

/**
 * Authorization methods for the usage of Contacts services(Handling existing of AddressBook or Contacts framework).
 */
typedef NS_ENUM(NSInteger, GCContactsAuthorizationType){
    GCContactsAuthorizationStatusNotDetermined = 0,
    /*! The application is not authorized to access contact data.
     *  The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place. */
    GCContactsAuthorizationStatusRestricted,
    /*! The user explicitly denied access to contact data for the application. */
    GCContactsAuthorizationStatusDenied,
    /*! The application is authorized to access contact data. */
    GCContactsAuthorizationStatusAuthorized
};

/**
 * Authorization methods for the usage of AV services.
 */
typedef NS_ENUM(NSInteger, GCAVAuthorizationType) {
    /// Authorization for Camera only
    GCAVAuthorizationTypeCamera,      // 相机
    /// Authorization for Microphone only
    GCAVAuthorizationTypeMicrophone   // 麦克风
};

typedef NS_OPTIONS(NSUInteger, GCPushNotificationType) {
  GCPushNotificationTypeNone = 0, // the application may not present any UI upon a notification being received
  GCPushNotificationTypeBadge = 1 << 0, // the application may badge its icon upon a notification being received
  GCPushNotificationTypeSound = 1 << 1, // the application may play a sound upon a notification being received
  GCPushNotificationTypeAlert = 1 << 2, // the application may display an alert upon a notification being received
};

/**
 * General callback for permissions.
 * @param hasPermission Returns YES if system permission was granted 
 *                      or is already available, NO otherwise.
 * @param userDialogResult Describes whether the user granted/denied access, 
 *                         or if the user didn't have an opportunity to take action. 
 *                         GCDialogResultParentallyRestricted is never returned.
 * @param systemDialogResult Describes whether the user granted/denied access, 
 *                           or was parentally restricted, or if the user didn't 
 *                           have an opportunity to take action.
 * @see GCDialogResult
 */
typedef void (^GCPrePermissionCompletionHandler)(BOOL hasPermission,
                                              GCDialogResult userDialogResult,
                                              GCDialogResult systemDialogResult);

+ (instancetype) sharedPermissions;

+ (GCAuthorizationStatus) cameraPermissionAuthorizationStatus;
+ (GCAuthorizationStatus) microphonePermissionAuthorizationStatus;
+ (GCAuthorizationStatus) photoPermissionAuthorizationStatus;
+ (GCAuthorizationStatus) contactsPermissionAuthorizationStatus;
+ (GCAuthorizationStatus) eventPermissionAuthorizationStatus:(GCEventAuthorizationType)eventType;
+ (GCAuthorizationStatus) locationPermissionAuthorizationStatus;
+ (GCAuthorizationStatus) pushNotificationPermissionAuthorizationStatus;
+ (GCAuthorizationStatus) GPSPermissionAuthorizationStatus;

- (void) showAVPermissionsWithType:(GCAVAuthorizationType)mediaType
                             title:(NSString *)requestTitle
                           message:(NSString *)message
                   denyButtonTitle:(NSString *)denyButtonTitle
                  grantButtonTitle:(NSString *)grantButtonTitle
                completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showCameraPermissionsWithTitle:(NSString *)requestTitle
                                message:(NSString *)message
                        denyButtonTitle:(NSString *)denyButtonTitle
                       grantButtonTitle:(NSString *)grantButtonTitle
                      completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showMicrophonePermissionsWithTitle:(NSString *)requestTitle
                                    message:(NSString *)message
                            denyButtonTitle:(NSString *)denyButtonTitle
                           grantButtonTitle:(NSString *)grantButtonTitle
                          completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showPhotoPermissionsWithTitle:(NSString *)requestTitle
                               message:(NSString *)message
                       denyButtonTitle:(NSString *)denyButtonTitle
                      grantButtonTitle:(NSString *)grantButtonTitle
                     completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showContactsPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showEventPermissionsWithType:(GCEventAuthorizationType)eventType
                                Title:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showLocationPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showLocationPermissionsForAuthorizationType:(GCLocationAuthorizationType)authorizationType
                                               title:(NSString *)requestTitle
                                             message:(NSString *)message
                                     denyButtonTitle:(NSString *)denyButtonTitle
                                    grantButtonTitle:(NSString *)grantButtonTitle
                                   completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

/**
 * @description (Experimental) This checks for your current push notifications 
 * authorization and attempts to register for push notifications for you. 
 * See discussion below.
 * @discussion This is NOT RECOMMENDED for using in your apps, unless
 * you are a simple app and don't care too much about push notifications. 
 * In some cases, this will not reliably check for push notifications or request them.
 * * Uninstalling/reinstalling your app within 24 hours may break this, your callback may
 * not be fired.
 */
- (void) showPushNotificationPermissionsWithType:(GCPushNotificationType)requestedType
                                           title:(NSString *)requestTitle
                                         message:(NSString *)message
                                 denyButtonTitle:(NSString *)denyButtonTitle
                                grantButtonTitle:(NSString *)grantButtonTitle
                               completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

- (void) showGPSPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(GCPrePermissionCompletionHandler)completionHandler;

@end
