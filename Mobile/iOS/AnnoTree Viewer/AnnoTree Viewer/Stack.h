//
//  Stack.h
//  AnnoTree Viewer
//
//  Created by Mike on 10/16/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray(Stack)

- (void) push: (id)item;
- (id) pop;
- (id) peek;

@end
