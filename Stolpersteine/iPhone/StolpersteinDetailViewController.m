//
//  DetailViewController.m
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinDetailViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>

#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteineListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CopyableImageView.h"

#define PADDING 20

@interface StolpersteinDetailViewController()

@property (strong, nonatomic) CopyableImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *streetButton;
@property (strong, nonatomic) UIButton *mapsButton;

@end

@implementation StolpersteinDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.stolperstein.title;

    // Image
    self.imageView = [[CopyableImageView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];

    UIEdgeInsets frameEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    UIImage *frameImage = [[UIImage imageNamed:@"image-frame.png"] resizableImageWithCapInsets:frameEdgeInsets];
    UIImageView *frameImageView = [[UIImageView alloc] initWithImage:frameImage];
    frameImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.imageView addSubview:frameImageView];
    
    self.imageActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.imageActivityIndicator.hidesWhenStopped = TRUE;
    [self.imageView addSubview:self.imageActivityIndicator];
    
    // Address
    NSMutableString *address = [NSMutableString stringWithCapacity:20];
    
    if (self.stolperstein.locationStreet) {
        [address appendString:self.stolperstein.locationStreet];
    }
    
    if (self.stolperstein.locationZipCode || self.stolperstein.locationCity) {
        [address appendString:@"\n"];
        
        if (self.stolperstein.locationZipCode) {
            [address appendFormat:@"%@", self.stolperstein.locationZipCode];
        }
        if (self.stolperstein.locationCity) {
            [address appendFormat:@" %@", self.stolperstein.locationCity];
        }
    }
    NSAttributedString *addressText = [[NSAttributedString alloc] initWithString:address];
    self.addressLabel = [[UILabel alloc] init];
    self.addressLabel.attributedText = addressText;
    self.addressLabel.numberOfLines = INT_MAX;
    [self.scrollView addSubview:self.addressLabel];
    
    // Street button
    self.streetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *streetButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.street", nil);
    self.streetButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.streetButton setTitle:streetButtonTitle forState:UIControlStateNormal];
    [self.streetButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.streetButton addTarget:self action:@selector(showAllInThisStreet:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.streetButton];

    // Maps button
    self.mapsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *mapsButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.maps", nil);
    self.mapsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.mapsButton setTitle:mapsButtonTitle forState:UIControlStateNormal];
    [self.mapsButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.mapsButton addTarget:self action:@selector(showInMapsApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.mapsButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.stolperstein.imageURLString && !self.imageView.image) {
        [self loadImageWithURLString:self.stolperstein.imageURLString];
    }
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.imageView cancelImageRequestOperation];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setImageActivityIndicator:nil];
    [self setScrollView:nil];

    [super viewDidUnload];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.stolperstein.imageURLString forKey:@"stolperstein.imageURLString"];
    [coder encodeObject:self.title forKey:@"title"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *imageURLString = [coder decodeObjectForKey:@"stolperstein.imageURLString"];
    if (imageURLString) {
        [self loadImageWithURLString:imageURLString];
    }
    self.title = [coder decodeObjectForKey:@"title"];
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)loadImageWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    [self.imageActivityIndicator startAnimating];
    
    __weak StolpersteinDetailViewController *weakSelf = self;
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.imageView.image = image;
        [weakSelf.imageActivityIndicator stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf.imageActivityIndicator stopAnimating];
    }];
}

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat height = PADDING;
    
    // Image
    self.imageView.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, screenWidth - 2 * PADDING);
    CGRect imageActivityIndicatorFrame = self.imageActivityIndicator.frame;
    imageActivityIndicatorFrame.origin.x = (self.imageView.frame.size.width - self.imageActivityIndicator.frame.size.width) * 0.5;
    imageActivityIndicatorFrame.origin.y = (self.imageView.frame.size.height - self.imageActivityIndicator.frame.size.height) * 0.5;
    self.imageActivityIndicator.frame = imageActivityIndicatorFrame;
    height += self.imageView.frame.size.height + PADDING * 0.5;
    
    // Address
    CGRect addressFrame;
    addressFrame.origin.x = PADDING;
    addressFrame.origin.y = height;
    addressFrame.size = [self.addressLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    self.addressLabel.frame = addressFrame;
    height += addressFrame.size.height + PADDING * 0.5;

    // Street button
    if (!self.isAllInThisStreetButtonHidden) {
        self.streetButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
        height += self.streetButton.frame.size.height + PADDING * 0.5;
    }
    
    // Maps button
    self.mapsButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
    height += self.mapsButton.frame.size.height + PADDING * 0.5;
    
    // Scroll view
    height += PADDING * 0.5;
    self.scrollView.contentSize = CGSizeMake(screenWidth, height);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    NSMutableArray *itemsToShare = [NSMutableArray arrayWithObject:self.title];
    if (self.imageView.image) {
        [itemsToShare addObject:self.imageView.image];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)showAllInThisStreet:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"stolpersteinDetailViewControllerToStolpersteineListViewController" sender:self];
}

- (void)showInMapsApp:(UIButton *)sender
{
    // Create an MKMapItem to pass to the Maps app
    CLLocationCoordinate2D coordinate = self.stolperstein.locationCoordinates.coordinate;
    NSDictionary *addressDictionary = @{
        (NSString *)kABPersonAddressStreetKey : self.stolperstein.locationStreet,
        (NSString *)kABPersonAddressCityKey : self.stolperstein.locationCity,
        (NSString *)kABPersonAddressZIPKey : self.stolperstein.locationZipCode
    };
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.stolperstein.title;
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"stolpersteinDetailViewControllerToStolpersteineListViewController"]) {
        StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
        searchData.locationStreet = self.stolperstein.locationStreetName;
        StolpersteineListViewController *listViewController = (StolpersteineListViewController *)segue.destinationViewController;
        listViewController.searchData = searchData;
        listViewController.title = searchData.locationStreet;
    }
}

@end