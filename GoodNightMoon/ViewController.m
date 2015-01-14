//
//  ViewController.m
//  GoodNightMoon
//
//  Created by Johnny Appleseed on 1/13/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "ViewController.h"
#import "ImageCollectionViewCell.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollisionBehaviorDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *moonImagesArray;
@property NSMutableArray *sunImagesArray;
@property NSMutableArray *currentImagesArray;

@property (weak, nonatomic) IBOutlet UIView *shadeView;

@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;
@property (strong, nonatomic) UIDynamicItemBehavior *dynamicItemBehavior;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.moonImagesArray = [[NSMutableArray alloc] init];
    self.sunImagesArray = [[NSMutableArray alloc] init];

    for (int i = 1; i < 7; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"moon_%i", i];
        [self.moonImagesArray addObject:[UIImage imageNamed:imageName]];
    }

    for (int i = 1; i < 7; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"sun_%i", i];
        [self.sunImagesArray addObject:[UIImage imageNamed:imageName]];
    }

    self.currentImagesArray = self.moonImagesArray;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView]];
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView]];
    self.dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView]];
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView] mode:UIPushBehaviorModeContinuous];

    [self.collisionBehavior addBoundaryWithIdentifier:@"bottom"
                                            fromPoint:CGPointMake(0, self.view.frame.size.height)
                                              toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height)];

    [self.collisionBehavior addBoundaryWithIdentifier:@"top"
                                            fromPoint:CGPointMake(0, -self.view.frame.size.height + 80)
                                              toPoint:CGPointMake(self.view.frame.size.width, -self.view.frame.size.height + 80)];

    [self.gravityBehavior setGravityDirection:CGVectorMake(0, 0)];  // no gravity when the view loads

    [self.dynamicItemBehavior setElasticity:0.25];   // for bouncing off the boundaries
    
    [self.dynamicAnimator addBehavior:self.collisionBehavior];
    [self.dynamicAnimator addBehavior:self.gravityBehavior];
    [self.dynamicAnimator addBehavior:self.pushBehavior];
    [self.dynamicAnimator addBehavior:self.dynamicItemBehavior];

    self.collisionBehavior.collisionDelegate = self;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.moonImagesArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = [self.currentImagesArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)point
{
    NSString *theIdent = (NSString *)identifier;
    if ([theIdent isEqualToString:@"bottom"])
    {
        self.currentImagesArray = self.sunImagesArray;
    }
    else
    {
        self.currentImagesArray = self.moonImagesArray;
    }
    [self.collectionView reloadData];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)gesture
{
    //Get the translation (or position in coordinates) of the gesture
    CGPoint translation = [gesture translationInView:gesture.view];

    gesture.view.center = CGPointMake(gesture.view.center.x, gesture.view.center.y + translation.y);
    NSLog(@"%f, %f", translation.x, translation.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];

    //
    CGFloat yVelocity = [gesture velocityInView:gesture.view].y;  // get the y velocity

    if (gesture.state == UIGestureRecognizerStateEnded) {

        [_dynamicAnimator updateItemUsingCurrentState:self.shadeView];

        if (yVelocity < -500.0) {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, -1)];
            [self.dynamicItemBehavior setElasticity:0.5];
            [self.pushBehavior setPushDirection:CGVectorMake(0, [gesture velocityInView:gesture.view].y)];
        }
        else if (yVelocity >= -500.0 && yVelocity < 0) {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, -1)];
            [self.dynamicItemBehavior setElasticity:0.25];
            [self.pushBehavior setPushDirection:CGVectorMake(0, -500.0)];
        }
        else if (yVelocity >= 0 && yVelocity < 500.0) {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, 1)];
            [self.dynamicItemBehavior setElasticity:0.25];
            [self.pushBehavior setPushDirection:CGVectorMake(0, 500.0)];
        } else {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, 1)];
            [self.dynamicItemBehavior setElasticity:0.5];
            [self.pushBehavior setPushDirection:CGVectorMake(0, [gesture velocityInView:gesture.view].y)];
        }
    }
}
@end
