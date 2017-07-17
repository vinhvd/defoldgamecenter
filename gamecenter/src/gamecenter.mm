#include <dmsdk/sdk.h>
#include "gamecenter_private.h"

#include <Foundation/Foundation.h>

#if defined(DM_PLATFORM_IOS) || defined(DM_PLATFORM_OSX)


@interface Hello : NSObject
{
    @private int year;
    @public  NSString *os;
}
@end

@implementation Hello

- (void)sayHello {
	#if defined(DM_PLATFORM_IOS)
		os = "IOS";
    #else		
		os = @"OSX";
	#endif
	year = 2017;
	NSLog (@"Hello %@ in %d!\n", os, year);
}

- (void)sayHello:(NSString*)name {
	NSLog (@"Hello %@!\n", name);
}

- (void)sayHello:(NSString*)name
			  	aString:(NSString*)anotherString
{
	NSLog (@"%@ and %@!\n", name, anotherString);
}
@end

Hello *hello = [[Hello alloc] init];

int testParam(int type, int quality) {
	
	[hello sayHello];
	[hello sayHello:@"World"];
	
    [hello sayHello:@"World" 
    		   aString:@"Me"];
    
#if defined(DM_PLATFORM_IOS)
    printf("IOS : %d, %d\n", type, quality);
#endif
    
#if defined(DM_PLATFORM_OSX)
    printf("OSX : %d, %d\n", type, quality);
#endif
    return 1;

}

#endif // DM_PLATFORM_IOS/DM_PLATFORM_OSX
