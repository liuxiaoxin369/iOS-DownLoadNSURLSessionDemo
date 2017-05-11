//
//  DownLoadModel.h
//  BatchDownloadDemo
//
//  Created by AutoStreets on 17/4/20.
//  Copyright © 2017年 AutoStreets. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DownLoadNotStart = 0,   //未开始状态
    DownLoadDoing,          //正在下载
    DownLoadStop,           //暂停下载
    DownLoadWaite,          //等待下载
}DownLoadState;

@interface DownLoadModel : NSObject

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, assign) NSInteger cellIndex;                      //在整个tableView的位置
@property (nonatomic, assign) DownLoadState state;                      //下载状态
@property (nonatomic, strong) NSData *resumeData;                       //断点续传已经下载的数据

@end
