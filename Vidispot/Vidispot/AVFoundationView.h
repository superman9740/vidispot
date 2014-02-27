#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>


@interface AVFoundationView : NSView<NSDraggingDestination>
{
	int nActiveVideo;
	
	NSTimer * videoTimer;
	BOOL bTimerRunning;
	BOOL bTimerInvalidated;
	NSColor * m_clrTimerFontColor;
	NSString * sTimerString;
	
	IBOutlet NSTextField * txtTimer;
	IBOutlet NSButton * btnPreviousFile; 
	IBOutlet NSButton * btnNextFile; 
	IBOutlet NSButton * btnPlay;
    IBOutlet NSButton *replaceBtn;
    IBOutlet NSButton *playBackBtn;
    IBOutlet NSButton *fullScreenBtn;
    
	IBOutlet NSSlider * sldVideoPos;
	IBOutlet NSSlider * sldVolume;
	
	 BOOL highlight;
    
    NSImage* newImage;
    
    
}

@property (nonatomic, strong)  AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, readonly, strong) AVPlayerLayer* playerLayer;



@property ( readwrite, assign ) id parentView;

@property ( readwrite, retain ) NSMutableArray * arrayVideosToPlay;
@property ( nonatomic, retain ) IBOutlet NSView *myPlayerView;

- ( IBAction ) playVideo: ( id ) sendero;
- ( IBAction ) pauseVideo: ( id ) sender;
- ( IBAction ) stopVideo: ( id ) sender;
- ( IBAction ) scrollVideo: ( id ) sender;
- ( IBAction ) changeVolume: ( id ) sender;
- ( IBAction ) setVolume: ( id ) sender;
- ( IBAction ) nextVideo: ( id ) sender;
- ( IBAction ) previousVideo: ( id ) sender;
- ( IBAction ) onBtnSaveNote: ( id ) sender;
- ( IBAction ) replaceButtonClicked :(id)sender;
- ( IBAction ) playBackButtonClicked :(id)sender;
- (IBAction)moveToNextVideo:(id)sender;



- ( void ) updateFromArray: ( NSMutableArray * ) array;
- ( void ) updateTime: ( NSTimer * ) timer;
- ( void ) updatePlayButtonWithState: ( NSInteger ) state;
- ( BOOL ) addFavouriteStatus:(BOOL) isFav;

- ( void ) playVideoWithIndex: ( NSInteger ) nIndex;
- ( void ) playVideoWithName: ( NSString * ) sFilePath;

- ( void ) startTimer;
- ( void ) stopTimer;
- ( void ) adjustFrameSize;

@end