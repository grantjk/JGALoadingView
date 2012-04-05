//
//  JGALoadingView.h
//  WordsToWellness
//
//  Created by John Grant on 12-02-15.
//  Copyright (c) JGApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGALoadingView : UIView

// Create a new view with loading text
+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text;

// Remove loading view if no key provided
+ (void)hideLoadingView;

// Create a new view with loading text and optional observer key
+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text forKey:(NSString *)key;

// Remove loading view based on key
+ (void)hideLoadingViewForKey:(NSString *)key;


@end
