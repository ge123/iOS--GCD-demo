//
//  GZGDCThreadManager.m
//  test-mutilThread
//
//  Created by 高召葛 on 2019/5/15.
//  Copyright © 2019 高召葛. All rights reserved.
//

#import "GZGDCThreadManager.h"
static GZGDCThreadManager * gzObjManager;
static const NSString * serialQueueIdentifier =@"GZSERIALQUEUEIDENTIFIER";
static const NSString * conCurrentQueueIdentifier =@"GZCONCURRENTQUEUEIDENTIFIER";

@implementation GZGDCThreadManager
+ (instancetype) shareInstence{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gzObjManager = [[GZGDCThreadManager alloc] init];
    });
    return gzObjManager;
}

- (void) execute{
    
//    [self testSerialQueue]; //  串行队列
//        [self testConcurrentQueue]; // 并发队列
//    [self testMainQueue]; // 主队列测试
    [self testGroupQueue]; // 队列组测试
//    [self testGCDSemaphore] // 测试GCD 信号量 实现异步任务同步进行
}

#pragma test 相关

/*组队组测试
 组队组: 组队列的每一个
 */
- (void) testGroupQueue{
    dispatch_group_t group =  [self getGroupQueue];
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"队列组：有一个耗时操作完成！");
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"队列组：有一个耗时操作完成！");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"队列组：前面的耗时操作都完成了，回到主线程进行相关操作");
    });
    
    
}

/*主队列测试
 1. 主队列异步事件: 按次序执行，不会开启新的线程
 2. 主队列同步事件: 程序崩溃，造成死锁
   死锁原因： 因为主线程默认是在主队列里，如果同步向队列里再加入一个任务队列，根据同步的原理系统会保证它只有线程执行，只有当上一个任务执行完，下一个任务才会执行，而队列任务与主线程任务会相互等待，导致相互阻塞，形成死锁。
 */
- (void) testMainQueue{
    dispatch_queue_t mainQueue = [self getMainQueue];
    NSLog(@"主队列-异步事件**************");
    dispatch_async(mainQueue, ^{
        for (int i=0; i<3; ++i) {
            NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
        }
    });
    dispatch_async(mainQueue, ^{
        for (int i=3; i<6; ++i) {
            NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
        }
    });
    
    
        NSLog(@"主队列--同步事件**************");
//        dispatch_sync(mainQueue, ^{
//            for (int i=0; i<3; ++i) {
//                NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
//            }
//        });
//        dispatch_sync(mainQueue, ^{
//            for (int i=3; i<6; ++i) {
//                NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
//            }
//        });
//
    
}

/*串行队列测试
 1. 串行同步执行： 执行完一个任务，再执行下一个任务。不开启新线程，都在主线程执行。
 2. 串行异步执行： 开启新线程，但因为任务是串行的，所以还是按顺序执行任务。
 3. 主线程的时间优先
 */
- (void) testSerialQueue{
    dispatch_queue_t serialQueue = dispatch_queue_create([serialQueueIdentifier UTF8String], DISPATCH_QUEUE_SERIAL);
    NSLog(@"串行队列-同步执行********\t");
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务1---currentThead:%@",[NSThread currentThread]);
    });
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务2---currentThead:%@",[NSThread currentThread]);
    });
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务3---currentThead:%@",[NSThread currentThread]);
    });
    
//    // 同步队列 用异步的方式没有作用
//    NSLog(@"串行队列-异步执行********\t");
//    dispatch_async(serialQueue, ^{
//        NSLog(@"任务1---currentThead:%@",[NSThread currentThread]);
//    });
//    dispatch_async(serialQueue, ^{
//        NSLog(@"任务2---currentThead:%@",[NSThread currentThread]);
//    });
//    dispatch_async(serialQueue, ^{
//        NSLog(@"任务3---currentThead:%@",[NSThread currentThread]);
//    });
    
    
}

/*并发队列测试
  1. 并发队列异步执行： 并发执行，会开启新的线程。
  2. 并发队列同步执行； 按顺序执行，不会开启新的线程。
  3. 主线程的时间优先。
 */
- (void) testConcurrentQueue{
    dispatch_queue_t concurrentQueue = [self createConcurrentQueue];
    NSLog(@"并发队列--异步执行");
    dispatch_async(concurrentQueue, ^{
        for (int i=0; i<3; ++i) {
            NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
        }
    });
    dispatch_async(concurrentQueue, ^{
        for (int i=3; i<6; ++i) {
            NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
        }
    });

    
//    NSLog(@"并发队列--同步执行");
//    dispatch_sync(concurrentQueue, ^{
//        for (int i=0; i<3; ++i) {
//            NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
//        }
//    });
//    dispatch_sync(concurrentQueue, ^{
//        for (int i=3; i<6; ++i) {
//            NSLog(@"任务:%d---currentThead:%@",i+1,[NSThread currentThread]);
//        }
//    });
    
}

#pragma 队列相关
- (dispatch_queue_t) createSerialQueue{
    return dispatch_queue_create([serialQueueIdentifier UTF8String], DISPATCH_QUEUE_SERIAL);
}

- (dispatch_queue_t) createConcurrentQueue{
    return dispatch_queue_create([conCurrentQueueIdentifier UTF8String], DISPATCH_QUEUE_CONCURRENT);
}

- (dispatch_queue_t) getMainQueue{
    return dispatch_get_main_queue();
}

- (dispatch_group_t) getGroupQueue{
    return dispatch_group_create();
}


// 保证：dispatch_semaphore_wait  任务进入队列的顺序是 任务1 、任务2 、任务3
// 保证：每个任务执行完 执行 dispatch_semaphore_signal(_semaphore); 信号加一 下一个线程任务才能执行 执行顺序：  任务1 、任务2 、任务3
- (void) testGCDSemaphore{
    dispatch_semaphore_t _semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t globeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(globeQueue, ^{
        NSLog(@"任务1 current thread : %@",[NSThread currentThread]);
        dispatch_semaphore_signal(_semaphore);
    });
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(globeQueue, ^{
        NSLog(@"任务2 current thread : %@",[NSThread currentThread]);
        dispatch_semaphore_signal(_semaphore);
        
    });
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(globeQueue, ^{
        NSLog(@"任务3 current thread : %@",[NSThread currentThread]);
        dispatch_semaphore_signal(_semaphore);
        
    });
    
}


@end
