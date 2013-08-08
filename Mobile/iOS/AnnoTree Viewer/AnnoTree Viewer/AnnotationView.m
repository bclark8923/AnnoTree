//
//  MyLineDrawingView.m
//  DrawLines
//
//  Created by Reetu Raj on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnotationView.h"
#import "AnnoTree.h"
#import "MoveableText.h"


@implementation AnnotationView

@synthesize drawingEnabled;
@synthesize textEnabled;

static int textBoxTag = 101;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        drawings = [[NSMutableArray alloc] init];
        textBoxes = [[NSMutableArray alloc] init];
        drawColor=[UIColor redColor];
        textColor=[UIColor redColor];
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //[brushPattern setStroke];
    [[UIColor redColor] setStroke];
    //NSLog(@"%i", [drawings count]);
    for (UIBezierPath *_path in drawings) {
         [_path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
    // Drawing code
    //[myPath stroke];
}

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(drawingEnabled) {
        myPath=[[UIBezierPath alloc]init];
        myPath.lineCapStyle=kCGLineCapRound;
        myPath.miterLimit=0;
        myPath.lineWidth=2;
        
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [myPath moveToPoint:[mytouch locationInView:self]];
        [drawings addObject:myPath];
    }
    
    if(textEnabled) {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];

        //NSLog(@"size is %f, %f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        
        CGPoint pos = [mytouch locationInView: mytouch.view];
        int offset = [self bounds].size.width;
        //NSString *string = @"this is an example";
        //CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:15.0f]];
        int textboxHeight = 35;
        int textboxWidth = offset - pos.x - 10;
        
        //NSLog(@"size is %f, %f", [self bounds].size.width, [self bounds].size.height);
        //NSLog(@"drop text box at %f, %f", pos.x, pos.y);
        //NSLog(@"%i", textboxWidth);
        
        /*UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(pos.x, pos.y-textboxHeight/2, textboxWidth, textboxHeight)];*/
        MoveableText *textField = [[MoveableText alloc] initWithFrame:CGRectMake(pos.x-10, pos.y-textboxHeight, textboxWidth, textboxHeight)];

        
    

        
        //textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.font = [UIFont systemFontOfSize:15];
        //textField.borderStyle = UITextBorderStyleLine;
        //textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeDefault;
        //textField.returnKeyType = UIReturnKeyDone;
        //textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;

        textField.delegate = [AnnoTree sharedInstance];
        UIColor *bgColor = UIColorFromRGB(0xF7F8F5);
        textField.backgroundColor = [bgColor colorWithAlphaComponent:0.8];
        [textField setInputAccessoryView:[self getKeyboardAccessoryView]];
        
                
        [self addSubview:textField];
        [textBoxes addObject:textField];
        
        

        
    }
}




-(UIToolbar*) getKeyboardAccessoryView {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardDone:)];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:flexButton, doneButton, nil];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

- (BOOL)keyboardDone:(UIBarButtonItem *)doneButton {
    [self endEditing:YES];
    NSMutableArray *deletes = [[NSMutableArray alloc] init];
    for(UITextView *view in textBoxes) {
        //if empty, delete
        NSString *content = [NSString stringWithFormat:@"%@", view.text];
        NSString *trimmedContent = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([trimmedContent length] == 0) {
             //delete
            [deletes addObject:view];
            [view removeFromSuperview];
        } else {
            CGRect frame = view.frame;
            frame.size.width = [view.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(265.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].width + 20;
            view.frame = frame;
        }
    }
    [textBoxes removeObjectsInArray:deletes];
    return NO;
}

-(void)textViewDidChangeSelection:(UITextView*)textView
{
    NSLog(@"called");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(drawingEnabled) {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [myPath addLineToPoint:[mytouch locationInView:self]];
        [self setNeedsDisplay];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void) clearAll {
    [drawings removeAllObjects];
    for(UITextView *view in textBoxes) {
        [view removeFromSuperview];
    }
    [textBoxes removeAllObjects];
    [self endEditing:YES];
    [self setNeedsDisplay];
}

- (void)dealloc
{
    //[brushPattern release];
    //[super dealloc];
}

@end
