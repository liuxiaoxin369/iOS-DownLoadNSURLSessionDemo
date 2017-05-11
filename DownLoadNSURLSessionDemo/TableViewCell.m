//
//  TableViewCell.m
//  BatchDownloadDemo
//
//  Created by AutoStreets on 17/4/19.
//  Copyright © 2017年 AutoStreets. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.progressView.progress = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
