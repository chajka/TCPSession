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

@interface TCPSessionException : NSException

@end
