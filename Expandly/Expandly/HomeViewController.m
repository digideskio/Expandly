//
//  ViewController.m
//  Expandly
//
//  Created by William Falcon on 1/13/15.
//  Copyright (c) 2015 Will. All rights reserved.
//

#import "HomeViewController.h"
#import "PopupView.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

#pragma mark - VC lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)bottomRightButtonPressed:(UIButton *)sender {

    //show alert
    [PopupView showFromViewController:self];
}

@end
