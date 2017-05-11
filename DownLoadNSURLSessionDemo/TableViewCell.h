//
//  TableViewCell.h
//  BatchDownloadDemo
//
//  Created by AutoStreets on 17/4/19.
//  Copyright © 2017年 AutoStreets. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *downLoadCount;
@property (weak, nonatomic) IBOutlet UIButton *downLoadBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end
