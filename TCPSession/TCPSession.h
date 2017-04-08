//
//  TCPSession.h
//  TCPSession
//
//  Created by Чайка on 4/7/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSessionException.h"

extern NSString * _Nonnull const KeyStreamError;

@class TCPSession;
@protocol TCPSessionDelegate <NSObject>
@required
- (void) session:(TCPSession * _Nonnull)session hasBytesAvailable:(NSInputStream * _Nonnull)stream;

@optional
- (void) session:(TCPSession * _Nonnull)session canAcceptBytes:(NSOutputStream * _Nonnull)stream;
- (void) session:(TCPSession * _Nonnull)session openCompleted:(NSStream * _Nonnull)stream;
- (void) session:(TCPSession * _Nonnull)session endEncountered:(NSStream * _Nonnull)stream;
- (void) session:(TCPSession * _Nonnull)session errorOccurred:(NSStream * _Nonnull)stream;
@end

typedef  NS_ENUM(NSUInteger, TCPSessionDirection) {
	DirectionRead = 1 << 0,
	DirectionWrite = 1 << 1,
	DirectionReadWrite = DirectionRead + DirectionWrite
};

@interface TCPSession : NSObject {
	NSString													*server;
	SInt32														port;

	id<TCPSessionDelegate>										delegate;
	BOOL														haveCanAcceptBytes;
	BOOL														haveOpenCompleted;
	BOOL														haveEndEncounted;
	BOOL														haveErrorOccured;

	CFReadStreamRef												readStream;
	CFWriteStreamRef											writeStream;
	CFRunLoopRef												targetRunLoop;
	CFRunLoopMode												currentRunLoopMode;
}
@property (strong, readonly) NSString 							* _Nonnull server;
@property (readonly) SInt32										port;
@property (weak, readwrite) id<TCPSessionDelegate> _Nullable	delegate;

/*
 Initialize

 @param server name as NSStreing
 @param server port number as integer
 @throw TCPSessionException initialization fail
 @throw server name name is nil
*/
- (nonnull instancetype) initWithServer:(NSString * _Nonnull)serverName andPort:(SInt32)portNumber;

/*
 Connect to server and start call delegates

 @param TCPSesionDirection direction for connection to server
 @param RunLoopRef target runloop to schedule stream(s)
 @throw did not set delegate
*/
- (BOOL) connect:(TCPSessionDirection)direction inRunLoop:(CFRunLoopRef _Nullable)runLoop;

- (BOOL) connect:(TCPSessionDirection)direction inRunLoop:(CFRunLoopRef _Nonnull)runLoop withMode:(CFRunLoopMode _Nonnull)mode;
@end
