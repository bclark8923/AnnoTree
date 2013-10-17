//
//  DrawingViewController.m
//  AnnoTree Viewer
//
//  Created by Brian Clark on 6/7/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import "DrawingViewController.h"

@interface DrawingViewController ()

@end

@implementation DrawingViewController

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

-(void)undo{
    [drawScreen undo];
}

-(void)redo{
    [drawScreen redo];
}

-(void)setTextSize:(int)size{
    [drawScreen setTextSize:size];
}

-(void)setLineWidth:(int)width{
    [drawScreen setLineWidth:width];
}

-(void)setDrawColor:(UIColor *)color{
    [drawScreen setDrawColor:color];
}

-(void)setTextColor:(UIColor *)color{
    [drawScreen setTextColor:color];
}

-(void) setDeleteEnabled:(BOOL)enabled{
    [drawScreen setDeleteEnabled:enabled];
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
