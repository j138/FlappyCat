#import "MainScene.h"

static const CGFloat scrollSpeed = 80.f;

@implementation MainScene {
    CCSprite *_hero; // SpriteBuilderとつなげるheroSprite
    CCPhysicsNode *_physicsNode; // SpirteBuilderとつなげる全画面物理ノード
    
    CCNode *_ground1; // SpriteBuilderと接続する地面その1
    CCNode *_ground2; // SpriteBuilderと接続する地面その2
    NSArray *_grounds; // 地面ループ処理用
}

-(void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2];
}

// 1F毎に呼ばれる
-(void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + (scrollSpeed*delta), _hero.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed*delta), _physicsNode.position.y);
    
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
}

-(void)onEnter {
    [super onEnter];
}

@end
