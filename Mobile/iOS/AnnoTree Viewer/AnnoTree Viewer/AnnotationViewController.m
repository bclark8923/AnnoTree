//
//  AnnotationViewController.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 6/7/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "AnnotationViewController.h"

@interface AnnotationViewController ()

@end

@implementation AnnotationViewController

@synthesize drawScreen;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        drawScreen = [[AnnotationView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        drawScreen.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.view = drawScreen;
    }
    return self;
}

-(void) setDrawingEnabled:(BOOL)enabled
{
    [drawScreen setDrawingEnabled:enabled];
}

-(void) setTextEnabled:(BOOL)enabled
{
    [drawScreen setTextEnabled:enabled];
}

-(void) clearAll
{
    [drawScreen clearAll];
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
