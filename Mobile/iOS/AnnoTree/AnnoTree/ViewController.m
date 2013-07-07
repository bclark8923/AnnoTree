//
//  ViewController.m
//  AnnoTree
//
//  Created by Brian Clark on 6/14/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
    
@synthesize viewWeb;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    self.view.backgroundColor = [UIColor blackColor];

    
    self.viewWeb.delegate = self;
    self.viewWeb.scalesPageToFit = YES;
    self.viewWeb.contentMode = UIViewContentModeRedraw;

    [[self.viewWeb scrollView] setBounces: NO];
    
    NSURL* url = [NSURL URLWithString:@"http://23.21.235.254:3000/CCP/index.htm"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.viewWeb loadRequest:request];
}
/*
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration: (NSTimeInterval)duration {
    
    CGRect webViewFrame = self.viewWeb.frame;
    int width = webViewFrame.size.width;
    webViewFrame.size.width = webViewFrame.size.height;
    webViewFrame.size.height = width;
    self.viewWeb.frame = webViewFrame;
}
*/
- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
