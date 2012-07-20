//
//  JGALoadingViewController.m
//  HMS
//
//  Created by John Grant on 12-07-20.
//  Copyright (c) 2012 Healthcare Made Simple. All rights reserved.
//

#import "JGALoadingViewController.h"

@implementation JGALoadingViewController

@synthesize fontName = _fontName;

static JGALoadingViewController *_sharedController;
+(JGALoadingViewController *)sharedController
{
    if (!_sharedController){
        _sharedController = [[JGALoadingViewController alloc] init];
        
    }
    return _sharedController;
}

- (id) init
{
    if (self=[super init]) {
    }
    return self;
}

+ (void)setDefaultFontName:(NSString *)fontName
{
    JGALoadingViewController *controller = [JGALoadingViewController sharedController];
    controller.fontName = fontName;
}

+ (NSString *)defaultFontName
{
    JGALoadingViewController *controller = [JGALoadingViewController sharedController];
    return controller.fontName;
}
@end
