//
//  NoteKeyButton.m
//  iOS MIDI Demo
//
//  Created by Michal Czwarnowski on 15.04.2016.
//  Copyright © 2016 Michał Czwarnowski. All rights reserved.
//

#import "NoteKeyButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation NoteKeyButton

- (void)awakeFromNib {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3.0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:185.0/255.0 alpha:1.0];
    } else {
        if (self.tag == 61 || self.tag == 63 || self.tag == 66 || self.tag == 68 || self.tag == 70) {
            self.backgroundColor = [UIColor blackColor];
        } else {
            self.backgroundColor = [UIColor whiteColor];
        }
    }
}

@end
