//
//  PopupView.h
//  Expandly
//
//  Created by William Falcon on 1/13/15.
//  Copyright (c) 2015 Will. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView

#pragma mark - Class methods

/**
Convenience method to show like an alert from a view controller
*/
+ (void)showFromViewController:(UIViewController *)sourceVC;

@end
