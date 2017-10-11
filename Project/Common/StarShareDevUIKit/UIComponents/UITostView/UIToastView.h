//
//  UIToastView.h
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIToastAnimator;

typedef NS_ENUM(NSInteger, UIToastViewPosition) {
  UIToastViewPositionTop,
  UIToastViewPositionCenter,
  UIToastViewPositionBottom
};

/**
 * `UIToastView`是一个用来显示toast的控件，其主要结构包括：`backgroundView`、`contentView`，这两个view都是通过外部赋值获取，默认使用`UIToastBackgroundView`和`UIToastContentView`。
 *
 * 拓展性：`UIToastBackgroundView`和`UIToastContentView`是QMUI提供的默认的view，这两个view都可以通过appearance来修改样式，如果这两个view满足不了需求，那么也可以通过新建自定义的view来代替这两个view。另外也提供了默认的toastAnimator来实现ToastView的显示和隐藏动画，如果需要重新定义一套动画，可以继承`UIToastAnimator`并且实现`UIToastViewAnimatorDelegate`中的协议就可以自定义自己的一套动画。
 *
 * 建议使用`UIToastView`的时候，再封装一层，具体可以参考`UITips`这个类。
 *
 * @see UIToastBackgroundView
 * @see UIToastContentView
 * @see UIToastAnimator
 * @see UITips
 */
@interface UIToastView : UIView

/**
 * 生成一个ToastView的唯一初始化方法，`view`的bound将会作为ToastView默认frame。
 *
 * @param view ToastView的superView。
 */
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

/**
 * parentView是ToastView初始化的时候传进去的那个view。
 */
@property(nonatomic, weak, readonly) UIView *parentView;

/**
 * 显示ToastView。
 *
 * @param animated 是否需要通过动画显示。
 *
 * @see toastAnimator
 */
- (void)showAnimated:(BOOL)animated;

/**
 * 隐藏ToastView。
 *
 * @param animated 是否需要通过动画隐藏。
 *
 * @see toastAnimator
 */
- (void)hideAnimated:(BOOL)animated;

/**
 * 在`delay`时间后隐藏ToastView。
 *
 * @param animated 是否需要通过动画隐藏。
 * @param delay 多少秒后隐藏。
 *
 * @see toastAnimator
 */
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

/// @warning 如果使用 [UITips showXxx] 系列快捷方法来显示 tips，willShowBlock 将会在 show 之后才被设置，最终并不会被调用。这种场景建议自己在调用 [UITips showXxx] 之前执行一段代码，或者不要使用 [UITips showXxx] 的方式显示 tips
@property(nonatomic, copy) void (^willShowBlock)(UIView *showInView, BOOL animated);
@property(nonatomic, copy) void (^didShowBlock)(UIView *showInView, BOOL animated);
@property(nonatomic, copy) void (^willHideBlock)(UIView *hideInView, BOOL animated);
@property(nonatomic, copy) void (^didHideBlock)(UIView *hideInView, BOOL animated);

/**
 * `UIToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`UIToastAnimator`，然后实现`UIToastAnimatorDelegate`中的方法，即可实现自定义的动画。如果不赋值，则会使用`UIToastAnimator`中的默认动画。
 */
@property(nonatomic, strong) UIToastAnimator *toastAnimator;

/**
 * 决定UIToastView的位置，目前有上中下三个位置，默认值是center。
 
 * 如果设置了top或者bottom，那么ToastView的布局规则是：顶部从marginInsets.top开始往下布局(UIToastViewPositionTop) 和 底部从marginInsets.bottom开始往上布局(UIToastViewPositionBottom)。
 */
@property(nonatomic, assign) UIToastViewPosition toastPosition;

/**
 * 是否在ToastView隐藏的时候顺便把它从superView移除，默认为NO。
 */
@property(nonatomic, assign) BOOL removeFromSuperViewWhenHide;


///////////////////


/**
 * 会盖住整个superView，防止手指可以点击到ToastView下面的内容，默认透明。
 */
@property(nonatomic, strong, readonly) UIView *maskView;

/**s
 * 承载Toast内容的UIView，可以自定义并赋值给contentView。如果contentView需要跟随ToastView的tintColor变化而变化，可以重写自定义view的`tintColorDidChange`来实现。默认使用`UIToastContentView`实现。
 */
@property(nonatomic, strong) __kindof UIView *contentView;

/**
 * `contentView`下面的黑色背景UIView，默认使用`UIToastBackgroundView`实现，可以通过`UIToastBackgroundView`的 cornerRadius 和 styleColor 来修改圆角和背景色。
 */
@property(nonatomic, strong) __kindof UIView *backgroundView;


///////////////////


/**
 * 上下左右的偏移值。
 */
@property(nonatomic, assign) CGPoint offset UI_APPEARANCE_SELECTOR;

/**
 * ToastView距离上下左右的最小间距。
 */
@property(nonatomic, assign) UIEdgeInsets marginInsets UI_APPEARANCE_SELECTOR;

@end

@interface UIToastView (ToastTool)

/**
 * 工具方法。隐藏`view`里面的所有ToastView。
 *
 * @param view 即将隐藏的ToastView的superView。
 * @param animated 是否需要通过动画隐藏。
 *
 * @return 如果成功隐藏一个ToastView则返回YES，失败则NO。
 */
+ (BOOL)hideAllToastInView:(UIView *)view animated:(BOOL)animated;

/**
 * 工具方法。返回`view`里面最顶级的ToastView，如果没有则返回nil。
 *
 * @param view ToastView的superView。
 * @return 返回一个UIToastView的实例。
 */
+ (instancetype)toastInView:(UIView *)view;

/**
 * 工具方法。返回`view`里面所有的ToastView，如果没有则返回nil。
 *
 * @param view ToastView的superView。
 * @return 包含所有UIToastView的数组。
 */
+ (NSArray <UIToastView *> *)allToastInView:(UIView *)view;

@end