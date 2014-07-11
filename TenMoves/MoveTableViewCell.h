//
//  MoveTableViewCell.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoveTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end
