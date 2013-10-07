//
//  MyScene.m
//  SpaceGamer
//
//  Created by Kasper on 10/1/13.
//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"

// 1
@interface MyScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKLabelNode *scoreContainer;
@property (nonatomic) SKLabelNode *livesContainer;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;
@end

@implementation MyScene;

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

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
    self.scoreValue += 75;
    _scoreContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_scoreValue];
}

-(void)livesUpdate{
    if (_livesValue > 0) {
        self.livesValue -= 1;
        _livesContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_livesValue];
    }
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // Background
        self.backgroundColor = [SKColor colorWithRed:0.09 green:0.12 blue:0.20 alpha:1.0];
        
        // Adds Player
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship"];
        self.player.position = CGPointMake(CGRectGetMidX(self.frame), 120);
        [self addChild:self.player];
        
        // Adds Score Text
        SKLabelNode *scoreText = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
        scoreText.text = @"SCORE";
        scoreText.fontSize = 12;
        scoreText.fontColor = [SKColor colorWithRed:0.40 green:0.44 blue:0.45 alpha:1.0];
        scoreText.position = CGPointMake(36, CGRectGetHeight(self.frame) - 24);
        [self addChild:scoreText];
        
        // Adds Score Value
        _scoreValue = 0;
        _scoreContainer = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
        _scoreContainer.horizontalAlignmentMode = NSTextAlignmentLeft;
        _scoreContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_scoreValue];
        _scoreContainer.fontSize = 12;
        _scoreContainer.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        _scoreContainer.position = CGPointMake(70, CGRectGetHeight(self.frame) - 24);
        [self addChild:_scoreContainer];
        
        // Adds Lives Value
        _livesValue = 3;
        _livesContainer = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Light"];
        _livesContainer.horizontalAlignmentMode = NSTextAlignmentLeft;
        _livesContainer.text = [NSString stringWithFormat:@"%lu",(unsigned long)_livesValue];
        _livesContainer.fontSize = 12;
        _livesContainer.fontColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        _livesContainer.position = CGPointMake(70, CGRectGetHeight(self.frame) - 48);
        [self addChild:_livesContainer];
        
        // World Gravity etc.
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
    }
    return self;
}

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"enemy1"];
    
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
    monster.physicsBody.collisionBitMask = 0;
    
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
    
    SKAction * loseAction = [SKAction runBlock:^{
        [self livesUpdate];
        
        if (_livesValue == 0) {
            SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
            SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
            [self.view presentScene:gameOverScene transition: reveal];
        }
    }];
    [monster runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    self.player.position = location;

    // Set up initial location of lazer
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"lazer"];
    projectile.position = self.player.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
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
    
    // Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
   
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    [projectile removeFromParent];
    [monster removeFromParent];
    
    [self scoreUpdate];
    
    self.monstersDestroyed++;
    if (self.monstersDestroyed > 30) {
        SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition: reveal];
    }
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
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
    
    // When colliding
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
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