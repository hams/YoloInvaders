//
//  GameViewController.m
//  SpaceGamer
//
//  Created by Kasper on 10/1/13.
//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@interface GameViewController () {
    SKView *gameView;
    GameScene *scene;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewDidLoad];
    
    // Configure the view.
    gameView = (SKView *)self.view;
    gameView.showsFPS = YES;
    gameView.showsNodeCount = YES;
    
    // Create and configure the scene.
    scene = [GameScene sceneWithSize:gameView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    scene.gameViewController = self;
    
    // Present the scene.
    [gameView presentScene:scene];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    gameView.paused = NO;
    [scene reset];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    gameView.paused = YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)presentGameOverScene
{
    [self performSegueWithIdentifier:@"gameOverSegue" sender:self];
}

@end
