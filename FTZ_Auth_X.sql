prompt Importing table sys_func_info...
set feedback off
set define off
insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_Auth_X', '交易流水号审核', null, 'FTZ_Auth', 9, '#', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210310', '远期结售汇', null, 'FTZ_Auth_X', 1, '/FTZOFF/AuthXQry?query_msgNo=210310', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', null);

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210310_1Dtl', '远期结售汇审核-查看详情', null, 'FTZ_XAuth_210310', null, '/FTZ210310/QryXAuthDtl', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210310_2Dtl', '远期结售汇审核-查看明细', null, 'FTZ_XAuth_210310', null, '/FTZ210310/QryXAuthDtlDtl', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210310_2Sbm', '远期结售汇审核-审核批量', null, 'FTZ_XAuth_210310', null, '/FTZ210310/AuthXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210310_3Sbm', '远期结售汇审核-审核明细', null, 'FTZ_XAuth_210310', null, '/FTZ210310/AuthXDtlDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XBacthAuth_210310_CTL', '远期结售汇-批量审核批量头', null, 'FTZ_XAuth_210310', null, '/FTZBatchCheck/offXMsgCheck', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XBacthAuth_210310_DTL', '远期结售汇-批量审核批量明细', null, 'FTZ_XAuth_210310', null, '/FTZBatchCheck/offXDtlCheck', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210311', '汇率掉期业务(远期未交割部分)', null, 'FTZ_Auth_X', 2, '/FTZOFF/AuthXQry?query_msgNo=210311', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', null);

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210311_1Dtl', '汇率掉期业务审核-查看详情', null, 'FTZ_XAuth_210311', null, '/FTZ210311/QryXAuthDtl', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210311_2Dtl', '汇率掉期业务审核-查看明细', null, 'FTZ_XAuth_210311', null, '/FTZ210311/QryXAuthDtlDtl', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210311_2Sbm', '汇率掉期业务审核-审核批量', null, 'FTZ_XAuth_210311', null, '/FTZ210311/AuthXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210311_3Sbm', '汇率掉期业务审核-审核明细', null, 'FTZ_XAuth_210311', null, '/FTZ210311/AuthXDtlDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XBacthAuth_210311_CTL', '汇率掉期业务-批量审核批量头', null, 'FTZ_XAuth_210311', null, '/FTZBatchCheck/offXMsgCheck', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XBacthAuth_210311_DTL', '汇率掉期业务-批量审核批量明细', null, 'FTZ_XAuth_210311', null, '/FTZBatchCheck/offXDtlCheck', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210312', '汇率期权', null, 'FTZ_Auth_X', 3, '/FTZ210312/AddXQry?optId=C', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210312_SUBMIT', '汇率期权-审核提交', null, 'FTZ_XAuth_210312', null, '/FTZ210312/AuthXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210313', '远期和期货', null, 'FTZ_Auth_X', 4, '/FTZ210313/AddXQry?optId=C', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210313_SUBMIT', '远期和期货-审核提交', null, 'FTZ_XAuth_210313', null, '/FTZ210313/AuthXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210314', '掉期', null, 'FTZ_Auth_X', 5, '/FTZ210314/AddXQry?optId=C', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210314_SUBMIT', '掉期-审核提交', null, 'FTZ_XAuth_210314', null, '/FTZ210314/AuthXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210315', '期权', null, 'FTZ_Auth_X', 6, '/FTZ210315/AddXQry?optId=C', null, null, null, null, null, null, null, null, null, null, '0', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_210315_SUBMIT', '期权-审核提交', null, 'FTZ_XAuth_210315', null, '/FTZ210315/AuthXDtlSubmit', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'M');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_2103_1Qry', '表外及其他审核-查询批量', null, 'FTZ_Auth_X', null, '/FTZOFF/AuthXQry', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_2103_1Red', '表外及其他审核-查看待审核明细', null, 'FTZ_Auth_X', null, '/FTZOFF/QryXRedirectAuth', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XAuth_2103_1RedA', '表外及其他审核-查看所有明细', null, 'FTZ_Auth_X', null, '/FTZOFF/QryXRedirectAuthAll', null, null, null, null, null, null, null, null, null, null, '1', '0', 'FTZMIS', 'Q');

insert into sys_func_info (FUNC_ID, FUNC_DESC, FUNC_I18N, SUP_FUNC_ID, FUNC_LVL, FUNC_URL, FUNC_PARA, CREATE_TIME, CREATE_USER, UPDATE_TIME, UPDATE_USER, RSV1, RSV2, RSV3, RSV4, RSV5, IS_BTN, IS_EDITABLE, SYSTEM_ID, OPT_TYPE)
values ('FTZ_XBathAuth_off2', '批量审核批量off2', null, 'FTZ_Auth_X', null, '/FTZBatchCheck/off2XCheck', null, null, null, null, null, null, null, null, null, null, '1', '1', 'FTZMIS', 'C');

prompt Done.
