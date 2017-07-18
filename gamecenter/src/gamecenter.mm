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
UIWindow *window = dmGraphics::GetNativeiOSUIWindow();
UIViewController *rController = window.rootViewController;
#else
NSWindow *window = dmGraphics::GetNativeOSXNSWindow();
NSViewController *rController = window.contentViewController;
#endif

/*#if defined(DM_PLATFORM_IOS)
UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
#else
NSViewController *controller = [NSApplication sharedApplication].keyWindow.contentViewController;
#endif*/

@interface GameKitHelper : NSObject

#if defined(DM_PLATFORM_IOS)
@property (nonatomic, readonly) UIViewController *authenticationViewController;
#else
@property (nonatomic, readonly) NSViewController *authenticationViewController;
#endif

@property (nonatomic, readonly) NSError *lastError;
@end

@implementation GameKitHelper
BOOL _enableGameCenter;

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
        
         #pragma mark - game halts when invoking the setLast error 
        //[self setLastError:error];
        
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
	self.authenticationViewController = authenticationViewController;
  [[NSNotificationCenter defaultCenter]
   postNotificationName:PresentAuthenticationViewController
   object:self];
}
#else
- (void)setAuthenticationViewController:(NSViewController *)authenticationViewController
{
	self.authenticationViewController = authenticationViewController;
  [[NSNotificationCenter defaultCenter]
   postNotificationName:PresentAuthenticationViewController
   object:self];
}
 #endif

- (void)setLastError:(NSError *)error
{
    if(error) {
	    self.lastError = [error copy];
	  	if (self.lastError) {
	    	NSLog(@"GameKitHelper ERROR: %@",
	        	[[self.lastError userInfo] description]);
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
       self.authenticationViewController
                          animated:YES
                          completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:rController];
}

@end

GameKitHelper *gameKitHelper = [[GameKitHelper alloc] init];
	
int authenticate() {
	[gameKitHelper authenticate];
	return 0;
}
#endif // DM_PLATFORM_IOS/DM_PLATFORM_OSX
