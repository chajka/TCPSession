//
//  TCPSession.h
//  TCPSession
//
//  Created by Чайка on 4/7/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface TCPSession : NSObject {
	NSString													*server;
	SInt32														port;

	id<TCPSessionDelegate>										delegate;
	BOOL														haveCanAcceptBytes;
	BOOL														haveOpenCompleted;
	BOOL														haveEndEncounted;
	BOOL														haveErrorOccured;
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
@end
