//
//  CSampleHTTPHandler.m
//  TouchHTTP
//
//  Created by Jonathan Wight on 03/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CSampleHTTPHandler.h"

#import "CRoutingHTTPConnection.h"
#import "CHTTPMessage.h"
#import "CHTTPMessage_ConvenienceExtensions.h"
#import "CQTCaptureSnapshot.h"

@implementation CSampleHTTPHandler

@synthesize snapshot;

- (id)init
{
if ((self = [super init]) != NULL)
	{
	self.snapshot = [[CQTCaptureSnapshot alloc] init];
	}
return(self);
}

- (void)dealloc
{
self.snapshot = NULL;
//
[super dealloc];
}

- (CTCPConnection *)TCPServer:(CTCPServer *)inServer createTCPConnectionWithAddress:(NSData *)inAddress inputStream:(NSInputStream *)inInputStream outputStream:(NSOutputStream *)inOutputStream;
{
CRoutingHTTPConnection *theConnection = [[[CRoutingHTTPConnection alloc] initWithTCPServer:inServer address:inAddress inputStream:inInputStream outputStream:inOutputStream] autorelease];
theConnection.router = self;
return(theConnection);
}

- (BOOL)routeConnection:(CRoutingHTTPConnection *)inConnection request:(CHTTPMessage *)inRequest toTarget:(id *)outTarget selector:(SEL *)outSelector error:(NSError **)outError;
{
#pragma unused (inConnection, inRequest, outTarget, outSelector, outError)
NSURL *theURL = [inRequest requestURL];

*outTarget = self;

if ([[theURL path] isEqualToString:@"/favicon.ico"])
	*outSelector = @selector(favIconResponseForRequest:error:);
else
	*outSelector = @selector(webcamResponseForRequest:error:);

return(YES);
}

- (CHTTPMessage *)favIconResponseForRequest:(CHTTPMessage *)inRequest error:(NSError **)outError
{
#pragma unused (inRequest, outError)
CHTTPMessage *theResponse = [CHTTPMessage HTTPMessageResponseWithStatusCode:200 statusDescription:@"OK" httpVersion:kHTTPVersion1_0];

NSData *theBodyData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:@"/Users/schwa/Pictures/Icons/schwa.png"]];
[theResponse setContentType:@"image/png" body:theBodyData];
return(theResponse);
}

- (CHTTPMessage *)webcamResponseForRequest:(CHTTPMessage *)inRequest error:(NSError **)outError
{
#pragma unused (inRequest, outError)
CHTTPMessage *theResponse = [CHTTPMessage HTTPMessageResponseWithStatusCode:200 statusDescription:@"OK" httpVersion:kHTTPVersion1_0];
NSData *theBodyData = self.snapshot.jpegData;
[theResponse setContentType:@"image/jpeg" body:theBodyData];
return(theResponse);
}

@end