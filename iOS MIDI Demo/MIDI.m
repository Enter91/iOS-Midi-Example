//
//  MIDI.m
//  iOS MIDI Demo
//
//  Created by Michal Czwarnowski on 15.04.2016.
//  Copyright © 2016 Michał Czwarnowski. All rights reserved.
//

#import "MIDI.h"
#import <CoreMIDI/CoreMIDI.h>

@interface MIDI ()

@property (copy, nonatomic) NSString *ip;
@property (copy, nonatomic) NSString *port;

@property (strong, nonatomic) MIDINetworkHost *host;
@property (strong, nonatomic) MIDINetworkConnection *connection;
@property (strong, nonatomic) MIDINetworkSession *midiSession;
@property (assign, nonatomic) MIDIEndpointRef destinationEndpoint;
@property (assign, nonatomic) MIDIClientRef client;
@property (assign, nonatomic) MIDIPortRef outputPort;

@end

@implementation MIDI

- (instancetype)initWithIP:(NSString *)IP port:(NSString *)port {
    self = [super init];
    if (self) {
        self.ip = IP;
        self.port = self.port;
    }
    return self;
}

- (BOOL)createMIDIConnection {
    self.host = [MIDINetworkHost hostWithName:@"iPad MIDI WiFi" address:self.ip port:self.port.integerValue];
    if(!self.host) {
        return NO;
    }
    
    self.connection = [MIDINetworkConnection connectionWithHost:self.host];
    if(!self.connection) {
        return NO;
    }
    
    self.midiSession = [MIDINetworkSession defaultSession];
    if (self.midiSession) {
        if (![self.midiSession addConnection:self.connection]) {
            [self disposeMIDIConnection];
            return NO;
        }
        self.midiSession.enabled = YES;
        self.destinationEndpoint = [self.midiSession destinationEndpoint];
        
        OSStatus status = 0;
        MIDIClientRef client = 0;
        MIDIPortRef outport = 0;
        status = MIDIClientCreate(CFSTR("iPad MIDI WiFi Client"), NULL, NULL, &client);
        if (status != noErr) {
            [self disposeMIDIConnection];
            return NO;
        }
        status = MIDIOutputPortCreate(client, CFSTR("iPad MIDI WiFi Output port"), &outport);
        if (status != noErr) {
            [self disposeMIDIConnection];
            return NO;
        }
        
        self.client = client;
        self.outputPort = outport;
        
        self.isSessionActive = YES;
        return YES;
    }
    
    return NO;
}

- (void)disposeMIDIConnection {
    self.isSessionActive = NO;
    self.client = 0;
    self.outputPort = 0;
    self.midiSession.enabled = NO;
    [self.midiSession removeConnection:self.connection];
    self.connection = nil;
    self.midiSession = nil;
}

- (void)sendStatus:(Byte)status data1:(Byte)data1 data2:(Byte)data2 {
    MIDIPacketList packetList;
    packetList.numPackets = 1;
    packetList.packet[0].length = 3;
    packetList.packet[0].data[0] = status;
    packetList.packet[0].data[1] = data1;
    packetList.packet[0].data[2] = data2;
    packetList.packet[0].timeStamp = 0;
    
    MIDISend(self.outputPort, self.destinationEndpoint, &packetList);
}

- (void)sendNoteOnEvent:(Byte)key velocity:(Byte)velocity {
    [self sendStatus:0x90 data1:key & 0x7F data2:velocity & 0x7F];
}

- (void)sendNoteOffEvent:(Byte)key velocity:(Byte)velocity {
    [self sendStatus:0x80 data1:key & 0x7F data2:velocity & 0x7F];
}

- (void)sendEvent:(Byte)event value:(Byte)value {
    [self sendStatus:0xB0 data1:event & 0x7F data2:value & 0x7F];
}

- (void)logMIDIDevicesProperties {
    NSDictionary *midiProperties;
    CFPropertyListRef midiPropertyListRef;
    
    for (ItemCount i = 0; i<MIDIGetNumberOfDevices(); ++i) {
        MIDIDeviceRef device = MIDIGetDevice(i);
        
        MIDIObjectGetProperties(device, &midiPropertyListRef, YES);
        midiProperties = (NSDictionary *)CFBridgingRelease(midiPropertyListRef);
        
        NSLog(@"MIDI DEVICE: %@", midiProperties);
    }
}


- (void)dealloc {
    [self disposeMIDIConnection];
}

@end
