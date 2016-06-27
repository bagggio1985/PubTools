//
//  PubToolsTests.m
//  PubToolsTests
//
//  Created by kyao on 14-9-2.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PTSerialize.h"
#import "PTLock.h"
#import "PTFileUtils.h"

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
//    [PubLocation systemLocationStatus];
//    PTLock *lock = [[PTLock alloc] init];
//    {
//        [[PTAutoLock alloc] initWithLock:lock];
//    }
//    
//    int i = 0;
    
    NSLog(@"%@", [[PTFileUtils getDocumentPath] stringByAppendingPathComponent:@"abc/123"]);
    NSLog(@"%@", [PTFileUtils getCachePath]);
    NSLog(@"%@", [PTFileUtils getResourcePath]);
    NSLog(@"%@", [PTFileUtils getTemporaryPath]);
    
    [PTFileUtils createFolderAtPath:[[PTFileUtils getDocumentPath] stringByAppendingPathComponent:@"abc/123"]];

    NSString* filePath = [PTFileUtils getFilePathAtDocument:@"1111/1231.txt"];
    
    XCTAssert([PTFileUtils createFileAtPath:filePath]);
    XCTAssert([PTFileUtils removeFileAtPath:filePath]);
    
    XCTAssert([PTFileUtils removeFolderAtPath:[PTFileUtils getFilePathAtDocument:@"1111"]]);
    XCTAssert([PTFileUtils removeFolderAtPath:[PTFileUtils getFilePathAtDocument:@"abc"]]);

    
}

@end
