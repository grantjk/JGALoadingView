//
//  LoadingView.h
//  WordsToWellness
//
//  Created by John Grant on 12-02-15.
//  Copyright (c) 2012 Mobywan Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView


+(LoadingView *)loadingViewInView:(UIView *)view withText:(NSString *)text viewController:(UIViewController *)vc;
-(void)show;
-(void)hide;
@end
