//
//  UICommonDefines.h
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define ScreenScale ([[UIScreen mainScreen] scale])

CG_INLINE float
floorfInPixel(float floatValue) {
  CGFloat resultValue = floorf(floatValue * ScreenScale) / ScreenScale;
  return resultValue;
}

CG_INLINE float
flatfSpecificScale(float floatValue, float scale) {
  scale = scale == 0 ? ScreenScale : scale;
  CGFloat flattedValue = ceilf(floatValue * scale) / scale;
  return flattedValue;
}

CG_INLINE float
flatf(float floatValue) {
  return flatfSpecificScale(floatValue, 0);
}

CG_INLINE CGSize
CGSizeFlatted(CGSize size) {
  return CGSizeMake(flatf(size.width), flatf(size.height));
}

static CGFloat onePixel = -1.0f;
CG_INLINE float
PixelOne() {
  if (onePixel < 0) {
    onePixel = 1 / [[UIScreen mainScreen] scale];
  }
  return onePixel;
}

CG_INLINE CGRect
CGRectMakeWithSize(CGSize size) {
  return CGRectMake(0, 0, size.width, size.height);
}

CG_INLINE CGFloat
UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
  return insets.left + insets.right;
}

CG_INLINE CGFloat
UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
  return insets.top + insets.bottom;
}

CG_INLINE CGFloat
CGFloatGetCenter(CGFloat parent, CGFloat child) {
  return flatf((parent - child) / 2.0);
}
