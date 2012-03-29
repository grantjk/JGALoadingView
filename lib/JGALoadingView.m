//
//  JGALoadingView.m
//  WordsToWellness
//
//  Created by John Grant on 12-02-15.
//  Copyright (c) 2012 Mobywan Corporation. All rights reserved.
//

#import "JGALoadingView.h"
#import <QuartzCore/QuartzCore.h>

@interface JGALoadingView()
@property(nonatomic, strong) UIActivityIndicatorView *activityView;
@property(nonatomic, strong) UILabel *activityLabel;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, assign) BOOL visible;
@property(nonatomic, strong) UIImageView *spinView;
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

static NSString *animationScaleUpKey = @"scaleUp";
static NSString *animationScaleNormKey = @"scaleNorm";
static NSString *animationScaleOutKey = @"scaleOut";

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
        self.activityLabel.textAlignment = UITextAlignmentCenter;

        // Create the spinner
        self.spinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmoothSpinner"]];
        _spinView.center = CGPointMake(self.center.x, self.center.y + 10);
        
        // Add the subviews
        [self addSubview: self.activityLabel];
        [self addSubview:_spinView];
    }
    return self;
}


// Returns the current loading view if there is one
+(JGALoadingView *)currentLoadingViewForController:(UIViewController *)vc{    
    if ([vc respondsToSelector:@selector(loadingView)]) {
        return [vc performSelector:@selector(loadingView)];
    }
    return nil;
}

// Create a new loading view with given text, add to view and set propery on controller
+(JGALoadingView *)newLoadingViewForView:(UIView *)view withText:(NSString *)text viewController: (UIViewController *)vc{
    CGRect frame = CGRectMake(0, 0, COLOR_WIDTH, COLOR_HEIGHT);
    JGALoadingView *lv = [[JGALoadingView alloc] initWithFrame:frame];
    lv.center = view.center;
    lv.activityLabel.text = text;
    lv.parentView = view;
    
    if ([vc respondsToSelector:@selector(setLoadingView:)]){
        [vc performSelector:@selector(setLoadingView:) withObject:lv];
    }
    
    return lv;
}


// Check if loading view exists inside view controller class
// If so, just return the same object - this way we don't end up with multiple views on top of each other
+(JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text viewController:(UIViewController *)vc{    
    JGALoadingView * existingLv = [JGALoadingView currentLoadingViewForController:vc];
    if (existingLv) {
        return existingLv;
    }
    return [JGALoadingView newLoadingViewForView:view withText:text viewController:vc];
}

// Animation
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
    rotation.duration = 0.45;
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

-(void)show
{
    if (!_visible) {
        self.visible = YES;
        [self.parentView addSubview:self];
        
        [self startSpinner];
        
        self.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        [self scaleNorm];
    }
}

-(void)hide
{
    // Animate in : Scale down and fade in
    NSDictionary *fadeOpts = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:1], @"fromValue",
                              [NSNumber numberWithInt:0], @"toValue",
                              nil];
    [self scaleLayerTo:SCALE_OUT_VALUE duration:SCALE_OUT_DURATION withKey:animationScaleOutKey fadeOpts:fadeOpts];
}

#pragma mark -
#pragma mark CAAnimation Delegate
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (theAnimation == [self.layer animationForKey:animationScaleUpKey] ) {
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


@end
