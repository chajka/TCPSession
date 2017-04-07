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
@end

@interface TCPSession : NSObject

@end
