//
//  LHBDownLoad.m
//  DownLoadNSURLSessionDemo
//
//  Created by AutoStreets on 17/5/10.
//  Copyright © 2017年 AutoStreets. All rights reserved.
//

#import "LHBDownLoad.h"
#import "DownLoadModel.h"

@implementation LHBDownLoad

+ (instancetype)downLoadInstance {
    static LHBDownLoad *sington = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sington = [[LHBDownLoad alloc] init];
    });
    return sington;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downLoadTaskArr = [NSMutableArray array];
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

//创建下载任务
- (void)startDownLoadTask:(NSString *)url cellIndex:(NSInteger)cellIndex {
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:requestUrl];
    DownLoadModel *model = [[DownLoadModel alloc] init];
    model.task = task;
    model.cellIndex = cellIndex;
    [self.downLoadTaskArr addObject:model];
    
    if ([self isMoreThanMaxTaskCount]) { //当前正在下载个数大于最大下载任务数量
        model.state = DownLoadWaite; //改变下载状态为等待下载状态
        return;
    }
    
    model.state = DownLoadDoing; //改变下载状态为正在下载状态
    
    //开始任务
    [self startTask:model.task];
}

//继续下载任务
- (void)continueDownLoadTaskWithCellIndex:(NSInteger)cellIndex {
    DownLoadModel *model = [self getModelWithCellIndex:cellIndex];
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithResumeData:model.resumeData];
    model.task = nil;  //清空原来的任务
    model.task = task; //赋值新的任务
    
    if ([self isMoreThanMaxTaskCount]) { //当前正在下载个数大于最大下载任务数量
        model.state = DownLoadWaite; //改变下载状态为等待下载状态
        return;
    }
    
    model.state = DownLoadDoing; //改变下载状态  (从暂停状态变为正在下载状态)
    //开始任务
    [self startTask:model.task];
}

//开始下载
- (void)startTask:(NSURLSessionDownloadTask *)task {
    [task resume];
}

//暂停下载
- (void)stopTaskWithCellIndex:(NSInteger)cellIndex {
    DownLoadModel *model = [self getModelWithCellIndex:cellIndex];
    model.state = DownLoadStop; //改变下载状态(暂停状态)
    //获取当前暂停的下载偏移量
    [model.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        model.resumeData = resumeData;
    }];
}

#pragma mark - NSURLSessionDownLoadDelegate
//下载完成回调
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location {
    if ([self.delegate respondsToSelector:@selector(downLoadFinishedWithTask:didFinishDownloadingToURL:)]) {
        [self.delegate downLoadFinishedWithTask:downloadTask didFinishDownloadingToURL:location];
    }
}

//下载过程中回调
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if ([self.delegate respondsToSelector:@selector(downLoadDoingWithTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate downLoadDoingWithTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

//下载失败回调
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                      didResumeAtOffset:(int64_t)fileOffset
                                     expectedTotalBytes:(int64_t)expectedTotalBytes {
    if ([self.delegate respondsToSelector:@selector(downLoadStopWithTask:didResumeAtOffset:expectedTotalBytes:)]) {
        [self.delegate downLoadStopWithTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
    }
}

#pragma mark - custom method
//通过task获取任务在tableView中的位置
- (NSInteger)getCellIndexWithTask:(NSURLSessionDownloadTask *)task {
    for (DownLoadModel *model in self.downLoadTaskArr) {
        if (model.task.taskIdentifier == task.taskIdentifier) {
            return model.cellIndex;
        }
    }
    return 0;
}

//通过cellIndex获取下载对象
- (DownLoadModel *)getModelWithCellIndex:(NSInteger)cellIndex {
    for (DownLoadModel *model in self.downLoadTaskArr) {
        if (model.cellIndex == cellIndex) {
            return model;
        }
    }
    return nil;
}

//通过task获取下载对象
- (DownLoadModel *)getModelWithTask:(NSURLSessionDownloadTask *)task {
    for (DownLoadModel *model in self.downLoadTaskArr) {
        if (model.task.taskIdentifier == task.taskIdentifier) {
            return model;
        }
    }
    return nil;
}

//获取整个队列中正在下载的个数
- (NSInteger)getDownLoadDoingCount {
    NSInteger count = 0;
    for (DownLoadModel *model in self.downLoadTaskArr) {
        if (model.state == DownLoadDoing) {
            count++;
        }
    }
    return count;
}

//开始当前最靠前的等待任务
- (NSURLSessionDownloadTask *)startForWaiteTask {
    for (DownLoadModel *model in self.downLoadTaskArr) {
        if (model.state == DownLoadWaite) {
            [self startTask:model.task];
            
            //修改任务状态(等待状态变为正在下载状态)
            model.state = DownLoadDoing;
            
            return model.task;
        }
    }
    return nil;
}

//判断cellIndex位置下的对象是否是断点续传
- (BOOL)isModelResumeWithCellIndex:(NSInteger)cellIndex {
    DownLoadModel *model = [self getModelWithCellIndex:cellIndex];
    if (model.resumeData.length > 0) {
        return true;
    } else {
        return false;
    }
}

//判断当前正在下载任务数量是否大于最大任务数
- (BOOL)isMoreThanMaxTaskCount {
    return [self getDownLoadDoingCount] >= self.downLoadMaxCount;
}

//下载完成或者失败移除任务
- (void)removeTaskWithTask:(NSURLSessionDownloadTask *)task {
    DownLoadModel *model = [self getModelWithTask:task];
    [self.downLoadTaskArr removeObject:model];
}

@end
