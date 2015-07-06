//
//  Constants.h
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  常量定义

#define DEPLOYMENT_ENVIRONMENT          2   // 部署环境，0：InHouse 1：AdHoc 2：Development

#define IOS_VERSION_7_OR_ABOVE          (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? (YES) : (NO))
#define IOS_VERSION_8_OR_ABOVE          (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) ? (YES) : (NO))

#define DEVICE_WIDTH                    [[UIScreen mainScreen] bounds].size.width
#define DEVICE_HEIGHT                   [[UIScreen mainScreen] bounds].size.height
#define STATUS_BAR_HEIGHT               20.0    // 状态栏高度
#define NAVIGATION_BAR_HEIGHT           44.0    // 导航栏高度
#define INPUT_ACCESSORY_VIEW_HEIGHT     44.0    // 键盘附加视图高度
#define PICKER_VIEW_HEIGHT              216.0   // 拾取器高度
#define TOOLBAR_HEIGHT                  44.0    // 工具栏高度
#define TABLEVIEW_CELL_HEIGHT           50.0    // 表视图单元格高度

#define COLOR(R, G, B)                  [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define NAVIGATION_BAR_COLOR            COLOR(0xcf,0x3b,0x1d)   // 导航栏背景颜色
#define TABLEVIEW_BG_COLOR              COLOR(0xff,0xff,0xff)   // 列表视图背景颜色

#define RED_BUTTON_BG_NORMAL_COLOR          COLOR(0xcf,0x3b,0x1d)   // 红色按钮背景颜色（正常）
#define RED_BUTTON_BG_HIGHLIGHTED_COLOR     COLOR(0xba,0x35,0x1a)   // 红色按钮背景颜色（高亮）
#define GRAY_BUTTON_BG_NORMAL_COLOR         COLOR(0xa9,0xa9,0xa9)   // 灰色按钮背景颜色（正常）
#define GRAY_BUTTON_BG_HIGHLIGHTED_COLOR    COLOR(0xc5,0xc5,0xc5)   // 灰色按钮背景颜色（高亮）
#define BLUE_BUTTON_TITLE_NORMAL_COLOR      COLOR(0x21,0x96,0xf3)   // 按钮蓝色标题颜色（正常）
#define BLUE_BUTTON_TITLE_HIGHLIGHTED_COLOR COLOR(0x1a,0x78,0xc2)   // 按钮蓝色标题颜色（高亮）

#define FONT(S)                 [UIFont systemFontOfSize:S]

#define ALERT_BUTTON_TITLE_CONFIRM      @"确定"
#define ALERT_BUTTON_TITLE_CANCEL       @"取消"
#define BAR_BUTTON_TITLE_DONE           @"完成"

// 接口定义
#define DEV_BASE_REQUEST_URL                            @"http://218.60.29.216:8080/kinghorse"
#define DIS_BASE_REQUEST_URL                            @"http://218.24.14.69:9090/dade"

#define LOGIN_USER_REQUEST_URL                          @"%@/LoginUser"                     // 用户登录身份验证接口
#define SEND_TEXT_REQUEST_URL                           @"%@/SendText"                      // 发送短信验证码接口
#define QUERY_ORGANIZATION_REQUEST_URL                  @"%@/QueryOrganization"             // 查询用户企业组织机构信息接口
#define QUERY_VERSION_NUMBER_REQUEST_URL                @"%@/QueryVersionNumber"            // 查询版本号

#define QUERY_INCOME_LIST_REQUEST_URL                   @"%@/QueryIncomeList"               // 待办文件查询列表接口
#define GET_INCOME_VIEW_BY_ID_REQUEST_URL               @"%@/GetIncomeViewById"             // 文件详细信息接口
#define GET_DATE_FILE_TEXT_BY_ID_REQUEST_URL            @"%@/GetDatefiletextById"           // 未打卡说明/请假申请详细信息接口
#define GET_FLOW_PATH_BY_FILE_ID_IN_TABLE_REQUEST_URL   @"%@/GetFlowPathByFileIdInTable"    // 文件流转信息接口
#define GET_NOW_FLOW_INFO_BY_FLOW_ID_REQUEST_URL        @"%@/GetNowFlowinfoByFlowid"        // 文件当前流转信息接口
#define APPROVAL_FILE_INFO_REQUEST_URL                  @"%@/ApprovalFileinfo"              // 文件审批操作
#define QUERY_NOTICE_LIST_REQUEST_URL                   @"%@/QueryNoticeList"               // 通知文件查询列表接口
#define SHOW_NOTICE_VIEW_BY_ID_REQUEST_URL              @"%@/ShowNoticeViewById"            // 通知详细信息接口
#define SHOW_NOTICE_FLOW_INFO_REQUEST_URL               @"%@/ShowNoticeFlowInfoList"        // 通知人员列表接口
#define IS_END_NOTICE_REQUEST_URL                       @"%@/IsEndNotice"                   // 通知查收确认接口
#define QUERY_NEWS_LIST_REQUEST_URL                     @"%@/QueryNewsList"                 // 邮件查询列表接口
#define QUERY_MAIL_INFO_BY_ID_REQUEST_URL               @"%@/QueryMailInfoById"             // 邮件详细信息查询接口
#define REPLY_MAIL_REQUEST_URL                          @"%@/ReplyMail"                     // 邮件回复接口

#define QUERY_TODO_WORK_LIST_REQUEST_URL                @"%@/QueryToDoWorkList"             // 工作联系单待办接口
#define QUERY_SUPERVISION_WORD_LIST_REQUEST_URL         @"%@/QuerySupervisionWordList"      // 工作联系单监督接口
#define QUERY_SUPERVISION_WORD_DRAFT_LIST_REQUEST_URL   @"%@/QuerySupervisionWordDraftList" // 工作联系单草稿接口
#define QUERY_TODO_WORK_INFO_REQUEST_URL                @"%@/QueryToDoWorkInfo"             // 工作联系单详细信息接口
#define QUERY_TODO_NOTICE_LIST_REQUEST_URL              @"%@/QueryToDoNoticeList"           // 工作联系单人员列表接口
#define SAVE_OR_UPDATE_TODO_WORD_REQUEST_URL            @"%@/SaveOrUpdateToDoWord"          // 工作联系单起草、修改接口
#define DELETE_TODO_WORD_REQUEST_URL                    @"%@/DeleteToDoWord"                // 工作联系单删除接口
#define QUERY_GZLXD_FLOW_LIST_REQUEST_URL               @"%@/QueryGzlxdFlowList"            // 查看工作联系单回复内容接口
#define REPLY_TODO_WORK_REQUEST_URL                     @"%@/ReplyToDoWork"                 // 回复工作联系单接口
#define END_TODO_WORD_REQUEST_URL                       @"%@/EndToDoWord"                   // 完结工作联系单接口
#define EVALUATION_TODO_WORK_REQUEST_URL                @"%@/EvaluationToDoWork"            // 评价工作联系接口

#define SAVE_MAIL_REQUEST_URL                           @"%@/SaveMail"                      // 邮件起草接口
#define SAVE_LEAVE_APPLICATION_REQUEST_URL              @"%@/SaveLeaveApplication"          // 请假申请起草接口
#define SAVE_NOT_PUNCH_REQUEST_URL                      @"%@/SaveNotPunch"                  // 未打卡说明起草接口
#define DRAFT_NOTICE_INFO_REQUEST_URL                   @"%@/DraftNoticeInfo"               // 通知起草接口
#define QUERY_STAFF_LIST_BY_NAME_REQUEST_URL            @"%@/QueryStaffListByName"          // 用户查询接口
#define GET_PROCESS_BY_FILE_ID_REQUEST_URL              @"%@/GetProcessByFileId"            // 起草文件审批流程查询接口

static NSString *const DDMainRefreshNotification = @"DDMainRefreshNotification";
static NSString *const DDNoticeListRefreshNotification = @"DDNoticeListRefreshNotification";
static NSString *const DDTodoListRefreshNotification = @"DDTodoListRefreshNotification";
static NSString *const DDWorkContactListNumberRefreshNotification = @"DDWorkContactListNumberRefreshNotification";
static NSString *const DDWorkContactListDetailRefreshNotification = @"DDWorkContactListDetailRefreshNotification";


