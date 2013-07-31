//
//  AnnotationViewController.h
//  AnnoTree Viewer
//
//  Created by Brian Clark on 6/7/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotationView.h"

@interface AnnotationViewController : UIViewController

@property (nonatomic, retain) AnnotationView *drawScreen;

-(void) setDrawingEnabled:(BOOL)enabled;
-(void) setTextEnabled:(BOOL)enabled;
-(void) clearAll;

@end
