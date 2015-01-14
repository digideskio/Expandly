//
//  PopupView.m
//  Expandly
//
//  Created by William Falcon on 1/13/15.
//  Copyright (c) 2015 Will. All rights reserved.
//

#import "PopupView.h"


//constants particular to this view
static float C_DISMISS_ANIMATION_DURATION = 0.25f;

//padding between top of screen and view
static float C_VIEW_BORDER_PADDING = 20.0f;
static float C_TRIANGLE_WIDTH = 14.0f;
static float C_SHRINKING_COEFFICIENT = 0.15;

//main view corner radius
static float C_CORNER_RADIUS = 5.0f;


@interface PopupView() <UITableViewDataSource>

//UI
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *mainActionButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

//supporting views
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *tipView;

//frame locations
@property (assign) CGRect smallFrame;
@property (assign) CGRect expandedFrame;


//flags
@property (nonatomic, assign) BOOL onScreen;
@end

@implementation PopupView

#pragma mark - Class methods
+ (void)showFromViewController:(UIViewController *)sourceVC {
    
    PopupView *popup = [PopupView newInstance];
    [popup animateToExpandInView:sourceVC.view];
}

/**
Convenience method to create a new instance of this view
*/
+(id)newInstance{
    PopupView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    [view build];
    return view;
}

#pragma mark - TableView Delegate
/**
Returns no rows so that the program can be kept simple
*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *fakeNonFunctioningCell = [tableView dequeueReusableCellWithIdentifier:@"noIdentifierExists" forIndexPath:indexPath];
    
    return fakeNonFunctioningCell;
}

#pragma mark - UI Utils
/**
Lays out subview elements
*/
- (void)build{
    
    [self addNotifications];
    
    //adds dark backgrounf
    [self buildBackgroundView];
    
    //add corners to view
    self.layer.cornerRadius = C_CORNER_RADIUS;
    
    //design textfield
    self.textField.layer.cornerRadius = 4.0f;
    self.textField.layer.borderColor = [UIColor blackColor].CGColor;
    self.textField.layer.borderWidth = 0.1f;
    
    //design main button
    self.mainActionButton.layer.cornerRadius = 17.0f;
    
    //set up tableview
    self.tableView.dataSource = self;
    
    //add lines to the header and footer views
    float yLocation = self.headerView.frame.size.height;
    float endingX = self.headerView.frame.size.width;
    [self drawLineFromPoint:CGPointMake(0.0, yLocation) toPoint:CGPointMake(endingX, yLocation) inView:self.headerView];
    [self drawLineFromPoint:CGPointMake(0.0, 0.0) toPoint:CGPointMake(endingX, 0.0) inView:self.footerView];
    
}

/**
Builds a black see through view to darken the background
*/
- (void)buildBackgroundView{
    UIView *view = [[UIView alloc]initWithFrame:self.bounds];
    view.backgroundColor = [UIColor blackColor];
    
    self.backgroundView = view;
}

/**
Draws a line between two points
*/
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
    
    [self.textField resignFirstResponder];
    [self dismissAnimated];
}

#pragma mark - Animations

/**
Expands the view from small state to above the keyboard
*/
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

/**
Core of the expansion animation

Sample animation looks like it starts in a small place on screen.
Then the frame size change is animated to something bigger than the final size.
Then the larger frame is slowly animated to the correct size.
The niceness of the effect is achieved by pushing the bottom up more than the top so that it has a bit of a bounce.
This bounce is achieved using a spring + damping effect
*/
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
    
    //grow to the bigger frame and show the view
    [UIView animateWithDuration:0.15f animations:^{
        self.frame = interimLargerFrame;
        self.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
    }];
    
    //add the tip and move it down so it can move with the main view during the animation
    [self addBottomTriangle];
    self.tipView.alpha = 0.0f;
    CGRect oldFrame = self.tipView.frame;
    CGRect offset = oldFrame;
    offset.origin.y += 15.0f;
    self.tipView.frame = offset;
    
    //go to final size
    [UIView animateWithDuration:0.9f delay:0.17f usingSpringWithDamping:0.6f initialSpringVelocity:0.8f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = expandedFrame;
        self.tipView.alpha = 1.0f;
        self.tipView.frame = oldFrame;
        
    } completion:^(BOOL finished) {
    }];
}

/**
Simply animates frame size change to the original location.
Then removes all the helper views it built.
*/
- (void)dismissAnimated {
    
    [UIView animateWithDuration:C_DISMISS_ANIMATION_DURATION animations:^{
        self.frame = self.smallFrame;
        self.alpha = 0.0f;
        [self.tipView removeFromSuperview];
        self.backgroundView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [self removeNotifications];
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

/**
 Place the view at the bottom left side of the screen in preparation for the expansion
 Make light alpha to create a nice expand/brighten effect
 */
- (void)placeInBottomOfView:(UIView *)view startingAlpha:(float)alpha{
    
    //scale frame from the original size and place at the bottom
    float shrinkCoef = C_SHRINKING_COEFFICIENT;
    CGRect smallFrame = CGRectMake(0, 0, view.frame.size.width*shrinkCoef, view.frame.size.height*shrinkCoef);
    smallFrame.origin = CGPointMake(smallFrame.size.width, view.bounds.size.height - smallFrame.size.height *1.6);
    
    //add to view
    self.frame = smallFrame;
    [view addSubview:self];
    
    //change alpha
    self.alpha = alpha;
    
    self.smallFrame = smallFrame;
}

/**
Adds the little triangle at the bottom left of the view
*/
- (void)addBottomTriangle{
    
    //create a view behind this view to show the tip.
    float viewHeight = 20.0f;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(5.0f, self.expandedFrame.size.height-viewHeight/2, self.expandedFrame.size.width-80.0f, 0.0f)];
    view.backgroundColor = [UIColor whiteColor];
    
    [self.superview insertSubview:view belowSubview:self];
    self.tipView = view;
    
    
    //create the triangle as a bezier path added to the sublayer
    float triangleWidth = C_TRIANGLE_WIDTH;
    CGPoint start = CGPointMake(40.0f, viewHeight);
    CGPoint end = CGPointMake(start.x + triangleWidth, viewHeight);
    CGPoint middle = CGPointMake(start.x + (triangleWidth/2), viewHeight+(triangleWidth/2));
    
    //design and draw the path
    UIBezierPath *path =[UIBezierPath new];
    [path moveToPoint:start];
    [path addLineToPoint:middle];
    [path addLineToPoint:end];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.lineWidth = 0.1f;
    shapeLayer.fillColor = view.backgroundColor.CGColor;
    
    //add the triangle to the view
    [view.layer addSublayer:shapeLayer];
}

#pragma mark - Notification Handlers

/**
Called when the keyboard slides up.
*/
- (void)keyboardWillShow:(NSNotification *)notification {
    float padding = C_VIEW_BORDER_PADDING;
    
    //calculate the frame for the expanded popup view
    CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect expandedFrame = self.superview.bounds;
    expandedFrame.size.height = expandedFrame.size.height - (keyboardFrame.size.height+(padding*1.4));
    expandedFrame.origin.y += padding/2;
    
    //need flag so we don't call this multiple times
    if (!self.onScreen) {
        self.onScreen = true;
        self.expandedFrame = expandedFrame;
        [self expandToFrame:expandedFrame];
    }
}

/**
Handles moving the autocomplete text above the keyboard up and down.
Adjusts the view based on this.
*/
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    float padding = C_VIEW_BORDER_PADDING;
    
    //calculate the frame for the expanded popup view
    CGRect keyboardFrame = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect expandedFrame = self.superview.bounds;
    expandedFrame.size.height = expandedFrame.size.height - (keyboardFrame.size.height+(padding*1.4));
    expandedFrame.origin.y += padding/2;
    
    //calculate tipview adjust frame
    float tipViewYAdjustment = expandedFrame.size.height - expandedFrame.origin.y;
    CGRect newTipFrame = self.tipView.frame;
    newTipFrame.origin.y = tipViewYAdjustment;
    
    if (self.onScreen) {
        
        //when keyboard autocomplete moves, adjust the view
        self.expandedFrame = expandedFrame;

        [UIView animateWithDuration:2.5f delay:0.1f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.frame = expandedFrame;
            self.tipView.frame = newTipFrame;
        } completion:nil];
    }
}

/**
Adds notifications
*/
- (void)addNotifications{
    
    //learn about changes to the keyboard size
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //notify when keyboard shows on screen
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

/**
Removes notifications
*/
- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

@end






