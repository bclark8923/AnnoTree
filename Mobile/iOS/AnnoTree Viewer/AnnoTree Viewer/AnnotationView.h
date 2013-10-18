//
//  MyLineDrawingView.h
//  DrawLines
//
//  Created by Reetu Raj on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stack.h"


@interface AnnotationView : UIView {
 
    UIBezierPath *myPath;

    NSMutableArray *drawings;
    NSMutableArray *drawingsColor;
    NSMutableArray *textBoxes;
    NSMutableArray *undoDrawings;
    NSMutableArray *undoDrawingsColor;
    
}

@property UIColor *drawColor;
@property UIColor *textColor;

@property BOOL drawingEnabled;
@property BOOL textEnabled;
@property int lineWidth;
@property int textSize;
@property BOOL deleteEnabled;

-(void) clearAll;
-(bool) undo;
-(void) redo;

@end
