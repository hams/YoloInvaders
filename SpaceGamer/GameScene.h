//
//  MyScene.h
//  SpaceGamer
//

//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

@property (nonatomic) NSUInteger scoreValue;
@property (nonatomic) NSUInteger livesValue;
@property SKEmitterNode *explosion;
@property SKEmitterNode *lazer;
@property SKEmitterNode *stars;
@property SKEmitterNode *stars2;
@property SKEmitterNode *fuel;
@property SKEmitterNode *point;
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * monster;
@property (nonatomic) SKSpriteNode * boss;
@property (nonatomic) SKSpriteNode * background;
@property (nonatomic) SKLabelNode * levelText;
@property (nonatomic) SKLabelNode * scoreContainer;
@property (nonatomic) SKLabelNode * livesContainer;
@property (nonatomic) SKLabelNode * pointsText;
@property (nonatomic) NSMutableArray * explosionTextures;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastAsteroidTimeInterval;
@property (nonatomic) NSTimeInterval lastLazerTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastBossSpawnTimeInterval;
@property (nonatomic) int monstersDestroyed;
@property (nonatomic) float lazerSpeed;
@property (nonatomic) float spawnSpeed;
@property (nonatomic) bool started;
-(void)scoreUpdate;
-(void)livesUpdate;

@end