//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Protocol.pbobjc.h"

typedef enum {
    IM_MT_REQUEST = 1,
    IM_MT_NOTIFY,
    IM_MT_RESPONSE,
    IM_MT_PUSH
} ONOMessageType;

@interface ONOCMessage : NSObject

@property(nonatomic) ONOMessageType type;
@property(nonatomic) NSString *route;
@property(nonatomic) NSUInteger messageId;
@property(nonatomic) BOOL isError;
@property(nonatomic, strong) GPBMessage *message;

- (NSData *)encode;
- (void)decode:(NSData *)data;

@end
