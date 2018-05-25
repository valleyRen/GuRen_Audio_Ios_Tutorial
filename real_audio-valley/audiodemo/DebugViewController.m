//
//  DebugViewController.m
//  Demo
//
//  Created by 张乃淦 on 16/2/18.
//  Copyright © 2016年 pingan. All rights reserved.
//

#import "DebugViewController.h"
#import "utility.h"
#import <AVFoundation/AVFoundation.h>
#include "snail_real_audio/IModuleDebuger_OC.h"
NSString* strParam = NULL;

@interface ConfigureItem : NSObject
@property (nonatomic)    int  type;
@property (nonatomic)    int  playflag;
@property (nonatomic)    int  open;
@property (nonatomic) NSString* text;
@end

@implementation ConfigureItem
@end

@interface DebugViewController()<UITableViewDataSource,UITableViewDelegate,DebugEventHandler>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSIndexPath* indexpath;
@property (nonatomic, strong) NSTimer* Timer;
@property (nonatomic,strong)  NSString* strParam;
@end

@implementation DebugViewController
{
    struct ConfigTable* mcfgTable;
    __weak AudioRoom*   audioRoom;
    DebugModule*        debugModule;
}

int  mlencfgTable = 0;

-(void)NotifyShowMessage:(NSString*)message
{
    NSLog(@"%@",message);
}

-(instancetype)initWithRoom:(AudioRoom*)room CfgTable:(struct ConfigTable*) cfgTable LengthOfTable:(int)length;
{
    if (self = [super init]) {
        self.title = @"调试界面";
        audioRoom = room;
    }
    mlencfgTable = length;
    mcfgTable = cfgTable;
    debugModule = (DebugModule*)[audioRoom GetModule:INNER_MODULE_DEBUGGER];
    [debugModule RegisterEventHandler:self];
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    

    [self loadData];
    [self.view addSubview:self.tableView];
    

    _Timer = [ NSTimer  scheduledTimerWithTimeInterval: 0.5
             
                                               target: self
             
                                             selector: @selector ( onTimer: )
             
                                             userInfo:nil
             
                                              repeats: YES ];
    

    
}

 - (void)loadData
{
    for (int i = 0; i < mlencfgTable; i++)
    {
        ConfigureItem*  item = [ConfigureItem new];
        item.type = mcfgTable[i].type;
        item.playflag = mcfgTable[i].bplay;
        item.text = [[NSString alloc ]initWithUTF8String:mcfgTable[i].text];
        item.open = mcfgTable[i].open;
        [self.dataSource addObject:item];
    }
    
    for (int i =0; i < 13; i++) {
        ConfigureItem*  item = [ConfigureItem new];
        item.type = -1;
        [self.dataSource addObject:item];
    }
    
    
}


//页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated
{
    //开启定时器
    // [timer setFireDate:[NSDate distantPast]];
    if (_Timer == nil) {
        _Timer = [ NSTimer  scheduledTimerWithTimeInterval: 0.5
                 
                                                   target: self
                 
                                                 selector: @selector ( onTimer: )
                 
                                                 userInfo:nil
                 
                                                  repeats: YES ];
    }
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated
{
    //关闭定时器
    if(_Timer)
    {
        [_Timer invalidate];
        _Timer = nil;
    }
}

- (void) dealloc
{
}

-(void) onTimer:(NSTimer*)sender{
}

#pragma mark - UITableViewDataSource
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}
// 设置每一行的内容，这是UI显示的重点，可以很好的锻炼iOS开发UI的能力
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ConfigureItem *item = self.dataSource[indexPath.row];
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
    if(item)
    {
            if( item.type == 0x2000000 ) //edit
            {
                UITextField* textEdit = [[UITextField alloc] initWithFrame:CGRectMake(50,0, kScreenWidth-70, 44)];
                textEdit.borderStyle = UITextBorderStyleRoundedRect;
                textEdit.text = strParam;
                [textEdit addTarget:self action:@selector(EditChanged:) forControlEvents:UIControlEventEditingDidEnd];
                [cell addSubview:textEdit];
            }
            else if(item.type != -1)
            {
                UISwitch *switchView = [[UISwitch alloc]initWithFrame:CGRectMake(kScreenWidth - 54.0f, 8.0f, 50.0f, 28.0f)];
                switchView.on = item.open;
                [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];   // 开关事件切换通知
                [switchView setTag:indexPath.row];
//                [self.view addSubview: switchView];
                [cell addSubview:switchView];
            }
    }
    cell.textLabel.text = item.text;
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
}


- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}


#pragma mark 点击行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if(indexPath == nil)
        return;
    
    
    
    _indexpath = indexPath;
    //MessageBox(@"点击事件", [[NSString alloc] initWithFormat:@"点击了%li 组,%li 行",(long)indexPath.section,(long)indexPath.row]);
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
        
        self.tableView.frame = [[UIScreen mainScreen] bounds];
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    return _tableView;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

-(void)switchAction:(id)sender
{
    int opflag = 0;
    [self.view endEditing:YES];
    int idx = (int)[sender tag];
    ConfigureItem* item = (ConfigureItem*)self.dataSource[idx];
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    item.open = isButtonOn;
    mcfgTable[idx].open = isButtonOn;
    if(isButtonOn)
    {
        opflag |= 1;
    }
    if (item.playflag) {
        opflag |= 2;
        
        //取消其他的播放设置
        for(int i = 0; i < mlencfgTable;i++)
        {
            if (mcfgTable[i].bplay && i != idx)
            {
                mcfgTable[i].open = 0;
                ((ConfigureItem*)self.dataSource[i]).open = 0;
            }
        }
    }

    if( TYPE_RECORD_ALL == item.type)
    {
        [debugModule EnableSaveRecord:item.open];
    }
    else if ( TYPE_PLAYOUT_ALL)
    {
        [debugModule EnableSavePlayout:item.open];
    }
    else if ( 0x1000000 == item.type)//pause playout
    {
        [debugModule PlayPause:item.open];
    }
    else if( 0x2000000 == item.open )
    {
        //todo
    }
    else
    {
        [debugModule PlaySavedFile:item.type Paly:item.open];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
    
    NSLog(@"[DebugCmd]type:%x,cmd:%d\n",item.type,opflag);
    
}

-(void)EditChanged:(id)sender
{
    UITextField* textEdit = (UITextField*)sender;
    strParam = textEdit.text;
    const char *param = [textEdit.text cStringUsingEncoding:NSASCIIStringEncoding];
    int idx = (int)[sender tag];
    ConfigureItem* item = (ConfigureItem*)self.dataSource[idx];
//    [self.audiomodule DebugCmd:item.type cmd:(const void*)param ];
    
    NSLog(@"[EditChanged]%@",strParam);
}

@end











