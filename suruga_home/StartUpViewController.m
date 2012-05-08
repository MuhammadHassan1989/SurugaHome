//
//  StartUpViewController.m
//  suruga_home
//
//  Created by Ted Tomlinson on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StartUpViewController.h"
#import "suruga_homeAppDelegate.h"
#import "extThree20JSON/SBJson.h"
#import "Category.h"
#import "Task.h"
#import "BudgetItem.h"
#import "HomeBudgetItem.h"
#import "Room.h"
#import "Furniture.h"
#import "TextFieldPickerView.h"

@implementation StartUpViewController
@synthesize nameTextField;
@synthesize reasonTextField;
@synthesize layoutTextField;
@synthesize sizeTextField;
@synthesize scrollView;
@synthesize userData;

//TODO - update user data for bedroom/bathroom preference

#pragma mark - PRIVATE FUNCTIONS
bool isNew = YES;
- (void)buildStaticData
{
   NSString *filePath = [[NSBundle mainBundle] pathForResource:@"introData" ofType:@"json"];
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *results = [fileContent JSONValue];
	
    //Tasks
	NSArray *categories = [results objectForKey:@"categories"];
    for (NSDictionary *category in categories) {
        Category *c =(Category*) [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.userData.managedObjectContext];
        
        c.order = [NSNumber numberWithInt:[[category objectForKey:@"order"] intValue]];
        c.name = [category objectForKey:@"name"];
        NSArray *tasks = [category objectForKey:@"tasks"];
        for (NSDictionary *task in tasks) {
            Task *t =(Task*) [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.userData.managedObjectContext];
            
            t.name = [task objectForKey:@"name"];
            t.advisorUrl = [task objectForKey:@"advisor_url"];
            t.order = [NSNumber numberWithInt:[[task objectForKey:@"order"] intValue]];
            t.category = c;
        }
    }
    
    //Budget Items
    NSArray *budgetItems = [results objectForKey:@"budget_items"];
    for (NSDictionary *item in budgetItems) {
        BudgetItem *b =(BudgetItem*) [NSEntityDescription insertNewObjectForEntityForName:@"BudgetItem" inManagedObjectContext:self.userData.managedObjectContext];
        
        b.name = [item objectForKey:@"name"];
        b.advisorUrl = [item objectForKey:@"advisor_url"];
        b.notes = [item objectForKey:@"notes"]; 
        b.amount = [NSNumber numberWithInt:[[item objectForKey:@"amount"] intValue]];
        b.isExpense = [NSNumber numberWithInt:[[item objectForKey:@"isExpense"] intValue]];
        b.inInitialBudget = [NSNumber numberWithInt:[[item objectForKey:@"inInitialBudget"] intValue]];
        b.isRenting = [NSNumber numberWithInt:[[item objectForKey:@"isRenting"] intValue]];
    }
    // Home Budget Items
    NSArray *homeBudgetItems = [results objectForKey:@"home_budget_items"];
    for (NSDictionary *item in homeBudgetItems) {
        HomeBudgetItem *b =(HomeBudgetItem*) [NSEntityDescription insertNewObjectForEntityForName:@"HomeBudgetItem" inManagedObjectContext:self.userData.managedObjectContext];
        
        b.name = [item objectForKey:@"name"];
        b.advisorUrl = [item objectForKey:@"advisor_url"];
        b.notes = [item objectForKey:@"notes"];
        b.amount = [NSNumber numberWithInt:[[item objectForKey:@"amount"] intValue]];
        //b.home = nil;
        b.inInitialBudget = [NSNumber numberWithInt:[[item objectForKey:@"inInitialBudget"] intValue]];
        b.isRenting = [NSNumber numberWithInt:[[item objectForKey:@"isRenting"] intValue]];
    }
    
    //Rooms
    //Tasks
	NSArray *rooms = [results objectForKey:@"rooms"];
    for (NSDictionary *room in rooms) {
        Room *r =(Room*) [NSEntityDescription insertNewObjectForEntityForName:@"Room" inManagedObjectContext:self.userData.managedObjectContext];
        //TODO - add in room icons
        r.name = [room objectForKey:@"name"];
        r.type = [room objectForKey:@"type"];
        NSArray *furniture = [room objectForKey:@"furniture"];
        for (NSDictionary *item in furniture) {
            Furniture *f =(Furniture*) [NSEntityDescription insertNewObjectForEntityForName:@"Furniture" inManagedObjectContext:self.userData.managedObjectContext];
            
            f.name = [item objectForKey:@"name"];
            f.type = [item objectForKey:@"type"];
            f.price = [NSNumber numberWithInt:[[item objectForKey:@"price"] intValue]];
            f.room = r;
        }
    }
    //Homes
}

#pragma mark - PRIVATE FUNCTIONS
- (void)keyBoardReasonPicker 
{
    NSArray *options = [NSArray arrayWithObjects:
                            NSLocalizedString(@"Marriage", @"marriage reason picker choice"),
                            NSLocalizedString(@"Birth of a Child",@"child reason picker choice"),
                            NSLocalizedString(@"Job Change",@"Job change reason picker choice"),
                            NSLocalizedString(@"Current Room is small",@"small room reason picker choice"),
                            NSLocalizedString(@"University",@"University Reason Picker Choice"),
                            NSLocalizedString(@"Independence",@"Independence Reason picker choice"),
                            nil];
    [[[TextFieldPickerView alloc] initWithTextField:reasonTextField options:options useNewButton:YES] autorelease];

}
- (void)keyBoardLayoutPicker 
{
    NSArray *options = [NSArray arrayWithObjects:
                              [NSArray arrayWithObjects:
                                NSLocalizedString(@"0 Baths", @"0 Baths"),
                                NSLocalizedString(@"1 Baths", @"1 Baths"),
                                NSLocalizedString(@"2 Baths", @"2 Baths"),
                                NSLocalizedString(@"3 Baths", @"3 Baths"),
                                  nil],
                              [NSArray arrayWithObjects:
                               NSLocalizedString(@"0 Bedrooms", @"0 Bedrooms"),
                               NSLocalizedString(@"1 Bedrooms", @"1 Bedrooms"),
                               NSLocalizedString(@"2 Bedrooms", @"2 Bedrooms"),
                               NSLocalizedString(@"3 Bedrooms", @"3 Bedrooms"),
                               nil], 
                            nil];
    [[[TextFieldPickerView alloc] initWithTextField:layoutTextField options:options useNewButton:NO] autorelease];
}
- (void)keyBoardSizePicker 
{
    NSArray *options = [NSArray arrayWithObjects:
                        NSLocalizedString(@"1 person", @"1 person"),
                        NSLocalizedString(@"2 people",@"2 people"),
                        NSLocalizedString(@"3 people",@"3 people"),
                        NSLocalizedString(@"4 people",@"4 people"),
                        NSLocalizedString(@"5 people",@"5 people"),
                        NSLocalizedString(@"6 people",@"6 people"),
                        NSLocalizedString(@"7 people",@"7 people"),
                        NSLocalizedString(@"8 people",@"8 people"),
                        NSLocalizedString(@"9 people",@"9 people"),
                        NSLocalizedString(@"10 people",@"10 people"),
                        nil];
    [[[TextFieldPickerView alloc] initWithTextField:sizeTextField options:options useNewButton:NO] autorelease];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Setup date keyboard view
    [self keyBoardReasonPicker];
    [self keyBoardLayoutPicker];
    [self keyBoardSizePicker];
    
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 1300);
    
    //Register for keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(keyboardWillBeHidden:)
     name:UIKeyboardWillHideNotification object:nil];
    
    if (self.userData == nil) {
        self.userData = [UserData fetchUserDataWithContext:[(suruga_homeAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]];
        
    }
    if (self.userData.name != nil) {
        //Fill in values
        nameTextField.text = userData.name;
        reasonTextField.text = userData.reason;
        layoutTextField.text = [NSString stringWithFormat:@"%d Baths, %d Bedrooms", [userData.numBaths intValue], [userData.numBeds intValue]];
        sizeTextField.text = [userData.numPeople stringValue];
        isNew = NO;
    }
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setReasonTextField:nil];
    [self setScrollView:nil];
    [self setLayoutTextField:nil];
    [self setSizeTextField:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)registerButtonClicked:(id)sender {
    //TODO - animate flip over to tab bar view
    if ((nameTextField.text.length > 0 &&
        reasonTextField.text.length > 0)) {
        //Set field values
        self.userData.name = nameTextField.text;
        self.userData.reason = reasonTextField.text;
        
        if (isNew) {
            [self buildStaticData];
        }

        NSError *error;
        if (![self.userData.managedObjectContext save:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        // Animate the transition
        suruga_homeAppDelegate *delegate = (suruga_homeAppDelegate *) [[UIApplication sharedApplication] delegate];
        [UIView transitionWithView:delegate.window duration:0.8 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            delegate.window.rootViewController = [TTNavigator navigator].rootViewController;
           [[TTNavigator navigator] openURLAction: [[TTURLAction actionWithURLPath:@"suruga://tabbar"] applyAnimated:YES]];
            //delegate.window.rootViewController = delegate.tabBarController;
        } completion:nil];
    }
    else {
        //TODO pop up a text box asking for validation
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Incomplete Registration", @"Home View validation alert dialog title") 
        message:NSLocalizedString(@"You must fill in User data", @"Home View validation alert dialog")
            delegate:nil 
        cancelButtonTitle:NSLocalizedString(@"OK", @"dialog OK text")
            otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
- (void)dealloc {
    [nameTextField release];
    [reasonTextField release];
    [scrollView release];
    [layoutTextField release];
    [sizeTextField release];
    
    [super dealloc];
}

#pragma mark - Keyboard events

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, CGPointMake(activeField.frame.origin.x, activeField.frame.origin.y + activeField.frame.size.height))) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height + 100);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}
#pragma mark -

@end
