#import "MainScene.h"
#import "Obstacle.h"

@implementation MainScene

//static const CGFloat scrollSpeed = 80.f;
static const CGFloat firstObstaclePosition = 280.f; // 障害物の初期値
static const CGFloat distanceBetweenObstacles = 160.f; // 障害物と次の障害物の距離

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrderHero
};


-(void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2];
    
    // enabled touch
    self.userInteractionEnabled = TRUE;

    // スクロールスピード
    _scrollSpeed = 80.f;
    
    // set obstacles
    _obstacles = [NSMutableArray array];
    
    // とりあえず、3つ設置
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    // レンダリング順を定義
    for (CCNode *ground in _grounds) {
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    _hero.zOrder = DrawingOrderHero;
    
    // デリゲートを設定
    _physicsNode.collisionDelegate = self;
    
    // 主人公の当たり判定を設定
    _hero.physicsBody.collisionType = @"hero";
    
    // DEBUG: デバックモード
    // _physicsNode.debugDraw = YES;
}

// 1F毎に描画処理
-(void)update:(CCTime)delta {
    
    // 猫を右に進める
    _hero.position = ccp(_hero.position.x + _scrollSpeed*delta, _hero.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed*delta), _physicsNode.position.y);
    
    // 速度をclamp
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(0, yVelocity);
    
    // 猫の角度を変える
    _sinceTouch += delta;
    // 角度にlimitつける
    _hero.rotation = clampf(_hero.rotation, -30.f, 85.f);
    
    // 回転可能かチェック
    if (_hero.physicsBody.allowsRotation) {
        // 角速度を設定
        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, -2.f, 1.f);
        _hero.physicsBody.angularVelocity = angularVelocity;
        
    }
    
    if (_sinceTouch > 0.5f) {
//        CCLOG(@"delta: %f", delta);
        [_hero.physicsBody applyAngularImpulse:-5000000.f*delta];
    }
    
    // 地面の処理
    for (CCNode *ground in _grounds) {
        // 地面のワールド座標
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        
        // 地面のスクリーン上の位置を取得
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        if (groundScreenPosition.x <= (-1 *ground.contentSize.width)) {
            
            // ground: 200*20
            // x, y :=> 100, 20
            // ground.position = 100 + 2*200 = [500..x] ;
            ground.position = ccp(ground.position.x + 2*ground.contentSize.width, ground.position.y);
        }
    }
    
    
    // 障害物の生成
    NSMutableArray *offScreenObstacles = nil;
    
    // _obstaclesの中に、左から飛び出た障害物を入れる
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace: obstacleWorldPosition];
        
        if(obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if(!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    // offScreenObstaclesに入ってる障害物を親ノードから消す
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        
        // 取り除いて設置
        [self spawnNewObstacle];
    }
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if(!_isGameOver) {
        // 力積を与える
        [_hero.physicsBody applyImpulse:ccp(0, 20000.f)];
        
        // 角速度を与える
        // TODO: fix param
        [_hero.physicsBody applyAngularImpulse:1000000.f];
        
        _sinceTouch = 0.f;
        
        // CCLOG(@"_heroPos: %f, %f", _hero.position.x, _hero.position.y);
    }
}

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    // 最初のオブジェクト設置がなければ設置
    if(!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    // CCBファイルから障害物オブジェクトを読み込み、生成
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);

    // 表示順を変更
    obstacle.zOrder = DrawingOrderPipes;
    
    // ランダムにパイプを再配置
    [obstacle setupRandomPosition];
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    [self gameOver];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    [goal removeFromParent];
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
    
    return TRUE;
}

-(void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}


-(void)gameOver {
    if(!_isGameOver) {
        _scrollSpeed = 0.f;
        _isGameOver = TRUE;
        
        _restartButton.visible = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}

-(void)onEnter {
    [super onEnter];
}

@end