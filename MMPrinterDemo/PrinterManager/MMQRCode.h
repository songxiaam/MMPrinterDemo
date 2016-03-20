//
//  MMQRCode.h
//  RevoSysAuto
//
//  Created by Zhaomike on 16/1/20.
//  Copyright © 2016年 leyutech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MMQRCode : NSObject

+ (UIImage *)qrCodeWithString:(NSString *)string logoName:(NSString *)name size:(CGFloat)width;

@end
