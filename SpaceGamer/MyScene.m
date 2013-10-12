//
//  MyScene.m
//  SpaceGamer
//
//  Created by Kasper on 10/1/13.
//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"

@interface MyScene () <SKPhysicsContactDelegate>
@end

@implementation MyScene;

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t playerCategory         =  0x1 << 2;

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

-(void)scoreUpdate{
    
    // Adds points for hitting
    self.scoreValue += 75;
    
    // Updates Score
    _scoreContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_scoreValue];
}

-(void)livesUpdate{
    if (_livesValue > 0) {
        
        // Removes Life for getting hit
        self.livesValue -= 1;
        
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


    }
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
    
    self.lastLazerTimeInterval += timeSinceLast;
    _lazerSpeed = 1;
    if (self.lastLazerTimeInterval > 0.3) {
        self.lastLazerTimeInterval = 0;
        [self addLazer];
    }
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [self performSelector:@selector(fadeOutLabels) withObject:nil afterDelay:3.0f];
        
        // Adds Background
        [self addBackground];
        
        // Adds Player
        [self addPlayer];
        
        [self addBoss];
        
        // Adds UI
        [self userInterface];
        
        // World Gravity etc.
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
    }
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    
    SKAction *movePlayer = [SKAction moveTo:location duration:0.05];
    SKAction *moveFuel = [SKAction moveTo:CGPointMake(location.x, location.y - 24) duration:0.05];
    [self.fuel runAction:[SKAction repeatActionForever:moveFuel]];
    [self.player runAction:[SKAction repeatActionForever:movePlayer]];
    
}

- (void)addPlayer {
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"plane3"];
    self.player.position = CGPointMake(CGRectGetMidX(self.frame), 120);
    self.player.zPosition = 10;
    self.player.Scale = 0.1;
    [self addChild:self.player];
    
    self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
    self.player.physicsBody.dynamic = YES;
    self.player.physicsBody.categoryBitMask = playerCategory;
    self.player.physicsBody.contactTestBitMask = monsterCategory;
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

- (void)addBackground {
    self.backgroundColor = [SKColor colorWithRed:0.09 green:0.17 blue:0.28 alpha:1.0];
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"bg3"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), 500);
    [self addChild:_background];
    
    SKAction *moveBackground = [SKAction moveToY:-1800 duration:50];
    [_background runAction:[SKAction repeatAction:[SKAction sequence:[NSArray arrayWithObjects:moveBackground, nil]] count:1]];
    
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
    _livesValue = 3;
    _livesContainer = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    _livesContainer.horizontalAlignmentMode = NSTextAlignmentLeft;
    _livesContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_livesValue];
    _livesContainer.fontSize = 12;
    _livesContainer.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    _livesContainer.position = CGPointMake(CGRectGetWidth(self.frame) - 30, CGRectGetHeight(self.frame) - 24);
    _livesContainer.zPosition = 100;
    [self addChild:_livesContainer];
    
    // Adds Level Text
    _levelText = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    _levelText.text = @"LEVEL 1";
    _levelText.fontSize = 18;
    _levelText.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    _levelText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxX(self.frame));
    _levelText.zPosition = 100;
    [self addChild:_levelText];
    
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
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    projectile.zPosition = 5;
    
    // Determine offset of location to lazer
    CGPoint offset = rwSub(CGPointMake(self.player.position.x, CGRectGetHeight(self.frame)), projectile.position);
    
    // Adds Lazer
    [self addChild:projectile];
    
    // Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
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

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"enemy2"];
    
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
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.contactTestBitMask = playerCategory;
    monster.physicsBody.collisionBitMask = 0;
    monster.physicsBody.usesPreciseCollisionDetection = YES;
    monster.zPosition = 7;
    
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    // Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 5.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(monster.size.width/2 + actualY, 0) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];

}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    [projectile removeFromParent];
    [monster removeFromParent];
    
    [self scoreUpdate];
    
    // Adds Explosion // >> THIS SECTION SHOULD GET MOVED TO OWN PART, BUT monster.position is the problem <<
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"explosion2" ofType:@"sks"];
    _explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    _explosion.position = monster.position;
    _explosion.zPosition = 7;
    [self addChild:_explosion];
    
    // Adds Points Text // >> THIS SECTION SHOULD GET MOVED TO OWN PART, BUT monster.position is the problem <<
    _pointsText = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
    _pointsText.text = @"+75";
    _pointsText.fontSize = 16;
    _pointsText.fontColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    _pointsText.position = CGPointMake(monster.position.x + 30, monster.position.y + 24);
    _pointsText.zPosition = 100;
    [self addChild:_pointsText];
    
    // Adds Points Animation // >> THIS SECTION SHOULD GET MOVED TO OWN PART, BUT monster.position is the problem <<
    SKAction *fadeoutAction = [SKAction fadeOutWithDuration:0.5];
    SKAction *fadeinAction = [SKAction fadeInWithDuration:0.3];
    SKAction *remove = [SKAction removeFromParent];
    [_pointsText runAction:[SKAction repeatAction:[SKAction sequence:[NSArray arrayWithObjects:fadeinAction, fadeoutAction, remove, nil]] count:1]];
    
    self.monstersDestroyed++;
    //    if (self.monstersDestroyed > 30) {
    //        SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
    //        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
    //        [self.view presentScene:gameOverScene transition: reveal];
    //    }
    
    // Adds Explosion // >> THIS SECTION SHOULD GET MOVED TO OWN PART, BUT monster.position is the problem <<
    NSString *pointsDrop = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"sks"];
    _point = [NSKeyedUnarchiver unarchiveObjectWithFile:pointsDrop];
    _point.position = monster.position;
    _point.zPosition = 7;
    [self addChild:_point];
    
}

- (void)player:(SKSpriteNode *)player didCollideWithPlayer:(SKSpriteNode *)monster {
    [monster removeFromParent];
    
    [self scoreUpdate];
    
    // Adds Explosion // >> THIS SECTION SHOULD GET MOVED TO OWN PART, BUT monster.position is the problem <<
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"explosion2" ofType:@"sks"];
    _explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    _explosion.position = monster.position;
    _explosion.zPosition = 7;
    [self addChild:_explosion];
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // Lazer coliding with monster
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    
    // Monster coliding with player
    if ((secondBody.categoryBitMask & playerCategory) != 0 &&
        (firstBody.categoryBitMask & monsterCategory) != 0)
    {
        [self livesUpdate];
        
        [self player:(SKSpriteNode *) secondBody.node didCollideWithPlayer:(SKSpriteNode *) firstBody.node];
        
        if (_livesValue == 0) {
            SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
            SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
            [self.view presentScene:gameOverScene transition: reveal];
        }

    }
}

- (void)update:(NSTimeInterval)currentTime {
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

@end