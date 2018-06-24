//  DictionaryKey.m
// Copyright (c) 2018 Jerry Hale
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
//  Created by Jerry Hale on 5/14/18.

#import <Foundation/Foundation.h>

#import "DictionaryKey.h"

//	theme colors
//	blue theme color
#define	THEME_COLOR_BLUE		0x76D6FF
#define	THEME_ALPHA_BLUE		0.8

//	sky theme color
#define	THEME_COLOR_SKY			0x73FDFF
#define	THEME_ALPHA_SKY			0.12

//	aluminum theme color
#define	THEME_COLOR_ALUMINUM	0xA9A9A9
#define	THEME_ALPHA_ALUMINUM	0.6
//
//	cherry theme color
#define	THEME_COLOR_CHERRY		0xFF2600
#define	THEME_ALPHA_CHERRY		0.3

//	lime theme color
#define	THEME_COLOR_LIME			0xCBFFD4
#define	THEME_ALPHA_LIME			0.9

NSUInteger THEME_COLOR = THEME_COLOR_BLUE;
float ALPHA_VALUE = THEME_ALPHA_BLUE;

NSString * const KEY_OPEN = @"open";
NSString * const KEY_HIGH = @"high";
NSString * const KEY_LOW = @"low";
NSString * const KEY_CLOSE = @"close";
NSString * const KEY_VOLUME = @"volume";

NSString * const VALUE_ROW_CELL = @"RowCell";
