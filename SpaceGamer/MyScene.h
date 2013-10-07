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
-(void)scoreUpdate;
-(void)livesUpdate;

@end