//
//  IMChatModel.m
//  UUChatTableView
//
//  Created by carrot__lsp on 2018/5/22.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "IMChatModel.h"
#import "IMGlobalData.h"

#import "UUMessage.h"
#import "UUMessageFrame.h"

@interface IMChatModel ()

@property (nonatomic, copy) NSString *offset;
@end

@implementation IMChatModel

- (int)loadRecordMessageData {
    if (self.dataSource == nil) {
        self.dataSource = [NSMutableArray array];
    }
    
//    [self.dataSource addObjectsFromArray:[self addRecordMessage]];
    
    NSArray *array = [self addRecordMessage];
    
    [self.dataSource insertObjects:array atIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, array.count)]];
    
    return (int)array.count;
//    [self addRecordMessage];
}

- (void)addRandomItemsToDataSource:(NSInteger)number{
    
//    for (int i=0; i<number; i++) {
//        [self.dataSource insertObject:[[self additems:1] firstObject] atIndex:0];
//    }
}

- (void)recountFrame
{
	[self.dataSource enumerateObjectsUsingBlock:^(UUMessageFrame * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		obj.message = obj.message;
	}];
}

// 添加自己的item
- (void)addMyChatItem:(NSDictionary *)dic
{
    ONOUser *user = [IMGlobalData sharedData].user;
    
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
//    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    [dataDic setObject:@(UUMessageFromMe) forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
//    [dataDic setObject:user.nickname forKey:@"strName"];
//    [dataDic setObject:URLStr forKey:@"strIcon"];
    
    [message setWithDict:dataDic];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
}

// 添加别人的item
- (void)addOtherChatItem:(NSDictionary *)dic
{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
//    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    [dataDic setObject:@(UUMessageFromOther) forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
//    [dataDic setObject:@"Hi:sister" forKey:@"strName"];
//    [dataDic setObject:URLStr forKey:@"strIcon"];
    
    [message setWithDict:dataDic];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
}

// 添加聊天item（一个cell内容）
static NSString *previousTime = nil;
- (NSArray<UUMessageFrame *> *)additems:(NSInteger)number
{
    NSMutableArray<UUMessageFrame *> *result = [NSMutableArray array];
    
    for (int i=0; i<number; i++) {
        
        NSDictionary *dataDic = [self getDic];
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc] init];
        [message setWithDict:dataDic];
        [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        
        if (message.showDateLabel) {
            previousTime = dataDic[@"strTime"];
        }
        [result addObject:messageFrame];
    }
    return result;
}


- (NSArray<UUMessageFrame *> *)addRecordMessage
{
    
    NSMutableArray<UUMessageFrame *> *result = [NSMutableArray array];
    NSArray <ONOMessage *> *messageArray = [[ONOIMClient sharedClient] getMessageList:self.targetId offset:self.offset limit:10];
    
    for (int i = 0 ; i < messageArray.count; i++) {
        ONOMessage *message = [messageArray objectAtIndex:i];
        if (i == 0) {
            self.offset = message.messageId;
        }
        if (message.type == 1) {
            ONOTextMessage *textMessage = (ONOTextMessage*)message;
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            
            [dictionary setObject:@(UUMessageTypeText) forKey:@"type"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:textMessage.timestamp];
            [dictionary setObject:[date description] forKey:@"strTime"];
            [dictionary setObject:textMessage.user.nickname forKey:@"strName"];
            [dictionary setObject:textMessage.user.avatar forKey:@"strIcon"];
            
            if (textMessage.isSelf) {
                [dictionary setObject:@(UUMessageFromMe) forKey:@"from"];
            } else {
                [dictionary setObject:@(UUMessageFromOther) forKey:@"from"];
            }
            
            if (message.isError) {
                NSString *failureMessage = [NSString stringWithFormat:@"发送失败:%@",textMessage.text];
                [dictionary setObject:failureMessage forKey:@"strContent"];
            } else {
                
                [dictionary setObject:textMessage.text forKey:@"strContent"];
            }
            
            NSDictionary *dataDic = [dictionary copy];
            UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
            UUMessage *message = [[UUMessage alloc] init];
            [message setWithDict:dataDic];
            [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
            messageFrame.showTime = message.showDateLabel;
            [messageFrame setMessage:message];
            
            if (message.showDateLabel) {
                previousTime = dataDic[@"strTime"];
            }
            [result addObject:messageFrame];
        }
    }
    
    return result;
}

// 如下:群聊（groupChat）
static int dateNum = 10;
- (NSDictionary *)getDic
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int randomNum = arc4random()%5;
    if (randomNum == UUMessageTypePicture) {
        [dictionary setObject:[UIImage imageNamed:[NSString stringWithFormat:@"%zd.jpeg",arc4random()%2]] forKey:@"picture"];
    } else {
        // 文字出现概率4倍于图片（暂不出现Voice类型）
        randomNum = UUMessageTypeText;
        [dictionary setObject:[self getRandomString] forKey:@"strContent"];
    }
    NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
    [dictionary setObject:@(UUMessageFromOther) forKey:@"from"];
    [dictionary setObject:@(randomNum) forKey:@"type"];
    [dictionary setObject:[date description] forKey:@"strTime"];
    // 这里判断是否是私人会话、群会话
    int index = _isGroupChat ? arc4random()%6 : 0;
    [dictionary setObject:[self getName:index] forKey:@"strName"];
    [dictionary setObject:[self getImageStr:index] forKey:@"strIcon"];
    
    return dictionary;
}

- (NSString *)getRandomString {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales.";
    
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(6, r); // no less than 6 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    return [NSString stringWithFormat:@"%@!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
}

- (NSString *)getImageStr:(NSInteger)index{
    NSArray *array = @[@"http://www.120ask.com/static/upload/clinic/article/org/201311/201311061651418413.jpg",
                       @"http://p1.qqyou.com/touxiang/uploadpic/2011-3/20113212244659712.jpg",
                       @"http://www.qqzhi.com/uploadpic/2014-09-14/004638238.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/5ab5c9ea15ce36d3b104443639f33a87e950b1b0.jpg",
                       @"http://ts1.mm.bing.net/th?&id=JN.C21iqVw9uSuD2ZyxElpacA&w=300&h=300&c=0&pid=1.9&rs=0&p=0",
                       @"http://ts1.mm.bing.net/th?&id=JN.7g7SEYKd2MTNono6zVirpA&w=300&h=300&c=0&pid=1.9&rs=0&p=0"];
    return array[index];
}

- (NSString *)getName:(NSInteger)index{
    NSArray *array = @[@"Hi,Daniel",@"Hi,Juey",@"Hey,Jobs",@"Hey,Bob",@"Hah,Dane",@"Wow,Boss"];
    return array[index];
}
@end
