//
//  TCPSession.m
//  TCPSession
//
//  Created by Чайка on 4/7/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import "TCPSession.h"
#import "TCPSessionException.h"

@implementation TCPSession
#pragma mark - synthesize properties
@synthesize server;
@synthesize port;

#pragma mark - class method
#pragma mark - constructor / destructor
- (nonnull instancetype) initWithServer:(NSString * _Nonnull)serverName andPort:(SInt32)portNumber
{
	self = [super init];
	if (!self)
		@throw [TCPSessionException exceptionWithName:InitializeFail reason:ConstructorReturnNil userInfo:nil];
	if (!serverName)
		@throw [TCPSessionException exceptionWithName:InitializeFail reason:ServerNameIsNil userInfo:nil];

	server = serverName;
	port = portNumber;

	return self;
}// end - (nonnull instancetype) initWithServer:(NSString * _Nonnull)serverName andPort:(SInt32)portNumber
#pragma mark - override
#pragma mark - properties
- (id<TCPSessionDelegate> _Nullable) delegate { return delegate; }
- (void) setDelegate:(id<TCPSessionDelegate>)delegate_
{
	delegate = delegate_;

	haveCanAcceptBytes = [delegate respondsToSelector:@selector(session:canAcceptBytes:)];
	haveOpenCompleted = [delegate respondsToSelector:@selector(session:openCompleted:)];
	haveEndEncounted = [delegate respondsToSelector:@selector(session:endEncountered:)];
	haveErrorOccured = [delegate respondsToSelector:@selector(session:errorOccurred:)];
}// end - (void) setDelegate:(id<TCPSessionDelegate>)delegate_
#pragma mark - actions
#pragma mark - messages
#pragma mark - private
#pragma mark - delegate
#pragma mark - C functions

@end
