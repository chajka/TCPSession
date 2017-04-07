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
@end

@interface TCPSession : NSObject

@end
