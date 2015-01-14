//
//  PopupView.m
//  Expandly
//
//  Created by William Falcon on 1/13/15.
//  Copyright (c) 2015 Will. All rights reserved.
//

#import "PopupView.h"

@interface PopupView() <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIButton *mainActionButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, assign) BOOL onScreen;

@end

@implementation PopupView

#pragma mark - Class methods
+ (void)showFromViewController:(UIViewController *)sourceVC {
    
    PopupView *popup = [PopupView newInstance];
    [popup animateToExpandInView:sourceVC.view];
}

+(id)newInstance{
    PopupView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    [view build];
    return view;
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *fakeNonFunctioningCell = [tableView dequeueReusableCellWithIdentifier:@"noIdentifierExists" forIndexPath:indexPath];
    
    return fakeNonFunctioningCell;
}

#pragma mark - UI Utils
- (void)build{
    
    [self addNotifications];
    [self buildBackgroundView];
    
    self.layer.cornerRadius = 5.0f;
    
    self.textField.layer.cornerRadius = 4.0f;
    self.textField.layer.borderColor = [UIColor blackColor].CGColor;
    self.textField.layer.borderWidth = 0.1f;
    
    self.mainActionButton.layer.cornerRadius = 17.0f;
    
    //set up tableview
    self.tableView.dataSource = self;

    //add lines to the header and footer views
    float yLocation = self.headerView.frame.size.height;
    float endingX = self.headerView.frame.size.width;
    [self drawLineFromPoint:CGPointMake(0.0, yLocation) toPoint:CGPointMake(endingX, yLocation) inView:self.headerView];
    [self drawLineFromPoint:CGPointMake(0.0, 0.0) toPoint:CGPointMake(endingX, 0.0) inView:self.footerView];
}

- (void)buildBackgroundView{
    UIView *view = [[UIView alloc]initWithFrame:self.bounds];
    view.backgroundColor = [UIColor blackColor];
    
    self.backgroundView = view;
}

- (void)drawLineFromPoint:(CGPoint)start toPoint:(CGPoint)end inView:(UIView *)view{
    
    UIBezierPath *path =[UIBezierPath new];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.lineWidth = 0.1f;
    
    [view.layer addSublayer:shapeLayer];
}
#pragma mark - Actions
- (IBAction)donePressed:(UIButton *)sender {

}

#pragma mark - Animations
- (void)animateToExpandInView:(UIView *)view{
    
    float startingAlpha = 0.2;
    
    //add the dark backgroundView (fully hidden so we can animate the fade)
    self.backgroundView.alpha = 0.0;
    [view addSubview:self.backgroundView];
    
    //place the popup view at the bottom so we can expand to the full size.
    //the expansion will begin when keyboard becomes active
    [self placeInBottomOfView:view startingAlpha:startingAlpha];
    
    //activate keyboard so view can start expanding
    [self.textField becomeFirstResponder];
}

- (void)expandToFrame:(CGRect)expandedFrame {
    
    //fade in the overlay
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha = 0.5f;
    }];
    
    //first size, the frame is a tad bigger than the final size
    CGRect interimLargerFrame = expandedFrame;
    
    CGSize expandedSize = CGSizeApplyAffineTransform(interimLargerFrame.size, CGAffineTransformMakeScale(1.1, 1.4));
    float newX = (expandedSize.width - interimLargerFrame.size.width) /2;
    interimLargerFrame.origin.x -= newX;
    interimLargerFrame.origin.y -= 60.0f;
    interimLargerFrame.size = expandedSize;
    
    [UIView animateWithDuration:0.15f animations:^{
        self.frame = interimLargerFrame;
        self.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:0.9f delay:0.17f usingSpringWithDamping:0.6f initialSpringVelocity:0.8f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = expandedFrame;
        [self addBottomTriangle];
    } completion:^(BOOL finished) {
        
    }];


}

- (void)popActionForView:(UIView *)view scaleFactor:(float)scale duration:(float)duration completion:(void(^)())completionBlock{
    
    //set the pop scale
    view.layer.affineTransform = CGAffineTransformMakeScale(scale, scale);
    
    //pop
    [UIView animateWithDuration:duration/2 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        view.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

/**
 Place the view at the bottom left side of the screen in preparation for the expansion
 Make light alpha to create a nice expand/brighten effect
 */
- (void)placeInBottomOfView:(UIView *)view startingAlpha:(float)alpha{
    
    //scale frame from the original size and place at the bottom
    float shrinkCoef = 0.15;
    CGRect smallFrame = CGRectMake(0, 0, view.frame.size.width*shrinkCoef, view.frame.size.height*shrinkCoef);
    smallFrame.origin = CGPointMake(smallFrame.size.width, view.bounds.size.height - smallFrame.size.height *1.6);
    
    //add to view
    self.frame = smallFrame;
    [view addSubview:self];
    
    //change alpha
    self.alpha = alpha;
}

- (void)addBottomTriangle{
    
    float triangleWidth = 14.0f;
    CGPoint start = CGPointMake(40.0f, self.frame.size.height);
    CGPoint end = CGPointMake(start.x + triangleWidth, self.frame.size.height);
    CGPoint middle = CGPointMake(start.x + (triangleWidth/2), self.frame.size.height+(triangleWidth/2));
    
    
    UIBezierPath *path =[UIBezierPath new];
    [path moveToPoint:start];
    [path addLineToPoint:middle];
    [path addLineToPoint:end];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.lineWidth = 0.1f;
    shapeLayer.fillColor = self.backgroundColor.CGColor;
    
    [self.layer addSublayer:shapeLayer];
}

#pragma mark - Notification Handlers

- (void)keyboardWillShow:(NSNotification *)notification {
    float padding = 20.0f;
    
    //calculate the frame for the expanded popup view
    CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect expandedFrame = self.superview.bounds;
    expandedFrame.size.height = expandedFrame.size.height - (keyboardFrame.size.height+(padding*1.4));
    expandedFrame.origin.y += padding/2;
    
    if (!self.onScreen) {
        self.onScreen = true;
        [self expandToFrame:expandedFrame];
    }
}


- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    float padding = 20.0f;
    
    //calculate the frame for the expanded popup view
    CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect expandedFrame = self.superview.bounds;
    expandedFrame.size.height = expandedFrame.size.height - (keyboardFrame.size.height+(padding*1.4));
    expandedFrame.origin.y += padding/2;
    
    [UIView animateWithDuration:0.30f animations:^{
        self.frame = expandedFrame;
    } completion:^(BOOL finished) {
    }];
    
}

- (void)addNotifications{
    
    //learn about changes to the keyboard size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //notify when keyboard shows on screen
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

@end






