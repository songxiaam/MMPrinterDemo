//
//  MMReceiptManager.m
//  MMPrinterDemo
//
//  Created by Zhaomike on 16/3/18.
//  Copyright © 2016年 mikezhao. All rights reserved.
//

//小票管理类,根据需求自行定制
#import "MMReceiptManager.h"

@implementation MMReceiptManager

- (instancetype)initWithHost:(NSString *)host port:(UInt16)port timeout:(NSTimeInterval)timeout {
    if (self = [super init])
    {
        [self.asynaSocket socketConnectToPrint:host port:port timeout:timeout];
    }
    return self;
}
- (void)connectWithHost:(NSString *)host port:(UInt16)port timeout:(NSTimeInterval)timeout {
    [self.asynaSocket socketConnectToPrint:host port:port timeout:timeout];
}
- (MMSocketManager *)asynaSocket {
    if (!_asynaSocket) {
        _asynaSocket = [[MMSocketManager alloc] init];
    }
    return _asynaSocket;
}
- (MMPrinterManager *)printerManager {
    if (!_printerManager) {
        _printerManager = [[MMPrinterManager alloc] init];
    }
    return _printerManager;
}
//基础设置
- (void)basicSetting {
    [self.printerManager printInitialize];
    [self.printerManager printSetStanderModel];
    [self.printerManager printDotDistanceW:DotSpace h:DotSpace];
//    [self.printerManager printLeftMargin:5.0];
    [self.printerManager printDefaultLineSpace];
//    [self.printerManager printAreaWidth:70];
    [self.printerManager printSelectFont:standardFont];
}
//清空缓存数据
- (void)clearData {
    self.printerManager.sendData.length = 0;
}
//写入单行文字
- (void)writeData_title:(NSString *)title Scale:(kCharScale)scale Type:(kAlignmentType)type {
    [_printerManager printCharSize:scale];
    [_printerManager printAlignmentType:type];
    [_printerManager printAddText:title];
    [_printerManager printAndGotoNextLine];
}
//写入多行文字
- (void)writeData_items:(NSArray *)items {
    [self.printerManager printCharSize:scale_1];
    [_printerManager printAlignmentType:LeftAlignment];
    for (NSString *item in items) {
        [_printerManager printAddText:item];
        [_printerManager printAndGotoNextLine];
    }
}
//打印图片
- (void)writeData_image:(UIImage *)image alignment:(kAlignmentType)alignment maxWidth:(CGFloat)maxWidth {
    [self.printerManager printAlignmentType:alignment];
//    UIImage *inImage = image;
    CGFloat width = image.size.width;
    if (width > maxWidth) {
        CGFloat height = image.size.height;
        CGFloat maxHeight = maxWidth * height / width;
        image = [self createCurrentImage:image width:maxWidth height:maxHeight];
    }
    [self.printerManager printBitmapModel:image];
    [self.printerManager printAndGotoNextLine];
}
// 缩放图片
- (UIImage *)createCurrentImage:(UIImage *)inImage width:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [inImage drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

//func createCurrentImage(inImage:UIImage, width:CGFloat, height:CGFloat)->UIImage{
//    //        let w = CGFloat(width)
//    //        let h = CGFloat(height)
//    let size = CGSizeMake(width, height)
//    UIGraphicsBeginImageContext(size)
//    inImage.drawInRect(CGRectMake(0, 0, width, height))
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    return image
//}

//条目,菜单,有间隔,如:
//  炸鸡排     2      12.50      25.00
- (void)writeData_content:(NSArray *)items {
    [self.printerManager printCharSize:scale_1];
    [_printerManager printAlignmentType:LeftAlignment];
    for (NSDictionary *dict in items) {
        [self writeData_spaceItem:dict];
    }
}
- (void)writeData_spaceItem:(NSDictionary *)item {
    [_printerManager printAddText:[item objectForKey:@"key01"]];
    [_printerManager printAbsolutePosition:350];
    [_printerManager printAddText:[item objectForKey:@"key02"]];
    [_printerManager printAbsolutePosition:500];
    [_printerManager printAddText:[item objectForKey:@"key03"]];
    [_printerManager printAbsolutePosition:640];
    [_printerManager printAddText:[item objectForKey:@"key04"]];
    [_printerManager printAndGotoNextLine];
}
//打印分割线
- (void)writeData_line {
    [self.printerManager printAlignmentType:MiddleAlignment];
    [self.printerManager printAddText:@"------------------------------------------"];
    [self.printerManager printAndGotoNextLine];
}
//打开钱箱
- (void)openCashDrawer {
    [self.printerManager printOpenCashDrawer];
}
//打印小票
- (void)printReceipt {
    [self.printerManager printCutPaper:feedPaperHalfCut Num:12];
    [_asynaSocket socketWriteData:[self.printerManager sendData]];
}

@end
