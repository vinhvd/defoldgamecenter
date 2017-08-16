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
#include <vector>
#include <map>
#include <string>

#include "gamecenter_private.h"
#include <Foundation/Foundation.h>
#include <GameKit/GameKit.h>

#if defined(DM_PLATFORM_IOS)
#include <UIKit/UIKit.h>
#endif

using namespace std;

#if defined(DM_PLATFORM_IOS) || defined(DM_PLATFORM_OSX)
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@protocol GameCenterManagerDelegate <GKGameCenterControllerDelegate>
@end

#if defined(DM_PLATFORM_IOS)
@interface GameKitManager : UIViewController <GameCenterManagerDelegate>
{
@private UIViewController *m_authenticationViewController;
#else
@interface GameKitManager : NSViewController <GameCenterManagerDelegate>
{
@private NSViewController *m_authenticationViewController;
#endif

@private id<GameCenterManagerDelegate, NSObject> m_delegate;
}
+ (instancetype)sharedGameKitManager;
@end


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
    	m_delegate = self;
    }
    return self;
}

- (void)authenticateLocalPlayer:(CallbackFn) fn withCallbackInfo:(CallbackInfo*) cbk
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
#if defined(DM_PLATFORM_IOS)
    localPlayer.authenticateHandler  =
    ^(UIViewController *viewController, NSError *error) {
#else        
    localPlayer.authenticateHandler  =
    ^(NSViewController *viewController, NSError *error) {
#endif  
		if (error != nil)
        {
            cbk->m_Error = new GKError([error code], [[error localizedDescription] UTF8String]);
        }
              
        if(viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
        	fn(cbk);
        } else {
        	cbk->m_Error = new GKError(GKErrorUnknown, "Unknown");
        	fn(cbk);
        }
    };
}

#if defined(DM_PLATFORM_IOS)
- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
#else
- (void)setAuthenticationViewController:(NSViewController *)authenticationViewController
#endif 
	{   
    m_authenticationViewController = authenticationViewController;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:PresentAuthenticationViewController
     object:self];
}


- (void) login:(CallbackFn) fn withCallbackInfo:(CallbackInfo*) cbk
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];
    
    [self authenticateLocalPlayer:fn withCallbackInfo:cbk];
}

- (void) reportScore:(NSString*)leaderboardId score:(int)score withCallback:(CallbackFn) fn withCallbackInfo:(CallbackInfo*) cbk
{
    GKScore* scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardId];
    scoreReporter.value = (int64_t)score;
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error)
        {
            cbk->m_Error = new GKError([error code], [[error localizedDescription] UTF8String]);
        }
        fn(cbk);
    }];
}
    
- (void)submitAchievement:(NSString*)identifier withPercentComplete:(double)percentComplete withCallback:(CallbackFn)fn withCallbackInfo:(CallbackInfo*) cbk
{
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:identifier]  autorelease];
    [achievement setPercentComplete:percentComplete];
    achievement.showsCompletionBanner = YES;
    [achievement reportAchievementWithCompletionHandler:^(NSError  *error) {
        if (error)
        {
            cbk->m_Error = new GKError([error code], [[error localizedDescription] UTF8String]);
        }
        fn(cbk);
    }];
}

- (void)loadAchievements:(CallbackFn)fn withCallbackInfo:(CallbackInfo*) cbk {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
            if (error == NULL)
            {
                if(achievements != NULL && achievements.count > 0) {
                	cbk->m_achievements.OffsetCapacity(achievements.count);
	                for (GKAchievement *achievement in achievements)
	                {
	                   cbk->m_achievements.Push(SAchievement([achievement.identifier UTF8String], achievement.percentComplete));
	                }
                }
            } else {
                cbk->m_Error = new GKError([error code], [[error localizedDescription] UTF8String]);
            }
            fn(cbk);
        }];   
}

- (void)resetAchievements:(CallbackFn)fn withCallbackInfo:(CallbackInfo*) cbk {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            cbk->m_Error = new GKError([error code], [[error localizedDescription] UTF8String]);
        }
        fn(cbk);
    }];
}

// BEGIN SHOW THE STANDARD USER INTERFACE
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

- (void)showLeaderboards:(NSString*)leaderboardId withTimeScope:(int)timeScope {
    [self showLeaderboard:leaderboardId withTimeScope:timeScope];
}

- (void)showLeaderboards:(int)timeScope {
    [self showLeaderboard:nil withTimeScope:timeScope];
}

- (void)showLeaderboard:(NSString*)leaderboardId withTimeScope:(int)timeScope {
    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gameCenterController.leaderboardTimeScope = (LeaderboardTimeScope)timeScope;
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
// END SHOW THE STANDARD USER INTERFACE


// BEGIN DELEGATE
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*) gameCenterViewController {
#if defined(DM_PLATFORM_IOS)
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:true completion:nil];
#else
    [self dismissViewController:gameCenterViewController];
#endif
}

//END DELEGATE

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

// BEGIN API

void login(CallbackFn fn , CallbackInfo* cbk) {
    [[GameKitManager sharedGameKitManager] login:fn withCallbackInfo:cbk];
}

void reportScore(const char *leaderboardId, int score, CallbackFn fn , CallbackInfo* cbk) {
    [[GameKitManager sharedGameKitManager] reportScore:@(leaderboardId) score:score withCallback:fn withCallbackInfo:cbk];
}

void showLeaderboards(int timeScope) {
    [[GameKitManager sharedGameKitManager] showLeaderboards:timeScope];
}

void showLeaderboards(const char *leaderboardId, int timeScope) {
    [[GameKitManager sharedGameKitManager] showLeaderboards:@(leaderboardId) withTimeScope:timeScope];
}

void showAchievements() {
    [[GameKitManager sharedGameKitManager] showAchievements];
}

void submitAchievement(const char *identifier, double percentComplete, CallbackFn fn , CallbackInfo* cbk) {
    [[GameKitManager sharedGameKitManager] submitAchievement:@(identifier) withPercentComplete:percentComplete withCallback:fn withCallbackInfo:cbk];
}

void loadAchievements(CallbackFn fn , CallbackInfo* cbk) {
    [[GameKitManager sharedGameKitManager] loadAchievements:fn withCallbackInfo:cbk];
}

void resetAchievements(CallbackFn fn , CallbackInfo* cbk) {
    [[GameKitManager sharedGameKitManager] resetAchievements:fn withCallbackInfo:cbk];
}
// END API

#endif // DM_PLATFORM_IOS/DM_PLATFORM_OSX
