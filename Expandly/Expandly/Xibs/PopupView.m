//
//  PopupView.m
//  Expandly
//
//  Created by William Falcon on 1/13/15.
//  Copyright (c) 2015 Will. All rights reserved.
//

#import "PopupView.h"

@interface PopupView()

@end

@implementation PopupView

#pragma mark - Class methods
+ (void)showFromViewController:(UIViewController *)sourceVC {
 
    PopupView *popup = [PopupView newInstance];
    [sourceVC.view addSubview:popup];
}

+(id)newInstance{
    PopupView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    return view;
}


#pragma mark - Inits
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self build];
    }
    return self;
}


#pragma mark - UI Utils
- (void)build{
    
}

- (void)buildBackgroundCover{
    
}

@end
