//
//  MMPrinterManager.h
//  MMPrinterDemo
//
//  Created by Zhaomike on 16/3/17.
//  Copyright © 2016年 mikezhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//横向或纵向移动单位
#define DotSpace 0.1
@interface MMPrinterManager : NSObject

//对齐方式
typedef enum :UInt8 {
    LeftAlignment = 0x30,
    MiddleAlignment = 0x31,
    RightAlignment = 0x32,
}kAlignmentType;

//页模式下打印区域方向
typedef enum  {
    LeftToRight = 0x30,
    DownToUP    = 0x31,
    RightToLeft = 0x32,
    UpToDown    = 0x33,
}kPrintOrientation;

//字符放大倍数
typedef enum: UInt8 {
    scale_1 = 0x00,
    scale_2 = 0x11,
    scale_3 = 0x22,
    scale_4 = 0x33,
    scale_5 = 0x44,
    scale_6 = 0x55,
    scale_7 = 0x66,
    scale_8 = 0x77,
}kCharScale;

//选择字体
typedef enum: UInt8 {
    standardFont = 0x30,
    smallerFont = 0x31,
}kCharFont;

//切纸模式
typedef enum :UInt8 {
    fullCut = 0x30,
    halfCut = 0x31,
    feedPaperHalfCut = 0x42,
}kCutPaperModel;

//打印数据(文字图片信息)
@property (nonatomic, strong) NSMutableData *sendData;

//0.录入文字
-(void)printAddText:(NSString *)text;

//2.打印并换行
-(void)printAndGotoNextLine;

//11.设置绝对打印位置
-(void)printAbsolutePosition:(NSInteger)location;

//14.选择位图模式
- (void)printBitmapModel:(UIImage *)bitmap;

//16.设置默认行间距(约3.75mm)
- (void)printDefaultLineSpace;

//20.初始化打印机
- (void)printInitialize;

//24.打印并走纸
- (void)printPrintAndFeedPaper:(CGFloat)space;

//26.设置字号
- (void)printSelectFont:(kCharFont)size;

//28.设置成标准模式
- (void)printSetStanderModel;

//33.设置对齐方式
-(void)printAlignmentType:(kAlignmentType)type;

//38.产生钱箱控制脉冲
-(void)printOpenCashDrawer;

//43.选择字符大小
-(void)printCharSize:(kCharScale)scale;

//51.设置左边距
- (void)printLeftMargin:(CGFloat)left;

//52.设置横向和纵向移动单位
- (void)printDotDistanceW:(CGFloat)w h:(CGFloat)h;

//53.选择切纸模式并切纸
-(void)printCutPaper:(kCutPaperModel)model Num:(UInt8)n;

//54.设置每行打印宽度
- (void)printAreaWidth:(CGFloat)width;

@end
