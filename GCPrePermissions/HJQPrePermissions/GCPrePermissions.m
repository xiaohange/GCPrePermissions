//
//  GCPrePermissions.m
//  GCPrePermissions
//
//  Created by HanJunqiang on 17/6/16.
//  Copyright (c) 2016 HaRi. All rights reserved.
//

typedef NS_ENUM(NSInteger, GCTitleType) {
    GCTitleTypeRequest,
    GCTitleTypeDeny
};

#import "GCPrePermissions.h"

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <EventKit/EventKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#define IOS9 [[[UIDevice currentDevice]systemVersion] floatValue] >= 9.0
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
//at least iOS 9 code here
@import Contacts;
#endif

NSString *const GCPrePermissionsDidAskForPushNotifications = @"GCPrePermissionsDidAskForPushNotifications";

@interface GCPrePermissions () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIAlertView *preAVPermissionAlertView;
@property (copy, nonatomic) GCPrePermissionCompletionHandler avPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *prePhotoPermissionAlertView;
@property (copy, nonatomic) GCPrePermissionCompletionHandler photoPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preContactPermissionAlertView;
@property (copy, nonatomic) GCPrePermissionCompletionHandler contactPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preEventPermissionAlertView;
@property (copy, nonatomic) GCPrePermissionCompletionHandler eventPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preLocationPermissionAlertView;
@property (copy, nonatomic) GCPrePermissionCompletionHandler locationPermissionCompletionHandler;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) GCLocationAuthorizationType locationAuthorizationType;
@property (assign, nonatomic) GCPushNotificationType requestedPushNotificationTypes;
@property (strong, nonatomic) UIAlertView *prePushNotificationPermissionAlertView;
@property (copy, nonatomic) GCPrePermissionCompletionHandler pushNotificationPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *gpsPermissionAlertView;
@property (strong, nonatomic) GCPrePermissionCompletionHandler gpsPermissionCompletionHandler;

@end

static GCPrePermissions *__sharedInstance;

@implementation GCPrePermissions

+ (instancetype) sharedPermissions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[GCPrePermissions alloc] init];
    });
    return __sharedInstance;
}

+ (GCAuthorizationStatus) AVPermissionAuthorizationStatusForMediaType:(NSString*)mediaType
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return GCAuthorizationStatusAuthorized;

        case AVAuthorizationStatusDenied:
            return GCAuthorizationStatusDenied;

        case AVAuthorizationStatusRestricted:
            return GCAuthorizationStatusRestricted;

        default:
            return GCAuthorizationStatusUnDetermined;
    }
}

+ (GCAuthorizationStatus) cameraPermissionAuthorizationStatus
{
    return [GCPrePermissions AVPermissionAuthorizationStatusForMediaType:AVMediaTypeVideo];
}

+ (GCAuthorizationStatus) microphonePermissionAuthorizationStatus
{
    return [GCPrePermissions AVPermissionAuthorizationStatusForMediaType:AVMediaTypeAudio];
}

+ (GCAuthorizationStatus) photoPermissionAuthorizationStatus
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusAuthorized:
            return GCAuthorizationStatusAuthorized;

        case ALAuthorizationStatusDenied:
            return GCAuthorizationStatusDenied;

        case ALAuthorizationStatusRestricted:
            return GCAuthorizationStatusRestricted;

        default:
            return GCAuthorizationStatusUnDetermined;
    }
}

#pragma mark - GPS Permissions Help
+ (GCAuthorizationStatus) GPSPermissionAuthorizationStatus
{
    CLAuthorizationStatus authStatus =  [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusDenied:
            return GCAuthorizationStatusDenied;
            break;
        case kCLAuthorizationStatusRestricted:
            return GCAuthorizationStatusRestricted;
            break;
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return GCAuthorizationStatusUnDetermined;
        default:
            break;
    }
}

+ (GCAuthorizationStatus) contactsPermissionAuthorizationStatus
{
    GCContactsAuthorizationType authType;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    //at least iOS 9 code here
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    authType = (GCContactsAuthorizationType)status;
#else
    //lower than iOS 9 code here
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    authType = (GCContactsAuthorizationType)status;
#endif
    switch (authType) {
        case GCContactsAuthorizationStatusAuthorized:
            return GCAuthorizationStatusAuthorized;
            
        case GCContactsAuthorizationStatusDenied:
            return GCAuthorizationStatusDenied;
            
        case GCContactsAuthorizationStatusRestricted:
            return GCAuthorizationStatusRestricted;
            
        default:
            return GCAuthorizationStatusUnDetermined;
    }
}

+ (GCAuthorizationStatus) eventPermissionAuthorizationStatus:(GCEventAuthorizationType)eventType
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:
                  [[GCPrePermissions sharedPermissions] EKEquivalentEventType:eventType]];
    switch (status) {
        case EKAuthorizationStatusAuthorized:
            return GCAuthorizationStatusAuthorized;

        case EKAuthorizationStatusDenied:
            return GCAuthorizationStatusDenied;

        case EKAuthorizationStatusRestricted:
            return GCAuthorizationStatusRestricted;

        default:
            return GCAuthorizationStatusUnDetermined;
    }
}

+ (GCAuthorizationStatus) locationPermissionAuthorizationStatus
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return GCAuthorizationStatusAuthorized;

        case kCLAuthorizationStatusDenied:
            return GCAuthorizationStatusDenied;

        case kCLAuthorizationStatusRestricted:
            return GCAuthorizationStatusRestricted;

        default:
            return GCAuthorizationStatusUnDetermined;
    }
}

+ (GCAuthorizationStatus) pushNotificationPermissionAuthorizationStatus
{
    BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:GCPrePermissionsDidAskForPushNotifications];

    if (didAskForPermission) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            // iOS8+
            if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
                return GCAuthorizationStatusAuthorized;
            } else {
                return GCAuthorizationStatusDenied;
            }
        } else {

            // Add compiler check to avoid warnings, if deployment target >= 8.0
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
            // iOS 7
            if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
                return GCAuthorizationStatusDenied;
            } else {
                return GCAuthorizationStatusAuthorized;
            }
#else
            // Impossible state to be in: iOS 8 device, but somehow doesn't respond to isRegisteredForRemoteNotifications?
            return GCAuthorizationStatusDenied;
#endif
        }
    } else {
        return GCAuthorizationStatusUnDetermined;
    }
}

#pragma mark - Push Notification Permissions Help
- (void) showPushNotificationPermissionsWithType:(GCPushNotificationType)requestedType
                                           title:(NSString *)requestTitle
                                         message:(NSString *)message
                                 denyButtonTitle:(NSString *)denyButtonTitle
                                grantButtonTitle:(NSString *)grantButtonTitle
                               completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Enable Push Notifications?";
    }
    denyButtonTitle = [self titleFor:GCTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:GCTitleTypeRequest fromTitle:grantButtonTitle];

    GCAuthorizationStatus status = [GCPrePermissions pushNotificationPermissionAuthorizationStatus];
    if (status == GCAuthorizationStatusUnDetermined) {
        self.pushNotificationPermissionCompletionHandler = completionHandler;
        self.requestedPushNotificationTypes = requestedType;
        self.prePushNotificationPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                                 message:message
                                                                                delegate:self
                                                                       cancelButtonTitle:denyButtonTitle
                                                                       otherButtonTitles:grantButtonTitle, nil];
        [self.prePushNotificationPermissionAlertView show];
    } else if(status == GCAuthorizationStatusDenied){

        [self showNoAutherOrRefuseAutherWithMessage:@"请在iPhone的 设置-通知 选项中允许发通知。"];
        
    }else{
        if (completionHandler) {
            completionHandler((status == GCAuthorizationStatusUnDetermined),
                              GCDialogResultNoActionTaken,
                              GCDialogResultNoActionTaken);
        }
    }
}

- (void) showActualPushNotificationPermissionAlert
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS8+
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)self.requestedPushNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        // Add compiler check to avoid warnings, if deployment target >= 8.0
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)self.requestedPushNotificationTypes];
#endif
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:GCPrePermissionsDidAskForPushNotifications];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) showGPSPermissionsWithTitle:(NSString *)requestTitle
                             message:(NSString *)message
                     denyButtonTitle:(NSString *)denyButtonTitle
                    grantButtonTitle:(NSString *)grantButtonTitle
                   completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Access GPS?";
    }
    denyButtonTitle  = [self titleFor:GCTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:GCTitleTypeRequest fromTitle:grantButtonTitle];
    CLAuthorizationStatus status =  [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        self.gpsPermissionCompletionHandler = completionHandler;
        self.gpsPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:denyButtonTitle
                                                            otherButtonTitles:grantButtonTitle, nil];
        [self.gpsPermissionAlertView show];
    } else {
        if (completionHandler) {
            completionHandler((status == kCLAuthorizationStatusRestricted),
                              GCDialogResultNoActionTaken,
                              GCDialogResultNoActionTaken);
        }
    }
}


- (void)applicationDidBecomeActive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [self firePushNotificationPermissionCompletionHandler];
}

- (void) firePushNotificationPermissionCompletionHandler
{
    GCAuthorizationStatus status = [GCPrePermissions pushNotificationPermissionAuthorizationStatus];
    if (self.pushNotificationPermissionCompletionHandler) {
        GCDialogResult userDialogResult = GCDialogResultGranted;
        GCDialogResult systemDialogResult = GCDialogResultGranted;
        if (status == GCAuthorizationStatusAuthorized) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultGranted;
        } else if (status == GCAuthorizationStatusDenied) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultDenied;
        } else if (status == GCAuthorizationStatusUnDetermined) {
            userDialogResult = GCDialogResultDenied;
            systemDialogResult = GCDialogResultNoActionTaken;
        }
        self.pushNotificationPermissionCompletionHandler((status == GCAuthorizationStatusAuthorized),
                                                         userDialogResult,
                                                         systemDialogResult);
        self.pushNotificationPermissionCompletionHandler = nil;
    }
}

#pragma mark - AV Permissions Help
- (void) showAVPermissionsWithType:(GCAVAuthorizationType)mediaType
                             title:(NSString *)requestTitle
                           message:(NSString *)message
                   denyButtonTitle:(NSString *)denyButtonTitle
                  grantButtonTitle:(NSString *)grantButtonTitle
                 completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        switch (mediaType) {
            case GCAVAuthorizationTypeCamera:
                requestTitle = @"Access Camera?";
                break;

            default:
                requestTitle = @"Access Microphone?";
                break;
        }
    }
    denyButtonTitle  = [self titleFor:GCTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:GCTitleTypeRequest fromTitle:grantButtonTitle];

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:[self AVEquivalentMediaType:mediaType]];
    if (status == AVAuthorizationStatusNotDetermined) {
        self.avPermissionCompletionHandler = completionHandler;
        self.preAVPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:denyButtonTitle
                                                         otherButtonTitles:grantButtonTitle, nil];
        self.preAVPermissionAlertView.tag = mediaType;
        [self.preAVPermissionAlertView show];
    } else if(status == AVAuthorizationStatusDenied) {
       
        [self showNoAutherOrRefuseAutherWithMessage:@"请在iPhone的 设置-隐私-相机 选项中允许访问相册。"];
    }else{
        if (completionHandler) {
            completionHandler((status == AVAuthorizationStatusAuthorized),
                              GCDialogResultNoActionTaken,
                              GCDialogResultNoActionTaken);
        }
    }
}

- (void) showCameraPermissionsWithTitle:(NSString *)requestTitle
                                message:(NSString *)message
                        denyButtonTitle:(NSString *)denyButtonTitle
                       grantButtonTitle:(NSString *)grantButtonTitle
                      completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    [self showAVPermissionsWithType:GCAVAuthorizationTypeCamera
                              title:requestTitle
                            message:message
                    denyButtonTitle:denyButtonTitle
                   grantButtonTitle:grantButtonTitle
                  completionHandler:completionHandler];
}

- (void) showMicrophonePermissionsWithTitle:(NSString *)requestTitle
                                    message:(NSString *)message
                            denyButtonTitle:(NSString *)denyButtonTitle
                           grantButtonTitle:(NSString *)grantButtonTitle
                          completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    [self showAVPermissionsWithType:GCAVAuthorizationTypeMicrophone
                              title:requestTitle
                            message:message
                    denyButtonTitle:denyButtonTitle
                   grantButtonTitle:grantButtonTitle
                  completionHandler:completionHandler];
}

- (void) showActualAVPermissionAlertWithType:(GCAVAuthorizationType)mediaType
{
    [AVCaptureDevice requestAccessForMediaType:[self AVEquivalentMediaType:mediaType]
                             completionHandler:^(BOOL granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self fireAVPermissionCompletionHandlerWithType:mediaType];
                                 });
                             }];
}


- (void) fireAVPermissionCompletionHandlerWithType:(GCAVAuthorizationType)mediaType
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:[self AVEquivalentMediaType:mediaType]];
    if (self.avPermissionCompletionHandler) {
        GCDialogResult userDialogResult = GCDialogResultGranted;
        GCDialogResult systemDialogResult = GCDialogResultGranted;
        if (status == AVAuthorizationStatusNotDetermined) {
            userDialogResult = GCDialogResultDenied;
            systemDialogResult = GCDialogResultNoActionTaken;
        } else if (status == AVAuthorizationStatusAuthorized) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultGranted;
        } else if (status == AVAuthorizationStatusDenied) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultDenied;
        } else if (status == AVAuthorizationStatusRestricted) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultParentallyRestricted;
        }
        self.avPermissionCompletionHandler((status == AVAuthorizationStatusAuthorized),
                                           userDialogResult,
                                           systemDialogResult);
        self.avPermissionCompletionHandler = nil;
    }
}

- (NSString*)AVEquivalentMediaType:(GCAVAuthorizationType)mediaType
{
    if (mediaType == GCAVAuthorizationTypeCamera) {
        return AVMediaTypeVideo;
    }
    else {
        return AVMediaTypeAudio;
    }
}

#pragma mark - Photo Permissions Help
- (void) showPhotoPermissionsWithTitle:(NSString *)requestTitle
                               message:(NSString *)message
                       denyButtonTitle:(NSString *)denyButtonTitle
                      grantButtonTitle:(NSString *)grantButtonTitle
                     completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Access Photos?";
    }
    denyButtonTitle  = [self titleFor:GCTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:GCTitleTypeRequest fromTitle:grantButtonTitle];

    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        self.photoPermissionCompletionHandler = completionHandler;
        self.prePhotoPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:denyButtonTitle
                                                            otherButtonTitles:grantButtonTitle, nil];
        [self.prePhotoPermissionAlertView show];
    } else if(status == ALAuthorizationStatusDenied){
       
        [self showNoAutherOrRefuseAutherWithMessage:@"请在iPhone的 设置-隐私-相机 选项中允许访问相机。"];
    }else{
        if (completionHandler) {
            completionHandler((status == ALAuthorizationStatusAuthorized),
                              GCDialogResultNoActionTaken,
                              GCDialogResultNoActionTaken);
        }
    }
}

- (void) showActualPhotoPermissionAlert
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // Got access! Show login
        [self firePhotoPermissionCompletionHandler];
        *stop = YES;
    } failureBlock:^(NSError *error) {
        // User denied access
        [self firePhotoPermissionCompletionHandler];
    }];
}

- (void) firePhotoPermissionCompletionHandler
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (self.photoPermissionCompletionHandler) {
        GCDialogResult userDialogResult = GCDialogResultGranted;
        GCDialogResult systemDialogResult = GCDialogResultGranted;
        if (status == ALAuthorizationStatusNotDetermined) {
            userDialogResult = GCDialogResultDenied;
            systemDialogResult = GCDialogResultNoActionTaken;
        } else if (status == ALAuthorizationStatusAuthorized) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultGranted;
        } else if (status == ALAuthorizationStatusDenied) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultDenied;
        } else if (status == ALAuthorizationStatusRestricted) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultParentallyRestricted;
        }
        self.photoPermissionCompletionHandler((status == ALAuthorizationStatusAuthorized),
                                              userDialogResult,
                                              systemDialogResult);
        self.photoPermissionCompletionHandler = nil;
    }
}

#pragma mark - Contact Permissions Help
/*!
* @discussion get the authorization status of accessing contacts. It handles both uses of Contacts framework iOS 9+ or AddressBook fremwork < iOS 9
* @param GCContactsAuthorizationType
*/
-(GCContactsAuthorizationType)getContactsAuthorizationType{
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    //at least iOS 9 code here
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    return (GCContactsAuthorizationType)status;
#else
    //lower than iOS 9 code here
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    return (GCContactsAuthorizationType)status;
#endif
}

- (void)showContactsPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Access Contacts?";
    }
    denyButtonTitle  = [self titleFor:GCTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:GCTitleTypeRequest fromTitle:grantButtonTitle];
    
    GCContactsAuthorizationType status = [self getContactsAuthorizationType];
    
    
    if (status == GCContactsAuthorizationStatusNotDetermined) {
        self.contactPermissionCompletionHandler = completionHandler;
        self.preContactPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                        message:message
                                                                       delegate:self
                                                              cancelButtonTitle:denyButtonTitle
                                                              otherButtonTitles:grantButtonTitle, nil];
        [self.preContactPermissionAlertView show];
    } else if(status ==GCContactsAuthorizationStatusDenied){
       
        [self showNoAutherOrRefuseAutherWithMessage:@"请在iPhone的 设置-隐私-通讯录 选项中允许访问通讯录。"];
    }else{
        if (completionHandler) {
            completionHandler(status == GCContactsAuthorizationStatusAuthorized,
                              GCDialogResultNoActionTaken,
                              GCDialogResultNoActionTaken);
        }
    }
}

- (void) showActualContactPermissionAlert
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    //at least iOS 9 code here
    CNContactStore *contactsStore = [[CNContactStore alloc] init];
    [contactsStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fireContactPermissionCompletionHandler];
        });
    }];
#else
    //lower than iOS 9 code here
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fireContactPermissionCompletionHandler];
        });
    });
#endif
}

- (void) fireContactPermissionCompletionHandler
{
    GCContactsAuthorizationType status = [self getContactsAuthorizationType];
    if (self.contactPermissionCompletionHandler) {
        GCDialogResult userDialogResult = GCDialogResultGranted;
        GCDialogResult systemDialogResult = GCDialogResultGranted;
        if (status == GCContactsAuthorizationStatusNotDetermined) {
            userDialogResult = GCDialogResultDenied;
            systemDialogResult = GCDialogResultNoActionTaken;
        } else if (status == GCContactsAuthorizationStatusAuthorized) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultGranted;
        } else if (status == GCContactsAuthorizationStatusDenied) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultDenied;
        } else if (status == GCContactsAuthorizationStatusRestricted) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultParentallyRestricted;
        }
        self.contactPermissionCompletionHandler((status == GCContactsAuthorizationStatusAuthorized),
                                                userDialogResult,
                                                systemDialogResult);
        self.contactPermissionCompletionHandler = nil;
    }
}

#pragma mark - Event Permissions Help
- (void) showEventPermissionsWithType:(GCEventAuthorizationType)eventType
                                Title:(NSString *)requestTitle
                              message:(NSString *)message
                      denyButtonTitle:(NSString *)denyButtonTitle
                     grantButtonTitle:(NSString *)grantButtonTitle
                    completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        switch (eventType) {
            case GCEventAuthorizationTypeEvent:
                requestTitle = @"Access Calendar?";
                break;

            default:
                requestTitle = @"Access Reminders?";
                break;
        }
    }
    denyButtonTitle  = [self titleFor:GCTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:GCTitleTypeRequest fromTitle:grantButtonTitle];

    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:[self EKEquivalentEventType:eventType]];
    if (status == EKAuthorizationStatusNotDetermined) {
        self.eventPermissionCompletionHandler = completionHandler;
        self.preEventPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:denyButtonTitle
                                                            otherButtonTitles:grantButtonTitle, nil];
        self.preEventPermissionAlertView.tag = eventType;
        [self.preEventPermissionAlertView show];
    } else if(status == EKAuthorizationStatusDenied){
        if (eventType == GCEventAuthorizationTypeEvent) {
    
            [self showNoAutherOrRefuseAutherWithMessage:@"请在iPhone的 设置-隐私-日历 选项中允许访问日历。"];
        }else{
       
            [self showNoAutherOrRefuseAutherWithMessage:@"请在iPhone的 设置-隐私-提醒事项 选项中允许访问提醒事项。"];
        }
    }else{
        if (completionHandler) {
            completionHandler((status == EKAuthorizationStatusAuthorized),
                              GCDialogResultNoActionTaken,
                              GCDialogResultNoActionTaken);
        }
    }
}

- (void) showActualEventPermissionAlert:(GCEventAuthorizationType)eventType
{
    EKEventStore *aStore = [[EKEventStore alloc] init];
    [aStore requestAccessToEntityType:[self EKEquivalentEventType:eventType] completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fireEventPermissionCompletionHandler:eventType];
        });
    }];
}

- (void) fireEventPermissionCompletionHandler:(GCEventAuthorizationType)eventType
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:[self EKEquivalentEventType:eventType]];
    if (self.eventPermissionCompletionHandler) {
        GCDialogResult userDialogResult = GCDialogResultGranted;
        GCDialogResult systemDialogResult = GCDialogResultGranted;
        if (status == EKAuthorizationStatusNotDetermined) {
            userDialogResult = GCDialogResultDenied;
            systemDialogResult = GCDialogResultNoActionTaken;
        } else if (status == EKAuthorizationStatusAuthorized) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultGranted;
        } else if (status == EKAuthorizationStatusDenied) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultDenied;
        } else if (status == EKAuthorizationStatusRestricted) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultParentallyRestricted;
        }
        self.eventPermissionCompletionHandler((status == EKAuthorizationStatusAuthorized),
                                              userDialogResult,
                                              systemDialogResult);
        self.eventPermissionCompletionHandler = nil;
    }
}

- (NSUInteger)EKEquivalentEventType:(GCEventAuthorizationType)eventType {
    if (eventType == GCEventAuthorizationTypeEvent) {
        return EKEntityTypeEvent;
    }
    else {
        return EKEntityTypeReminder;
    }
}

#pragma mark - Location Permission Help
- (void) showLocationPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    [self showLocationPermissionsForAuthorizationType:GCLocationAuthorizationTypeAlways
                                                title:requestTitle
                                              message:message
                                      denyButtonTitle:denyButtonTitle
                                     grantButtonTitle:grantButtonTitle
                                    completionHandler:completionHandler];
}

- (void) showLocationPermissionsForAuthorizationType:(GCLocationAuthorizationType)authorizationType
                                               title:(NSString *)requestTitle
                                             message:(NSString *)message
                                     denyButtonTitle:(NSString *)denyButtonTitle
                                    grantButtonTitle:(NSString *)grantButtonTitle
                                   completionHandler:(GCPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Access Location?";
    }
    denyButtonTitle  = [self titleFor:GCTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:GCTitleTypeRequest fromTitle:grantButtonTitle];

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        self.locationPermissionCompletionHandler = completionHandler;
        self.locationAuthorizationType = authorizationType;
        self.preLocationPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                         message:message
                                                                        delegate:self
                                                               cancelButtonTitle:denyButtonTitle
                                                               otherButtonTitles:grantButtonTitle, nil];
        [self.preLocationPermissionAlertView show];
    } else if(status == kCLAuthorizationStatusDenied){
      
        [self showNoAutherOrRefuseAutherWithMessage:@"请在iPhone的 设置-隐私-位置 选项中允许访问您的位置。"];
    }else{
        if (completionHandler) {
            completionHandler(([self locationAuthorizationStatusPermitsAccess:status]),
                              GCDialogResultNoActionTaken,
                              GCDialogResultNoActionTaken);
        }
    }
}


- (void) showActualLocationPermissionAlert
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    if (self.locationAuthorizationType == GCLocationAuthorizationTypeAlways &&
        [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {

        [self.locationManager requestAlwaysAuthorization];

    } else if (self.locationAuthorizationType == GCLocationAuthorizationTypeWhenInUse &&
               [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {

        [self.locationManager requestWhenInUseAuthorization];
    }

    [self.locationManager startUpdatingLocation];
}


- (void) fireLocationPermissionCompletionHandler
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (self.locationPermissionCompletionHandler) {
        GCDialogResult userDialogResult = GCDialogResultGranted;
        GCDialogResult systemDialogResult = GCDialogResultGranted;
        if (status == kCLAuthorizationStatusNotDetermined) {
            userDialogResult = GCDialogResultDenied;
            systemDialogResult = GCDialogResultNoActionTaken;
        } else if ([self locationAuthorizationStatusPermitsAccess:status]) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultGranted;
        } else if (status == kCLAuthorizationStatusDenied) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultDenied;
        } else if (status == kCLAuthorizationStatusRestricted) {
            userDialogResult = GCDialogResultGranted;
            systemDialogResult = GCDialogResultParentallyRestricted;
        }
        self.locationPermissionCompletionHandler(([self locationAuthorizationStatusPermitsAccess:status]),
                                                 userDialogResult,
                                                 systemDialogResult);
        self.locationPermissionCompletionHandler = nil;
    }
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation], self.locationManager = nil;
    }
}

- (BOOL)locationAuthorizationStatusPermitsAccess:(CLAuthorizationStatus)authorizationStatus
{
    return authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
    authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse;
}

#pragma mark CLLocationManagerDelegate
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self fireLocationPermissionCompletionHandler];
    }
}

#pragma mark Public UIAlertView Show
- (void)showNoAutherOrRefuseAutherWithMessage:(NSString*)message
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    NSURL*url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication]openURL:url];
#else
    UIAlertView *photoAlertviews = [[UIAlertView alloc] initWithTitle:@"提示"message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [photoAlertviews show];
#endif
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.preAVPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, jerk.
            [self fireAVPermissionCompletionHandlerWithType:alertView.tag];
        } else {
            // User granted access, now show the REAL permissions dialog
            [self showActualAVPermissionAlertWithType:alertView.tag];
        }

        self.preAVPermissionAlertView = nil;
    } else if (alertView == self.prePhotoPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, jerk.
            [self firePhotoPermissionCompletionHandler];
        } else {
            // User granted access, now show the REAL permissions dialog
            [self showActualPhotoPermissionAlert];
        }

        self.prePhotoPermissionAlertView = nil;
    } else if (alertView == self.preContactPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            [self fireContactPermissionCompletionHandler];
        } else {
            // User granted access, now try to trigger the real contacts access
            [self showActualContactPermissionAlert];
        }
    } else if (alertView == self.preEventPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            [self fireEventPermissionCompletionHandler:alertView.tag];
        } else {
            // User granted access, now try to trigger the real contacts access
            [self showActualEventPermissionAlert:alertView.tag];
        }
    } else if (alertView == self.preLocationPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            [self fireLocationPermissionCompletionHandler];
        } else {
            // User granted access, now try to trigger the real location access
            [self showActualLocationPermissionAlert];
        }
    } else if (alertView == self.prePushNotificationPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            [self firePushNotificationPermissionCompletionHandler];
        } else {
            // User granted access, now try to trigger the real location access
            [self showActualPushNotificationPermissionAlert];
        }
    }else if (alertView == self.gpsPermissionAlertView){
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            
        } else {
            // User granted access, now try to trigger the real location access
            // 暂且放放，等待完善GPS授权
        }
    }
}

#pragma mark - Titles
- (NSString *)titleFor:(GCTitleType)titleType fromTitle:(NSString *)title
{
    switch (titleType) {
        case GCTitleTypeDeny:
            title = (title.length == 0) ? @"Not Now" : title;
            break;
        case GCTitleTypeRequest:
            title = (title.length == 0) ? @"Give Access" : title;
            break;
        default:
            title = @"";
            break;
    }
    return title;
}

@end
