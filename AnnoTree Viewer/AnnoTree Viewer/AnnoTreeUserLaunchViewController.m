//
//  AnnoTreeUserLaunchViewController.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 4/11/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnoTreeUserLaunchViewController.h"

@interface AnnoTreeUserLaunchViewController ()

@end

@implementation AnnoTreeUserLaunchViewController

@synthesize openGesture;
@synthesize annoTreeLogo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        openGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTree:)];
        openGesture.numberOfTapsRequired = 2;
        
        UIImage *annoTreeImage = [UIImage imageNamed:@"AnnoTreeLogo.png"];
        UIButton *btnOpen = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOpen.userInteractionEnabled = YES;
        [btnOpen setFrame:CGRectMake(0.0,0.0, 35.0, 35.0)];
        [btnOpen setBackgroundImage:annoTreeImage forState:UIControlStateNormal];
        [btnOpen addGestureRecognizer:openGesture];
        
        [btnOpen addTarget:self action:@selector(wasDragged:withEvent:)
         forControlEvents:UIControlEventTouchDragInside];
        
        //[self.view addSubview:btnOpen];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) openTree:(UIGestureRecognizer*)gr
{
    UIWindow *AnnoTreeWindow = [[AnnoTree sharedInstance] AnnoTreeWindow];
    AnnoTreeWindow.hidden = NO;
    [AnnoTreeWindow makeKeyAndVisible];
    
    //UIView *screenBlock = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[AnnoTreeWindow addSubview:screenBlock];
    //[self loadFingerDrawing];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    if (touch.view == annoTreeLogo) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                        message:@"Message"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_x = location.x - previousLocation.x;
	CGFloat delta_y = location.y - previousLocation.y;
    
	// move button
	button.center = CGPointMake(button.center.x + delta_x,
                                button.center.y + delta_y);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
