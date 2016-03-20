//
//  MMSocketManager.h
//  MMPrinterDemo
//
//  Created by Zhaomike on 16/3/17.
//  Copyright © 2016年 mikezhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface MMSocketManager : NSObject<AsyncSocketDelegate>

//打印
@property (strong, nonatomic) void (^blockPrintData)();
//检查缓存数据(连接断开时,检查缓存数据)
//可能遇到的问题
//打印机只能同时连接一个socket
//1.wifi打印机:当wifi打印机一直连接着一个socket01,这时如果另一个socket02想要连接时,会将socket01会断开,连上socket02,可以正常打印
//2.有线打印机:当wifi打印机一直连接着一个socket01,这时如果另一个socket02想要连接时,会将socket01不会断开,因此socket02不能正常打印
//对于问题2,将timeout设置为10,连接10秒连不上断开,检查数据,如果有数据,再次连接.,同时设置[sock disconnectAfterWriting];(写入数据后连接断开)
@property (strong, nonatomic) void (^blockCheckData)();

//连接打印机
- (void)socketConnectToPrint:(NSString *)host port:(UInt16)port timeout:(NSTimeInterval)timeout;
//发送数据
- (void)socketWriteData:(NSData *)data;
//检查是否连接
- (BOOL)socketIsConnect;
//断开连接
- (void)socketDisconnectSocket;

@end
