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

    NSMutableArray *drawings;
    NSMutableArray *drawingsColor;
    NSMutableArray *textBoxes;
    
}

@property UIColor *drawColor;
@property UIColor *textColor;

@property BOOL drawingEnabled;
@property BOOL textEnabled;
@property BOOL deleteEnabled;
@property int lineWidth;
@property int textSize;

-(void) clearAll;

@end
