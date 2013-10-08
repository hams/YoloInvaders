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
        
        // Sequence
        [self runAction:
         [SKAction sequence:@[
                              [SKAction waitForDuration:3.0],
                              [SKAction runBlock:^{
             // 5
             SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
             SKScene * myScene = [[MyScene alloc] initWithSize:self.size];
             [self.view presentScene:myScene transition: reveal];
         }]
                              ]]
         ];
        
    }
    return self;
}

@end