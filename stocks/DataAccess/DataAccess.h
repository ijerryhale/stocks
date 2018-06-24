//  DataAccess.h
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

#import "AFNetworking/AFNetworking.h"

@interface AFIBClient : AFHTTPSessionManager

+(instancetype)sharedClient;

@end

@interface AFCormyaClient : AFHTTPSessionManager

+(instancetype)sharedClient;

@end

@interface DataAccess : NSObject

@property (strong) NSManagedObjectContext   *managedObjectContext;

+(NSString *)URL_IB_BORROW_LIST;

-(void)getIB_BorrowList:(NSString *)fileName completion:(void (^)(NSArray *csvtable, NSError *error))block;

+(NSString *)URL_BASE;

+(NSString *)URL_FUNC_OHLC;
+(NSString *)URL_FUNC_DAILY;
+(NSString *)URL_SYMBOL;

-(void)getOHLCData:(NSString *)symbol
		completion:(void (^)(NSDictionary *dict, NSError *error))block;
		
-(void)getDailyData:(NSString *)symbol
		completion:(void (^)(NSDictionary *dict, NSError *error))block;



@end
