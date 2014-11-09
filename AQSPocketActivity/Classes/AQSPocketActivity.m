//
//  AQSPocketActivity.m
//  AQSPocketActivity
//
//  Created by kaiinui on 2014/11/10.
//  Copyright (c) 2014年 Aquamarine. All rights reserved.
//

#import "AQSPocketActivity.h"

#import <PocketAPI.h>

NSString *const kAQSPocketActivitySaveURLDidFinishNotification = @"AQSPocketActivitySaveURLDidFinishNotification";

NSString *const kAQSPocketActivitySaveURLDidFinishNotificationIsSuccessKey = @"AQSPocketActivitySaveURLDidFinishNotificationIsSuccess";
NSString *const kAQSPocketActivitySaveURLDidFinishNotificationSavedURLsKey = @"AQSPocketActivitySaveURLDidFinishNotificationSavedURLs";
NSString *const kAQSPocketActivitySaveURLDidFinishNotificationFailedURLsKey = @"AQSPocketActivitySaveURLDidFinishNotificationFailedURLs";
NSString *const kAQSPocketActivitySaveURLDidFinishNotificationFailedErrorsKey = @"AQSPocketActivitySaveURLDidFinishNotificationFailedErrors";

@interface AQSPocketActivity ()

@property (nonatomic, strong) NSArray *activityItems;

//{@dependencies
@property (nonatomic, weak) PocketAPI *pocket;
//}

@end

@implementation AQSPocketActivity

# pragma mark - Setup Helpers

+ (void)setupPocketWithConsumerKey:(NSString *)consumerKey {
    [self setConsumerKey:consumerKey];
    [self setURLSchemeWithConsumerKey:consumerKey];
}

+ (void)setConsumerKey:(NSString *)consumerKey {
    [[PocketAPI sharedAPI] setConsumerKey:consumerKey];
}

+ (void)setURLSchemeWithConsumerKey:(NSString *)consumerKey {
    NSString *appID = [consumerKey componentsSeparatedByString:@"-"][0];
    NSString *scheme = [NSString stringWithFormat:@"pocketapp%@", appID];
    [self setURLScheme:scheme];
}

+ (void)setURLScheme:(NSString *)scheme {
    [[PocketAPI sharedAPI] setURLScheme:scheme];
}

+ (BOOL)handleOpenURL:(NSURL *)URL {
    return [[PocketAPI sharedAPI] handleOpenURL:URL];
}

# pragma mark - Instantiation

- (instancetype)init {
    self = [super init];
    if (self) {
        _pocket = [PocketAPI sharedAPI];
    }
    return self;
}

- (instancetype)initWithPocketAPIAppID:(NSString *)ID {
    self = [self init];
    if (self) {
        [_pocket setURLScheme:ID];
    }
    return self;
}

- (instancetype)initWithPocketAPI:(PocketAPI *)pocket {
    self = [self init];
    if (self) {
        _pocket = pocket;
    }
    return self;
}

# pragma mark - UIActivity

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [super prepareWithActivityItems:activityItems];
    
    self.activityItems = activityItems;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"org.openaquamarine.pocket";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Send to Pocket", nil);
}

- (UIImage *)activityImage {
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 8) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"color_%@", NSStringFromClass([self class])]];
    } else {
        return [UIImage imageNamed:NSStringFromClass([self class])];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return ([self isPocketAvailable] && [self nilOrFirstURLFromArray:activityItems] != nil);
}

- (void)performActivity {
    if ([self isPocketLoggedIn] == NO) {
        [self performLoginAndActivity];
        return;
    }
    
    [self performSaving];
}

# pragma mark - Helpers (Pocket)

/**
 *  Perform actual operation.
 */
- (void)performSaving {
    NSArray *URLs = [[self urlSetFromArray:_activityItems] allObjects];
    [self saveURLs:URLs];
}

- (void)saveURLs:(NSArray /* NSURL */ *)URLs {
    __block NSInteger URLsLeft = URLs.count;
    __block NSMutableArray *failedURLs = [NSMutableArray array];
    __block NSMutableArray *errors = [NSMutableArray array];
    __block NSMutableArray *succeedURLs = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    for (NSURL *URL in URLs) {
        [self saveURL:URL withBlock:^(NSURL *URL, NSError *error) {
            if (error != nil) {
                [failedURLs addObject:URL];
                [errors addObject:error];
            } else {
                [succeedURLs addObject:URL];
            }
            URLsLeft -= 1;
            
            if (URLsLeft == 0) {
                BOOL isFailed = (succeedURLs == 0); // It is failed if all of URLs are not saved.
                [weakSelf activityDidFinish:isFailed withFailedURLs:failedURLs withSavedURLs:succeedURLs withErrors:errors];
            }
        }];
    }
}

- (void)saveURL:(NSURL *)URL withBlock:(void(^)(NSURL *URL, NSError *error))block {
    [self.pocket saveURL:URL handler:^(PocketAPI *api, NSURL *url, NSError *error) {
        block(url, error);
    }];
}

- (void)performLoginAndActivity {
    __weak typeof(self) weakSelf = self;
    [self.pocket loginWithHandler:^(PocketAPI *pocket, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error);
            [weakSelf activityDidFinish:NO withFailedURLs:@[] withSavedURLs:@[] withErrors:@[error]];
        } else {
            [weakSelf performSaving];
        }
    }];
}

- (BOOL)isPocketLoggedIn {
    return [self.pocket isLoggedIn];
}

- (BOOL)isPocketAvailable {
    NSURL *pocketURL = [NSURL URLWithString:[[PocketAPI pocketAppURLScheme] stringByAppendingString:@":test"]];
    return [[UIApplication sharedApplication] canOpenURL:pocketURL];
}

# pragma mark - Helpers (NSNotification)

- (void)activityDidFinish:(BOOL)completed withFailedURLs:(NSArray *)failedURLs withSavedURLs:(NSArray *)savedURLs withErrors:(NSArray *)errors {
    NSDictionary *userInfo = @{
                               kAQSPocketActivitySaveURLDidFinishNotificationIsSuccessKey: @(completed),
                               kAQSPocketActivitySaveURLDidFinishNotificationSavedURLsKey: savedURLs,
                               kAQSPocketActivitySaveURLDidFinishNotificationFailedURLsKey: failedURLs,
                               kAQSPocketActivitySaveURLDidFinishNotificationFailedErrorsKey: errors
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:kAQSPocketActivitySaveURLDidFinishNotification object:nil userInfo:userInfo];
    
    [self activityDidFinish:completed];
}

# pragma mark - Helpers (Array)

- (NSString *)nilOrFirstStringFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[NSString class]]) {
            return item;
        }
    }
    return nil;
}

- (NSURL *)nilOrFirstURLFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[NSURL class]]) {
            return item;
        }
    }
    return nil;
}

- (NSMutableSet /* NSURL */ *)urlSetFromArray:(NSArray *)array {
    NSMutableSet *set = [NSMutableSet set];
    for (id item in array) {
        if ([item isKindOfClass:[NSURL class]]) {
            [set addObject:item];
        }
    }
    return set;
}

@end
