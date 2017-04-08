//
//  TCPSession.m
//  TCPSession
//
//  Created by Чайка on 4/7/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import "TCPSession.h"
#import <SystemConfiguration/SystemConfiguration.h>

static NSString * const KeySelf = @"KeySelf";
static NSString * const KeyDelegate = @"KeyDelegate";

NSString * _Nonnull const KeyStreamError = @"KeyStreamError";

@interface TCPSession ()
- (BOOL) checkReachability;
- (void) createStream:(TCPSessionDirection)direction;
- (void) setupAndScheduleReadStream;
- (void) setupAndScheduleWriteStream;
- (void) unscheduleReadStream:(CFRunLoopRef _Nonnull)runLoop mode:(CFRunLoopMode _Nonnull)mode;
- (void) unscheduleWriteStream:(CFRunLoopRef _Nonnull)runLoop mode:(CFRunLoopMode _Nonnull)mode;

#ifdef __cplusplus
extern "C" {
#endif
static void readStreamCallback(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo);
static void writeStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo);
#ifdef __cplusplus
} //end extern "C"
#endif

@end

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

	server = [[NSString alloc] initWithString:serverName];
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
- (BOOL) connect:(TCPSessionDirection)direction inRunLoop:(CFRunLoopRef _Nullable)runLoop
{
	if (!delegate)
		@throw [TCPSessionException exceptionWithName:DelegateNotDefined reason:DelegateIsNil userInfo:nil];

	if (![self checkReachability])
		return NO;
	[self createStream:direction];
	
	targetRunLoop = runLoop;
	if (!targetRunLoop)
		targetRunLoop = CFRunLoopGetMain();
	currentRunLoopMode = kCFRunLoopCommonModes;
	[self setupAndScheduleReadStream];
	[self setupAndScheduleWriteStream];

	return YES;
}// end - (BOOL) connect:(TCPSessionDirection)direction

- (BOOL) connect:(TCPSessionDirection)direction inRunLoop:(CFRunLoopRef _Nonnull)runLoop withMode:(CFRunLoopMode _Nonnull)mode
{
	if (!delegate)
		@throw [TCPSessionException exceptionWithName:DelegateNotDefined reason:DelegateIsNil userInfo:nil];
	
	if (![self checkReachability])
		return NO;
	[self createStream:direction];
	
	targetRunLoop = runLoop;
	currentRunLoopMode = mode;
	if (!targetRunLoop)
		targetRunLoop = CFRunLoopGetMain();
	[self setupAndScheduleReadStream];
	[self setupAndScheduleWriteStream];
	
	return YES;
}// end - (BOOL) connect:(TCPSessionDirection)direction

- (void) disconnect
{
	if (readStream)
		[self unscheduleReadStream:targetRunLoop mode:currentRunLoopMode];
	if (writeStream)
		[self unscheduleWriteStream:targetRunLoop mode:currentRunLoopMode];
}// end - (void) disconnect

#pragma mark - private
#pragma mark connect message client
- (BOOL) checkReachability
{
	SCNetworkReachabilityRef reachablity = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, server.UTF8String);
	SCNetworkReachabilityFlags flags;
	Boolean success = SCNetworkReachabilityGetFlags(reachablity, &flags);
	CFRelease(reachablity);

	return success ? YES : NO;
}// end - (void) checkReachability

- (void) createStream:(TCPSessionDirection)direction
{
	switch (direction) {
		case DirectionRead:
			CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)server, port, &readStream, NULL);
			if (!readStream)
				@throw [TCPSessionException exceptionWithName:StreamOpenFail reason:ReadStreamOpenFail userInfo:nil];
			break;
		case DirectionWrite:
			CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)server, port, NULL, &writeStream);
			if (!writeStream)
				@throw [TCPSessionException exceptionWithName:StreamOpenFail reason:WriteStreamOpenFail userInfo:nil];
			break;
		case DirectionReadWrite:
			CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)server, port, &readStream, &writeStream);
			if (!readStream)
				@throw [TCPSessionException exceptionWithName:StreamOpenFail reason:ReadStreamOpenFail userInfo:nil];
			if (!writeStream)
				@throw [TCPSessionException exceptionWithName:StreamOpenFail reason:WriteStreamOpenFail userInfo:nil];
			break;
		default:
			break;
	}// end switch - case by direction
}// end - (void) createStream:(TCPSessionDirection)direction

- (void) setupAndScheduleReadStream
{
	if (!readStream)
		return;

	NSDictionary<NSString *, id> *info = @{ KeySelf:self, KeyDelegate:delegate };
	CFStreamClientContext context = { 0, (__bridge void *)(info), NULL, NULL, NULL };
	
		// setup callback
	if (readStream) {
		// make callback flags
		CFOptionFlags flags = kCFStreamEventHasBytesAvailable;
		if (haveOpenCompleted)
			flags |= kCFStreamEventOpenCompleted;
		if (haveEndEncounted)
			flags |= kCFStreamEventErrorOccurred;
		if (haveErrorOccured)
			flags |= kCFStreamEventErrorOccurred;
		
		// set callback to read stream
		CFReadStreamSetClient(readStream, flags, readStreamCallback, &context);
	}// end if have read stream

	CFReadStreamScheduleWithRunLoop(readStream, targetRunLoop, currentRunLoopMode);
	if (CFReadStreamOpen(readStream)) {
		__autoreleasing NSError *err = (__bridge_transfer NSError *)CFReadStreamCopyError(readStream);
		[self unscheduleReadStream:targetRunLoop mode:currentRunLoopMode];
		@throw [TCPSessionException exceptionWithName:StreamScheduleFail reason:ReadStreamScheduleFail userInfo:@{KeyStreamError:err}];
	}// end if readstream can not open
}// end - (void) setupAndScheduleReadStream:(CFRunLoopRef)runLoop

- (void) setupAndScheduleWriteStream
{
	if (!writeStream)
		return;

	NSDictionary<NSString *, id> *info = @{ KeySelf:self, KeyDelegate:delegate };
	CFStreamClientContext context = { 0, (__bridge void *)(info), NULL, NULL, NULL };
	
		// setup callback
	if (writeStream) {
		// make callback flags
		CFOptionFlags flags = kCFStreamEventNone;
		if (haveCanAcceptBytes)
			flags |= kCFStreamEventCanAcceptBytes;
		if (haveOpenCompleted)
			flags |= kCFStreamEventOpenCompleted;
		if (haveEndEncounted)
			flags |= kCFStreamEventErrorOccurred;
		if (haveErrorOccured)
			flags |= kCFStreamEventErrorOccurred;
		
		// set callback to write stream
		CFWriteStreamSetClient(writeStream, flags, writeStreamCallback, &context);
	}// end if have write stream

	CFWriteStreamScheduleWithRunLoop(writeStream, targetRunLoop, currentRunLoopMode);
	if (!CFWriteStreamOpen(writeStream)) {
		__autoreleasing NSError *err = (__bridge_transfer NSError *)CFWriteStreamCopyError(writeStream);
		[self unscheduleWriteStream:targetRunLoop mode:currentRunLoopMode];
		@throw [TCPSessionException exceptionWithName:StreamScheduleFail reason:WriteStreamScheduleFail userInfo:@{KeyStreamError:err}];
	}// end if writestream can not open
}// end - (void) setupAndScheduleWriteStream:(CFRunLoopRef)runLoop

- (void) unscheduleReadStream:(CFRunLoopRef _Nonnull)runLoop mode:(CFRunLoopMode _Nonnull)mode
{
	CFReadStreamUnscheduleFromRunLoop(readStream, runLoop, mode);
	CFReadStreamSetClient(readStream, kCFStreamEventNone, NULL, NULL);
}// - (void) unscheduleStream:(CFSetRef _Nonnull)stream

- (void) unscheduleWriteStream:(CFRunLoopRef _Nonnull)runLoop mode:(CFRunLoopMode _Nonnull)mode
{
	CFWriteStreamUnscheduleFromRunLoop(writeStream, runLoop, mode);
	CFWriteStreamSetClient(writeStream, kCFStreamEventNone, NULL, NULL);
}// - (void) unscheduleStream:(CFSetRef _Nonnull)stream

#pragma mark - delegate
#pragma mark - C functions
static void
readStreamCallback(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)
{
	id<TCPSessionDelegate> delegate = ((__bridge_transfer NSDictionary *)clientCallBackInfo)[KeyDelegate];
	TCPSession *mySelf = ((__bridge_transfer NSDictionary *)clientCallBackInfo)[KeySelf];

	switch (eventType) {
		case kCFStreamEventHasBytesAvailable:
			[delegate session:mySelf hasBytesAvailable:(__bridge_transfer NSInputStream *)stream];
			break;
		case kCFStreamEventOpenCompleted:
			[delegate session:mySelf openCompleted:(__bridge_transfer NSInputStream *)stream];
			break;
		case kCFStreamEventEndEncountered:
			[delegate session:mySelf endEncountered:(__bridge_transfer NSInputStream *)stream];
			break;
		case kCFStreamEventErrorOccurred:
			[delegate session:mySelf endEncountered:(__bridge_transfer NSInputStream *)stream];
			break;
		default:
			break;
	}// end switch - case by stream event types
}// end static void readStreamCallback(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)

static void
writeStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)
{
	id<TCPSessionDelegate> delegate = ((__bridge_transfer NSDictionary *)clientCallBackInfo)[KeyDelegate];
	TCPSession *mySelf = ((__bridge_transfer NSDictionary *)clientCallBackInfo)[KeySelf];
	
	switch (eventType) {
		case kCFStreamEventCanAcceptBytes:
			[delegate session:mySelf canAcceptBytes:(__bridge_transfer NSOutputStream *)stream];
			break;
		case kCFStreamEventOpenCompleted:
			[delegate session:mySelf openCompleted:(__bridge_transfer NSOutputStream *)stream];
			break;
		case kCFStreamEventEndEncountered:
			[delegate session:mySelf endEncountered:(__bridge_transfer NSOutputStream *)stream];
			break;
		case kCFStreamEventErrorOccurred:
			[delegate session:mySelf endEncountered:(__bridge_transfer NSOutputStream *)stream];
			break;
		default:
			break;
	}// end switch - case by stream event types
}// end static void writeStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo)

@end
