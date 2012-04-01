//
//  PSFile.m
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/31/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "PSFile.h"

@implementation PSFile
@synthesize iURL, iFilename, iDate, iState;

-(void) dealloc
{
    self.iURL = nil;
    self.iFilename = nil;
    self.iDate = nil;
    [super dealloc];
}
@end
