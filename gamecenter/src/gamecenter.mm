/*******************************************************************************
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *******************************************************************************/

#include <dmsdk/sdk.h>
#include "gamecenter_private.h"

#include <Foundation/Foundation.h>
#include <GameKit/GameKit.h>

#if defined(DM_PLATFORM_IOS)
#include <UIKit/UIKit.h>
#endif

#if defined(DM_PLATFORM_IOS) || defined(DM_PLATFORM_OSX)
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@protocol GameCenterManagerDelegate <GKGameCenterControllerDelegate>

@end

#if defined(DM_PLATFORM_IOS)
@interface GameKitManager : UIViewController <GameCenterManagerDelegate>
{
@private UIViewController *m_authenticationViewController;
}
+ (instancetype)sharedGameKitManager;
@end

#else
@interface GameKitManager : NSViewController <GameCenterManagerDelegate>
{
@private NSViewController *m_authenticationViewController;
}
+ (instancetype)sharedGameKitManager;
@end
#endif

@implementation GameKitManager

+ (instancetype)sharedGameKitManager
{
    static GameKitManager *sharedGameKitManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitManager = [[GameKitManager alloc] init];
    });
    return sharedGameKitManager;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
#if defined(DM_PLATFORM_IOS)
    localPlayer.authenticateHandler  =
    ^(UIViewController *viewController, NSError *error) {
        
        if(viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
        } else {
        }
    };
#else
    localPlayer.authenticateHandler  =
    ^(NSViewController *viewController, NSError *error) {
        
        if(viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
        } else {
        }
    };
#endif
}

#if defined(DM_PLATFORM_IOS)
- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    m_authenticationViewController = authenticationViewController;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:PresentAuthenticationViewController
     object:self];
}
#else
- (void)setAuthenticationViewController:(NSViewController *)authenticationViewController
{
    m_authenticationViewController = authenticationViewController;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:PresentAuthenticationViewController
     object:self];
}
#endif

- (void)showAuthenticationViewController
{
#if defined(DM_PLATFORM_IOS)
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:
     m_authenticationViewController
                                                                                 animated:YES
                                                                               completion:nil];
    
#else
    [self presentViewControllerAsModalWindow:m_authenticationViewController];
#endif
}

- (void) login
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];
    
    [self authenticateLocalPlayer];
}

- (int) reportScore:(NSString*)leaderboardId score:(int)score {
    GKScore* highScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardId];
    highScore.value = (int64_t)score;
    [GKScore reportScores:@[highScore] withCompletionHandler:^(NSError *error) {
        NSLog(@"Game Center : report score : %@", [[error userInfo] description]);
    }];
    return 0;
}

- (void)showLeaderboard:(NSString*)leaderboardId {
    [self showLeaderboards:leaderboardId];
}

- (void)showLeaderboards {
    [self showLeaderboards:nil];
}


- (void)showLeaderboards:(NSString*)leaderboardId {
    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
    
    if(leaderboardId != nil) {
        gameCenterController.leaderboardIdentifier = leaderboardId;
    }
    gameCenterController.gameCenterDelegate = self;
    
    
#if defined(DM_PLATFORM_IOS)
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:
     gameCenterController animated:YES completion:nil];
#else
    [self presentViewControllerAsModalWindow:gameCenterController];
#endif
}

- (void)showAchievements {
    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
    gameCenterController.gameCenterDelegate = self;
    
#if defined(DM_PLATFORM_IOS)
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:
     gameCenterController animated:YES completion:nil];
#else
    [self presentViewControllerAsModalWindow:gameCenterController];
#endif
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*) gameCenterViewController {
#if defined(DM_PLATFORM_IOS)
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:true completion:nil];
#else
    [self dismissViewController:gameCenterViewController];
#endif
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

// BEGIN API
int login() {
    [[GameKitManager sharedGameKitManager] login];
    return 0;
}

int reportScore(const char *leaderboardId, int score) {
    return [[GameKitManager sharedGameKitManager] reportScore:@(leaderboardId) score:score];
}

int showLeaderboards() {
    [[GameKitManager sharedGameKitManager] showLeaderboards];
    return 0;
}

int showLeaderboard(const char *leaderboardId) {
    [[GameKitManager sharedGameKitManager] showLeaderboard:@(leaderboardId)];
    return 0;
}

int showAchievements() {
    [[GameKitManager sharedGameKitManager] showAchievements];
    return 0;
}
// END API

#endif // DM_PLATFORM_IOS/DM_PLATFORM_OSX
