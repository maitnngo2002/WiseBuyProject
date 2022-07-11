//
//  RegisterViewController.m
//  WiseBuy
//
//  Created by Mai Ngo on 7/5/22.
//

#import "RegisterViewController.h"
#import "User.h"
#import "DatabaseManager.h"
#import "AlertManager.h"

@interface RegisterViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@end

@implementation RegisterViewController

- (IBAction)onTapRegister:(id)sender {
    [self registerUser];
}
- (IBAction)onTapImage:(id)sender {
    [self chooseImage];
}

- (void)registerUser {
    if ([self inputFieldsAreEmpty]) {
        [AlertManager loginAlert:LoginErrorMissingInput errorString:nil viewController:self];
        return;
    }
    if ([self inputFieldsContainSpacesOrNewLines]) {
        [AlertManager loginAlert:InputValidationError errorString:nil viewController:self];
        return;
    }
    User *newUser = [[User alloc] init];
    newUser.firstName = self.firstNameField.text;
    newUser.lastName = self.lastNameField.text;
    newUser.email = self.emailField.text;
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.profileImage = UIImagePNGRepresentation(self.profileImage.image);
    
    [DatabaseManager registerUser:newUser withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self performSegueWithIdentifier:@"registerSegue" sender:nil];
            [self resetFields];
        }
        else {
            [AlertManager loginAlert:ServerError errorString:error.localizedDescription viewController:self];
        }
    }];}

- (void)resetFields {
    self.firstNameField.text = @"";
    self.lastNameField.text = @"";
    self.usernameField.text = @"";
    self.passwordField.text = @"";
    self.emailField.text = @"";
    self.profileImage.image = [UIImage imageNamed: @""];
}

-(BOOL) inputFieldsAreEmpty {
    return [self.firstNameField.text isEqual:@""]  || [self.lastNameField.text isEqual:@""]  || [self.emailField.text isEqual:@""] || [self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""];
}

-(BOOL)inputFieldsContainSpacesOrNewLines {
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *newLineSet = [NSCharacterSet newlineCharacterSet];
    return [[self.firstNameField.text stringByTrimmingCharactersInSet:charSet] length] < [self.usernameField.text length] || [[self.usernameField.text stringByTrimmingCharactersInSet:charSet] length] < [self.passwordField.text length]   || [[self.passwordField.text stringByTrimmingCharactersInSet:charSet] length] < [self.firstNameField.text length] || [[self.emailField.text stringByTrimmingCharactersInSet:charSet] length] < [self.emailField.text length]         || [[self.lastNameField.text stringByTrimmingCharactersInSet:newLineSet] length] < [self.lastNameField.text length];
}

-(void)chooseImage{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    [self updateProfileImage: originalImage ?: editedImage];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateProfileImage:(UIImage *)image {
    CGSize size = CGSizeMake(400, 400);
    self.profileImage.image = [self resizeImage:image withSize:size];
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.cornerRadius = self.profileImage.layer.bounds.size.width / 2;
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
