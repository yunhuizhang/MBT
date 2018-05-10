prompt Importing table sys_func_info...
set feedback off
set define off
insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_Add_X', '交易流水号修改', null, 'FTZ_Add', 9, '#', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'O');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310', '远期结售汇', null, 'FTZ_Add_X', 10, '/FTZ210310/AddXQry?optId=X', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_1Mod', '远期结售汇录入-修改批量', null, 'FTZ_AddX_210310', null, '/FTZ210310/UpdXDtlInit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'O');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_1Qry', '远期结售汇录入-查询批量', null, 'FTZ_AddX_210310', null, '/FTZ210310/AddXQry', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_2Dtl', '远期结售汇录入-查看明细', null, 'FTZ_AddX_210310', null, '/FTZ210310/QryXDtlDtl', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_2Mod', '远期结售汇录入-修改明细', null, 'FTZ_AddX_210310', null, '/FTZ210310/XDtlDtlInit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'O');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_2NQry', '远期结售汇录入-查询明细数量', null, 'FTZ_AddX_210310', null, '/FTZ210310/QryXDtlNum', null, null, null, null, null, null, null, null, null, null, '0', '0', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_2Ref', '远期结售汇录入-刷新明细', null, 'FTZ_AddX_210310', null, '/FTZ210310/DtlXInitReflash', null, null, null, null, null, null, null, null, null, null, '0', '0', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_2Sbm', '远期结售汇录入-提交批量', null, 'FTZ_AddX_210310', null, '/FTZ210310/AddXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'A');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210310_3Mod', '远期结售汇录入-修改提交', null, 'FTZ_AddX_210310', null, '/FTZ210310/XDtlDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_Add_210310_1Dtl', '远期结售汇录入-查看详情', null, 'FTZ_AddX_210310', null, '/FTZ210310/QryXDtl', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210311', '汇率掉期业务(远期未交割部分)', null, 'FTZ_Add_X', 11, '/FTZ210311/AddXQry?optId=X', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210311_1Mod', '汇率掉期业务录入-修改批量', null, 'FTZ_AddX_210311', null, '/FTZ210311/UpdXDtlInit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'O');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210311_1Qry', '汇率掉期业务录入-查询批量', null, 'FTZ_AddX_210311', null, '/FTZ210311/AddXQry', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210311_2Ref', '汇率掉期业务录入-刷新明细', null, 'FTZ_AddX_210311', null, '/FTZ210311/DtlXInitReflash', null, null, null, null, null, null, null, null, null, null, '0', '0', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210311_3Mod', '汇率掉期业务录入-修改提交', null, 'FTZ_AddX_210311', null, '/FTZ210311/XDtlDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210312', '汇率期权', null, 'FTZ_Add_X', 12, '/FTZ210312/AddXQry?optId=X', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210312_UPDATE_SUBMIT', '汇率期权-录入修改提交', null, 'FTZ_AddX_210312', null, '/FTZ210312/UptXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210313', '远期和期货', null, 'FTZ_Add_X', 13, '/FTZ210313/AddXQry?optId=X', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210313_UPDATE_SUBMIT', '远期和期货-录入修改提交', null, 'FTZ_AddX_210313', null, '/FTZ210313/UptXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210314', '掉期', null, 'FTZ_Add_X', 14, '/FTZ210314/AddXQry?optId=X', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210314_UPDATE_SUBMIT', '掉期-录入修改提交', null, 'FTZ_AddX_210314', null, '/FTZ210314/UptXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210315', '期权', null, 'FTZ_Add_X', 15, '/FTZ210315/AddXQry?optId=X', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_AddX_210315_UPDATE_SUBMIT', '期权-录入修改提交', null, 'FTZ_AddX_210315', null, '/FTZ210315/UptXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

prompt Done.
