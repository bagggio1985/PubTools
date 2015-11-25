//
//  PBTableViewCell.m
//  TestTableViewController
//
//  Created by kyao on 15/11/24.
//  Copyright © 2015年 mac. All rights reserved.
//

#import "PTTableViewCell.h"

@interface PTTableViewCell ()

@property (nonatomic, strong) id entity;

@end

@implementation PTTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
}

- (void)configEntity:(id)entity {
    self.entity = entity;
}

- (void)awakeFromNib {
    // Initialization code
    [self commonInit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
