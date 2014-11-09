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

@interface AQSPocketActivity : UIActivity

+ (void)setupPocketWithConsumerKey:(NSString *)consumerKey;
+ (BOOL)handleOpenURL:(NSURL *)URL;

@end
