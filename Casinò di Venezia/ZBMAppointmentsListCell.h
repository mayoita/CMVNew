//
//  ZBMAppointmentsListCell.h
//  ZerobaseMobile
//
//  Created by Massimo Moro on 17/06/13.
//  Copyright (c) 2013 Massimo Moro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBMAppointmentsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *HOUR;

@property (nonatomic, weak) IBOutlet UILabel *DDAY;
@property (weak, nonatomic) IBOutlet UIImageView *AppointmentImage;
@property (nonatomic, weak) IBOutlet UILabel *DLDES;
@end
