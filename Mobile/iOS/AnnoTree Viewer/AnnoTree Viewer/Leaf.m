//
//  Leaf.m
//  AnnoTree Viewer
//
//  Created by Mike on 9/2/13.
//  Copyright (c) 2013 AnnoTree. All rights reserved.
//

#import <AnnoTree/AnnoTree.h>
#import "ScreenShotUtil.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation Leaf

@synthesize leafName;
@synthesize leafUploading;

AnnoTree* annoTree;
NSString* boundary = @"-";

- (id)init:(NSString*)leafName annotree:(NSObject*)annotree{
    DDLogVerbose(@"Attempting to create Leaf %@", leafName);
        self = [super init];
        if(self){
            NSString *leafNameTrimmed = [leafName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.leafName = leafNameTrimmed;
            annoTree = (AnnoTree *)annotree;
            leafUploading = [[UIAlertView alloc] initWithTitle:@"Uploading"
                                                       message:@""
                                                      delegate:annoTree
                                             cancelButtonTitle: nil //NSLocalizedString(@"Cancel",nil)
                                             otherButtonTitles: nil
            ];

        }
        return self;
    }

+ (void) addRequestParm:(NSMutableData *)body :(NSString *)property :(NSString *)value {
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", property] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSMutableURLRequest*) createRequest{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    return request;
}

- (void)sendLeaf{	

    // create request
    NSMutableURLRequest *request = [Leaf createRequest];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    [Leaf addRequestParm:body :@"token" : annoTree.activeTree];
    [Leaf addRequestParm:body :@"leafName" :self.leafName];
    
    [Leaf addRequestParm:body :@"metaSystem" :[[UIDevice currentDevice] systemName]];
    [Leaf addRequestParm:body :@"metaVersion" :[[UIDevice currentDevice] systemVersion]];
    [Leaf addRequestParm:body :@"metaModel" :[[UIDevice currentDevice] model]];
    [Leaf addRequestParm:body :@"metaSystem" :[[UIDevice currentDevice] systemName]];
    [Leaf addRequestParm:body :@"metaSystem" :[[UIDevice currentDevice] systemName]];
    [Leaf addRequestParm:body :@"metaVendor" : @"Apple"];
    
    NSString *orientation = @"";
    if([[UIDevice currentDevice] orientation] == 0) orientation = @"portrait";
    else orientation = @"landscape";
    [Leaf addRequestParm:body :@"metaOrientation" : orientation];
    
    // add image data
    
    [annoTree.view endEditing:YES];
    [annoTree.shareView.view endEditing:YES];
    [annoTree.annoTreeToolbar setAlpha:0];
    DDLogVerbose(@"PreScreenshot");
    UIImage *image = [ScreenShotUtil screenshot];

    DDLogVerbose(@"PostScreenshot");
    UIImage *finalImage;
    UIImage *rotateImage;
    UIInterfaceOrientation curOrient = annoTree.shareView.interfaceOrientation;
    if(curOrient == UIInterfaceOrientationLandscapeLeft) {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight];
    } else if(curOrient == UIInterfaceOrientationLandscapeRight) {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationLeft];
    } else if(curOrient == UIInterfaceOrientationPortraitUpsideDown) {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationDown];
    } else {
        finalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationUp];
    }
    UIGraphicsEndImageContext();
    rotateImage = [ScreenShotUtil scaleAndRotateImage:finalImage];
    UIGraphicsEndImageContext();
    
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);


    DDLogVerbose(@"ImageData");
    NSData * imageData = UIImagePNGRepresentation(rotateImage);
    //[data writeToFile:@"foo.png" atomically:YES];
    
    NSString* FileParamConstant = @"annotation";
    //NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"screenshot.png\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        //TODO:Some sort of error
        DDLogError(@"Error taking ScreenShot");
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    //TODO:Move this
    NSURL *requestURL = [NSURL URLWithString:@"https://dev.annotree.com/services/ios/leaf"];
    [request setURL:requestURL];

    DDLogVerbose(@"Connection");
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //TODO:Fix this.
    //
    if( connection )
    {
        //TODO:something
    }else{
        //TODO:some sort of error
    }
    
    [annoTree.annoTreeToolbar setAlpha:1];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [leafUploading show];
        
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Fail..
    DDLogError(@"error.code:%d error.description:%@", error.code, error.description);
    [leafUploading dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *leafNameError = [[UIAlertView alloc] initWithTitle:@"Leaf Failed To Upload"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok",nil)
                                                  otherButtonTitles: nil
    ];


    [leafNameError show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Request performed.
    //NSLog(@"success");
    [leafUploading dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *leafNameSuccess = [[UIAlertView alloc] initWithTitle:@"Leaf Uploaded"
                                                              message:@""
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Ok",nil)
                                                    otherButtonTitles: nil
    ];


    [leafNameSuccess show];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Request performed.
    //NSLog(@"response");
    //NSLog([response textEncodingName]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Request performed.
    //NSLog(@"data recieved");
    //NSLog(data);
    //NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(responseBody);
}




@end
