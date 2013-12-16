//
//  JGALoadingView.m
//  WordsToWellness
//
//  Created by John Grant on 12-02-15.
//  Copyright (c) 2012 Mobywan Corporation. All rights reserved.
//

#import "JGALoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "JGALoadingViewController.h"

@interface JGALoadingView()
@property(nonatomic, strong) UIActivityIndicatorView *activityView;
@property(nonatomic, strong) UILabel *activityLabel;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, assign) BOOL visible;
@property(nonatomic, strong) UIImageView *spinView;

-(void)show;

@end

@implementation JGALoadingView

@synthesize activityView = _activityView;
@synthesize activityLabel = _activityLabel;
@synthesize parentView = _parentView;
@synthesize visible = _visible;
@synthesize spinView = _spinView;

#define COLOR_WIDTH 150
#define COLOR_HEIGHT 125

#define LABEL_WIDTH COLOR_WIDTH
#define LABEL_HEIGHT 20
#define LABEL_TOP 20

#define CORNER_RADIUS 15.0

#define SCALE_UP_DURATION 0.25
#define SCALE_UP_VALUE 1.2
#define SCALE_NORM_DURATION 0.3
#define SCALE_NORM_VALUE 1.0
#define SCALE_OUT_DURATION 0.25
#define SCALE_OUT_VALUE 0.01

#define kOptsKeyMessage @"message"
#define kOptsKeyDelay @"delay"
#define kOptsKeyType @"type"

#define kNotifSuccess @"successNotification"
#define kNotifError @"errorNotification"

#define kCompletionBlock @"completion_block"

static NSString *animationScaleUpKey = @"scaleUp";
static NSString *animationScaleNormKey = @"scaleNorm";
static NSString *animationScaleOutKey = @"scaleOut";

static NSString *_defaultKey = @"defaultJGALoadingViewobserverkey";
static NSInteger DEFAULT_TAG = 874567;

+ (void)setDefaultFontName:(NSString *)fontName
{
    [JGALoadingViewController setDefaultFontName:fontName];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        // Create a color view
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        self.layer.cornerRadius = CORNER_RADIUS;    
        
        // Create the label
        self.activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, LABEL_TOP, LABEL_WIDTH, LABEL_HEIGHT)];
        self.activityLabel.backgroundColor = [UIColor clearColor];
        self.activityLabel.textColor = [UIColor whiteColor];
        self.activityLabel.font = [UIFont boldSystemFontOfSize:16];
        self.activityLabel.textAlignment = NSTextAlignmentCenter;

        // Create the spinner
        self.spinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmoothSpinner"]];
        _spinView.center = CGPointMake(self.center.x, self.center.y + 10);
        
        // Set autoresizing masks
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
            UIViewAutoresizingFlexibleRightMargin | 
            UIViewAutoresizingFlexibleTopMargin | 
            UIViewAutoresizingFlexibleBottomMargin;
        
        // Add the subviews
        [self addSubview: self.activityLabel];
        [self addSubview:_spinView];
        
        // Set up a tag so we can check against later
        self.tag = DEFAULT_TAG;
    }
    return self;
}

-(void)show
{
    [self scaleUp];
}

#pragma mark - Existing loading view?
+ (JGALoadingView *)existingLoadingViewInView:(UIView *)view
{
    UIView *v = [view viewWithTag:DEFAULT_TAG];
    if (v && [v isKindOfClass:[JGALoadingView class]]) {
        return (JGALoadingView *)v;
    }
    return nil;
}

#pragma mark - Creating
// Create a new view with loading text
+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text
{
    return [JGALoadingView loadingViewInView:view withText:text forKey:_defaultKey];
}

+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text fontName:(NSString *)fontName
{
    return [JGALoadingView loadingViewInView:view withText:text forKey:_defaultKey fontName:fontName];
}

+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text forKey:(NSString *)key
{
    return [JGALoadingView newLoadingViewForView:view withText:text forKey:key];
}

+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text forKey:(NSString *)key fontName:(NSString *)fontName
{
    return [JGALoadingView newLoadingViewForView:view withText:text forKey:key fontName:fontName];
}

// Check if loading view exists inside view controller class
// If so, just return the same object - this way we don't end up with multiple views on top of each other
+(JGALoadingView *)newLoadingViewForView:(UIView *)view withText:(NSString *)text forKey:(NSString *)key
{
    return [JGALoadingView newLoadingViewForView:view withText:text forKey:key fontName:nil];
}
// Create a new loading view with given text, add to view and set propery on controller
+(JGALoadingView *)newLoadingViewForView:(UIView *)view withText:(NSString *)text forKey:(NSString *)key fontName:(NSString *)fontName
{
    JGALoadingView *loadingView = [JGALoadingView existingLoadingViewInView:view];
    if (!loadingView) {
        CGRect frame = CGRectMake(0, 0, COLOR_WIDTH, COLOR_HEIGHT);
        loadingView = [[JGALoadingView alloc] initWithFrame:frame];
        loadingView.center = CGPointMake(view.frame.size.width * 0.5f, view.frame.size.height * 0.5f);
        loadingView.frame = CGRectIntegral(loadingView.frame);
        loadingView.activityLabel.text = text;
        loadingView.parentView = view;
        [loadingView show];
        
        if (fontName) {
            loadingView.activityLabel.font = [UIFont fontWithName:fontName 
                                                             size:loadingView.activityLabel.font.pointSize];
        }else{
            NSString *defaultCustomFontName = [JGALoadingViewController defaultFontName];
            if (defaultCustomFontName){
                loadingView.activityLabel.font = [UIFont fontWithName:defaultCustomFontName
                                                                 size:loadingView.activityLabel.font.pointSize];
            }
        }
        
        // Subscribe to remove notification
        [[NSNotificationCenter defaultCenter] addObserver:loadingView 
                                                 selector:@selector(hideNotificationTriggered:) 
                                                     name:key 
                                                   object:nil];
    }
    
    return loadingView;
}

#pragma mark - Hiding
// Remove loading view if no key provided
+ (void)hideLoadingViewForKey:(NSString *)key
{
    [JGALoadingView hideLoadingViewWithType:JGALoadingViewTypeNone
                                        key:key
                                       text:nil
                                      delay:0
                                 completion:nil];
}

+ (void)hideLoadingView{
    [JGALoadingView hideLoadingViewForKey:_defaultKey];
}

+ (void)hideLoadingViewWithSuccessText:(NSString *)message delay:(int)delay
{
    [JGALoadingView hideLoadingViewWithSuccess:message delay:delay completion:nil];
}

+ (void)hideLoadingViewWithSuccessText:(NSString *)message 
                                 delay:(int)delay
                            completion:(JGALoadingViewCompletionBlock)completion
{
    [JGALoadingView hideLoadingViewWithSuccessText:message
                                               key:_defaultKey
                                             delay:delay
                                        completion:completion];
}
+ (void)hideLoadingViewWithSuccessText:(NSString *)message 
                                   key:(NSString *)key
                                 delay:(int)delay
                            completion:(JGALoadingViewCompletionBlock)completion
{
    [JGALoadingView hideLoadingViewWithType:JGALoadingViewTypeSuccess
                                        key:key
                                       text:message
                                      delay:delay
                                 completion:completion];
}

+ (void)hideLoadingViewWithErrorMessage:(NSString *)message 
                                    key:(NSString *)key
                                  delay:(int)delay
{
    [JGALoadingView hideLoadingViewWithType:JGALoadingViewTypeError
                                        key:key
                                       text:message
                                      delay:delay
                                 completion:nil];
}

+ (void)hideLoadingViewWithErrorMessage:(NSString *)message 
                                    key:(NSString *)key
                                  delay:(int)delay
                             completion:(JGALoadingViewCompletionBlock)completion
{
    [JGALoadingView hideLoadingViewWithType:JGALoadingViewTypeError
                                        key:key
                                       text:message
                                      delay:delay
                                 completion:completion];
}

+ (void)hideLoadingViewWithErrorMessage:(NSString *)message 
                                  delay:(int)delay
{
    [JGALoadingView hideLoadingViewWithType:JGALoadingViewTypeError
                                        key:_defaultKey
                                       text:message
                                      delay:delay
                                 completion:nil];
}

+ (void)hideLoadingViewWithType:(JGALoadingViewType)type
                            key:(NSString *)key
                           text:(NSString *)text
                          delay:(int)delay
                     completion:(JGALoadingViewCompletionBlock)completion
{
    NSMutableDictionary *opts = [NSMutableDictionary dictionary];
    [opts setObject:[NSNumber numberWithInt:delay] forKey:kOptsKeyDelay];
    [opts setObject:[NSNumber numberWithInt:type] forKey:kOptsKeyType];
    if(text)[opts setObject:text forKey:kOptsKeyMessage];
    if (completion) {
        JGALoadingViewCompletionBlock block = (JGALoadingViewCompletionBlock)completion;
        [opts setObject:[block copy] forKey:kCompletionBlock];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:key
                                                        object:nil 
                                                      userInfo:opts];  
}

#pragma mark - Notification Handling
- (void)hideNotificationTriggered:(NSNotification *)notification
{
    NSDictionary *opts = notification.userInfo;
    int type = [[opts objectForKey:kOptsKeyType] intValue];
    if (type == JGALoadingViewTypeSuccess) {
        [self showSuccessNotification:opts];
    }else if (type == JGALoadingViewTypeError) {
        [self showFailNotification:opts];
    }
    [self delayNotificationImage:opts];
}

#pragma mark - Notification Images
- (void)showSuccessNotification:(NSDictionary *)opts
{
    UIImage *checkmark = [UIImage imageNamed:@"WhiteCheck"];
    [self showNotificationImage:checkmark opts:opts];
}

- (void)showFailNotification:(NSDictionary *)opts
{
    UIImage *failImage = [UIImage imageNamed:@"WhiteX"];
    [self showNotificationImage:failImage opts:opts];
}
- (void)showNotificationImage:(UIImage *)image opts:(NSDictionary *)opts
{
    UIImageView *notifView = [[UIImageView alloc] initWithImage:image];
    notifView.center = _spinView.center;
    [_spinView removeFromSuperview];
    [self addSubview:notifView];
    _activityLabel.text = [opts objectForKey:kOptsKeyMessage];
}
- (void)delayNotificationImage:(NSDictionary *)opts
{
    int delay = [[opts objectForKey:kOptsKeyDelay] intValue];
    [NSTimer scheduledTimerWithTimeInterval:delay 
                                     target:self 
                                   selector:@selector(hide:) 
                                   userInfo:opts 
                                    repeats:0];
}

#pragma mark - Completion
-(void)hide:(NSTimer *)timer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self executeCompletionBlock:[timer userInfo]];
    
    // Animate in : Scale down and fade in
    NSDictionary *fadeOpts = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1], @"fromValue",
                              [NSNumber numberWithInt:0], @"toValue",
                              nil];
    
    [self scaleLayerTo:SCALE_OUT_VALUE 
              duration:SCALE_OUT_DURATION 
               withKey:animationScaleOutKey 
              fadeOpts:fadeOpts];
    
}

- (void)executeCompletionBlock:(NSDictionary *)opts
{
    JGALoadingViewCompletionBlock block = [opts objectForKey:kCompletionBlock];
    if (block) block();
}

#pragma mark - Animation
-(void)scaleLayerTo:(float)scaleValue duration:(float)duration withKey:(NSString *)key fadeOpts:(NSDictionary *)fadeOpts{
    // Bounce In
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.toValue = [NSNumber numberWithFloat:scaleValue];
    scale.duration = duration;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    scale.delegate = self;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.layer addAnimation:scale forKey:key];
    
    if (fadeOpts) {
        NSNumber *fromValue = [fadeOpts objectForKey:@"fromValue"];
        NSNumber *toValue = [fadeOpts objectForKey:@"toValue"];
        
        // Fade
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.fromValue = fromValue;
        fadeAnimation.toValue = toValue;
        fadeAnimation.removedOnCompletion = YES;
        fadeAnimation.delegate = self;
        fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        [self.layer addAnimation:fadeAnimation forKey:@"fade"];
    }
}

- (void)scaleUp
{
    // Use animation to scale initial. Have to set duration to something small since
    // using 0 creates a default duration of 0.25
    [self scaleLayerTo:3 duration:0.001 withKey:animationScaleUpKey fadeOpts:nil];
}

-(void)scaleNorm{
    // Animate in : Scale down and fade in
    NSDictionary *fadeOpts = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:0], @"fromValue",
                              [NSNumber numberWithInt:1], @"toValue",
                              nil];
    [self scaleLayerTo:SCALE_NORM_VALUE duration:SCALE_NORM_DURATION withKey:animationScaleNormKey fadeOpts:fadeOpts];
}
- (void)startSpinner
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.toValue = [NSNumber numberWithFloat:M_PI];
    rotation.duration = 0.35;
    rotation.repeatCount = HUGE_VALF;
    rotation.cumulative = YES;
    rotation.removedOnCompletion = NO;
    rotation.fillMode = kCAFillModeForwards;
    rotation.delegate = self;
    [_spinView.layer addAnimation:rotation forKey:@"rotate"];
}

- (void)stopSpinner
{
    [_spinView.layer removeAllAnimations];
}

#pragma mark - CAAnimation Delegate
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (theAnimation == [self.layer animationForKey:animationScaleUpKey] ) {
        [self.parentView addSubview:self];
        [self startSpinner];
        [self scaleNorm];
    }
    else if (theAnimation == [self.layer animationForKey:animationScaleNormKey] ) {
        self.layer.transform = CATransform3DMakeScale(1, 1, 1);
    }
    else if (theAnimation == [self.layer animationForKey:animationScaleOutKey] ) {
        [self stopSpinner];
        [self removeFromSuperview];
        [self.layer removeAllAnimations];
        
        self.visible = NO;
    }
}

#pragma mark - Deprecated
+ (void)hideLoadingViewWithSuccess:(NSString *)message
                             delay:(int)delay
                        completion:(JGALoadingViewCompletionBlock)completion
{
    [JGALoadingView hideLoadingViewWithSuccessText:message delay:delay completion:completion];
}

+ (void)hideLoadingViewWithSuccess:(NSString *)message delay:(int)delay
{
    [JGALoadingView hideLoadingViewWithSuccessText:message delay:delay];
}

+ (void)hideLoadingViewWithError:(NSString *)message delay:(int)delay
{
    [JGALoadingView hideLoadingViewWithErrorMessage:message delay:delay];
}

@end
