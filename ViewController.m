//
//  ViewController.m
//  NSoperationStudy
//
//  Created by pencho on 16/6/17.
//  Copyright © 2016年 litong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self studyQueueBaseOperation];
}

- (void)studyQueueBaseOperation{
    /*
     1,并发，同时执行的任务数，比如同时开三个线程执行3三个任务数，并发数就是3
     2，最大并发数，同一时间最多只能执行的任务个数
     3，最大并发相关方法
       －（nsinterger）maxConcurrentOperationcount;
        - (void)setMaxConcurrentOperationCount:(nsinteger)count
     说明：如果没有是设置最大并发数，那么并发的个数是由系统内存和cpu决定的，可能内存多就开多一点，内存少就少开一点。
     注意：num的指并不代表线程的个数，仅仅代表线程的id
     提示：最大并发数不要乱写（5以内）不要开太多，一般2～3为宜，因为虽然任务是在子线程处理的但是cpu处理这些过多的子线程可能会影响UI，让UI变卡。
     
     */
    
    /*
     1, 取消对列的所有操作
     －（void）cancelAllOperations；
     提示：也可以调用nsoperation的－（void）cancel当方法取消单个操作
     2，暂停和恢复对列
     － （void）setSuspended：（bool）b//yes 为暂停对列 no 为恢复对列
     － （void）isSuspended //当前状态
     3，暂停和恢复的适用场合，在tableview界面，开线程下载远程的网络页面，对UI会有影响，使用户体验变差，那么这种情况下，就可以设置在用户造作UI（如滚动屏幕）的时候，暂停对列（不是取消对列），停止滚动的时候，恢复对列。
     */
    /*
      操作优先级
     NSOperationQueuePriorityVeryLow ＝ －8L,
     NSOperationQueuePriorityLow = -4L,
     NSOperationQueuePriorityNormal = 0,
     NSOperationQueuePriorityHigh = 4,
     NsOperationQueuePriorityVeryhigh = 8,
     说明：优先级较高的任务，调用几率会更大。
     */
    /*
     操作依赖
     1，NSOperation 之间可以设置依赖来保证执行顺行，比如一定要让操作A执行完后，才能执行操作B，可以像下面这么写，［operationB addDependency:operationA］//操作B依赖于操作A
     2，可以在不同的queue的NSOperation之间创建以来关系。
     */
    //创建nsinvacationOperation对象，封装操作
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(test:) object:@"study1"];
    NSInvocationOperation *operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(test2:) object:@"study2"];

    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i =0 ; i < 5; i++) {
            NSLog(@"NSBLockOperation3-1--%@",[NSThread currentThread]);
        }
    }];
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"NSBLockOperation33-2--%@",[NSThread currentThread]);
        }
    }];
    [blockOperation setCompletionBlock:^{
        //opration成功和取消都会调用 此时位于子线程
        NSLog(@"blockOperation Complete__%@",[NSThread currentThread]);
    }];
    [blockOperation setQueuePriority:NSOperationQueuePriorityHigh];

    //设置操作依赖
    //先设置operation2，在执行operation1，最后执行operation3
    [blockOperation addDependency:operation1];
    [operation1 addDependency:operation2];
    //不能相互依赖 like this
    /*
    [operation2 addDependency:operation1];
    [operation1 addDependency:operation2];
     */
    //创建nsoperationQueue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:blockOperation];
    //[queue setSuspended:YES];
    [queue cancelAllOperations];//取消操作会有延迟
    
}


- (void)studyOperationQueue{
    //凡是追加到queue里面都是在异步执行
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
    
    NSInvocationOperation *invo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(test:) object:@"hello"];
    
    [queue addOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
    [queue addOperation:op1];
    [queue addOperation:invo];
}


- (void)studyOperation{
    /*
     nsoperation 的作用：配合使用nsoperation和nsoperation queue 也能实现多线程。
     nsoperation  和 nsoperationQueue实现多线程的具体步骤
     1，想讲需要执行的操作封装到一个nsoperation对象中
     2，然后将nsoperation对象添加到nsoprationqueue当中
     3，系统会自动将nsoperationqueue中的nsoperation取出来
     4，将取出的nsoperation封装的造作放到一条新线程中执行
     */
    /*
     nsoperation的子类
     nsoperation是个抽象类，并不具备封装操作的能力，必须使用它的子类
     使用nsoperation子类的方式有三种：
     1 nsinvocationOperation
     2 nsblockOperation
     3 自定义子类继承的nsoperation，实现内部相应的方法
     */
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(test:) object:@"hi"];
    [operation start];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        //在主线程执行
        NSLog(@"111%@",[NSThread currentThread]);
    }];
    //blockOperation操作数大于1则为异步线程处理
    [blockOperation addExecutionBlock:^{
        //在子线程执行
        NSLog(@"222%@",[NSThread currentThread]);

    }];
    [blockOperation start];
}

- (void)test:(id)ob{
    NSLog(@"%@",ob);
    NSLog(@"%@",[NSThread currentThread]);
}

- (void)test2:(id)ob{
    NSLog(@"%@",ob);
    NSLog(@"%@",[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
