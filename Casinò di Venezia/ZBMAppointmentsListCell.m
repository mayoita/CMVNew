//
//  ZBMAppointmentsListCell.m
//  ZerobaseMobile
//
//  Created by Massimo Moro on 17/06/13.
//  Copyright (c) 2013 Massimo Moro. All rights reserved.
//

#import "ZBMAppointmentsListCell.h"

@implementation ZBMAppointmentsListCell
@synthesize DDAY,DLDES, HOUR, AppointmentImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
