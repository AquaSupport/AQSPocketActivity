//
//  AQSPocketActivityTests.m
//  AQSPocketActivityTests
//
//  Created by kaiinui on 2014/11/10.
//  Copyright (c) 2014年 Aquamarine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "AQSPocketActivity.h"

@interface AQSPocketActivity (Test)

- (BOOL)isPocketAvailable;
- (BOOL)isPocketLoggedIn;
- (void)performLoginAndActivity;
- (void)saveURLs:(NSArray /* NSURL */ *)URLs;
- (void)saveURL:(NSURL *)URL withBlock:(void(^)(NSURL *URL, NSError *error))block;

@end

@interface AQSPocketActivityTests : XCTestCase

@property AQSPocketActivity *activity;

@end

@implementation AQSPocketActivityTests

- (void)setUp {
    [super setUp];
    
    _activity = [[AQSPocketActivity alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testItsActivityCategoryIsShare {
    XCTAssertTrue(AQSPocketActivity.activityCategory == UIActivityCategoryShare);
}

- (void)testItReturnsItsImage {
    XCTAssertNotNil(_activity.activityImage);
}

- (void)testItReturnsItsType {
    XCTAssertTrue([_activity.activityType isEqualToString:@"org.openaquamarine.pocket"]);
}

- (void)testItReturnsItsTitle {
    XCTAssertTrue([_activity.activityTitle isEqualToString:@"Send to Pocket"]);
}

- (void)testItCanPerformActivityWithURLWhenPocketInstalled {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketAvailable]).andReturn(YES);
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"]];
    XCTAssertTrue([activity canPerformWithActivityItems:activityItems]);
}

- (void)testItCannotPerformActivityWithURLIfPocketNotInstalled {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketAvailable]).andReturn(NO);
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"]];
    XCTAssertFalse([activity canPerformWithActivityItems:activityItems]);
}

- (void)testItCannotPerformActivityWithNoURLWhenPocketInstalled {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketAvailable]).andReturn(YES);
    
    NSArray *activityItems = @[@"whoa"];
    XCTAssertFalse([activity canPerformWithActivityItems:activityItems]);
}

- (void)testItAttemptToLoginIfNotLoggedIn {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketLoggedIn]).andReturn(NO);
    [[activity expect] performLoginAndActivity];
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"]];
    [activity prepareWithActivityItems:activityItems];
    [activity performActivity];
    
    [activity verify];
}

- (void)testItDoNotAttemptToLoginWhenLoggedIn {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketLoggedIn]).andReturn(YES);
    [[activity reject] performLoginAndActivity];
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"]];
    [activity prepareWithActivityItems:activityItems];
    [activity performActivity];
    
    [activity verify];
}

- (void)testItInvokesSaveURLsWithURLsInActivityItems {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketLoggedIn]).andReturn(YES);
    [[activity expect] saveURLs:[OCMArg checkWithBlock:^BOOL(NSArray *URLs) {
        return URLs.count == 2;
    }]];
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"], [NSURL URLWithString:@"http://yahoo.com/"], @"whoa", @2];
    [activity prepareWithActivityItems:activityItems];
    [activity performActivity];
    
    [activity verify];
}

- (void)testItInvokesSaveURLsWithDuplicateEliminatedURLsInActivityItems {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketLoggedIn]).andReturn(YES);
    [[activity expect] saveURLs:[OCMArg checkWithBlock:^BOOL(NSArray *URLs) {
        return URLs.count == 2;
    }]];
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"], [NSURL URLWithString:@"http://yahoo.com/"], [NSURL URLWithString:@"http://yahoo.com/"], @"whoa", @2];
    [activity prepareWithActivityItems:activityItems];
    [activity performActivity];
    
    [activity verify];
}

- (void)testItInvokesActivityDidFinishWhenSuccess {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketLoggedIn]).andReturn(YES);
    void (^proxyBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^passedBlock)(NSURL *URL, NSError *error);
        [invocation getArgument: &passedBlock atIndex: 3];
        
        passedBlock([NSURL URLWithString:@"http://google.com"], nil);
    };
    [[[activity stub] andDo: proxyBlock] saveURL:[OCMArg any] withBlock:[OCMArg any]];
    OCMExpect([activity activityDidFinish:YES]);
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"], [NSURL URLWithString:@"http://yahoo.com/"], @"whoa", @2];
    [activity prepareWithActivityItems:activityItems];
    [activity performActivity];
    
    [activity verify];
}

- (void)testItInvokesActivityDidFinishWithNoWhenAllURLFailedToSave {
    id activity = [OCMockObject partialMockForObject:_activity];
    OCMStub([activity isPocketLoggedIn]).andReturn(YES);
    void (^proxyBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^passedBlock)(NSURL *URL, NSError *error);
        NSURL *passedURL;
        [invocation getArgument:&passedURL atIndex:2];
        [invocation getArgument:&passedBlock atIndex:3];
        
        passedBlock(passedURL, [NSError errorWithDomain:@"" code:0 userInfo:nil]);
    };
    [[[activity stub] andDo:proxyBlock] saveURL:[OCMArg any] withBlock:[OCMArg any]];
    OCMExpect([activity activityDidFinish:NO]);
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"], [NSURL URLWithString:@"http://yahoo.com/"], @"whoa", @2];
    [activity prepareWithActivityItems:activityItems];
    [activity performActivity];
    
    [activity verify];
}

- (void)testItInvokesActivityDidFinishWithYESWhenAtLeastOneURLSucceedToSave {
    id activity = [OCMockObject partialMockForObject:_activity];
    __block BOOL firstURL = YES;
    
    OCMStub([activity isPocketLoggedIn]).andReturn(YES);
    void (^proxyBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^passedBlock)(NSURL *URL, NSError *error);
        NSURL *passedURL;
        NSError *error = nil;
        [invocation getArgument:&passedURL atIndex:2];
        [invocation getArgument:&passedBlock atIndex:3];
        
        if (firstURL == YES) {
            error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
            firstURL = NO;
        }
        passedBlock(passedURL, error);
    };
    [[[activity stub] andDo:proxyBlock] saveURL:[OCMArg any] withBlock:[OCMArg any]];
    OCMExpect([activity activityDidFinish:YES]);
    
    NSArray *activityItems = @[[NSURL URLWithString:@"http://google.com/"], [NSURL URLWithString:@"http://yahoo.com/"], [NSURL URLWithString:@"http://duckduckgo.com/"], @"whoa", @2];
    [activity prepareWithActivityItems:activityItems];
    [activity performActivity];
    
    [activity verify];
}

@end
