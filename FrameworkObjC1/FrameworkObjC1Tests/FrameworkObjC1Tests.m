//
//  FrameworkObjC1Tests.m
//  FrameworkObjC1Tests
//
//  Created by Adolf Jurgens Freitas on 3/31/17.
//  Copyright © 2017 Adolf Jurgens Freitas. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FrameworkObjC1Tests : XCTestCase

@end

@implementation FrameworkObjC1Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
