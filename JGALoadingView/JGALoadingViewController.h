//
//  JGALoadingViewController.h
//  HMS
//
//  Created by John Grant on 12-07-20.
//  Copyright (c) 2012 Healthcare Made Simple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGALoadingViewController : NSObject

@property (nonatomic, strong) NSString *fontName;

// Sets the default font name to use for all instances of JGALoadingView
+ (void)setDefaultFontName:(NSString *)fontName;

// Returns the default font name
+ (NSString *)defaultFontName;
@end
