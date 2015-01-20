//
//  PubToolsTests.m
//  PubToolsTests
//
//  Created by kyao on 14-9-2.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PubLocation.h"

@interface PubToolsTests : XCTestCase

@end

@implementation PubToolsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    [PubLocation systemLocationStatus];
}

@end
