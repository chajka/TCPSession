//
//  TCPSessionTests.m
//  TCPSessionTests
//
//  Created by Чайка on 4/8/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TCPSession.h"

@interface TCPSessionTests : XCTestCase<TCPSessionDelegate>

@end

NSString * const server = @"chajka.from.tv";
//NSString * const server = nil;
SInt32 port = 80;

@implementation TCPSessionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) test01_Allocation
{
	TCPSession *session = nil;
	@try {
		session = [[TCPSession alloc] initWithServer:server andPort:port];
	} @catch (TCPSessionException *exception) {
		NSLog(@"initialize exception catched");
	}
	XCTAssertNotNil(session);
	XCTAssertEqual(session.server, server);
	XCTAssertEqual(session.port, port);
	session.delegate = self;
	XCTAssertEqual(session.delegate, self);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void) session:(TCPSession *)session hasBytesAvailable:(NSInputStream *)stream
{
	
}
@end
