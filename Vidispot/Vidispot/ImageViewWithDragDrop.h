//
//  ImageViewWithDragDrop.h
//  Vidispot
//
//  Created by sdickson on 2/19/14.
//
//

#import <Cocoa/Cocoa.h>

@interface ImageViewWithDragDrop : NSImageView<NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
{
    
    
    
}


- (id)initWithCoder:(NSCoder *)coder;


@end
@protocol DragDropImageViewDelegate <NSObject>

- (void)dropComplete:(NSString *)filePath;

@end
