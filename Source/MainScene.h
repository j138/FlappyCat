#import "CCNode.h"
@interface MainScene : CCNode <CCPhysicsCollisionDelegate> {
    CCSprite *_hero; // SpriteBuilderとつなげるheroSprite
    CCPhysicsNode *_physicsNode; // SpirteBuilderとつなげる全画面物理ノード
    
    CCNode *_ground1; // SpriteBuilderと接続する地面その1
    CCNode *_ground2; // SpriteBuilderと接続する地面その2
    NSArray *_grounds; // 地面ループ処理用
    NSTimeInterval _sinceTouch; // touch after sec
    NSMutableArray *_obstacles; // 障害物格納用配列
}
@end