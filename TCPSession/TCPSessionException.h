//
//  TCPSessionException.h
//  TCPSession
//
//  Created by Чайка on 4/8/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const InitializeFail;
extern NSString * const ConstructorReturnNil;
extern NSString * const ServerNameIsNil;

extern NSString * const DelegateNotDefined;
extern NSString * const DelegateIsNil;

extern NSString * const StreamOpenFail;
extern NSString * const ReadStreamOpenFail;
extern NSString * const WriteStreamOpenFail;

extern NSString * const StreamScheduleFail;
extern NSString * const ReadStreamScheduleFail;
extern NSString * const WriteStreamScheduleFail;


@interface TCPSessionException : NSException

@end
