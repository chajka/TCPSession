//
//  TCPSessionException.m
//  TCPSession
//
//  Created by Чайка on 4/8/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import "TCPSessionException.h"

NSString * const InitializeFail = @"Initilization Fail";
NSString * const ConstructorReturnNil = @"Super return nil";
NSString * const ServerNameIsNil = @"Server name is nil";

NSString * const DelegateNotDefined = @"Delegate not defined";
NSString * const DelegateIsNil = @"Delegate is nil";

NSString * const StreamOpenFail = @"Stream Open Fail";
NSString * const ReadStreamOpenFail = @"Read stream can not open";
NSString * const WriteStreamOpenFail = @"Write Stream can not open";

NSString * const StreamScheduleFail = @"Stream schedule fail";
NSString * const ReadStreamScheduleFail = @"Read stream schedule fail";
NSString * const WriteStreamScheduleFail = @"Write stream schedule fail";

@implementation TCPSessionException

@end
