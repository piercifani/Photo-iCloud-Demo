//
//  PSCloudDelegate.m
//  icloudtest
//
//  Created by Pierluigi Cifani on 3/18/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "PSCloudDelegate.h"
#import "PSPicture.h"
#import "PSFile.h"

static PSCloudDelegate *sharedInstance = nil;

@interface PSCloudDelegate ()
- (void)initSharedInstance;
- (void)setUpQuery;
- (void)appHasGoneInBackground;
- (void)appWillEnterForeground;
- (void)updateUbiquitousDocuments:(NSNotification *)notification;
- (NSURL *) generatePathURL;
- (iCloudState) getFileState:(NSMetadataItem *)item;
@end

@implementation PSCloudDelegate

@synthesize query;
@synthesize documents;

-(void) dealloc
{
    [super dealloc];
    self.query = nil;
    self.documents = nil;
}
- (void)setDelegate:(id<PSCloudProtocol>)aDelegate;
{
    delegate = aDelegate;
}
#pragma mark Singleton Methods
+ (id)sharedDelegate
{ 
    @synchronized(self) {
        if(sharedInstance == nil){
            sharedInstance = [[super allocWithZone:NULL] init];
            [sharedInstance initSharedInstance];
        }
    }
    return sharedInstance;
}
+ (id)allocWithZone:(NSZone *)zone {
    
    return [[self sharedDelegate] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}
- (id) retain {
    
    return self;
}
- (NSUInteger) retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}
- (oneway void) release
{
    //do nothing
}
- (id) autorelease {
    
    return self;
}

- (void)initSharedInstance;
{
    [sharedInstance setUpQuery];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    self.documents = [NSMutableDictionary dictionary];
}

+ (BOOL) checkIfiCloudAvaiable
{
    NSURL *ubiq = [[NSFileManager defaultManager] 
                   URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Query
- (void)setUpQuery
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    NSLog(@"cloudURL %@", cloudURL);
    
    self.query = [[NSMetadataQuery alloc] init];
    query.predicate = [NSPredicate predicateWithFormat:@"%K like '*.pspicture'", NSMetadataItemFSNameKey];
    query.searchScopes = [NSArray arrayWithObject: NSMetadataQueryUbiquitousDocumentsScope];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateUbiquitousDocuments:) 
                                                 name:NSMetadataQueryDidUpdateNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateUbiquitousDocuments:) 
                                                 name:NSMetadataQueryDidFinishGatheringNotification 
                                               object:nil];
    [query startQuery];
    
}
- (void)updateUbiquitousDocuments:(NSNotification *)notification
{
        
    NSLog(@"updated Ubiquitous Documents, results = %@", self.query.results);
    
    NSArray *results = [self.query.results sortedArrayUsingComparator:
                        ^NSComparisonResult(id obj1, id obj2){
                            NSMetadataItem *item1 = obj1;
                            NSMetadataItem *item2 = obj2;
                            return [[item1 valueForAttribute:NSMetadataItemFSContentChangeDateKey] 
                                    compare:[item2 valueForAttribute:NSMetadataItemFSContentChangeDateKey]];
                        }];


    if ([results count] < [documents count]) {
        //Poor algorith to detect that someone erased something
        //We start over if that happens
        NSLog(@"Something got deleted");
        self.documents = [NSMutableDictionary dictionary];
    }
    
    BOOL somethingUpdated = NO;

    for (NSMetadataItem *item in results) {
        
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSString *filename = [url lastPathComponent];
        
        if ([documents objectForKey:filename]) {
            iCloudState itemState = [self getFileState:item];
            PSFile *aFile = [documents objectForKey:filename];
            if (aFile.iState == itemState) {
                NSLog(@"No Change");
            } else {
                NSLog(@"Something Changed State");
                somethingUpdated = YES;
                aFile.iState = itemState;
            }
        }  else {
            NSLog(@"New File!!!");
            PSFile *newFile = [[[PSFile alloc] init] autorelease];
            
            newFile.iState = [self getFileState:item];
            newFile.iURL = url;
            newFile.iFilename = filename;
            newFile.iDate = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
            
            [documents setObject:newFile forKey:filename];
            somethingUpdated = YES;
        }
    }
    if (somethingUpdated) {
        [delegate documentsUpdated];
    }
}

#pragma mark App Lifecycle

-(void) appHasGoneInBackground
{
    [query stopQuery];
}

-(void) appWillEnterForeground
{
    [query startQuery];
}

#pragma mark Utils

- (NSURL *) generatePathURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    NSURL *pathURL = [cloudURL URLByAppendingPathComponent:@"Documents"];
    return pathURL;
}

- (iCloudState) getFileState:(NSMetadataItem *)item;
{

    NSString *isDownloading = [item valueForAttribute:NSMetadataUbiquitousItemIsDownloadingKey];
    if ([isDownloading boolValue]) {
        return EStateDownloading;
    } 
    
    NSString *isUploading = [item valueForAttribute:NSMetadataUbiquitousItemIsUploadingKey];
    if ([isUploading boolValue]) {
        return EStateUploading;
    }

    NSString *isDownloaded = [item valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey];
    NSString *isUploaded = [item valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey];
            
    if ([isDownloaded boolValue] && [isUploaded boolValue]) {
        return EStateReady;
    }

    return EStateUnknown;
}

#pragma mark Interface
- (void) createNewPictureWithName:(NSString *)aName andImage:(UIImage *)aImage
{
    NSURL *cloudURL = [self generatePathURL];
    NSURL *fullPathURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.pspicture", aName]
                                relativeToURL:cloudURL];
    
    PSPicture *newPicture = [[[PSPicture alloc] initWithFileURL:fullPathURL] autorelease];
    newPicture.iPhoto = aImage;
    
    [newPicture saveToURL:[newPicture fileURL] 
         forSaveOperation:UIDocumentSaveForCreating 
        completionHandler:^(BOOL success) {            
            if (success) {

            }
        }];
}

- (void) deleteFile:(NSString *)aName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    PSFile *aFile = [documents objectForKey:aName];
    if ([fileManager removeItemAtURL:aFile.iURL error:nil]) {
        NSLog(@"erased succesfully");
    } else {
        NSLog(@"erased unsuccesfully");
    }
}
- (void) eraseCloudDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *allValues = [documents allValues];
    for (PSFile *aFile in allValues) {
        if ([fileManager removeItemAtURL:aFile.iURL error:nil]) {
            NSLog(@"erased succesfully");
        } else {
            NSLog(@"erased unsuccesfully");
        }
    }
}

@end
