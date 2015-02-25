//
//  MySignUpViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MySignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CMVLogInFieldsBGThree.h"


@interface MySignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@property(strong,nonatomic)UIImageView *line;
@property(strong,nonatomic)UIImageView *line2;
@property(strong,nonatomic)UILabel *divietoiPAD;
@property(strong, nonatomic)CMVLogInFieldsBGThree *myBG;
@property(strong, nonatomic)UIImageView *ombraTop;
@property(strong, nonatomic)UIImageView *ombraBottom;
@end

@implementation MySignUpViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iPHONE ) {
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
        [self.signUpView.usernameField setValue:[NSNumber numberWithInt:0] forKey:@"separatorStyle"];
        [self.signUpView.passwordField setValue:[NSNumber numberWithInt:0] forKey:@"separatorStyle"];
        [self.signUpView.emailField setValue:[NSNumber numberWithInt:0] forKey:@"separatorStyle"];
   
    
        [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LogInImage.png"]]];
        [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"CloseButtonRaster.png"] forState:UIControlStateNormal];
        [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"CloseButtonRaster.png"] forState:UIControlStateHighlighted];
        
        UIImage *myGradient = [UIImage imageNamed:@"LogInColorPattern"];
        [self.signUpView.signUpButton setTitleColor:[UIColor colorWithPatternImage:myGradient] forState:UIControlStateNormal];
        
        self.myBG = [[CMVLogInFieldsBGThree alloc] init];
        self.myBG.backgroundColor = [UIColor clearColor];
        self.myBG.alpha = 0.3f;
        [self.signUpView addSubview:self.myBG];
        [self.signUpView sendSubviewToBack:self.myBG];
  
        
        self.ombraTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ombra.png"]];
        [self.view addSubview:self.ombraTop];
        
        self.ombraBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ombra.png"]];
        [self.view addSubview:self.ombraBottom];

        [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CasinoLabel.png"]]];

    

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIView *defaultFieldsBackground = [[self.signUpView subviews] objectAtIndex:4];
    defaultFieldsBackground.hidden=YES;
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignUpLogInBK.png"] forState:UIControlStateNormal];
    
    self.myBG.frame = CGRectMake(self.view.center.x-250/2, 160, 250, 118);
    if (iPHONE) {
        [self.signUpView.dismissButton setFrame:CGRectMake(5.0f, 27.0f,22.0f, 22.0f)];
    } else {
        [self.signUpView.dismissButton setFrame:CGRectMake(10.0f, 20.0f,22.0f, 22.0f)];
    }
       self.signUpView.signUpButton.titleLabel.font = GOTHAM_XLight(20);
        
        [self.signUpView.usernameField setFrame:CGRectMake(self.view.center.x-250/2, 155.0f, 250.0f, 50.0f)];
        self.signUpView.usernameField.font = GOTHAM_BOOK(12);
        self.signUpView.usernameField.textColor =[UIColor whiteColor];
        self.signUpView.usernameField.backgroundColor = [UIColor clearColor];
        self.signUpView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"USERNAME", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [self.signUpView.passwordField setFrame:CGRectMake(self.view.center.x-250/2, 196.0f, 250.0f, 50.0f)];
        self.signUpView.passwordField.font = GOTHAM_BOOK(12);
        self.signUpView.passwordField.textColor =[UIColor whiteColor];
        self.signUpView.passwordField.backgroundColor = [UIColor clearColor];
        self.signUpView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PASSWORD", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [self.signUpView.emailField setFrame:CGRectMake(self.view.center.x-250/2, 236.0f, 250.0f, 50.0f)];
        self.signUpView.emailField.font = GOTHAM_BOOK(12);
        self.signUpView.emailField.textColor =[UIColor whiteColor];
        self.signUpView.emailField.backgroundColor = [UIColor clearColor];
        self.signUpView.emailField.hidden = YES;
        self.signUpView.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EMAIL", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        self.signUpView.emailField.hidden = NO;
       
        [self.fieldsBackground setFrame:CGRectMake(self.view.center.x-250/2, 145.0f, 250.0f, 100.0f)];
        
        self.ombraTop.frame = CGRectMake(self.view.center.x-300/2, 135, 300, 4);
        self.ombraBottom.frame = CGRectMake(self.view.center.x-300/2, 300, 300, 4);

        
        if (self.signUpView.bounds.size.height > 480.0f) {
            [self.signUpView.logo setFrame:CGRectMake(self.view.center.x-270/2, 85.0f, 270.0f, 28.0f)];
            [self.signUpView.signUpButton setFrame:CGRectMake(self.view.center.x-250/2, 475.0f, 250.0f, 40.0f)];
        
        
        } else {
            
            [self.signUpView.signUpButton setFrame:CGRectMake(self.view.center.x-250/2, 420.0f, 250.0f, 40.0f)];
            [self.signUpView.logo setFrame:CGRectMake(self.view.center.x-270/2, 85.0f, 270.0f, 28.0f)];
        }



}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
