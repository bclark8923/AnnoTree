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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
    self.viewWeb.delegate = self;
    self.viewWeb.scalesPageToFit = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.viewWeb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [[self.viewWeb scrollView] setBounces: NO];
    
    NSURL* url = [NSURL URLWithString:@"http://annotree.com/appLoginScreen.html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.viewWeb loadRequest:request];
}
    
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
