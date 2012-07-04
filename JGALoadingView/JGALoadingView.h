//
//  JGALoadingView.h
//  WordsToWellness
//
//  Created by John Grant on 12-02-15.
//  Copyright (c) JGApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JGALoadingViewCompletionBlock)(void);

@interface JGALoadingView : UIView

// Create a new view with loading text
+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text;

// Remove loading view if no key provided
+ (void)hideLoadingView;

// Hides the loading view with a success message after a given delay
+ (void)hideLoadingViewWithSuccess:(NSString *)message delay:(int)delay;

// Hides the loading view with an error message after a given delay
+ (void)hideLoadingViewWithError:(NSString *)message delay:(int)delay;

// Create a new view with loading text and optional observer key
+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text forKey:(NSString *)key;

// Remove loading view based on key
+ (void)hideLoadingViewForKey:(NSString *)key;

// Removes the loading view with a success and takes a block to execute after success delay
+ (void)hideLoadingViewWithSuccess:(NSString *)message delay:(int)delay completion:(void(^)(void))completion;

@end
