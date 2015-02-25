//
//  MyLogInViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MyLogInViewController.h"
#import "CMVLogInFieldsBG.h"
#import <QuartzCore/QuartzCore.h>


@interface MyLogInViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@property(strong,nonatomic)UIImageView *line;
@property(strong,nonatomic)UIImageView *line2;
@property(strong,nonatomic)UILabel *divietoiPAD;
@property(strong, nonatomic)CMVLogInFieldsBG *myBG;
@property(strong,nonatomic)UIImageView *myBackgroundView;
@property(strong, nonatomic)UIImageView *ombraTop;
@property(strong, nonatomic)UIImageView *ombraBottom;
@property(strong, nonatomic)CMVLogInFieldsBG *fieldsBG;
@end

@implementation MyLogInViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBasic];
}
-(void)setBasic {
    
    // Set buttons appearance
        [self.logInView.dismissButton setImage:[UIImage imageNamed:@"CloseButtonRaster.png"] forState:UIControlStateNormal];
        [self.logInView.dismissButton setImage:[UIImage imageNamed:@"CloseButtonRaster.png"] forState:UIControlStateHighlighted];
    
    
        //http://stackoverflow.com/questions/27648499/parse-com-pfloginview-uitextfield-display-issue-cant-remove-border
        [self.logInView.usernameField setValue:[NSNumber numberWithInt:0] forKey:@"separatorStyle"];
        [self.logInView.passwordField setValue:[NSNumber numberWithInt:0] forKey:@"separatorStyle"];
    
   
        [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LogInImage.png"]]];
        [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.logInView.passwordForgottenButton setTitle:NSLocalizedString(@"FORGOT?", nil) forState:UIControlStateNormal];
        self.logInView.passwordForgottenButton.titleLabel.minimumScaleFactor=0.5;
        self.logInView.passwordForgottenButton.titleLabel.adjustsFontSizeToFitWidth=YES;
        [self.logInView.passwordForgottenButton.titleLabel setFont:GOTHAM_Medium(10)];
    
     if (iPHONE) {
        UILabel *diciotto =[[UILabel alloc] init];
        diciotto.text= @"18+";
        diciotto.textColor = [UIColor whiteColor];
        diciotto.frame=CGRectMake(27, 26, 30, 21);
        [self.view addSubview:diciotto];
        
        UILabel *divieto =[[UILabel alloc] init];
        divieto.text= NSLocalizedString(@"UNDER 18 ARE NOT ALLOWED TO GAMBLE. GAMBLING CAN BE PATHOLOGICALLY ADDICTIVE.", nil);
        divieto.font = GOTHAM_Medium(7);
        divieto.numberOfLines = 0;
        divieto.minimumScaleFactor = 0.5f;
        divieto.frame=CGRectMake(61, 26, 240, 21);
        divieto.adjustsFontSizeToFitWidth = YES;
        divieto.textColor = [UIColor whiteColor];
        [self.view addSubview:divieto];
     }
    
        [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        
        
        self.fieldsBG = [[CMVLogInFieldsBG alloc] init];
        self.fieldsBG.backgroundColor = [UIColor clearColor];
        self.fieldsBG.alpha = 0.3f;

        [self.logInView addSubview:self.fieldsBG];
        [self.logInView sendSubviewToBack:self.fieldsBG];
        
        self.ombraTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ombra.png"]];
        [self.logInView addSubview:self.ombraTop];

        
        self.ombraBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ombra.png"]];;
        self.line =self.ombraBottom;
        [self.logInView addSubview:self.ombraBottom];

        
        [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CasinoLabel.png"]]];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIView *defaultFieldsBackground = [[self.logInView subviews] objectAtIndex:5];
    defaultFieldsBackground.hidden=YES;
    
    self.logInView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"USERNAME", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.logInView.usernameField.backgroundColor = [UIColor clearColor];
    self.logInView.usernameField.borderStyle = UITextBorderStyleNone;
    self.logInView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PASSWORD", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.logInView.passwordField.backgroundColor = [UIColor clearColor];
    
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"SignUpLogInBK.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignUpLogInBK.png"] forState:UIControlStateNormal];


    if (iPHONE) {
        [self.logInView.dismissButton setFrame:CGRectMake(5.0f, 27.0f,22.0f, 22.0f)];
    } else {
         [self.logInView.dismissButton setFrame:CGRectMake(10.0f, 20.0f,22.0f, 22.0f)];
    }
        self.logInView.facebookButton.titleLabel.font = [UIFont systemFontOfSize:14];
        self.fieldsBG.frame = CGRectMake(self.view.center.x-250/2, 160, 250, 80);
        UIImage *myGradient = [UIImage imageNamed:@"LogInColorPattern"];
        [self.logInView.logInButton setTitleColor:[UIColor colorWithPatternImage:myGradient] forState:UIControlStateNormal];
        [self.logInView.signUpButton setTitleColor:[UIColor colorWithPatternImage:myGradient] forState:UIControlStateNormal];
        self.logInView.logInButton.titleLabel.font = GOTHAM_XLight(20);
        self.logInView.signUpButton.titleLabel.font = GOTHAM_XLight(20);
        self.logInView.signUpButton.hidden = false;
    self.logInView.passwordForgottenButton.hidden = false;
    
        [self.logInView.usernameField setFrame:CGRectMake(self.view.center.x-250/2, 155.0f, 250.0f, 50.0f)];
        //[self.logInView.usernameField setCenter:CGPointMake(self.view.center.x,155.0f)];
        self.logInView.usernameField.font = GOTHAM_BOOK(14);
        self.logInView.usernameField.textColor =[UIColor whiteColor];
        
        [self.logInView.passwordField setFrame:CGRectMake(self.view.center.x-250/2, 196.0f, 250.0f, 50.0f)];
        self.logInView.passwordField.font = GOTHAM_BOOK(14);
        self.logInView.passwordField.textColor =[UIColor whiteColor];
        
        [self.logInView.logInButton setFrame:CGRectMake(self.view.center.x-250/2, 250.0f, 250.0f, 40.0f)];
        self.logInView.logInButton.layer.cornerRadius = 2;
        
        [self.fieldsBackground setFrame:CGRectMake(self.view.center.x-250/2, 145.0f, 250.0f, 100.0f)];;

        [self.ombraTop setFrame:CGRectMake(self.view.center.x-300/2, 135, 300, 4)];
        
        
        [self.logInView.passwordForgottenButton setFrame:CGRectMake(self.view.center.x-160/2, 300.0f, 160.0f, 20.0f)];
     
        if (self.logInView.bounds.size.height > 480.0f) {
            self.line.frame = CGRectOffset(self.line.frame, 0, 30);
            [self.logInView.logo setFrame:CGRectMake(self.view.center.x-270/2, 85.0f, 270.0f, 28.0f)];
            [self.logInView.facebookButton setFrame:CGRectMake(self.view.center.x-125, 383.0f, 120.0f, 40.0f)];
            [self.logInView.twitterButton setFrame:CGRectMake(self.view.center.x-125+130.0f, 383.0f, 120.0f, 40.0f)];
            [self.logInView.signUpButton setFrame:CGRectMake(self.view.center.x-250/2, 475.0f, 250.0f, 40.0f)];
            [self.ombraBottom setFrame:CGRectMake(self.view.center.x-300/2, 300, 300, 4)];

          
        } else {

            [self.logInView.logo setFrame:CGRectMake(self.view.center.x-270/2, 85.0f, 270.0f, 28.0f)];
            [self.logInView.facebookButton setFrame:CGRectMake(self.view.center.x-125, 330.0f, 120.0f, 40.0f)];
            [self.logInView.twitterButton setFrame:CGRectMake(self.view.center.x-125+130.0f, 330.0f, 120.0f, 40.0f)];
            [self.logInView.signUpButton setFrame:CGRectMake(self.view.center.x-250/2, 420.0f, 250.0f, 40.0f)];
            [self.ombraBottom setFrame:CGRectMake(self.view.center.x-300/2, 300, 300, 4)];
        }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
