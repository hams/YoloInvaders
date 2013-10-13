//
//  GameOverViewController.m
//  SpaceGamer
//
//  Created by Miroslav Zoricak on 13.10.13.
//  Copyright (c) 2013 Kasper. All rights reserved.
//

#import "GameOverViewController.h"

@implementation GameOverViewController

- (IBAction)tryAgain:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
