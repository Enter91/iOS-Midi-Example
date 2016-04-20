//
//  MIDI.h
//  iOS MIDI Demo
//
//  Created by Michal Czwarnowski on 15.04.2016.
//  Copyright © 2016 Michał Czwarnowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIDI : NSObject

@property (assign, nonatomic) BOOL isSessionActive;

- (instancetype)initWithIP:(NSString *)IP port:(NSString *)port;

- (BOOL)createMIDIConnection;
- (void)disposeMIDIConnection;

- (void)sendNoteOnEvent:(Byte)key velocity:(Byte)velocity;
- (void)sendNoteOffEvent:(Byte)key velocity:(Byte)velocity;
- (void)sendEvent:(Byte)event value:(Byte)value;

@end
