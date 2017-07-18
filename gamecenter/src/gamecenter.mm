#include <dmsdk/sdk.h>
#include <dmsdk/graphics/graphics_native.h>
#include "gamecenter_private.h"

#include <Foundation/Foundation.h>
#include <GameKit/GameKit.h>

#if defined(DM_PLATFORM_IOS)
#include <UIKit/UIKit.h>
#endif

#if defined(DM_PLATFORM_IOS) || defined(DM_PLATFORM_OSX)
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

#if defined(DM_PLATFORM_IOS)
UIViewController *rController = [UIApplication sharedApplication].keyWindow.rootViewController;
#else
NSViewController *rController = [NSApplication sharedApplication].keyWindow.contentViewController;
#endif

@interface GameKitHelper : NSObject
{
	#if defined(DM_PLATFORM_IOS)
	@private UIViewController *m_authenticationViewController;
	#else
	@private NSViewController *m_authenticationViewController;
	#endif
	@private NSError *m_lastError;
}
+ (instancetype)sharedGameKitHelper;
@end

@implementation GameKitHelper
BOOL _enableGameCenter;

+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
      _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    #if defined(DM_PLATFORM_IOS)
    localPlayer.authenticateHandler  =
    ^(UIViewController *viewController, NSError *error) {
        
        [self setLastError:error];
        
        if(viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            _enableGameCenter = YES;
        } else {
            _enableGameCenter = NO;
        }
    };
    #else
    localPlayer.authenticateHandler  =
    ^(NSViewController *viewController, NSError *error) {
        
        [self setLastError:error];
        
        if(viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            _enableGameCenter = YES;
        } else {
            _enableGameCenter = NO;
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

- (void)setLastError:(NSError *)error
{
    if(error) {
	    m_lastError = [error copy];
	  	if (m_lastError) {
	    	NSLog(@"GameKitHelper ERROR: %@",
	        	[[m_lastError userInfo] description]);
	  	}
  	}
}

- (void) authenticate
{
	[[NSNotificationCenter defaultCenter]
       addObserver:rController
       selector:@selector(showAuthenticationViewController)
       name:PresentAuthenticationViewController
       object:nil];
    
    [self authenticateLocalPlayer];
}

- (void)showAuthenticationViewController
{	
    [rController presentViewController:
       m_authenticationViewController
                          animated:YES
                          completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:rController];
}

@end

int authenticate() {
	[[GameKitHelper sharedGameKitHelper] authenticate];
	return 0;
}
#endif // DM_PLATFORM_IOS/DM_PLATFORM_OSX
