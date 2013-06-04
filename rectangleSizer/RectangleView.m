//
//  RectangleView.m
//  rectangleSizer
//
//  Created by grady player on 5/30/13.
//  Copyright (c) 2013 Objectively Better, LLC. All rights reserved.
//

#import "RectangleView.h"
#import "Rectangle.h"

static inline NSRect NSRectFromWeightedRect(WeightedRect r)
{
	return NSMakeRect(r.x, r.y, r.w, r.h);
}

#include <dlfcn.h>

typedef void * LibraryRef;
typedef WeightedRect ( *rectLocationFunc)( double time, NSRect bounds) ;

LibraryRef openLibrary(const char * path, NSError ** err);
BOOL closeLibrary (LibraryRef libRef, NSError ** err);

static WeightedRect cachedRect = {0};
static LibraryRef currentLib = NULL;
#define tmpDir @"/tmp/rect_exmple12345"

WeightedRect rectLocation( double time, NSRect bounds );

static rectLocationFunc funcToUse = rectLocation;

@implementation RectangleView

+(void)initialize
{
	if (self == [RectangleView class]) {
		NSFileManager * fm = [NSFileManager defaultManager];
		BOOL isDir;
		if (![fm fileExistsAtPath:tmpDir isDirectory:&isDir] && isDir) {
			if (![fm createDirectoryAtPath:tmpDir withIntermediateDirectories:NO attributes:nil error:nil]) {
				exit(EXIT_FAILURE);
			}
		}
		NSString * path = [[NSBundle mainBundle] pathForResource:@"Rectangle" ofType:@"h"];
		[fm removeItemAtPath:[tmpDir stringByAppendingPathComponent:@"Rectangle.h"] error:nil];
		[fm moveItemAtPath:path toPath:[tmpDir stringByAppendingPathComponent:@"Rectangle.h"] error:nil];
	}
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(updateRect) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSBezierPath * path= [NSBezierPath bezierPathWithRect:NSRectFromWeightedRect(cachedRect)];
	[path setLineWidth:cachedRect.weight];
	[path stroke];
	
}

-(void)updateCode:(id)sender
{
	NSData * data = [[codeTextView string] dataUsingEncoding:NSUTF8StringEncoding];
	[data writeToFile:[tmpDir stringByAppendingPathComponent:@"lib.m"] atomically:NO];
	
	NSTask * compile = [NSTask new];
	[compile setLaunchPath:@"/usr/bin/clang"];
	NSArray * args = @[@"-dynamiclib", @"-x", @"objective-c", [tmpDir stringByAppendingPathComponent:@"lib.m"], @"-I \"/Users/grady/programing/Proj/self modifying code/rectangleSizer/rectangleSizer/shared\"",@"-fobjc-arc",  @"-framework", @"Foundation",@"-fobjc-link-runtime", @"-framework", @"Cocoa", @"-o", [tmpDir stringByAppendingPathComponent:@"lib.dylib"]];
	
	[compile setArguments:args];

	[compile launch];
	[compile waitUntilExit];
	
	if ([compile terminationStatus]!=0) {
		NSLog(@"failed to compile");
	}else{
		if (currentLib) {
			closeLibrary(currentLib, nil);
		}
		currentLib = openLibrary([[tmpDir stringByAppendingPathComponent:@"lib.dylib"] UTF8String], nil);
		rectLocationFunc tmpFunc = dlsym(currentLib, "rectLocation");
		if (tmpFunc) {
			funcToUse = tmpFunc;
			[self setNeedsDisplay:YES];
		}
		
	}
	[compile release];
	
	
	
}
- (void)updateRect
{
	cachedRect = funcToUse([NSDate timeIntervalSinceReferenceDate], self.bounds);
	[self setNeedsDisplay:YES];
}

@end

/*
int main(int argc, const char * argv[])
{
	LibraryRef liba = openLibrary( "/Users/grady/Library/Developer/Xcode/DerivedData/re-load_lib-edegykelicbvxrduhzourfraoaju/Build/Products/Debug/liba.dylib", NULL );
	LibraryRef libb = openLibrary( "/Users/grady/Library/Developer/Xcode/DerivedData/re-load_lib-edegykelicbvxrduhzourfraoaju/Build/Products/Debug/libb.dylib", NULL );
	
	libTypeFunc a = dlsym(liba , "libFunc");
	if (a) {a();}
	
	libTypeFunc b = dlsym(libb , "libFunc");
	if (b) {b();}
	
	closeLibrary(liba, nil);
	closeLibrary(libb, nil);
	return 0;
}*/

LibraryRef openLibrary(const char * path, NSError ** err)
{
	LibraryRef ref = dlopen(path,  RTLD_LAZY | RTLD_LOCAL);
	
	if (!ref) {
		if (err) {
			char * errStr = dlerror();
			*err = [NSError errorWithDomain:@"re-load lib domain" code:1 userInfo:
					@{@"error string" : [NSString stringWithUTF8String:errStr]}];
		}
	}
	
	return ref;
}
BOOL closeLibrary (LibraryRef libRef, NSError ** err)
{
	if (dlclose(libRef))
	{
		return YES;
	}
	if (err) {
		char * errStr = dlerror();
		*err = [NSError errorWithDomain:@"re-load lib domain" code:1 userInfo:
				@{@"error string" : [NSString stringWithUTF8String:errStr]}];
	}
	return NO;
	
}
WeightedRect rectLocation( double time, NSRect bounds )
{
	WeightedRect r;
	//lets move the rectangle left and right in the middle 1/3 of the view
#define period 10
	double d = time/period;
	long long trunc = d;
	BOOL even = ((trunc %2) == 0);
	double spaceH = bounds.size.width - bounds.size.width/3;
	if (even) {
		//from the left
		r = RectangleMake( 0 +  spaceH * (d - trunc), bounds.size.height/3 , bounds.size.height/3, bounds.size.height/3, (d-trunc) * 10);
	}else{
		//from the right
		r = RectangleMake( spaceH -  spaceH * (d - trunc),bounds.size.height/3, bounds.size.height/3, bounds.size.height/3 ,(d-trunc) * 10);
	}

	return r;
}
