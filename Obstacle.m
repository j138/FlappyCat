//
//  Obstacle.m
//  FlappyCat
//
//  Created by Junya Nakazato on 11/16/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle

// 3.5inch iPhoneを考慮した座標
static const CGFloat minYPositionTopPipe = 128.f;
static const CGFloat maxYPositionBottomPipe = 440.f;

// 上下のパイプ管の距離
static const CGFloat pipeDistance = 142.f;

// 上のパイプの出現範囲
static const CGFloat maxYPositionTopPipe = maxYPositionBottomPipe - pipeDistance;

// パイプ.yの出現できるレンジ
static const CGFloat pipeRange = maxYPositionTopPipe - minYPositionTopPipe;

-(void)didLoadFromCCB {
    // 当たり判定
    _topPipe.physicsBody.collisionType = @"level";
    _topPipe.physicsBody.sensor = TRUE;
    
    _bottomPipe.physicsBody.collisionType = @"level";
    _bottomPipe.physicsBody.sensor = TRUE;
    
}

-(void)setupRandomPosition {
    // 乱数 0.f〜1.fの範囲
     CGFloat random = CCRANDOM_0_1();
    _topPipe.position = ccp(_topPipe.position.x, minYPositionTopPipe + (random*pipeRange));
    _bottomPipe.position = ccp(_topPipe.position.x, _topPipe.position.y + pipeDistance);
}

@end