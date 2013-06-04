//
//  Rectangle.h
//  rectangleSizer
//
//  Created by grady player on 5/30/13.
//  Copyright (c) 2013 Objectively Better, LLC. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#ifndef rectangleSizer_Rectangle_h
#define rectangleSizer_Rectangle_h




typedef struct{
	float x;
	float y;
	float w;
	float h;
	float weight;
} WeightedRect;

static inline WeightedRect RectangleMake(float x, float y, float w, float h, float weight)
{
	WeightedRect rect;
	rect.x = x;
	rect.y = y;
	rect.w = w;
	rect.h = h;
	rect.weight = weight;
	return rect;
}

#endif
