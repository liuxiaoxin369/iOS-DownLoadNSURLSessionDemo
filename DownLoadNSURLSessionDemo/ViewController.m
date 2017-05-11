//
//  ViewController.m
//  DownLoadNSURLSessionDemo
//
//  Created by AutoStreets on 17/5/10.
//  Copyright © 2017年 AutoStreets. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "LHBDownLoad.h"

#define kLHBDownLoad [LHBDownLoad downLoadInstance]

#define kDownLoadUrl @"http://www.imagomat.de/testimages/1.tiff"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, LHBDownLoadDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    kLHBDownLoad.delegate = self;
    kLHBDownLoad.downLoadMaxCount = 4;  //设置最大任务数
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UINib nibWithNibName:@"TableViewCell" bundle:nil] instantiateWithOwner:self options:nil] objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.downLoadBtn.tag = 2000 + indexPath.row;
    [cell.downLoadBtn addTarget:self action:@selector(handleDownLoadAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.progressView.progress = 0;
    cell.downLoadCount.text = [NSString stringWithFormat:@"0M/0M"];
    return cell;
}

#pragma mark - LHBDownLoadDelegate
//下载完成
- (void)downLoadFinishedWithTask:(NSURLSessionDownloadTask *)downloadTask
       didFinishDownloadingToURL:(NSURL *)location {
    //下载中给cell上的控件赋值
    [self assignmentControlsWithTask:downloadTask receiveData:0 alreadyTotalData:0 totalData:0 downLoadDes:@"下载完成"];
    [kLHBDownLoad removeTaskWithTask:downloadTask]; //移除任务
    
    [self modifyWaiteBtnTitleAndStartTaskWithBtn:nil]; //当下载成功后, 检测是否还有等待任务, 如果有就开启
}

//下载中
- (void)downLoadDoingWithTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    //下载中给cell上的控件赋值
    [self assignmentControlsWithTask:downloadTask receiveData:bytesWritten alreadyTotalData:totalBytesWritten totalData:totalBytesExpectedToWrite downLoadDes:@"正在下载"];
}

//下载失败
- (void)downLoadStopWithTask:(NSURLSessionDownloadTask *)downloadTask
           didResumeAtOffset:(int64_t)fileOffset
          expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"下载失败的数据%lld****************%@", fileOffset, downloadTask.error);
    if (downloadTask.error != NULL) {
        [self assignmentControlsWithTask:downloadTask receiveData:0 alreadyTotalData:0 totalData:0 downLoadDes:@"下载失败"];
        [kLHBDownLoad removeTaskWithTask:downloadTask]; //移除任务
        
        [self modifyWaiteBtnTitleAndStartTaskWithBtn:nil];  //当下载成功后, 检测是否还有等待任务, 如果有就开启
    }
}

#pragma mark - custom method
//根据任务获取对应的cell
- (UITableViewCell *)getCellWithTask:(NSURLSessionDownloadTask *)task {
    NSInteger cellIndex = [kLHBDownLoad getCellIndexWithTask:task];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

//给对应任务cell上的控件赋值
- (void)assignmentControlsWithTask:(NSURLSessionDownloadTask *)task
                       receiveData:(int64_t)receiveData
                  alreadyTotalData:(int64_t)alreadyTotalData
                         totalData:(int64_t)totalData
                       downLoadDes:(NSString *)downLoadDes {
    TableViewCell *tableCell = (TableViewCell *)[self getCellWithTask:task];
    if ([downLoadDes isEqualToString:@"正在下载"]) { //正在下载
        [tableCell.progressView setProgress:(alreadyTotalData * 1.0 / totalData) animated:YES];
        tableCell.downLoadCount.text = [NSString stringWithFormat:@"%.2f/%.2f", alreadyTotalData * 1.0 / (1024*1024), totalData * 1.0 / (1024*1024)];
        NSLog(@"%.2f", (alreadyTotalData * 1.0 / totalData));
    } else if ([downLoadDes isEqualToString:@"下载完成"]) { //下载完成
        tableCell.downLoadBtn.hidden = YES;
        tableCell.downLoadCount.text = [NSString stringWithFormat:@"下载完成"];
    } else if ([downLoadDes isEqualToString:@"下载失败"]) { //下载失败
        tableCell.downLoadBtn.hidden = YES;
        tableCell.downLoadCount.text = [NSString stringWithFormat:@"下载失败"];
    }
}

//修改当前最靠前的等待任务进入正在下载状态
- (void)modifyWaiteBtnTitleAndStartTaskWithBtn:(UIButton *)sender {
    NSURLSessionDownloadTask *task = [kLHBDownLoad startForWaiteTask]; //开启当前最靠前的等待的任务
    if (!task) { //判断到最后一个没有等待任务时  单独处理
        if (sender) {
            [sender setTitle:@"下载" forState:UIControlStateNormal];
        }
        return;
    }
    TableViewCell *cell = (TableViewCell *)[self getCellWithTask:task];
    [cell.downLoadBtn setTitle:@"暂停" forState:UIControlStateNormal];  //修改已经开始的按钮
}

#pragma mark - handleAction
- (void)handleDownLoadAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"下载"]) {
        if ([kLHBDownLoad isModelResumeWithCellIndex:sender.tag - 2000]) { //当前是否为断点续传
            if ([kLHBDownLoad isMoreThanMaxTaskCount]) { //当前正在进行的任务大于最大任务数   应该处于等待状态
                [sender setTitle:@"等待" forState:UIControlStateNormal];
                [kLHBDownLoad continueDownLoadTaskWithCellIndex:sender.tag - 2000]; //断点续传
                return;
            }
            [kLHBDownLoad continueDownLoadTaskWithCellIndex:sender.tag - 2000]; //断点续传
        } else {
            if ([kLHBDownLoad isMoreThanMaxTaskCount]) {
                [sender setTitle:@"等待" forState:UIControlStateNormal];
                [kLHBDownLoad startDownLoadTask:kDownLoadUrl cellIndex:sender.tag - 2000]; //下载
                return;
            }
            [kLHBDownLoad startDownLoadTask:kDownLoadUrl cellIndex:sender.tag - 2000]; //下载
        }
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    } else if ([sender.titleLabel.text isEqualToString:@"暂停"]) {
        [kLHBDownLoad stopTaskWithCellIndex:sender.tag - 2000]; //暂停
        [sender setTitle:@"下载" forState:UIControlStateNormal];
        
        [self modifyWaiteBtnTitleAndStartTaskWithBtn:sender];
    }
}


@end
