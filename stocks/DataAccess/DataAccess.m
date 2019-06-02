//  DataAccess.m
// Copyright (c) 2019 Jerry Hale
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


#import "DictionaryKey.h"

#import "CHCSVParser.h"
#import "DataAccess.h"

@implementation AFIBClient

+(instancetype)sharedClient
{
    static AFIBClient		*sharedClient = nil;
    static dispatch_once_t	onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AFIBClient alloc] initWithBaseURL:[NSURL URLWithString:[DataAccess URL_IB_BORROW_LIST]]];

		sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
		sharedClient.responseSerializer
								= [AFHTTPResponseSerializer serializer];
		[sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });

    return (sharedClient);
}
@end

@implementation AFCormyaClient

+(instancetype)sharedClient
{
    static AFCormyaClient		*sharedClient = nil;
    static dispatch_once_t	onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AFCormyaClient alloc] initWithBaseURL:[NSURL URLWithString:[DataAccess URL_BASE]]];

		sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
		sharedClient.responseSerializer
								= [AFHTTPResponseSerializer serializer];
		[sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });

    return (sharedClient);
}
@end

@implementation DataAccess

#pragma mark -

+(NSString *)URL_IB_BORROW_LIST
{
    static dispatch_once_t once;
    static NSString	*URL_IB_BORROW_LIST;
    dispatch_once(&once, ^{
        URL_IB_BORROW_LIST = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_IB_BORROW_LIST"];
    });
    return (URL_IB_BORROW_LIST);
}

-(void)getIB_BorrowList:(NSString *)fileName completion:(void (^)(NSArray *array, NSError *error))block
{
	NSMutableString	*url = [NSMutableString stringWithString:[DataAccess URL_IB_BORROW_LIST]];

	[url appendString:@"/"];
	[url appendString:fileName];

	[[AFIBClient sharedClient] GET:url
				parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id responseObject)
	{
		NSString	*csvString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
	
		if (csvString == nil)
		{
			block([NSArray array], nil);
			return;
		}

		CHCSVParser	*parser = [[CHCSVParser alloc]initWithDelimitedString:csvString delimiter:'|'];

		//	parser.delegate = self;

		CHCSVAggregator *aggregator = [[CHCSVAggregator alloc] init];

		parser.delegate = aggregator;

		[parser parse];

		if (block) block(aggregator.lines, nil);
	}
	 
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		if (block) block([NSArray array], error);
	}];
}

+(NSString *)URL_BASE
{
    static dispatch_once_t once;
    static NSString	*URL_BASE;
    dispatch_once(&once, ^{
        URL_BASE = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_BASE"];
    });
    return (URL_BASE);
}

+(NSString *)URL_FUNC_OHLC
{
    static dispatch_once_t once;
    static NSString	*URL_FUNC_OHLC;
    dispatch_once(&once, ^{
        URL_FUNC_OHLC = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_FUNC_OHLC"];
    });
    return (URL_FUNC_OHLC);
}

+(NSString *)URL_FUNC_DAILY
{
    static dispatch_once_t once;
    static NSString	*URL_FUNC_DAILY;
    dispatch_once(&once, ^{
        URL_FUNC_DAILY = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_FUNC_DAILY"];
    });
    return (URL_FUNC_DAILY);
}

+(NSString *)URL_SYMBOL
{
    static dispatch_once_t once;
    static NSString	*URL_SYMBOL;
    dispatch_once(&once, ^{
        URL_SYMBOL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"URL_SYMBOL"];
    });
    return (URL_SYMBOL);
}

//	https://cormya.com/query?function=OHLC&symbol=MSFT
-(void)getOHLCData:(NSString *)symbol
		completion:(void (^)(NSDictionary *dict, NSError *error))block
{
	NSMutableString	*url = [NSMutableString stringWithString:[DataAccess URL_FUNC_OHLC]];

	[url appendString:[DataAccess URL_SYMBOL]];
	[url appendString:symbol];

	[[AFCormyaClient sharedClient] GET:url
				parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id responseObject)
	{
		NSError			*error = nil;
		NSDictionary	*dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
		
		if (block) block(dict, error);
	}
	 
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		if (block) block(nil, error);
	}];
}

-(void)getDailyData:(NSString *)symbol
		completion:(void (^)(NSDictionary *dict, NSError *error))block
{
	NSMutableString	*url = [NSMutableString stringWithString:[DataAccess URL_FUNC_DAILY]];

	[url appendString:[DataAccess URL_SYMBOL]];
	[url appendString:symbol];

	[[AFCormyaClient sharedClient] GET:url
				parameters:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id responseObject)
	{
		NSError			*error = nil;
		NSDictionary	*dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
		
		if (block) block(dict, error);
	}
	 
	failure:^(NSURLSessionDataTask *__unused task, NSError *error)
	{
		if (block) block(nil, error);
	}];
}

@end

