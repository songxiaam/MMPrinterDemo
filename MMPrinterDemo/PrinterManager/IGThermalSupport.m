//  
//  IGThermalSupport.m
//  
//  This class is released in the MIT license.
//  Created by Chris Chan in 12 Aug 2012.
//  Copyright (c) 2012 IGPSD Ltd.
//  
//  https://github.com/moming2k/ThermalPrinterKit.git
//
//  Version 1.0.3

#import "IGThermalSupport.h"
//#import "FileManager.h"
//#import "Barcode.h"

@implementation IGThermalSupport

+ (NSData *) imageToThermalData:(UIImage*)image
{
	CGImageRef imageRef = image.CGImage;
    
	// Create a bitmap context to draw the uiimage into
	CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
	if(!context) {
		return NULL;
	}
    
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
    
	CGRect rect = CGRectMake(0, 0, width, height);
    
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, imageRef);
    
	// Get a pointer to the data	
	uint32_t *bitmapData = (uint32_t *)CGBitmapContextGetData(context);
    
	if(bitmapData) {
        
        uint8_t *m_imageData = (uint8_t *) malloc(width * height/8 + 8*height/8);
        memset(m_imageData, 0, width * height/8 + 8*height/8);
        int result_index = 0;
        
        for(int y = 0; (y + 24) < height; ) {
            m_imageData[result_index++] = 27;
            m_imageData[result_index++] = 51;
            m_imageData[result_index++] = 0;
            
            m_imageData[result_index++] = 27; 
            m_imageData[result_index++] = 42; 
            m_imageData[result_index++] = 33;
            m_imageData[result_index++] = width%256; 
            m_imageData[result_index++] = width/256;
            for(int x = 0; x < width; x++) {
                int value = 0;
                for (int temp_y = 0 ; temp_y < 8; ++temp_y)
                {
                    uint8_t *rgbaPixel = (uint8_t *) &bitmapData[(y+temp_y) * width + x];
                    uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                    
                    if (gray < 127)
                    {
                        value += 1<<(7-temp_y)&255;
                    }
                    
                }
                m_imageData[result_index++] = value;
                
                value = 0;
                for (int temp_y = 8 ; temp_y < 16; ++temp_y)
                {
                    uint8_t *rgbaPixel = (uint8_t *) &bitmapData[(y+temp_y) * width + x];
                    uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                    
                    if (gray < 127)
                    {
                        value += 1<<(7-temp_y%8)&255;
                    }
                    
                }
                m_imageData[result_index++] = value;
                
                value = 0;
                for (int temp_y = 16 ; temp_y < 24; ++temp_y)
                {
                    uint8_t *rgbaPixel = (uint8_t *) &bitmapData[(y+temp_y) * width + x];
                    uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                    
                    if (gray < 127)
                    {
                        value += 1<<(7-temp_y%8)&255;
                    }
                    
                }
                m_imageData[result_index++] = value;
            }
            m_imageData[result_index++] = 13; 
            m_imageData[result_index++] = 10;
            y += 24;
        }
        
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
        [data appendBytes:m_imageData length:result_index];
        
		free(bitmapData);
        return data;
        
	} else {
		NSLog(@"Error getting bitmap pixel data\n");
	}
    
	CGContextRelease(context);
    
	return nil ; 
}


+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint32_t *bitmapData;
    
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
    
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
    
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
    
	// Allocate memory for image data
	bitmapData = (uint32_t *)malloc(bufferLength);
    
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
    
	//Create bitmap context
    
	context = CGBitmapContextCreate(bitmapData, 
                                    width, 
                                    height, 
                                    bitsPerComponent, 
                                    bytesPerRow, 
                                    colorSpace, 
                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);	// RGBA
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
    
	CGColorSpaceRelease(colorSpace);
    
	return context;	
}

+ (UIImage*)mergeImage:(UIImage*)first withShopLogo:(UIImage*)shopLogo withColorType:(NSString*)colorType withNumber:(int)number
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);

    // get size of the logo image
    CGImageRef shopLogoImageRef = shopLogo.CGImage;
    CGFloat shopLogoWidth = CGImageGetWidth(shopLogoImageRef);
    CGFloat shopLogoHeight = CGImageGetHeight(shopLogoImageRef);
    
    // get size of the number image
    int first_num = number/100;
    int secord_num = (number - first_num*100)/10;
    int third_num = number - first_num*100 - secord_num*10;
    
    UIImage *ticket_type = [UIImage imageNamed:[NSString stringWithFormat:@"char-%@",colorType]];
    UIImage *first_number = [UIImage imageNamed:[NSString stringWithFormat:@"char-%i",first_num]];
    UIImage *secord_number = [UIImage imageNamed:[NSString stringWithFormat:@"char-%i",secord_num]];
    UIImage *third_number = [UIImage imageNamed:[NSString stringWithFormat:@"char-%i",third_num]];
    
    CGImageRef secondImageRef = first_number.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(530, firstHeight + shopLogoHeight);
//    CGSize mergedSize = CGSizeMake(MAX(firstWidth, shopLogoWidth), MAX(firstHeight, shopLogoHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [shopLogo drawInRect:CGRectMake(0, firstHeight, shopLogoWidth, shopLogoHeight)];
    [ticket_type drawInRect:CGRectMake(220, 280, secondWidth, secondHeight)];
    [first_number drawInRect:CGRectMake(280, 280, secondWidth, secondHeight)];
    [secord_number drawInRect:CGRectMake(340, 280, secondWidth, secondHeight)];
    [third_number drawInRect:CGRectMake(400, 280, secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
+ (UIImage*)mergeImageQrcode:(UIImage*)first withShopLogo:(UIImage*)shopLogo withImageInfo:(UIImage*)imageInfo withQRCode:(NSString*)qrcode withColorType:(NSString*)colorType withNumber:(int)number withShopName:(NSString*)shopName withShopInfo:(NSString*)shopInfo withTicketTime:(NSString*)ticketTime withTicketDetail:(NSString*)ticketDetail
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the logo image
    CGImageRef shopLogoImageRef = shopLogo.CGImage;
    CGFloat shopLogoWidth = CGImageGetWidth(shopLogoImageRef);
    CGFloat shopLogoHeight = CGImageGetHeight(shopLogoImageRef);
    
    // get size of the number image
    int first_num = number/100;
    int secord_num = (number - first_num*100)/10;
    int third_num = number - first_num*100 - secord_num*10;
    
    UIImage *ticket_bg = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_white_bg"]];
    UIImage *ticket_type = [UIImage imageNamed:[NSString stringWithFormat:@"char-%@",colorType]];
    UIImage *first_number = [UIImage imageNamed:[NSString stringWithFormat:@"char-%i",first_num]];
    UIImage *secord_number = [UIImage imageNamed:[NSString stringWithFormat:@"char-%i",secord_num]];
    UIImage *third_number = [UIImage imageNamed:[NSString stringWithFormat:@"char-%i",third_num]];
    
    CGImageRef secondImageRef = first_number.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // get size of the info image
    CGImageRef infoImageRef = imageInfo.CGImage;
    CGFloat infoWidth = CGImageGetWidth(infoImageRef);
    CGFloat infoHeight = CGImageGetHeight(infoImageRef);
    CGFloat info_y = firstHeight + shopLogoHeight + 100;
    
    // gen qr code
    Barcode *barcode = [[Barcode alloc] init];
    [barcode setupQRCode:qrcode];
    UIImage *image_qrcode = barcode.qRBarcode;
    CGFloat qrcode_y = info_y + infoHeight + 20;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(520, qrcode_y + 200);
    //    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [ticket_bg drawInRect:CGRectMake(0, 0, firstWidth, qrcode_y + 200)];
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [shopLogo drawInRect:CGRectMake(0, firstHeight, shopLogoWidth, shopLogoHeight)];
    [ticket_type drawInRect:CGRectMake(220, 280, secondWidth, secondHeight)];
    [first_number drawInRect:CGRectMake(280, 280, secondWidth, secondHeight)];
    [secord_number drawInRect:CGRectMake(340, 280, secondWidth, secondHeight)];
    [third_number drawInRect:CGRectMake(400, 280, secondWidth, secondHeight)];
    [imageInfo drawInRect:CGRectMake(0, info_y, infoWidth, infoHeight)];
    [image_qrcode drawInRect:CGRectMake(25, qrcode_y, 200, 200)];
    
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIFont *font = [UIFont boldSystemFontOfSize:18];
    CGFloat textwidth = [IGThermalSupport widthOfString:shopName withFont:font];
    UIImage *newImageWithText = [IGThermalSupport drawText:shopName inImage:newImage atPoint:CGPointMake((530 - textwidth)/2, firstHeight + shopLogoHeight + 20) withFont:(UIFont *)font];
    textwidth = [IGThermalSupport widthOfString:shopInfo withFont:font];
    UIImage *newImageWithText1 = [IGThermalSupport drawText:shopInfo inImage:newImageWithText atPoint:CGPointMake((530 - textwidth)/2, firstHeight + shopLogoHeight + 40) withFont:(UIFont *)font];
    textwidth = [IGThermalSupport widthOfString:ticketTime withFont:font];
    UIImage *newImageWithText2 = [IGThermalSupport drawText:ticketTime inImage:newImageWithText1 atPoint:CGPointMake((530 - textwidth)/2, firstHeight + shopLogoHeight + 60) withFont:(UIFont *)font];
    textwidth = [IGThermalSupport widthOfString:ticketDetail withFont:font];
    UIImage *newImageWithText3 = [IGThermalSupport drawText:ticketDetail inImage:newImageWithText2 atPoint:CGPointMake(230, qrcode_y + 10) withFont:(UIFont *)font];
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImageWithText3;
}
*/
/*
+ (UIImage*)mergeImageStore:(UIImage*)first withImageInfo:(UIImage*)imageInfo withQRCode:(NSString*)qrcode  withNumber:(int)number withShopName:(NSString*)shopName withShopInfo:(NSString*)shopInfo withTicketTime:(NSString*)ticketTime withTicketDetail:(NSString*)ticketDetail
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the number image
    int first_num = number/100;
    int secord_num = (number - first_num*100)/10;
    int third_num = number - first_num*100 - secord_num*10;
    
    UIImage *ticket_bg = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_white_bg"]];
    UIImage *first_number = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_%i",first_num]];
    UIImage *secord_number = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_%i",secord_num]];
    UIImage *third_number = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_%i",third_num]];
    
    CGImageRef secondImageRef = first_number.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // get size of the info image
    CGImageRef infoImageRef = imageInfo.CGImage;
    CGFloat infoWidth = CGImageGetWidth(infoImageRef);
    CGFloat infoHeight = CGImageGetHeight(infoImageRef);
    CGFloat info_y = firstHeight + 100;
    
    // gen qr code
    Barcode *barcode = [[Barcode alloc] init];
    [barcode setupQRCode:qrcode];
    UIImage *image_qrcode = barcode.qRBarcode;
    CGFloat qrcode_y = info_y + infoHeight + 20;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(520, qrcode_y + 200);
    //    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [ticket_bg drawInRect:CGRectMake(0, 0, firstWidth, qrcode_y + 200)];
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [first_number drawInRect:CGRectMake(270, 230, secondWidth, secondHeight)];
    [secord_number drawInRect:CGRectMake(340, 230, secondWidth, secondHeight)];
    [third_number drawInRect:CGRectMake(410, 230, secondWidth, secondHeight)];
    [imageInfo drawInRect:CGRectMake(0, info_y, infoWidth, infoHeight)];
    [image_qrcode drawInRect:CGRectMake(25, qrcode_y, 200, 200)];
    
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIFont *font = [UIFont boldSystemFontOfSize:18];
    CGFloat textwidth = [IGThermalSupport widthOfString:shopName withFont:font];
    UIImage *newImageWithText = [IGThermalSupport drawText:shopName inImage:newImage atPoint:CGPointMake((530 - textwidth)/2, firstHeight + 20) withFont:(UIFont *)font];
    textwidth = [IGThermalSupport widthOfString:shopInfo withFont:font];
    UIImage *newImageWithText1 = [IGThermalSupport drawText:shopInfo inImage:newImageWithText atPoint:CGPointMake((530 - textwidth)/2, firstHeight + 40) withFont:(UIFont *)font];
    textwidth = [IGThermalSupport widthOfString:ticketTime withFont:font];
    UIImage *newImageWithText2 = [IGThermalSupport drawText:ticketTime inImage:newImageWithText1 atPoint:CGPointMake((530 - textwidth)/2, firstHeight + 60) withFont:(UIFont *)font];
    textwidth = [IGThermalSupport widthOfString:ticketDetail withFont:font];
    UIImage *newImageWithText3 = [IGThermalSupport drawText:ticketDetail inImage:newImageWithText2 atPoint:CGPointMake(230, qrcode_y + 10) withFont:(UIFont *)font];
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImageWithText3;
}
*/

+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

+ (UIImage*)drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point withFont:(UIFont *)font
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor blackColor] set];
    [text drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:font}];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)mergeImage2:(UIImage*)first withNumber:(int)number
{
    // get size of the first image
    
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    
    int first_num = number/100;
    int secord_num = (number - first_num*100)/10;
    int third_num = number - first_num*100 - secord_num*10;
    
    UIImage *first_number = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_%i",first_num]];
    UIImage *secord_number = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_%i",secord_num]];
    UIImage *third_number = [UIImage imageNamed:[NSString stringWithFormat:@"ticket_%i",third_num]];
    
    CGImageRef secondImageRef = first_number.CGImage ;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [first_number drawInRect:CGRectMake(270, 230, secondWidth, secondHeight)];
    [secord_number drawInRect:CGRectMake(340, 230, secondWidth, secondHeight)];
    [third_number drawInRect:CGRectMake(410, 230, secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSData *)cutLine
{
    int index = 0;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
    uint8_t *m_imageData = (uint8_t *) malloc(4);
    m_imageData[index++] = 29;
    m_imageData[index++] = 86;
    m_imageData[index++] = 65;
    m_imageData[index++] = 10;
    [data appendBytes:m_imageData length:4];
    return data;
    
}

+ (NSData *)feedLines:(int)lines
{
    int index = 0;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
    uint8_t *m_imageData = (uint8_t *) malloc(3);
    m_imageData[index++] = 27;
    m_imageData[index++] = 100;
    m_imageData[index++] = lines;
    [data appendBytes:m_imageData length:3];
    return data;
}

+ (UIImage *) receiptImage:(UIImage*)image withNumber:(int)number
{
    UIImage *result = image;
    return result;
    
//    UIImage *bottomImage = [UIImage imageNamed:@"bottom.png"]; //background image
//    UIImage *image       = [UIImage imageNamed:@"top.png"]; //foreground image
//    
//    CGSize newSize = CGSizeMake(width, height);
//    UIGraphicsBeginImageContext( newSize );
//    
//    // Use existing opacity as is
//    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    
//    // Apply supplied opacity if applicable
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.8];
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
}


@end
