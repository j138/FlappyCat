//
//  Goal.m
//  FlappyCat
//
//  Created by Junya Nakazato on 11/16/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Goal.h"


@implementation Goal

-(void)didLoadFromCCB {
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
}

@end
