//
//  ScreenShotUtil.h
//  AnnoTree Viewer
//
//  Created by Mike on 9/2/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ScreenShotUtil : NSObject

@property GLuint colorRenderbuffer;



+ (UIImage*)scaleAndRotateImage:(UIImage *)image;

+ (UIImage*)screenshot;

@end
