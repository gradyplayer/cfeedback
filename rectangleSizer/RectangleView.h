//
//  RectangleView.h
//  rectangleSizer
//
//  Created by grady player on 5/30/13.
//  Copyright (c) 2013 Objectively Better, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RectangleView : NSView
{
	IBOutlet NSTextView * codeTextView;
}

-(IBAction) updateCode:(id)sender;

@end

