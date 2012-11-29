//
//  JGALoadingView.h
//  WordsToWellness
//
//  Created by John Grant on 12-02-15.
//  Copyright (c) JGApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JGALoadingViewCompletionBlock)(void);

typedef enum JGALoadingViewType{
    JGALoadingViewTypeNone,
    JGALoadingViewTypeSuccess,
    JGALoadingViewTypeError,
}JGALoadingViewType;

@interface JGALoadingView : UIView

// Set a default font name for the loading view
+ (void)setDefaultFontName:(NSString *)fontName;

// Create a new view with loading text
+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text;

// Create a new view with loading text and optional observer key
+ (JGALoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text forKey:(NSString *)key;

// Font name optional
+ (JGALoadingView *)loadingViewInView:(UIView *)view 
                             withText:(NSString *)text 
                               forKey:(NSString *)key
                             fontName:(NSString *)fontName;

// Remove loading view if no key provided
+ (void)hideLoadingView;

// Remove loading view based on key
+ (void)hideLoadingViewForKey:(NSString *)key;

// Hides the loading view with a success message after a given delay
+ (void)hideLoadingViewWithSuccessText:(NSString *)message
                                 delay:(int)delay;

// Removes the loading view with a success and takes a block to execute after success delay
+ (void)hideLoadingViewWithSuccessText:(NSString *)message
                                 delay:(int)delay
                            completion:(JGALoadingViewCompletionBlock)completion;

+ (void)hideLoadingViewWithSuccessText:(NSString *)message
                                   key:(NSString *)key
                                 delay:(int)delay
                            completion:(JGALoadingViewCompletionBlock)completion;

// Hides the loading view with an error message after a given delay
+ (void)hideLoadingViewWithErrorMessage:(NSString *)message
                                  delay:(int)delay;

+ (void)hideLoadingViewWithErrorMessage:(NSString *)message 
                                    key:(NSString *)key
                                  delay:(int)delay;

+ (void)hideLoadingViewWithErrorMessage:(NSString *)message 
                                    key:(NSString *)key
                                  delay:(int)delay
                             completion:(JGALoadingViewCompletionBlock)completion;

#pragma mark - Deprecated
+ (void)hideLoadingViewWithSuccess:(NSString *)message
                             delay:(int)delay;

+ (void)hideLoadingViewWithSuccess:(NSString *)message
                             delay:(int)delay
                        completion:(JGALoadingViewCompletionBlock)completion;

+ (void)hideLoadingViewWithError:(NSString *)message delay:(int)delay;
@end
