//
//  LHBDownLoad.h
//  DownLoadNSURLSessionDemo
//
//  Created by AutoStreets on 17/5/10.
//  Copyright © 2017年 AutoStreets. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LHBDownLoadDelegate <NSObject>

@required
//下载完成
- (void)downLoadFinishedWithTask:(NSURLSessionDownloadTask *)downloadTask
       didFinishDownloadingToURL:(NSURL *)location;
//下载中
- (void)downLoadDoingWithTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
//下载失败
- (void)downLoadStopWithTask:(NSURLSessionDownloadTask *)downloadTask
           didResumeAtOffset:(int64_t)fileOffset
          expectedTotalBytes:(int64_t)expectedTotalBytes;

@end

@interface LHBDownLoad : NSObject<NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableArray *downLoadTaskArr; //存放下载任务
@property (nonatomic, strong) NSURLSession *session; //创建session
@property (nonatomic, assign) NSInteger downLoadMaxCount; //同时下载的最大个数

@property (nonatomic, assign) id<LHBDownLoadDelegate> delegate;

+ (instancetype)downLoadInstance;

//创建下载任务
- (void)startDownLoadTask:(NSString *)url cellIndex:(NSInteger)cellIndex;
//继续下载任务
- (void)continueDownLoadTaskWithCellIndex:(NSInteger)cellIndex;
//暂停下载
- (void)stopTaskWithCellIndex:(NSInteger)cellIndex;

//通过task获取任务在tableView中的位置
- (NSInteger)getCellIndexWithTask:(NSURLSessionDownloadTask *)task;
//开始当前最靠前的等待任务
- (NSURLSessionDownloadTask *)startForWaiteTask;
//判断cellIndex位置下的对象是否是断点续传
- (BOOL)isModelResumeWithCellIndex:(NSInteger)cellIndex;
//判断当前正在下载任务数量是否大于最大任务数
- (BOOL)isMoreThanMaxTaskCount;
//下载完成或者失败移除任务
- (void)removeTaskWithTask:(NSURLSessionDownloadTask *)task;

@end
