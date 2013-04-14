//
//  ShareViewController.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 4/14/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

@synthesize closeShareView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIImage *annoTreeImage = [UIImage imageNamed:@"CloseIconToolbar.png"];
        closeShareView = [UIButton buttonWithType:UIButtonTypeCustom];
        closeShareView.userInteractionEnabled = YES;
        [closeShareView setFrame:CGRectMake(20,20, 30, 30)];
        [closeShareView setBackgroundImage:annoTreeImage forState:UIControlStateNormal];
        [closeShareView addTarget:self action:@selector(closeAnnoTreeShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeShareView];
    }
    return self;
}

-(void)closeAnnoTreeShare:(id)sender {
    self.view.frame = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    }];
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self.view removeFromSuperview];
    });
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
