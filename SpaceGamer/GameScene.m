//
//  GameScene.m
//  SpaceGamer
//
//  Created by Kasper on 10/1/13.
//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import "GameScene.h"

@interface GameScene () <SKPhysicsContactDelegate>

@end

@implementation GameScene;

const uint32_t good_guys    =  0x1 << 0;
const uint32_t bad_guys     =  0x1 << 1;
const uint32_t power_ups    =  0x1 << 2;
const uint32_t bad_lazers   =  0x1 << 3;
const uint32_t good_lazers  =  0x1 << 3;

-(void)scoreUpdate:(SKSpriteNode *) monster{
    
    // Adds points for hitting
    self.scoreValue += 75;
    
    // Updates Score
    _scoreContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_scoreValue];
    
    // Adds Points Text
    _pointsText = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    _pointsText.text = @"+75";
    _pointsText.fontSize = 16;
    _pointsText.fontColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    _pointsText.position = CGPointMake(monster.position.x + 30, monster.position.y + 24);
    _pointsText.zPosition = 100;
    [self addChild:_pointsText];
    
    // Adds Points Animation
    SKAction *fadeoutAction = [SKAction fadeOutWithDuration:0.5];
    SKAction *fadeinAction = [SKAction fadeInWithDuration:0.3];
    SKAction *remove = [SKAction removeFromParent];
    [_pointsText runAction:[SKAction repeatAction:[SKAction sequence:[NSArray arrayWithObjects:fadeinAction, fadeoutAction, remove, nil]] count:1]];
}

-(void)livesUpdate{
    if (_livesValue > 1) {
        
        // Removes Life for getting hit
        self.livesValue -= 20;
        
        // Removes Points for getting hit
        self.scoreValue -= 25;
        
        // Updates Life
        _livesContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_livesValue];
        
        // Makes spaceship blink red when hit
        SKAction *pulseRed = [SKAction sequence:@[
                                                  [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
                                                  [SKAction waitForDuration:0.1],
                                                  [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
        [self.player runAction:[SKAction repeatAction:[SKAction sequence:[NSArray arrayWithObjects:pulseRed, nil]] count:4]];


    } else {
        [self.gameViewController presentGameOverScene];
    }
}

// Time Intervals
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    // Spawning Asteroids
    self.lastAsteroidTimeInterval += timeSinceLast;
    if (self.lastAsteroidTimeInterval > 1.5) {
        self.lastAsteroidTimeInterval = 0;
        [self addAsteroid];
    }
    
    // Spawning Enemies
    self.lastSpawnTimeInterval += timeSinceLast;
    if (_scoreValue == 0) {
        _spawnSpeed = 1.2;
    }
    else {
        _spawnSpeed = 1.2;  // / _scoreValue;
    }
    if (self.lastBossSpawnTimeInterval > 10 && self.lastSpawnTimeInterval > _spawnSpeed) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
    
    // Spawning Boss
    self.lastBossSpawnTimeInterval += timeSinceLast;
    if (self.lastBossSpawnTimeInterval > 60) {
        self.lastBossSpawnTimeInterval = 0;
        
        // Adds Boss
        [self addBoss];
    }
    
    // Lazer Speed
    self.lastLazerTimeInterval += timeSinceLast;
    if (_scoreValue == 0) {
        _lazerSpeed = 0.3;
    }
    else {
        _lazerSpeed = 0.3; // / _scoreValue;
    }
    if (self.lastLazerTimeInterval > _lazerSpeed) {
        self.lastLazerTimeInterval = 0;
        [self addLazer];
    }

}

- (void)reset
{
    // Resets Timers
    _lastSpawnTimeInterval = 0;
    _lastAsteroidTimeInterval = 0;
    _lastLazerTimeInterval = 0;
    _lastUpdateTimeInterval = 0;
    _lastBossSpawnTimeInterval = 0;
    
    // Adds Background
    [self addBackground];
    
    // Adds Player
    [self addPlayer];
    
    // Adds UI
    [self userInterface];
    
    // World Gravity etc.
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    _started = false;
}

// For moving the Space Ship
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (_started == false) {
        _started = true;
        [self performSelector:@selector(fadeOutLabels) withObject:nil afterDelay:0.0f];
    }
    
    
    SKAction *movePlayer = [SKAction moveTo:location duration:0.05];
    SKAction *moveFuel = [SKAction moveTo:CGPointMake(location.x, location.y - 24) duration:0.05];

    [self.fuel runAction:moveFuel];
    [self.player runAction:movePlayer];
    
}

- (void)addBackground {
    self.backgroundColor = [SKColor colorWithRed:0.09 green:0.17 blue:0.28 alpha:1.0];
    
//    _background = [SKSpriteNode spriteNodeWithImageNamed:@"bg3"];
//    _background.position = CGPointMake(CGRectGetMidX(self.frame), 500);
//    [self addChild:_background];
//    
//    SKAction *moveBackground = [SKAction moveToY:-1800 duration:50];
//    [_background runAction:[SKAction repeatAction:[SKAction sequence:[NSArray arrayWithObjects:moveBackground, nil]] count:1]];

    CGContextRef context = CGBitmapContextCreate(NULL, 640.0, 2000, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);

    CGFloat locations[2] = {0.0, 1.0};
    CGFloat compoments[8] = {0.26, 0.15, 0.47, 1.0,
                             0.10, 0.16, 0.25, 1.0};
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), compoments, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(600.0, 2000.0), 0);
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithCGImage:image]];
    
    
//    SKShapeNode *bg = [SKShapeNode node];
//    bg.path = CGPathCreateWithRect(CGRectMake(0.0, 0.0, 50.0, 50.0), &CGAffineTransformIdentity);
//    bg.fillColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
    bg.position = CGPointMake(0.0, 1000.0);
    NSArray *actions = @[[SKAction moveToY:0.0 duration:3], [SKAction moveToY:1000.0 duration:3]];
    [bg runAction:[SKAction repeatActionForever:[SKAction sequence:actions]]];
    
    [self addChild:bg];
    
    NSString *starsEmitter = [[NSBundle mainBundle] pathForResource:@"stars" ofType:@"sks"];
    _stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsEmitter];
    _stars.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
    [self addChild:_stars];
    
    NSString *starsEmitter2 = [[NSBundle mainBundle] pathForResource:@"stars2" ofType:@"sks"];
    _stars2 = [NSKeyedUnarchiver unarchiveObjectWithFile:starsEmitter2];
    _stars2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
    [self addChild:_stars2];
    
}

- (void)userInterface {
    
    // Adds Score Text
    SKLabelNode *scoreText = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    scoreText.text = @"SCORE";
    scoreText.fontSize = 12;
    scoreText.fontColor = [SKColor colorWithRed:0.40 green:0.44 blue:0.45 alpha:1.0];
    scoreText.position = CGPointMake(36, CGRectGetHeight(self.frame) - 24);
    scoreText.zPosition = 100;
    [self addChild:scoreText];
    
    // Adds Score Value
    _scoreValue = 0;
    _scoreContainer = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    _scoreContainer.horizontalAlignmentMode = NSTextAlignmentLeft;
    _scoreContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_scoreValue];
    _scoreContainer.fontSize = 12;
    _scoreContainer.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    _scoreContainer.position = CGPointMake(70, CGRectGetHeight(self.frame) - 24);
    _scoreContainer.zPosition = 100;
    [self addChild:_scoreContainer];
    
    // Adds Lives Value
    _livesValue = 100;
    _livesContainer = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    _livesContainer.horizontalAlignmentMode = NSTextAlignmentLeft;
    _livesContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_livesValue];
    _livesContainer.fontSize = 12;
    _livesContainer.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    _livesContainer.position = CGPointMake(CGRectGetWidth(self.frame) - 30, CGRectGetHeight(self.frame) - 24);
    _livesContainer.zPosition = 100;
    [self addChild:_livesContainer];
    
    // Adds Health Graphics
    SKShapeNode * healthBar = [SKShapeNode node];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(CGRectGetMaxX(self.frame) - 30, 20, 20, 200));
    healthBar.path = path;
    [healthBar setFillColor:[UIColor colorWithRed:0.16 green:0.21 blue:0.32 alpha:1.0]];
    [healthBar setStrokeColor:[UIColor colorWithRed:0.16 green:0.21 blue:0.32 alpha:0.0]];
    CGPathRelease(path);
    [self addChild:healthBar];
    
    SKShapeNode * healthBarValue = [SKShapeNode node];
    _paththree = CGPathCreateMutable();
    CGPathAddRect(_paththree, NULL, CGRectMake(CGRectGetMaxX(self.frame) - 30, 20, 20, _livesValue * 2));
    healthBarValue.path = _paththree;
    [healthBarValue setFillColor:[UIColor colorWithRed:0.24 green:0.69 blue:0.80 alpha:1.0]];
    [healthBarValue setStrokeColor:[UIColor colorWithRed:0.16 green:0.21 blue:0.32 alpha:0.0]];
    CGPathRelease(_paththree);
    [self addChild:healthBarValue];
    
    SKShapeNode * healthBarOverlay = [SKShapeNode node];
    CGMutablePathRef pathtwo = CGPathCreateMutable();
    CGPathAddRect(pathtwo, NULL, CGRectMake(CGRectGetMaxX(self.frame) - 20, 20, 20/2, 200));
    healthBarOverlay.path = pathtwo;
    [healthBarOverlay setFillColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
    [healthBarOverlay setStrokeColor:[UIColor colorWithRed:0.16 green:0.21 blue:0.32 alpha:0.0]];
    CGPathRelease(pathtwo);
    [self addChild:healthBarOverlay];
    
    
    // Adds Level Text
    _levelText = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    _levelText.text = @"TAP TO START";
    _levelText.fontSize = 18;
    _levelText.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    _levelText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxX(self.frame));
    _levelText.zPosition = 100;
    [self addChild:_levelText];
    
    SKAction *pulse = [SKAction sequence:@[
                                           [SKAction fadeOutWithDuration:0],
                                           [SKAction waitForDuration:0.3],
                                           [SKAction fadeInWithDuration:1],
                                           [SKAction waitForDuration:0.5],
                                           [SKAction fadeOutWithDuration:1]
                                        ]
    ];
    [_levelText runAction:[SKAction repeatActionForever:pulse]];
    
}

-(void)fadeOutLabels
{
    SKAction *fadeoutAction = [SKAction fadeOutWithDuration:0.5];
    SKAction *fadeinAction = [SKAction fadeInWithDuration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    [_levelText runAction:[SKAction repeatAction:[SKAction sequence:[NSArray arrayWithObjects:fadeinAction, fadeoutAction, remove, nil]] count:1]];
}

- (void)addLazer {
    
    // Set up initial location of lazer
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"lazer"];
    projectile.position = self.player.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = good_lazers;
    projectile.physicsBody.contactTestBitMask = bad_guys;
    //projectile.physicsBody.collisionBitMask = bad_guys | bad_guys;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    projectile.zPosition = 5;
    // Adds Lazer
    [self addChild:projectile];
    
    // Add the shoot amount to the current position
    CGPoint realDest = CGPointMake(self.player.position.x, CGRectGetMaxY(self.frame));
    
    // Adds Lazer Effect
    NSString *lazerPath = [[NSBundle mainBundle] pathForResource:@"fuel" ofType:@"sks"];
    _lazer = [NSKeyedUnarchiver unarchiveObjectWithFile:lazerPath];
    _lazer.position = projectile.position;
    _lazer.zPosition = 7;
    _lazer.scale = 0.2;
    [self addChild:_lazer];
    
    // Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    [_lazer runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
 //   SKAction* soundAction = [SKAction playSoundFileNamed:@"lazer.wav" waitForCompletion:NO];
//    [self runAction:soundAction];
    
}

- (void)addPlayer {
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship5"];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame), 120);
    self.player.zPosition = 10;
    self.player.Scale = 0.5;
    [self addChild:self.player];
    
    self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
    self.player.physicsBody.dynamic = YES;
    self.player.physicsBody.categoryBitMask = good_guys;
    self.player.physicsBody.contactTestBitMask = bad_guys | power_ups | bad_lazers;
    //self.player.physicsBody.collisionBitMask = bad_guys;
    self.player.physicsBody.collisionBitMask = 0;
    self.player.physicsBody.usesPreciseCollisionDetection = YES;
    
    // Adds Fuel Effect
    NSString *fuelPath = [[NSBundle mainBundle] pathForResource:@"fuel" ofType:@"sks"];
    _fuel = [NSKeyedUnarchiver unarchiveObjectWithFile:fuelPath];
    _fuel.position = CGPointMake(self.player.position.x, self.player.position.y - 24);
    _fuel.zPosition = 7;
    _fuel.Scale = 0.2;
    [self addChild:_fuel];
}

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"enemy4"];
    
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.width / 2;
    int maxY = self.frame.size.width - monster.size.width / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) - minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(monster.size.width/2 + actualY, self.frame.size.height);
    [self addChild:monster];
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = bad_guys;
    monster.physicsBody.contactTestBitMask = good_guys | good_lazers;
    //monster.physicsBody.collisionBitMask = good_guys | good_lazers;
    monster.physicsBody.collisionBitMask = 0;
    monster.physicsBody.usesPreciseCollisionDetection = YES;
    monster.zPosition = 7;
    monster.Scale = 0.8;
    
    // Adds Fuel Effect
//    NSString *fuelPath = [[NSBundle mainBundle] pathForResource:@"fuel2" ofType:@"sks"];
//    _fuel2 = [NSKeyedUnarchiver unarchiveObjectWithFile:fuelPath];
//    _fuel2.position = CGPointMake(monster.position.x,monster.position.y + 48);
//    _fuel2.zPosition = 7;
//    _fuel2.Scale = 0.5;
//    _fuel2.zRotation = 0.0;
//    [self addChild:_fuel2];
    
    // Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 5.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(monster.size.width/2 + actualY, 0) duration:actualDuration];
//    SKAction * actionFuelMove = [SKAction moveTo:CGPointMake(monster.size.width/2 + actualY, 0 + 48) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
//    [_fuel2 runAction:[SKAction sequence:@[actionFuelMove, actionMoveDone]]];
    
}

- (void)addAsteroid {
    
    // Create sprite
    SKSpriteNode * asteroid = [SKSpriteNode spriteNodeWithImageNamed:@"asteroid"];
    
    // Determine where to spawn the monster along the Y axis
    int minY = asteroid.size.width / 2;
    int maxY = self.frame.size.width - asteroid.size.width / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) - minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    asteroid.position = CGPointMake(asteroid.size.width/2 + actualY, self.frame.size.height);
    [self addChild:asteroid];
    
    asteroid.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:asteroid.size];
    asteroid.physicsBody.dynamic = YES;
    asteroid.physicsBody.categoryBitMask = bad_guys;
    asteroid.physicsBody.contactTestBitMask = good_guys | good_lazers;
    //asteroid.physicsBody.collisionBitMask = good_guys | good_lazers;
    asteroid.physicsBody.collisionBitMask = 0;
    asteroid.physicsBody.usesPreciseCollisionDetection = YES;
    asteroid.zPosition = 7;
    
    // Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 10.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake((arc4random() % rangeY) - minY, 0) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [asteroid runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)addBoss {
    
    _boss = [SKSpriteNode spriteNodeWithImageNamed:@"boss"];
    _boss.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + _boss.size.height);
    _boss.zPosition = 10;
    [self addChild:_boss];
    
    SKAction *enterBoss = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - _boss.size.height /1.5) duration:3];
    SKAction *leftBoss = [SKAction moveToX:CGRectGetMaxX(self.frame) duration:3];
    SKAction *rightBoss = [SKAction moveToX:CGRectGetMinX(self.frame) duration:3];
    
    [self.boss runAction:[SKAction repeatAction:enterBoss count:1]];
    [self.boss runAction:[SKAction repeatActionForever:[SKAction sequence:@[leftBoss, rightBoss]]]];
    
    
}

- (void)addExplosion:(SKSpriteNode *) monster {
    // Adds Explosion
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"explosion2" ofType:@"sks"];
    _explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    _explosion.position = monster.position;
    _explosion.zPosition = 7;
    [self addChild:_explosion];
}

- (void)addHealthDrop:(SKSpriteNode *) monster {
    
    
//    SKSpriteNode * health = [SKSpriteNode spriteNodeWithImageNamed:@"health"];
//    health.position = monster.position;
//    [self addChild:health];
//    
//    health.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:health.size];
//    health.physicsBody.dynamic = YES;
//    health.physicsBody.categoryBitMask = healthDropCategory;
//    health.physicsBody.contactTestBitMask = playerCategory;
//    health.physicsBody.collisionBitMask = 0;
//    health.physicsBody.usesPreciseCollisionDetection = YES;
//    health.zPosition = 7;
    
    // Health Glow
    NSString *pointsDrop = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"sks"];
    _point = [NSKeyedUnarchiver unarchiveObjectWithFile:pointsDrop];
    _point.position = monster.position;
    _point.zPosition = 6;
    [self addChild:_point];
    
    //[_health runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];

}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    
    SKAction *pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.1],
                                              [SKAction waitForDuration:0.1],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.1]]];
    
    SKAction * removeAction = [SKAction removeFromParent];
    
    // Lazer colides with Enemy
    if ((contact.bodyA.categoryBitMask & bad_guys) != 0)
    {
        SKNode *enemy = (contact.bodyA.categoryBitMask & good_lazers) ? contact.bodyB.node : contact.bodyA.node;

        // Updates Score
        [self scoreUpdate:(SKSpriteNode *) enemy];
        
        // Adds Explosion
        [self addExplosion:(SKSpriteNode *) enemy];
        
        // Adds Health Drop
        [self addHealthDrop:(SKSpriteNode *) enemy];
        
        [enemy runAction:[SKAction repeatAction:[SKAction sequence:[NSArray arrayWithObjects:pulseRed, removeAction, nil]] count:1]];
    }
    
    // Player colides with Enemy
    if ((contact.bodyB.categoryBitMask & bad_guys) != 0)
    {
        SKNode *enemy = (contact.bodyB.categoryBitMask & good_guys) ? contact.bodyA.node : contact.bodyB.node;
        
        // Updates Lifes
        [self livesUpdate];
        
        // Destroys Monster
        [enemy removeFromParent];
        
        // Adds Explosion
        [self addExplosion:(SKSpriteNode *) enemy];
    }

}

- (void)update:(NSTimeInterval)currentTime {
    
    if (_started) {
        // Handle time delta.
        // If we drop below 60fps, we still want everything to move the same distance.
        CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        if (timeSinceLast > 1) { // more than a second since last update
            timeSinceLast = 1.0 / 60.0;
            self.lastUpdateTimeInterval = currentTime;
        }
        
        [self updateWithTimeSinceLastUpdate:timeSinceLast];
    }
    
}

-(void)didEvaluateActions {
    //CGPathAddRect(_paththree, NULL, CGRectMake(CGRectGetMaxX(self.frame) - 30, 20, 20, _livesValue * 2));
    //[_healthBarValue setPath:(_paththree)];
    
    // Each Frame
    // -> update: -> SKScene Evaluate Actions -> didEvaluateActions -> SKScene Simulate Physics -> didSimulatePhysics -> Renders
    
    SKAction * actionMove = [SKAction moveTo:self.player.position duration:0.7];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [_point runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

@end