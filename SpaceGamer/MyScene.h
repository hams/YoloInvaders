//
//  MyScene.h
//  SpaceGamer
//

//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene

@property (nonatomic) NSUInteger scoreValue;
@property (nonatomic) NSUInteger livesValue;
@property SKEmitterNode *explosion;
@property SKEmitterNode *lazer;
@property SKEmitterNode *stars;
@property SKEmitterNode *stars2;
@property SKEmitterNode *fuel;
-(void)scoreUpdate;
-(void)livesUpdate;

@end
