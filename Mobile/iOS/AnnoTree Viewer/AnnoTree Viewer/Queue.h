//
//  Queue.h
//  AnnoTree Viewer
//
//  Created by Mike on 10/16/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSMutableArray

- (void) enqueue: (id)item;
- (id) dequeue;
- (id) peek;


@end
