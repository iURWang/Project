//
//  UIImage+UIConfig.m
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import "UIImage+UIConfig.h"
#import "UICommonDefines.h"

@implementation UIImage (UIConfig)

+ (UIImage *)ui_imageWithShape:(UIImageShape)shape
                          size:(CGSize)size
                     tintColor:(UIColor *)tintColor {
  CGFloat lineWidth = 0;
  switch (shape) {
    case UIImageShapeNavBack:
    lineWidth = 3*PixelOne();
    break;
    case UIImageShapeDisclosureIndicator:
    lineWidth = 3*PixelOne();
    break;
    case UIImageShapeCheckmark:
    lineWidth = 3*PixelOne();
    break;
    case UIImageShapeNavClose:
    lineWidth = 3*PixelOne();
    break;
    case UIImageShapeNavAdd:
    lineWidth = 3*PixelOne();
    break;
    default:
    break;
  }
  return [UIImage ui_imageWithShape:shape size:size lineWidth:lineWidth tintColor:tintColor];
}
  
+ (UIImage *)ui_imageWithShape:(UIImageShape)shape
                          size:(CGSize)size
                     lineWidth:(CGFloat)lineWidth
                     tintColor:(UIColor *)tintColor {
  size = CGSizeFlatted(size);
  CGContextInspectSize(size);
  
  UIImage *resultImage = nil;
  tintColor = tintColor ? tintColor : [UIColor whiteColor];
  
  
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextInspectContext(context);
  UIBezierPath *path = nil;
  BOOL drawByStroke = NO;
  CGFloat drawOffset = lineWidth / 2;
  switch (shape) {
    case UIImageShapeOval: {
      path = [UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithSize(size)];
    }
    break;
    case UIImageShapeTriangle: {
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(0, size.height)];
      [path addLineToPoint:CGPointMake(size.width / 2, 0)];
      [path addLineToPoint:CGPointMake(size.width, size.height)];
      [path closePath];
    }
    break;
    case UIImageShapeNavBack: {
      drawByStroke = YES;
      path = [UIBezierPath bezierPath];
      path.lineWidth = lineWidth;
      [path moveToPoint:CGPointMake(size.width - drawOffset, drawOffset)];
      [path addLineToPoint:CGPointMake(0 + drawOffset, size.height / 2.0)];
      [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height - drawOffset)];
    }
    break;
    case UIImageShapeDisclosureIndicator: {
      path = [UIBezierPath bezierPath];
      drawByStroke = YES;
      path.lineWidth = lineWidth;
      [path moveToPoint:CGPointMake(drawOffset, drawOffset)];
      [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height / 2)];
      [path addLineToPoint:CGPointMake(drawOffset, size.height - drawOffset)];
    }
    break;
    case UIImageShapeCheckmark: {
      CGFloat lineAngle = M_PI_4;
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(0, size.height / 2)];
      [path addLineToPoint:CGPointMake(size.width / 3, size.height)];
      [path addLineToPoint:CGPointMake(size.width, lineWidth * sin(lineAngle))];
      [path addLineToPoint:CGPointMake(size.width - lineWidth * cos(lineAngle), 0)];
      [path addLineToPoint:CGPointMake(size.width / 3, size.height - lineWidth / sin(lineAngle))];
      [path addLineToPoint:CGPointMake(lineWidth * sin(lineAngle), size.height / 2 - lineWidth * sin(lineAngle))];
      [path closePath];
    }
    break;
    case UIImageShapeNavClose: {
      drawByStroke = YES;
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(0, 0)];
      [path addLineToPoint:CGPointMake(size.width, size.height)];
      [path closePath];
      [path moveToPoint:CGPointMake(size.width, 0)];
      [path addLineToPoint:CGPointMake(0, size.height)];
      [path closePath];
      path.lineWidth = lineWidth;
      path.lineCapStyle = kCGLineCapRound;
    }
    break;
    case UIImageShapeNavAdd: {
      drawByStroke = YES;
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(size.width/2.0, 0)];
      [path addLineToPoint:CGPointMake(size.width/2.0, size.height)];
      [path closePath];
      [path moveToPoint:CGPointMake(0, size.height/2.0)];
      [path addLineToPoint:CGPointMake(size.width, size.height/2.0)];
      [path closePath];
      path.lineWidth = lineWidth;
      path.lineCapStyle = kCGLineCapRound;
    }
    break;
    default:
    break;
  }
  
  if (drawByStroke) {
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    [path stroke];
  } else {
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    [path fill];
  }
  
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return resultImage;
}
  
+ (UIImage *)ui_imageWithColor:(UIColor *)color
                          size:(CGSize)size
                  cornerRadius:(CGFloat)cornerRadius {
  size = CGSizeFlatted(size);
  CGContextInspectSize(size);
  
  UIImage *resultImage = nil;
  color = color ? color : [UIColor whiteColor];
  
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, color.CGColor);
  
  if (cornerRadius > 0) {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMakeWithSize(size) cornerRadius:cornerRadius];
    [path addClip];
    [path fill];
  } else {
    CGContextFillRect(context, CGRectMakeWithSize(size));
  }
  
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resultImage;
}

- (UIImage *)ui_imageWithSpacingExtensionInsets:(UIEdgeInsets)extension {
  CGSize contextSize = CGSizeMake(self.size.width + UIEdgeInsetsGetHorizontalValue(extension), self.size.height + UIEdgeInsetsGetVerticalValue(extension));
  UIGraphicsBeginImageContextWithOptions(contextSize, NO, self.scale);
  [self drawAtPoint:CGPointMake(extension.left, extension.top)];
  UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return finalImage;
}
  
- (UIImage *)ui_imageByApplyingAlpha:(CGFloat)alpha
{
  UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
  
  CGContextScaleCTM(ctx, 1, -1);
  
  CGContextTranslateCTM(ctx, 0, -area.size.height);
  
  CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
  
  CGContextSetAlpha(ctx, alpha);
  
  CGContextDrawImage(ctx, area, self.CGImage);
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return newImage;
}

#pragma mark - 
  
+ (void)inspectContextSize:(CGSize)size {
  if (size.width < 0 || size.height < 0) {
    NSAssert(NO, @"UI CGPostError, %@:%d %s, 非法的size：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, NSStringFromCGSize(size), [NSThread callStackSymbols]);
  }
}
  
+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef)context {
  if (!context) {
    NSAssert(NO, @"UI CGPostError, %@:%d %s, 非法的context：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, context, [NSThread callStackSymbols]);
  }
}
  
+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef)context {
  if (context) {
    return YES;
  }
  return NO;
}
  
@end
