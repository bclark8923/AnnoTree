//
//  MyLineDrawingView.h
//  DrawLines
//
//  Created by Brian Clark on 6/7/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AnnotationView : UIView {
 
    UIBezierPath *myPath;
    UIColor *drawColor;
    UIColor *textColor;
    NSMutableArray *drawings;
    NSMutableArray *textBoxes;
}

@property BOOL drawingEnabled;
@property BOOL textEnabled;

-(void) clearAll;

@end
