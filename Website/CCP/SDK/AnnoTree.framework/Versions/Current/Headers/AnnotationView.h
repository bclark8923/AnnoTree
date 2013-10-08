//
//  MyLineDrawingView.h
//  DrawLines
//
//  Created by Reetu Raj on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
