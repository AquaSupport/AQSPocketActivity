//
//  AQSPocketActivity.h
//  AQSPocketActivity
//
//  Created by kaiinui on 2014/11/10.
//  Copyright (c) 2014年 Aquamarine. All rights reserved.
//

#import <UIKit/UIKit.h>

# pragma mark - NSNotification Keys
/** @name NSNotification Keys */

/**
 *  Posted when saving URLs to Pocket finished.
 *
 *  @notification
 *  - name: kAQSPocketActivitySaveURLDidFinishNotification
 *  - object: `nil`
 *  - userInfo
 *    - NSNumber<BOOL> : kAQSPocketActivitySaveURLDidFinishNotificationIsSuccessKey
 *    - NSArray<NSURL> : kAQSPocketActivitySaveURLDidFinishNotificationSavedURLsKey;
 *    - NSArray<NSURL> : kAQSPocketActivitySaveURLDidFinishNotificationFailedURLsKey
 *    - NSArray<NSError> : kAQSPocketActivitySaveURLDidFinishNotificationFailedErrorsKey
 */
extern NSString *const kAQSPocketActivitySaveURLDidFinishNotification;

# pragma mark - kAQSPocketActivitySaveURLDidFinishNotification UserInfo Keys
/** @name kAQSPocketActivitySaveURLDidFinishNotification UserInfo Keys */

extern NSString *const kAQSPocketActivitySaveURLDidFinishNotificationIsSuccessKey;
extern NSString *const kAQSPocketActivitySaveURLDidFinishNotificationSavedURLsKey;
extern NSString *const kAQSPocketActivitySaveURLDidFinishNotificationFailedURLsKey;
extern NSString *const kAQSPocketActivitySaveURLDidFinishNotificationFailedErrorsKey;

# pragma mark -

/**
 *  You must setup Pocket client with Consumer key.
 *
 *  1. To obtain a consumer key, visit http://getpocket.com/api/signup and regist an new app. Keep in mind "Add" permission is required.
 *  2. You should provide an URL Scheme like `pocketapp42` where `42` is a part of consumer key. For consumer key "12345-abcdefghijklmn" the number is "12345". (This is called "App ID") Don't forget to set the URL Identifier `com.getpocket.sdk`.
 *  3. On your `AppDelegate`'s `- application:didFinishLaunchingWithOptions:`, call `+ setupPocketWithConsumerKey:` with obtained consumer key to setup Pocket client.
 *  4. On your `AppDelegate`'s `- application:handleOpenURL:`, call `+ handleOpenURL:` with passed URL. Keep the method returns `YES` whenever `+ handleOpenURL` returns `YES`.
 *
 *  For detailed instruction, visit Pocket's official repository https://github.com/Pocket/Pocket-ObjC-SDK
 *
 *  @see https://github.com/Pocket/Pocket-ObjC-SDK
 *  @see `+ setupPocketWithConsumerKey:`
 */
@interface AQSPocketActivity : UIActivity

# pragma mark - Handling OAuth Application
/** @name Handling OAuth Applciation */

/**
 *  Setup Pocket client with passed consumer key.
 *
 *  This method does automatically setup Pocket client with URL scheme built from consumer key. You do not need to `[[PocketAPI sharedAPI] setURLScheme:scheme]`.
 *  This method does both `- setConsumerKey:` and `- setURLScheme:` behalf of you.
 *
 *  @warning This method should be called on `- application:didFinishLaunchingWithOptions:`. Otherwise the activity may not work.
 *
 *  @param consumerKey 
 *
 *  @see https://github.com/Pocket/Pocket-ObjC-SDK
 */
+ (void)setupPocketWithConsumerKey:(NSString *)consumerKey;

/**
 *  Handle `openURL:` for Pocket's callback.
 *
 *  @warning This method should be called on `- application:handleOpenURL:`. Otherwise the activity may not work.
 *
 *  @param URL Passed URL on `- application:handleOpenURL:`
 *
 *  @return Whether the URL should be handled by Pocket client.
 */
+ (BOOL)handleOpenURL:(NSURL *)URL;

@end
