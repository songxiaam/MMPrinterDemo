//
//  MMSocketManager.m
//  MMPrinterDemo
//
//  Created by Zhaomike on 16/3/17.
//  Copyright © 2016年 mikezhao. All rights reserved.
//

#import "MMSocketManager.h"

@interface MMSocketManager()

@property (nonatomic, strong) AsyncSocket *asyncSocket;

@end

@implementation MMSocketManager

-(instancetype)init {
    if (self = [super init]) {
        self.asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [self.asyncSocket setRunLoopModes:@[NSRunLoopCommonModes]];
    }
    return self;
}

//连接打印机
-(void)socketConnectToPrint:(NSString *)host port:(UInt16)port timeout:(NSTimeInterval)timeout {
    NSError *error = nil;
    [self.asyncSocket connectToHost:host onPort:port withTimeout:timeout error:&error];
}
//检查连接状态
-(BOOL)socketIsConnect
{
    BOOL isConn = [self.asyncSocket isConnected];
    if (isConn) {
        NSLog(@"host=%@\nport=%hu\nlocalHost=%@\nlocalPort=%hu",self.asyncSocket.connectedHost,self.asyncSocket.connectedPort,self.asyncSocket.localHost,self.asyncSocket.localPort);
    }
    return isConn;
}
//发送数据
- (void)socketWriteData:(NSData *)data {
    [self.asyncSocket writeData:data withTimeout:-1 tag:0];
}
//手动断开连接
- (void)socketDisconnectSocket {
    [self.asyncSocket disconnect];
}

#pragma mark - Delegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    if (_blockCheckData) {
        _blockPrintData();
    }
    [sock disconnectAfterWriting];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    if (_blockCheckData) {
        _blockCheckData();
    }
}
//
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"读取完成");
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"写入完成");
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"即将断开");
}
@end
