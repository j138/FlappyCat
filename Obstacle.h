//
//  Obstacle.h
//  FlappyCat
//
//  Created by Junya Nakazato on 11/16/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Obstacle : CCNode {
    CCNode *_topPipe;
    CCNode *_bottomPipe;
}

- (void)setupRandomPosition;
@end
