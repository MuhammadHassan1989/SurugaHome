//
//  OneBoxTableViewController.m
//  DubbleWrapper
//
//  Created by Glen Urban on 6/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BudgetTableViewController.h"

@implementation BudgetTableViewController

@synthesize costItems, incomeItems,managedObjectContext, isInitial;
@synthesize doneButton;


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [self.tableView reloadData]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.tableView.editing = NO;
	
	if (self.isInitial) {
        self.title=NSLocalizedString(@"Fixed Costs",@"Initial Budget List Title");
    } else {
        self.title = self.title=NSLocalizedString(@"Monthly Budget ",@"Running Budget List Title");
    }
	//add a button
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //Done button
    self.doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    
    //Initialize data arrays
    self.costItems = [NSMutableArray arrayWithArray: [BudgetItem fetchBudgetItemsWithContext:managedObjectContext inInitial:isInitial isExpense:YES]];
    self.incomeItems = [NSMutableArray arrayWithArray: [BudgetItem fetchBudgetItemsWithContext:managedObjectContext inInitial:isInitial isExpense:NO]];
}
#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.costItems = nil;
    self.incomeItems = nil;
    self.managedObjectContext = nil;
}

#pragma mark -

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.costItems.count + 1;
    } else {
        return self.incomeItems.count + 1;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section{
	if(section == 1){
        if (self.isInitial)
            return NSLocalizedString(@"Allocated Costs US \n Except new home costs", @"Budget List Fixed Costs Header section text");
        else
            return NSLocalizedString(@"Expenses US$/Month \n Except new home costs.", @"Budget List Expenses Header section text");
	}
	else{
        if (self.isInitial)
            return NSLocalizedString(@"Savings US $", @"Budget List Savings Header section text");
        else
            return NSLocalizedString(@"Income US$/Month", @"Budget List Income Header section text");
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 && indexPath.row == incomeItems.count) ||
        (indexPath.section == 1 && indexPath.row == costItems.count)) {
        //TODO - create a special add cell.
        static NSString *CellIdentifier = @"AddItemCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        NSString *text;
        if(indexPath.section == 1){
            if (isInitial)
                text = NSLocalizedString(@"Add Fixed Cost Item", @"Budget List Fixed Cost add an item text");
            else
                text = NSLocalizedString(@"Add a monthly expense", @"Budget List Expense add an item text");
        }
        else{
            if (isInitial)
                text = NSLocalizedString(@"Add Savings Item", @"Budget List Savings add an item text");
            else
                text = NSLocalizedString(@"Add an Income", @"Budget List Income add an item text");
        }
        cell.textLabel.text = text;
        //TODO set the imageView of the cell to be a + image.
        return cell;
    } else {
        //TODO - make this a standard budget item cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BudgetCell"];
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BudgetCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
    NSMutableArray *a = indexPath.section == 0 ? incomeItems : costItems;
	BudgetItem *item = (BudgetItem *) [a objectAtIndex:indexPath.row];    
    // Configure the cell to show the Budget Item's details
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = item.name;
    
    UITextField *amountField = (UITextField *)[cell viewWithTag:2];
    amountField.text = [item.amount stringValue];
    amountField.delegate = self;
    //[amountField setAccessibilityHint:[NSString stringWithFormat:@"%d,%d",indexPath.section,indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}
#pragma mark -
#pragma mark Editing

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BudgetItem *item;
    if((indexPath.section == 0 && indexPath.row == incomeItems.count) ||
       (indexPath.section == 1 && indexPath.row == costItems.count)){
        //TODO - Add a new budget item
        item = (BudgetItem*) [NSEntityDescription insertNewObjectForEntityForName:@"BudgetItem" inManagedObjectContext:managedObjectContext];
        item.isExpense = [NSNumber numberWithBool:(indexPath.section != 0)];
        item.inInitialBudget = [NSNumber numberWithBool:self.isInitial];
        // hardcode all manually created budget items to always show up.
        item.isRenting = [NSNumber numberWithInt:3];
        // hardcode order to be 100 to come after all pre-populated ones.
        item.order = [NSNumber numberWithInt:100];
        //Insert the object into the table view
        NSMutableArray *a = indexPath.section == 0 ? incomeItems : costItems;
        [a addObject:item];
    }
    else {
        NSMutableArray *a = indexPath.section == 0 ? incomeItems : costItems;
        item = (BudgetItem *)[a objectAtIndex:indexPath.row];
            
    }
    
    BudgetItemViewController * vc = [[BudgetItemViewController alloc] initWithNibName:@"BudgetItemViewController" bundle:nil];
    vc.item = item;	
    vc.parentController = self;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *a = indexPath.section == 0 ? incomeItems : costItems;
        BudgetItem * itemToDelete = [a objectAtIndex:indexPath.row];
		[managedObjectContext deleteObject:itemToDelete];
		
		[a removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
		[tableView reloadData];
    }   
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO make this conditional so last row ads a cell
    if((indexPath.section == 0 && indexPath.row == incomeItems.count) ||
       (indexPath.section == 1 && indexPath.row == costItems.count)){
        return UITableViewCellEditingStyleNone;
    } else{
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)budgetItemViewController:(BudgetItemViewController *)controller didFinishWithSave:(BOOL)save {
    if (save) {
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        [self.tableView reloadData];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark Text Fields

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //TODO update the object in the cell based on tag.
	//NSArray* indexPath = [textField.accessibilityValue componentsSeparatedByString: @","];
    //int section = [[indexPath objectAtIndex:0] intValue];
    //int row = [[indexPath objectAtIndex:1] intValue];
    for (UIView *parent = [textField superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;               
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            
            // now use the index path
            NSMutableArray *a = path.section == 0 ? incomeItems : costItems;
            BudgetItem *item = [a objectAtIndex:path.row];
            item.amount = [NSNumber numberWithInt: [textField.text intValue]];
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                // Update to handle the error appropriately.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }

            break; // for
        }
    }
    return YES;
}

- (IBAction)done:(id)sender {
    [activeField resignFirstResponder];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
#pragma mark -

#pragma mark memory maanagement

- (void)dealloc {
	[costItems release];
    [incomeItems release];
    [managedObjectContext release];
	[super dealloc];
}


@end

