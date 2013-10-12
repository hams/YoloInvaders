//
//  GameOverScene.m
//  SpaceGamer
//
//  Created by Kasper on 10/4/13.
//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

- (SKLabelNode *)retryButton
{
    SKLabelNode *retryNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    retryNode.position = CGPointMake(self.size.width/2, self.size.height/2.5);
    retryNode.name = @"retryButton";//how the node is identified later
    retryNode.text = @"Retry?";
    retryNode.fontSize = 24;
    retryNode.fontColor = [SKColor whiteColor];
    retryNode.zPosition = 1.0;
    return retryNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"retryButton"]) {
        SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
        SKScene * myScene = [[MyScene alloc] initWithSize:self.size];
        [self.view presentScene:myScene transition: reveal];
    }
}

-(id)initWithSize:(CGSize)size won:(BOOL)won {
    if (self = [super initWithSize:size]) {
        
        // Background Color
        self.backgroundColor = [SKColor colorWithRed:0.09 green:0.12 blue:0.20 alpha:1.0];
        
        // Game Over / Win Text
        NSString * message;
        if (won) {
            message = @"MISSION COMPLETE";
        } else {
            message = @"GAME OVER";
        }
        
        // Game Over / Win Settings
        SKLabelNode *gameOver = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
        gameOver.text = message;
        gameOver.fontSize = 24;
        gameOver.fontColor = [SKColor whiteColor];
        gameOver.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:gameOver];
        
        // Game Over / Win Settings
        SKLabelNode *score = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
        score.text = @"003433";
        score.fontSize = 24;
        score.fontColor = [SKColor whiteColor];
        score.position = CGPointMake(self.size.width/2, self.size.height/1.7);
        [self addChild:score];
        
        [self addChild: [self retryButton]];
        
        SKSpriteNode * background;
        background = [SKSpriteNode spriteNodeWithImageNamed:@"bg3"];
        background.position = CGPointMake(CGRectGetMidX(self.frame), 500);
        background.zPosition = -2;
        [self addChild:background];
        
        NSString *starsEmitter = [[NSBundle mainBundle] pathForResource:@"stars" ofType:@"sks"];
        _stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsEmitter];
        _stars.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        [self addChild:_stars];
        
        NSString *starsEmitter2 = [[NSBundle mainBundle] pathForResource:@"stars2" ofType:@"sks"];
        _stars2 = [NSKeyedUnarchiver unarchiveObjectWithFile:starsEmitter2];
        _stars2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        [self addChild:_stars2];

        
    }
    return self;

}

@end