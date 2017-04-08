//
//  TCPSessionTests.m
//  TCPSessionTests
//
//  Created by Чайка on 4/8/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TCPSession.h"

@interface TCPSessionTests : XCTestCase<TCPSessionDelegate> {
	TCPSession *session;
}

@end

NSString * const server = @"chajka.from.tv";
NSString * const nilServer = nil;
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

- (void) test_01_Allocation
{
	@try {
		session = [[TCPSession alloc] initWithServer:server andPort:port];
	} @catch (TCPSessionException *exception) {
		NSLog(@"failer initialize exception catched");
	}
	XCTAssertNotNil(session);
	XCTAssertEqual(session.server, server);
	XCTAssertEqual(session.port, port);
	session.delegate = self;
	XCTAssertEqual(session.delegate, self);
}// end - (void) test01_Allocation

- (void) test_02_NilServer
{
	@try {
		session = [[TCPSession alloc] initWithServer:nilServer andPort:port];
	} @catch (NSException *exception) {
		NSLog(@"OK initialize exception catched");
		XCTAssertNil(session, @"can catch session nil exception : %@", session);
	}// end try - catch pass nil server name
}// end - (void) test02_NilServer

- (void) test_03_Reachability
{
	@try {
		session = [[TCPSession alloc] initWithServer:server andPort:port];
		session.delegate = self;
		BOOL reachable = [session connect:DirectionReadWrite inRunLoop:NULL];
		XCTAssertTrue(reachable);
	} @catch (NSException *exception) {
		XCTFail(@"Unexpected failer");
	}
}// end - (void) test_03_Reachability

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
