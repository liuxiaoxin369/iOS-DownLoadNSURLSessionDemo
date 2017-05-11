//
//  DownLoadModel.m
//  BatchDownloadDemo
//
//  Created by AutoStreets on 17/4/20.
//  Copyright © 2017年 AutoStreets. All rights reserved.
//

#import "DownLoadModel.h"

@implementation DownLoadModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.task = nil;
        self.cellIndex = 0;
        self.state = DownLoadNotStart;
        self.resumeData = nil;
    }
    return self;
}

@end
