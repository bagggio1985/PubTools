//
//  UIImage+Helper.m
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "UIImage+Helper.h"

@implementation UIImage (Helper)

- (UIImage*)fillInSize:(CGSize)viewsize {
    
    CGSize size = self.size;
    
    CGFloat scalex = viewsize.width / size.width;
    CGFloat scaley = viewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(viewsize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    CGFloat dwidth = ((viewsize.width - width) / 2.0f);
    CGFloat dheight = ((viewsize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
    [self drawInRect:rect];
    
    UIImage * newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (UIImage*)fitInSize:(CGSize)viewsize {
    
    UIGraphicsBeginImageContext(viewsize);
	[self drawInRect:[self frameSize:self.size inSize:viewsize]];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage*)resizeImageAtPath:(NSString*)imagePath {
    // Create the image source (from path)
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
    
    // To create image source from UIImage, use this
    // NSData* pngData =  UIImagePNGRepresentation(image);
    // CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)pngData, NULL);
    
    // Create thumbnail options
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(640)
                                                           };
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options); 
    CFRelease(src);
    
    return CFBridgingRelease(thumbnail);
}

#pragma mark Private

- (CGRect) frameSize: (CGSize)thisSize inSize: (CGSize) aSize
{
	CGSize size = [self fitSize:thisSize inSize: aSize];
	float dWidth = aSize.width - size.width;
	float dHeight = aSize.height - size.height;
	
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, size.width, size.height);
}

- (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize) aSize
{
	CGFloat scale;
	CGSize newsize = thisSize;
	
	if (newsize.height && (newsize.height > aSize.height))
	{
		scale = aSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width >= aSize.width))
	{
		scale = aSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	return newsize;
}

@end
