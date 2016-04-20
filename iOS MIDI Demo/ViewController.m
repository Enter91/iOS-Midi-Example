//
//  ViewController.m
//  iOS MIDI Demo
//
//  Created by Michal Czwarnowski on 15.04.2016.
//  Copyright © 2016 Michał Czwarnowski. All rights reserved.
//

#import "ViewController.h"
#import "MIDI.h"
#import "MHRotaryKnob.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIImageView *adsrImageView;
@property (weak, nonatomic) IBOutlet MHRotaryKnob *attackView;
@property (weak, nonatomic) IBOutlet MHRotaryKnob *decayView;
@property (weak, nonatomic) IBOutlet MHRotaryKnob *sustainView;
@property (weak, nonatomic) IBOutlet MHRotaryKnob *releaseView;
@property (strong, nonatomic) MIDI *midi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    
    [self setupKnob:self.attackView];
    [self setupKnob:self.decayView];
    [self setupKnob:self.sustainView];
    [self setupKnob:self.releaseView];
    
    [self.attackView addTarget:self action:@selector(attack:) forControlEvents:UIControlEventValueChanged];
    [self.decayView addTarget:self action:@selector(decay:) forControlEvents:UIControlEventValueChanged];
    [self.sustainView addTarget:self action:@selector(sustain:) forControlEvents:UIControlEventValueChanged];
    [self.releaseView addTarget:self action:@selector(release:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)connectAction:(id)sender {
    if (!self.ipTextField.text || !self.portTextField.text) {
        return;
    }
    
    if (!self.midi) {
        self.midi = [[MIDI alloc] initWithIP:self.ipTextField.text port:self.portTextField.text];
    }
    
    if (self.midi.isSessionActive) {
        [self.midi disposeMIDIConnection];
        self.midi = nil;
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    } else {
        BOOL success = [self.midi createMIDIConnection];
        if (success) {
            [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)noteOn:(id)sender {
    if (self.midi.isSessionActive) {
        [sender setSelected:YES];
        [self.midi sendNoteOnEvent:(Byte)[sender tag] velocity:(Byte)127];
    }
}

- (IBAction)noteOff:(id)sender {
    if (self.midi.isSessionActive) {
        [sender setSelected:NO];
        [self.midi sendNoteOffEvent:(Byte)[sender tag] velocity:(Byte)127];
    }
}

- (void)attack:(id)sender {
    if (self.midi.isSessionActive) {
        int rotaryValue = (int)[(MHRotaryKnob *)sender value];
        [self.midi sendEvent:(Byte)73 value:(Byte)rotaryValue];
    }
}

- (void)decay:(id)sender {
    if (self.midi.isSessionActive) {
        int rotaryValue = (int)[(MHRotaryKnob *)sender value];
        [self.midi sendEvent:(Byte)75 value:(Byte)rotaryValue];
    }
}

- (void)sustain:(id)sender {
    if (self.midi.isSessionActive) {
        int rotaryValue = (int)[(MHRotaryKnob *)sender value];
        [self.midi sendEvent:(Byte)70 value:(Byte)rotaryValue];
    }
}

- (void)release:(id)sender {
    if (self.midi.isSessionActive) {
        int rotaryValue = (int)[(MHRotaryKnob *)sender value];
        [self.midi sendEvent:(Byte)72 value:(Byte)rotaryValue];
    }
}

- (IBAction)touchDragEnter:(id)sender {
    if (self.midi.isSessionActive) {
        [sender setSelected:YES];
        [self.midi sendNoteOnEvent:(Byte)[sender tag] velocity:(Byte)127];
    }
}

- (IBAction)touchUpInside:(id)sender {
    if (self.midi.isSessionActive) {
        [sender setSelected:NO];
        [self.midi sendNoteOffEvent:(Byte)[sender tag] velocity:(Byte)127];
    }
}

- (void)setupKnob:(MHRotaryKnob *)knob {
    knob.minimumValue = 0;
    knob.maximumValue = 127;
    knob.defaultValue = 64;
    knob.interactionStyle = MHRotaryKnobInteractionStyleRotating;
    knob.backgroundColor = [UIColor clearColor];
    knob.backgroundImage = [UIImage imageNamed:@"Knob Background"];
    [knob setKnobImage:[UIImage imageNamed:@"Knob"] forState:UIControlStateNormal];
    [knob setKnobImage:[UIImage imageNamed:@"Knob Highlighted"] forState:UIControlStateHighlighted];
    [knob setKnobImage:[UIImage imageNamed:@"Knob Disabled"] forState:UIControlStateDisabled];
    knob.knobImageCenter = CGPointMake(CGRectGetWidth(knob.frame)/2, CGRectGetHeight(knob.frame)/2);
}

@end