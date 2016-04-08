//
//  MMPrinterManager.m
//  MMPrinterDemo
//
//  Created by Zhaomike on 16/3/17.
//  Copyright © 2016年 mikezhao. All rights reserved.
//

#import "MMPrinterManager.h"
#import "IGThermalSupport.h"

@implementation MMPrinterManager

-(instancetype)init {
    if (self = [super init]) {
        _sendData = [NSMutableData dataWithCapacity:0];
    }
    return self;
}

- (void)addBytesCommand:(const void *)command Length:(NSUInteger)length {
    [self.sendData appendBytes:command length:length];
}

//0.录入文字
-(void)printAddText:(NSString *)text {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [text dataUsingEncoding:enc];
    NSUInteger size = data.length;
    void *textdata = malloc(size);
    [data getBytes:textdata length:size];
    [self addBytesCommand:textdata Length:size];
    free(textdata);
}

//2.打印并换行
-(void)printAndGotoNextLine {
    unsigned char data[] = {0x0A};
    [self addBytesCommand:data Length:1];
}

//11.设置绝对打印位置
-(void)printAbsolutePosition:(NSInteger)location {
    unsigned char nL = location % 256;
    unsigned char nH = location / 256;
    unsigned char data[] = {0x1B, 0x24, nL, nH};
    [self addBytesCommand:data Length:4];
}

//14.选择位图模式
- (void)printBitmapModel:(UIImage *)bitmap {
    NSData *data = [IGThermalSupport imageToThermalData:bitmap];
    NSUInteger size = data.length;
    void *picSize = malloc(size);
    [data getBytes:picSize length:size];
    [self addBytesCommand:picSize Length:size];
    free(picSize);
}

//16.设置默认行间距(约3.75mm)
- (void)printDefaultLineSpace {
    unsigned char data[] = {0x1B,0x32};
    [self addBytesCommand:data Length:2];
}

//20.初始化打印机
- (void)printInitialize {
    unsigned char data[] = {0x1B, 0x40};
    [self addBytesCommand:data Length:2];
}

//24.打印并走纸
- (void)printPrintAndFeedPaper:(CGFloat)space {
    unsigned char n = (UInt8)(space/DotSpace);
    unsigned char data[] = {0x1B, 0x4A, n};
    [self addBytesCommand:data Length:3];
}

//26.设置字号
- (void)printSelectFont:(kCharFont)size {
    unsigned char data[] = {0x1B,0x4D,size};
    [self addBytesCommand:data Length:3];
}

//28.设置成标准模式
- (void)printSetStanderModel {
    unsigned char data[] = {0x1B,0x53};
    [self addBytesCommand:data Length:2];
}

//33.设置对齐方式
-(void)printAlignmentType:(kAlignmentType)type {
    unsigned char data[] = {0x1B,0x61,type};
    [self addBytesCommand:data Length:3];
}

//38.产生钱箱控制脉冲
-(void)printOpenCashDrawer {
    unsigned char data[5] = {0x1B, 0x70, 0x00, 0x80, 0xFF};
    [self addBytesCommand:data Length:5];
}

//43.选择字符大小
-(void)printCharSize:(kCharScale)scale {
    unsigned char data[] = {0x0A,0x1D,0x21,scale};
    [self addBytesCommand:data Length:4];
}

//51.设置左边距
- (void)printLeftMargin:(CGFloat)left {
    NSInteger t = left/DotSpace;
    unsigned char nL = t%256;
    unsigned char nH = t/256;
    unsigned char data[] = {0x1D,0x4C,nL,nH};
    [self addBytesCommand:data Length:4];
}

//52.设置横向和纵向移动单位
- (void)printDotDistanceW:(CGFloat)w h:(CGFloat)h {
    unsigned char width = (unsigned char)(25.4/w);
    unsigned char height = (unsigned char)(25.4/h);
    unsigned char data[] = {0x1D,0x50,width,height};
    [self addBytesCommand:data Length:4];
}

//53.选择切纸模式并切纸
-(void)printCutPaper:(kCutPaperModel)model Num:(UInt8)n {
    unsigned char m = 0;
    if (model == feedPaperHalfCut) {
        m = n;
    }
    unsigned char data[] = {0x1D, 0x56, model, m};
    [self addBytesCommand:data Length:4];
}

//54.设置每行打印宽度
- (void)printAreaWidth:(CGFloat)width {
    unsigned char nL = (int)(width / DotSpace) % 256;
    unsigned char nH = (int)(width / DotSpace) / 256;
    unsigned char data[] = {0x1D,0x57,nL,nH};
    [self addBytesCommand:data Length:4];
}

@end
