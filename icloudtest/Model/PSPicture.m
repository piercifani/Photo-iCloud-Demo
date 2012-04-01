//
//  PSPicture.m
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/16/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "PSPicture.h"

@implementation PSPicture
@synthesize iPhoto;

-(void)dealloc
{
    NSLog(@"PSPicture dealloc");
    self.iPhoto = nil;
    [super dealloc];
}

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName 
                   error:(NSError **)outError
{
    if ([contents length] > 0)
    {
        iPhoto = [[UIImage alloc] initWithData:contents];    
    }

    return YES;    
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError 
{
    return UIImagePNGRepresentation(self.iPhoto);
}

@end
