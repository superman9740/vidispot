//
//  QuickTimeView.m
//  Learn Mac OS X 10.6
//
//  Created by Kostya on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AVFoundationView.h"


NSString *kPrivateDragUTI2 = @"com.yourcompany.cocoadraganddrop";


@implementation AVFoundationView



//==============================================================================
- ( void ) awakeFromNib
{
	nActiveVideo = -1;
	
	
	bTimerRunning = NO;
	bTimerInvalidated = YES;
	
	NSFont * font = [ NSFont fontWithName: @"Tahoma" size: 13.0 ];
	[ txtTimer setFont: font ];
	[ txtTimer setTextColor: 
    [ NSColor colorWithCalibratedRed: 58.0 / 255.0 green: 98.0 / 255.0 blue: 225.0 / 255.0 alpha: 1.0 ]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToNextVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    
   [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];
    
    
  }



//==============================================================================
- ( void ) playVideo: ( id ) sender
{

	if(self.player) {
        if( !sender )
        {
            [ btnPlay setState: [ btnPlay state ] == NSOnState ? NSOffState : NSOnState ];
        }

        [ self updatePlayButtonWithState: [ btnPlay state ] ];		

        if( [ btnPlay state ] == NSOffState )
        {
            [ self stopTimer ];
            [ self.player pause];
        }
        else 
        {
            if( self.player == nil )
            {
                [ txtTimer setStringValue: @"00:00:00" ];	
                return;
            }
            
            [ self stopTimer ];
            [ self startTimer ];
            [self.player play];
            
            
            NSString *title = [playBackBtn title];
            if ([title isEqualToString:@"1x"]) {
                [self.player setRate:1.0f];
            }
            else if ([title isEqualToString:@"1.5x"]) {
                [self.player setRate:1.5f];
            }
            else if ([title isEqualToString:@"2x"]){
                [self.player setRate:2.0f];
            }
            else if ([title isEqualToString:@"0.5x"]){
                [self.player setRate:0.5f];
            }
            [self.player setVolume: [ sldVolume floatValue ] / 100.0];
        }
    }
}


//==============================================================================
- ( void ) pauseVideo: ( id ) sender
{
	[ self.player pause ];
}


//==============================================================================
- ( void ) stopVideo: ( id ) sender
{

	if( self.player == nil )
		return;
	
	//	NSLog(@"OnBtnStop 4" );
	if( [ self.player rate ] > 0.0 )
		[ self.player pause ];
	
	if( bTimerRunning )
	{	
		bTimerRunning = NO;
		bTimerInvalidated = YES;
		[ videoTimer invalidate ];
	}	
}


//==============================================================================
- ( void ) scrollVideo: ( id ) sender
{
	float fValue = [ sldVideoPos floatValue ] / 100.0;
	AVPlayerItem *playerItem = [self.player currentItem];
    CMTime fullTime;

    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        
        fullTime =  [[playerItem asset] duration];
    }
    
    
    
    fullTime.value *= fValue;
    fullTime.value -= 10; 			// allow timer to switch video if fValue >= 1.0

    
	
	[ self.player seekToTime: fullTime ];
   
	float playedSoFar = CMTimeGetSeconds([self.player currentTime]);
    float durInMiliSec = 1000.0 * playedSoFar;
	int x = durInMiliSec / 1000;
    x = durInMiliSec / 1000;
    int seconds = x % 60;
    x /= 60;
    int minutes = x % 60;
    x /= 60;
    int hours = x % 24;
    x /= 24;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setMinimumIntegerDigits:2];
    
    NSNumber * numberSeconds = [NSNumber numberWithInt:seconds];
    NSNumber * numberMinutes = [NSNumber numberWithInt:minutes];
    NSNumber * numberHours = [NSNumber numberWithInt:hours];
    
    
    NSString* tempString = [NSString stringWithFormat:@"%@:%@:%@", [numberFormatter stringFromNumber:numberHours], [numberFormatter stringFromNumber:numberMinutes], [numberFormatter stringFromNumber:numberSeconds]];
    sTimerString = tempString;
    
    
    
}


//==============================================================================
- ( void ) setVolume: ( id ) sender
{
	
}



//==============================================================================
- ( IBAction ) changeVolume: ( id ) sender
{
	if( self.player )
		[ self.player setVolume: [ sldVolume floatValue ] / 100.0 ];
}


//==============================================================================



- ( IBAction ) replaceButtonClicked: ( id ) sender{
  
    if(self.player){
    if ([ btnPlay state ] == NSOffState) {
        [self playVideo:nil];
    }
    
    CMTime time = [[[self player] currentItem] currentTime];
    
    long long result;
    
    // timeScale is fps * 100
   
    if (time.timescale > 0) {
        result = time.value / time.timescale; // second
        
        //frame = (time.timeValue % time.timeScale) / 100;
        
        int second = result;
        
        if (second > 30) {
            second = second - 30;
        }
        else{
            
            second = 0;
        }
        
        result = second;
        
        time.value = result*time.timescale;
        
        [ self.player seekToTime: time ];
        
        
        
    }
    }
   
    
    
}



- ( IBAction ) playBackButtonClicked: (id)sender{
    
    if(self.player){
        
        if ([ btnPlay state ] == NSOnState) {
            float rate = [self.player rate];
            NSString *title;
        
            if (rate == 1.000000)
            {
                rate = 1.500000;
                title = @"1.5x";
            }
            else if (rate == 1.500000)
            {
                rate = 2.000000;
                title = @"2x";
            }
            else if (rate == 2.000000)
            {
                rate = 0.500000;
                title = @"0.5x";
            }
            else
            {
                rate = 1.000000;
                title = @"1x";
            }
            
            [playBackBtn setTitle:title];    
            [self.player setRate:rate];
        }
    }
}


//==============================================================================
- ( void ) updateTime: ( NSTimer * ) timer
{
	if( bTimerInvalidated )
		return;
	
	bTimerRunning = YES;
	
	CMTime currentT =  self.player.currentItem.currentTime;
	CMTime fullT = self.player.currentItem.duration;
    
    NSTimeInterval currentTime = CMTimeGetSeconds(currentT);
    NSTimeInterval duration = CMTimeGetSeconds(fullT);
    
    
	
	float playedSoFar = CMTimeGetSeconds([self.player currentTime]);
    float durInMiliSec = 1000.0 * playedSoFar;
	int x = durInMiliSec / 1000;
    x = durInMiliSec / 1000;
    int seconds = x % 60;
    x /= 60;
    int minutes = x % 60;
    x /= 60;
    int hours = x % 24;
    x /= 24;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setMinimumIntegerDigits:2];
    
    NSNumber * numberSeconds = [NSNumber numberWithInt:seconds];
    NSNumber * numberMinutes = [NSNumber numberWithInt:minutes];
    NSNumber * numberHours = [NSNumber numberWithInt:hours];
    
    
    NSString* tempString = [NSString stringWithFormat:@"%@:%@:%@", [numberFormatter stringFromNumber:numberHours], [numberFormatter stringFromNumber:numberMinutes], [numberFormatter stringFromNumber:numberSeconds]];
    sTimerString = tempString;
    
    
	[ txtTimer setStringValue: sTimerString ];
	
	if( duration > 0 )
	{
		float fValue = ( ( float ) currentTime ) / ( ( float ) duration ) * 100.0;
		[ sldVideoPos setFloatValue: fValue ];		
	}
}




//==============================================================================
- ( void ) playVideoWithName: ( NSString * ) sFilePath
{
/*
//	NSLog( @"path to movie = %@", sFilePath );
	
	if ( [[NSFileManager defaultManager] fileExistsAtPath:sFilePath])
	{
		[ globalData.logger writeInformationLogWithString: @"QuickTimeView playVideoWithName - QTMovie canInitWithFile" ];

        
        
        
        NSURL *myMovieURL = [[NSURL alloc] initFileURLWithPath:sFilePath];
        
        
        
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:myMovieURL options:nil];
        
        if(![avAsset isPlayable])
        {
            NSLog(@"Asset cannot be played back.");
      
            return;
        }
        if ([[avAsset tracksWithMediaType:AVMediaTypeVideo] count] == 0)
        {
            NSLog(@"Asset cannot be played back.");
            
            return;
            
        }
            
        NSString *tracksKey = @"tracks";
        
        [avAsset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
         ^{
             
             
             
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                NSError *error;
                                AVKeyValueStatus status = [avAsset statusOfValueForKey:tracksKey error:&error];
                                
                                if (status == AVKeyValueStatusLoaded)
                                {
                                    self.playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
                                    
                                    
                                        [self.playerItem addObserver:self forKeyPath:@"status"
                                                         options:0 context:&ItemStatusContext];
                                    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                                    
                                    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                                    _playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
                                    _playerLayer.hidden = NO;
                                    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                                    
                                   // _playerLayer.videoGravity = AVLayerVideoGravity;
                                    [self setWantsLayer:YES];
                                    _playerLayer.frame = self.layer.bounds;
                                    [self.layer addSublayer:_playerLayer];
                                    
                                    
                                    //[self setLayer:_playerLayer];
                                    //[self.layer addSublayer:_playerLayer];
                                    
                                    
                                    
                                  
                                    CMTime currentTime = self.player.currentTime;
                                    CMTime fullTime = self.player.currentItem.duration;
                                    
                                    [ globalData.logger writeInformationLogWithString:
                                     [ NSString stringWithFormat: @"QuickTimeView updateTime currentTime = %lld, fullTime = %lld",
                                      currentTime.value, fullTime.value
                                      ]
                                     ];
                                    
                                    [ self updatePlayButtonWithState: NSOnState ];
                                    
                                    if( bTimerRunning )
                                    {
                                        bTimerRunning = NO;
                                        bTimerInvalidated = YES;
                                        [ videoTimer invalidate ];
                                    }
                                    
                                    [ txtTimer setStringValue: @"00:00:00" ];
                                    
                                    videoTimer = 
                                    [ NSTimer scheduledTimerWithTimeInterval: 0.5 
                                                                      target: self 
                                                                    selector: @selector( updateTime: ) 
                                                                    userInfo: nil 
                                                                     repeats: YES
                                     ];
                                    bTimerInvalidated = NO;
                                    
                                    if( nActiveVideo == 0 )
                                        [ btnPreviousFile setEnabled: YES ];
                                    else
                                        [ btnPreviousFile setEnabled: YES ];
                                    
                                    if( nActiveVideo == ( [ self.arrayVideosToPlay count ] - 1 ) )
                                        [ btnNextFile setEnabled: YES ];
                                    else
                                        [ btnNextFile setEnabled: YES ];
                                    
                                    [ sldVideoPos setFloatValue: 0.0 ];
                                    [ self.player setVolume: [ sldVolume floatValue ] / 100.0 ];
                                }
                                else {
                                    // You should deal with the error appropriately.
                                    NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                                }
                            });

             
             
             
             
             
         }];
        
	
	}
	else 
	{
		[ globalData.logger writeInformationLogWithString: @"QuickTimeView playVideoWithName - QTMovie can't init with file" ];

 }
 */
    
}


//==============================================================================
- ( void ) startTimer
{

	videoTimer = 
		[ NSTimer scheduledTimerWithTimeInterval: 0.5 
										  target: self 
										selector: @selector( updateTime: ) 
										userInfo: nil 
										 repeats: YES
		 ];
	bTimerInvalidated = NO;
}


//==============================================================================
- ( void ) stopTimer
{

	if( bTimerRunning )
	{	
		bTimerRunning = NO;
		bTimerInvalidated = YES;
		[ videoTimer invalidate ];
	}
}


//==============================================================================
- ( void ) updatePlayButtonWithState: ( NSInteger ) state
{
	if( state == NSOnState )
	{	
		//[ btnPlay setTitle: @"Pause" ];
		[ btnPlay setImage: [ NSImage imageNamed: @"b_pause.png" ] ];
	}
	else 
	{	
		//[ btnPlay setTitle: @"Play" ];
		[ btnPlay setImage: [ NSImage imageNamed: @"b_play.png" ] ];
	}

	[ btnPlay setState: state ];
}


//==============================================================================
- ( void ) windowDidResize: ( NSNotification * ) notification
{
    
    [self adjustFrameSize];
    
    /*
	NSRect buttonRect = [ btnPlay frame ];
    
    
    
     NSRect buttonRect_replace = buttonRect;
    buttonRect_replace.origin.x = frame.origin.x + frame.size.width / 2.0 - buttonRect.size.width * 1.5 -10 - 105;
    [replaceBtn setFrame:buttonRect_replace];
    
    
   
    buttonRect_replace.origin.x = frame.origin.x + frame.size.width / 2.0 - buttonRect.size.width * 1.5 -10 -23-5 - buttonRect_replace.size.width ;
    buttonRect_replace.size.width = 23;
    [fullScreenBtn setFrame:buttonRect];
    
    
	buttonRect.origin.x = frame.origin.x + frame.size.width / 2.0 - buttonRect.size.width * 1.5 - 5;
	[ btnPreviousFile setFrame: buttonRect ];
    
   
	buttonRect.origin.x += buttonRect.size.width + 5;
	[ btnPlay setFrame: buttonRect ];
	buttonRect.origin.x += buttonRect.size.width + 5;
	[ btnNextFile setFrame: buttonRect ];
    
   buttonRect.origin.x += buttonRect.size.width + 5;
    [playBackBtn setFrame:buttonRect];
    
    
     
    
   */ 
}

-(void)adjustFrameSize{
    
	NSRect frame = [ self frame ];
	
    NSRect playerFrame = [_myPlayerView frame];
    CGFloat widthDiff = frame.size.width - playerFrame.size.width;
    
    //    if (widthDiff >= 250) {
    //        playerFrame.origin.x = widthDiff/2;
    //    }
    //    else{
    
    playerFrame.origin.x = (widthDiff - 120)/2;
    //   }
    
    
    if (playerFrame.origin.x < 0) {
        playerFrame.origin.x = 0;
    }
    [_myPlayerView setFrame:playerFrame];
    
}
#pragma mark drag and drop
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag enters our drop zone
     --------------------------------------------------------*/
    
    // Check if the pasteboard contains image data and source/user wants it copied
    if ( [NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] &
        NSDragOperationCopy ) {
        
        //highlight our drop zone
        highlight=YES;
        
        [self setNeedsDisplay: YES];
        
        /* When an image from one window is dragged over another, we want to resize the dragging item to
         * preview the size of the image as it would appear if the user dropped it in. */
        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent
                                          forView:self
                                          classes:[NSArray arrayWithObject:[NSPasteboardItem class]]
                                    searchOptions:nil
                                       usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                           
                                           /* Only resize a fragging item if it originated from one of our windows.  To do this,
                                            * we declare a custom UTI that will only be assigned to dragging items we created.  Here
                                            * we check if the dragging item can represent our custom UTI.  If it can't we stop. */
                                           if ( ![[[draggingItem item] types] containsObject:kPrivateDragUTI2] ) {
                                               
                                               *stop = YES;
                                               
                                           } else {
                                               /* In order for the dragging item to actually resize, we have to reset its contents.
                                                * The frame is going to be the destination view's bounds.  (Coordinates are local
                                                * to the destination view here).
                                                * For the contents, we'll grab the old contents and use those again.  If you wanted
                                                * to perform other modifications in addition to the resize you could do that here. */
                                               //[draggingItem setDraggingFrame:self.bounds contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
                                           }
                                       }];
        
        //accept data as a copy operation
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag exits our drop zone
     --------------------------------------------------------*/
    //remove highlight of the drop zone
    highlight=NO;
    
    [self setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)rect
{
    /*------------------------------------------------------
     draw method is overridden to do drop highlighing
     --------------------------------------------------------*/
    //do the usual draw operation to display the image
    [super drawRect:rect];
    
    if ( highlight ) {
        //highlight by overlaying a gray border
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: rect];
   }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method to determine if we can accept the drop
     --------------------------------------------------------*/
    //finished with the drag so remove any highlighting
    highlight=NO;
    
    [self setNeedsDisplay: YES];
    
    //check to see if we can accept the data
    return [NSImage canInitWithPasteboard: [sender draggingPasteboard]];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method that should handle the drop data
     --------------------------------------------------------*/
    if ( [sender draggingSource] != self ) {
        NSURL* fileURL;
        
        //set the image using the best representation we can get from the pasteboard
        if([NSImage canInitWithPasteboard: [sender draggingPasteboard]]) {
            newImage = [[NSImage alloc] initWithPasteboard: [sender draggingPasteboard]];
        }
        
        //if the drag comes from a file, set the window title to the filename
        fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
        [[self window] setTitle: fileURL!=NULL ? [fileURL absoluteString] : @"(no name)"];
    }
    CGSize size = CGSizeMake(480, 640);
    [self writeImagesToMovieAtPath:@"/tmp/movie.mov" withSize:size];
    
    return YES;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame;
{
    /*------------------------------------------------------
     delegate operation to set the standard window frame
     --------------------------------------------------------*/
    //get window frame size
    NSRect ContentRect=self.window.frame;
    
    //set it to the image frame size
//    ContentRect.size=[[self image] size];
    
    return [NSWindow frameRectForContentRect:ContentRect styleMask: [window styleMask]];
};




#pragma mark Generate movie from images
-(void)writeImagesToMovieAtPath:(NSString*)path withSize:(CGSize)size
{
    NSLog(@"Write Started");
    
    NSError*error=nil;
    
    AVAssetWriter*videoWriter=[[AVAssetWriter alloc]initWithURL:
                               [NSURL fileURLWithPath:path]fileType:AVFileTypeQuickTimeMovie
                                                         error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:480], AVVideoWidthKey,
                                   [NSNumber numberWithInt:640], AVVideoHeightKey,
                                   nil];

    
    AVAssetWriterInput* videoWriterInput=[AVAssetWriterInput
                                          assetWriterInputWithMediaType:AVMediaTypeVideo
                                          outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor*adaptor=[AVAssetWriterInputPixelBufferAdaptor
                                                  assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                  sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime=YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer=NULL;
    
    //convert uiimage to CGImage.
    
    int frameCount=0;
    NSArray* imageArray = [[NSArray alloc] initWithObjects:newImage, nil];
    
    
    
    for (NSImage* image in imageArray)
    {
        NSImage* resizedImage = [self imageResize:image newSize:size];
        
        buffer=[self pixelBufferFromCGImage:[resizedImage CGImageForProposedRect:nil context:nil hints:nil] andSize:size];
        
        BOOL append_ok=NO;
        int j =0;
        while(!append_ok && j < 30)
        {
            if(adaptor.assetWriterInput.readyForMoreMediaData)
            {
                printf("appending %d attemp %d\n",frameCount,j);
                
                CMTime frameTime= CMTimeMake(frameCount,24);
                append_ok=[adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                
                if(buffer)
                    CVBufferRelease(buffer);
                [NSThread sleepForTimeInterval:0.05];
            }
            else
            {
                printf("adaptor not ready %d, %d\n",frameCount,j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if(!append_ok){
            printf("error appending image %d times %d\n",frameCount,j);
        }
        frameCount++;
    }


//Finish the session:
[videoWriterInput markAsFinished ];
[videoWriter finishWriting];
NSLog(@"Write Ended");

}



-(CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image andSize:(CGSize)size
{
    NSDictionary*options=[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                          [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,
                          nil];
    CVPixelBufferRef pxbuffer=NULL;
    
    CVReturn status=CVPixelBufferCreate(kCFAllocatorDefault,size.width,
                                       size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef)options,
                                       &pxbuffer);
    NSParameterAssert(status==kCVReturnSuccess&&pxbuffer!=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    void*pxdata=CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata!=NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context=CGBitmapContextCreate(pxdata,size.width,
                                              size.height,8,4*size.width,rgbColorSpace,
                                              kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context,CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),
                                          CGImageGetHeight(image)),image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
    
}

- (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
    NSImage *sourceImage = anImage;
    [sourceImage setScalesWhenResized:YES];
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid])
    {
        NSLog(@"Invalid Image");
    } else
    {
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}

@end
