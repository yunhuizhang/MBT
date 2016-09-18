-----------------------------------------------
-- Export file for user BCRIS                --
-- Created by 1483437 on 2016/9/14, 13:28:05 --
-----------------------------------------------

spool MBT2.0数据表结构.log

prompt
prompt Creating table CCT_T_CONVERT_BANKACCEPTS
prompt ========================================
prompt
create table CCT_T_CONVERT_BANKACCEPTS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  card_no        VARCHAR2(300),
  proto_no       VARCHAR2(300),
  proto_noold    VARCHAR2(300),
  bill_no        VARCHAR2(300),
  bill_noold     VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  remitter_name  VARCHAR2(300),
  money_kind     VARCHAR2(300),
  bill_money     VARCHAR2(300),
  accept_date    VARCHAR2(300),
  maturity_date  VARCHAR2(300),
  pay_date       VARCHAR2(300),
  deposit_scale  VARCHAR2(300),
  assure_flag    VARCHAR2(300),
  diankuanflag   VARCHAR2(300),
  bill_status    VARCHAR2(300),
  five_class     VARCHAR2(300),
  rpttype        VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  protonochg     VARCHAR2(300),
  billnochg      VARCHAR2(300),
  traceno        VARCHAR2(300),
  trustno        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_BAOHANS
prompt ====================================
prompt
create table CCT_T_CONVERT_BAOHANS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  baohan_no      VARCHAR2(300),
  baohan_noold   VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  baohan_kind    VARCHAR2(300),
  baohan_status  VARCHAR2(300),
  money_kind     VARCHAR2(300),
  baohan_money   VARCHAR2(300),
  start_date     VARCHAR2(300),
  end_date       VARCHAR2(300),
  deposit_scale  VARCHAR2(300),
  assure_flag    VARCHAR2(300),
  diankuanflag   VARCHAR2(300),
  baohan_balance VARCHAR2(300),
  balance_date   VARCHAR2(300),
  five_class     VARCHAR2(300),
  rpttype        VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  baohannochg    VARCHAR2(300),
  traceno        VARCHAR2(300),
  trustno        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_BAOLIS
prompt ===================================
prompt
create table CCT_T_CONVERT_BAOLIS
(
  id               VARCHAR2(300),
  orgcode          VARCHAR2(300),
  orgcodeold       VARCHAR2(300),
  loancont_no      VARCHAR2(300),
  loancont_noold   VARCHAR2(300),
  card_no          VARCHAR2(300),
  name             VARCHAR2(300),
  ywdate           VARCHAR2(300),
  operation_type   VARCHAR2(300),
  baoli_type       VARCHAR2(300),
  baoli_status     VARCHAR2(300),
  money_kind       VARCHAR2(300),
  money            VARCHAR2(300),
  loancont_date    VARCHAR2(300),
  loancont_balance VARCHAR2(300),
  balance_date     VARCHAR2(300),
  assure_flag      VARCHAR2(300),
  diankuanflag     VARCHAR2(300),
  four_class       VARCHAR2(300),
  five_class       VARCHAR2(300),
  rpttype          VARCHAR2(300),
  orgcodechg       VARCHAR2(300),
  loancontnochg    VARCHAR2(300),
  traceno          VARCHAR2(300),
  trustno          VARCHAR2(300),
  realywdate       VARCHAR2(300),
  incenter         VARCHAR2(300),
  rptdate          VARCHAR2(300),
  step_id          VARCHAR2(5),
  bat_date         VARCHAR2(8),
  task_id          VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_BILLDISCOUNTS
prompt ==========================================
prompt
create table CCT_T_CONVERT_BILLDISCOUNTS
(
  id              VARCHAR2(300),
  orgcode         VARCHAR2(300),
  orgcodeold      VARCHAR2(300),
  bill_no         VARCHAR2(300),
  bill_noold      VARCHAR2(300),
  card_no         VARCHAR2(300),
  ywdate          VARCHAR2(300),
  operation_type  VARCHAR2(300),
  bill_kind       VARCHAR2(300),
  proposer_name   VARCHAR2(300),
  acceptor_name   VARCHAR2(300),
  acceptor_card   VARCHAR2(300),
  acceptororgcode VARCHAR2(300),
  money_kind      VARCHAR2(300),
  discount_money  VARCHAR2(300),
  discount_date   VARCHAR2(300),
  accept_date     VARCHAR2(300),
  bill_money      VARCHAR2(300),
  bill_status     VARCHAR2(300),
  four_class      VARCHAR2(300),
  five_class      VARCHAR2(300),
  rpttype         VARCHAR2(300),
  orgcodechg      VARCHAR2(300),
  billnochg       VARCHAR2(300),
  trust           VARCHAR2(300),
  traceno         VARCHAR2(300),
  realywdate      VARCHAR2(300),
  incenter        VARCHAR2(300),
  rptdate         VARCHAR2(300),
  step_id         VARCHAR2(5),
  bat_date        VARCHAR2(8),
  task_id         VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_BILLEXPS
prompt =====================================
prompt
create table CCT_T_CONVERT_BILLEXPS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  loancont_no    VARCHAR2(300),
  bill_no        VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  exp_times      VARCHAR2(300),
  exp_timesold   VARCHAR2(300),
  exp_money      VARCHAR2(300),
  exp_balance    VARCHAR2(300),
  start_date     VARCHAR2(300),
  end_date       VARCHAR2(300),
  rpttype        VARCHAR2(300),
  exptimeschg    VARCHAR2(300),
  traceno        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  bill_id        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_BINVCAPITALS
prompt =========================================
prompt
create table CCT_T_CONVERT_BINVCAPITALS
(
  id               VARCHAR2(300),
  orgcode          VARCHAR2(300),
  mainid           VARCHAR2(300),
  card_no          VARCHAR2(300),
  investor         VARCHAR2(300),
  investor_card    VARCHAR2(300),
  certifycode      VARCHAR2(300),
  certifytype      VARCHAR2(300),
  regcode          VARCHAR2(300),
  investor_orgcode VARCHAR2(300),
  money_kind       VARCHAR2(300),
  money            VARCHAR2(300),
  incenter         VARCHAR2(300),
  operation_type   VARCHAR2(300),
  step_id          VARCHAR2(5),
  bat_date         VARCHAR2(8),
  task_id          VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_BORROWERS
prompt ======================================
prompt
create table CCT_T_CONVERT_BORROWERS
(
  id               VARCHAR2(300),
  orgcode          VARCHAR2(300),
  orgcodeold       VARCHAR2(300),
  card_no          VARCHAR2(300),
  card_noold       VARCHAR2(300),
  ywdate           VARCHAR2(300),
  operation_type   VARCHAR2(300),
  name_cn          VARCHAR2(300),
  name_ucn         VARCHAR2(300),
  country          VARCHAR2(300),
  certify_type     VARCHAR2(300),
  certify_code     VARCHAR2(300),
  jkr_create_year  VARCHAR2(300),
  regist_type      VARCHAR2(300),
  regist_code      VARCHAR2(300),
  regist_date      VARCHAR2(300),
  licence_maturity VARCHAR2(300),
  gsh_login_no     VARCHAR2(300),
  dsh_login_n      VARCHAR2(300),
  jkr_kind         VARCHAR2(300),
  trade_code       VARCHAR2(300),
  intrade_num      VARCHAR2(300),
  district_code    VARCHAR2(300),
  jkr_inpress      VARCHAR2(300),
  jkr_phone        VARCHAR2(300),
  jkr_regist_addr  VARCHAR2(300),
  jkr_fax          VARCHAR2(300),
  jkr_email        VARCHAR2(300),
  jkr_url          VARCHAR2(300),
  jkr_comm_addr    VARCHAR2(300),
  postcode         VARCHAR2(300),
  mainproducts     VARCHAR2(300),
  field_area       VARCHAR2(300),
  ownership        VARCHAR2(300),
  group_flag       VARCHAR2(300),
  impexp_flag      VARCHAR2(300),
  inmarket_flag    VARCHAR2(300),
  rpttype          VARCHAR2(300),
  orgcodechg       VARCHAR2(300),
  cardnochg        VARCHAR2(300),
  traceno          VARCHAR2(300),
  realywdate       VARCHAR2(300),
  incenter         VARCHAR2(300),
  rptdate          VARCHAR2(300),
  step_id          VARCHAR2(5),
  bat_date         VARCHAR2(8),
  task_id          VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_BSS
prompt ================================
prompt
create table CCT_T_CONVERT_BSS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  report_year    VARCHAR2(300),
  report_type    VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  card_noold     VARCHAR2(300),
  report_yearold VARCHAR2(300),
  report_typeold VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  cardnochg      VARCHAR2(300),
  reportyearchg  VARCHAR2(300),
  reporttypechg  VARCHAR2(300),
  report_detail  VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  hbzj           VARCHAR2(300),
  dqtz           VARCHAR2(300),
  yspj           VARCHAR2(300),
  ysgl           VARCHAR2(300),
  yslx           VARCHAR2(300),
  yszk           VARCHAR2(300),
  qtys           VARCHAR2(300),
  yfzk           VARCHAR2(300),
  qhbzj          VARCHAR2(300),
  ysbtk          VARCHAR2(300),
  ysckts         VARCHAR2(300),
  ch             VARCHAR2(300),
  chycl          VARCHAR2(300),
  chccp          VARCHAR2(300),
  dtfy           VARCHAR2(300),
  dclss          VARCHAR2(300),
  dqcqtz         VARCHAR2(300),
  qtldzc         VARCHAR2(300),
  ldzchj         VARCHAR2(300),
  cqtz           VARCHAR2(300),
  cqgqtz         VARCHAR2(300),
  cqzqtz         VARCHAR2(300),
  hbcj           VARCHAR2(300),
  cqtzhj         VARCHAR2(300),
  gdzcyj         VARCHAR2(300),
  ljzj           VARCHAR2(300),
  gdzcjz         VARCHAR2(300),
  gdzczb         VARCHAR2(300),
  gdzcje         VARCHAR2(300),
  gdzcql         VARCHAR2(300),
  gcwz           VARCHAR2(300),
  zjgc           VARCHAR2(300),
  dclgzss        VARCHAR2(300),
  dzhj           VARCHAR2(300),
  wxzc           VARCHAR2(300),
  wztsyq         VARCHAR2(300),
  dyzc           VARCHAR2(300),
  dyzgzxl        VARCHAR2(300),
  dygzgz         VARCHAR2(300),
  qtcqzc         VARCHAR2(300),
  qtcqzcb        VARCHAR2(300),
  wxjqzhj        VARCHAR2(300),
  dyskjx         VARCHAR2(300),
  zchj           VARCHAR2(300),
  dqjk           VARCHAR2(300),
  yfpj           VARCHAR2(300),
  yinfzk         VARCHAR2(300),
  yuszk          VARCHAR2(300),
  yfgz           VARCHAR2(300),
  yfflf          VARCHAR2(300),
  yflr           VARCHAR2(300),
  yjsj           VARCHAR2(300),
  qtyjk          VARCHAR2(300),
  qtyfk          VARCHAR2(300),
  ytfy           VARCHAR2(300),
  yjfz           VARCHAR2(300),
  ndqcfz         VARCHAR2(300),
  qtldfz         VARCHAR2(300),
  ldfzhj         VARCHAR2(300),
  cqjk           VARCHAR2(300),
  yfzj           VARCHAR2(300),
  cqyfk          VARCHAR2(300),
  zxyfk          VARCHAR2(300),
  qtcqfz         VARCHAR2(300),
  cqfzcbj        VARCHAR2(300),
  cqfzhj         VARCHAR2(300),
  dyskdx         VARCHAR2(300),
  fzhj           VARCHAR2(300),
  ssgdqy         VARCHAR2(300),
  sszb           VARCHAR2(300),
  gjzb           VARCHAR2(300),
  jtzb           VARCHAR2(300),
  frzb           VARCHAR2(300),
  fzgyz          VARCHAR2(300),
  fzjtz          VARCHAR2(300),
  grzb           VARCHAR2(300),
  wszb           VARCHAR2(300),
  zbgj           VARCHAR2(300),
  yygj           VARCHAR2(300),
  ygfdyg         VARCHAR2(300),
  yygjgyj        VARCHAR2(300),
  ygbclz         VARCHAR2(300),
  fqrts          VARCHAR2(300),
  ffpll          VARCHAR2(300),
  wbzsc          VARCHAR2(300),
  syzqy          VARCHAR2(300),
  fzsyzhj        VARCHAR2(300),
  rpttype        VARCHAR2(300),
  chkhouse       VARCHAR2(300),
  checker        VARCHAR2(300),
  chktime        VARCHAR2(300),
  traceno        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_CASHS
prompt ==================================
prompt
create table CCT_T_CONVERT_CASHS
(
  id             VARCHAR2(300),
  name           VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  report_year    VARCHAR2(300),
  report_type    VARCHAR2(300),
  report_detail  VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  xsplwxj        VARCHAR2(300),
  sdsffh         VARCHAR2(300),
  sdqtjyygxj     VARCHAR2(300),
  jyhdxjlrxj     VARCHAR2(300),
  gmsplw         VARCHAR2(300),
  zfgzg          VARCHAR2(300),
  zfdgxsf        VARCHAR2(300),
  zfqtjyygxj     VARCHAR2(300),
  jyxjlcxj       VARCHAR2(300),
  jycsxjllje1    VARCHAR2(300),
  shtzsdxj       VARCHAR2(300),
  qdtzsdxj       VARCHAR2(300),
  czgzwzdje      VARCHAR2(300),
  sdqttzygxj     VARCHAR2(300),
  tzxjlrxj       VARCHAR2(300),
  gjgzwzxj       VARCHAR2(300),
  tzzfxj         VARCHAR2(300),
  zfqttzyg       VARCHAR2(300),
  tzxjlcxj       VARCHAR2(300),
  tzcsxjllje     VARCHAR2(300),
  xstzssxj       VARCHAR2(300),
  jkssxj         VARCHAR2(300),
  sdqtzzyg       VARCHAR2(300),
  zzxjlrxj       VARCHAR2(300),
  chzwzfxj       VARCHAR2(300),
  fpgllrxj       VARCHAR2(300),
  zfqtzzyg       VARCHAR2(300),
  zzxjlcxj       VARCHAR2(300),
  zzcsxjllje     VARCHAR2(300),
  hlbdyx         VARCHAR2(300),
  xjjxjdjw       VARCHAR2(300),
  jlr            VARCHAR2(300),
  jtzcjzzb       VARCHAR2(300),
  gdzccj         VARCHAR2(300),
  wxzctx         VARCHAR2(300),
  cqdtfytx       VARCHAR2(300),
  dtfyjs         VARCHAR2(300),
  ytfyzj         VARCHAR2(300),
  czgzdss        VARCHAR2(300),
  gzbfss         VARCHAR2(300),
  cwfy           VARCHAR2(300),
  tzss           VARCHAR2(300),
  dyskdx         VARCHAR2(300),
  chjs           VARCHAR2(300),
  jyxsfjs        VARCHAR2(300),
  jyxyfjs        VARCHAR2(300),
  qt1            VARCHAR2(300),
  jycsxjllje2    VARCHAR2(300),
  zwzwzb         VARCHAR2(300),
  yndqkzzq       VARCHAR2(300),
  rzzrgz         VARCHAR2(300),
  qt2            VARCHAR2(300),
  xjqmye         VARCHAR2(300),
  xjqcye         VARCHAR2(300),
  xdqmye         VARCHAR2(300),
  xdqcye         VARCHAR2(300),
  xxdjze         VARCHAR2(300),
  rpttype        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  card_noold     VARCHAR2(300),
  report_yearold VARCHAR2(300),
  report_typeold VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  cardnochg      VARCHAR2(300),
  reportyearchg  VARCHAR2(300),
  reporttypechg  VARCHAR2(300),
  traceno        VARCHAR2(300),
  chkhouse       VARCHAR2(300),
  checker        VARCHAR2(300),
  chktime        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_COLREGS
prompt ====================================
prompt
create table CCT_T_CONVERT_COLREGS
(
  id         VARCHAR2(300),
  tableid    VARCHAR2(300),
  colname    VARCHAR2(300),
  coldef     VARCHAR2(300),
  iskey      VARCHAR2(300),
  length     VARCHAR2(300),
  coltype    VARCHAR2(300),
  idchg      VARCHAR2(300),
  olddata    VARCHAR2(300),
  chgchk     VARCHAR2(300),
  filledchar VARCHAR2(300),
  filledway  VARCHAR2(300),
  showinb    VARCHAR2(300),
  showinseg  VARCHAR2(300),
  must       VARCHAR2(300),
  step_id    VARCHAR2(5),
  bat_date   VARCHAR2(8),
  task_id    VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_CREDITBUSINESS
prompt ===========================================
prompt
create table CCT_T_CONVERT_CREDITBUSINESS
(
  id                  VARCHAR2(300),
  orgcode             VARCHAR2(300),
  orgcodeold          VARCHAR2(300),
  credit_no           VARCHAR2(300),
  credit_noold        VARCHAR2(300),
  card_no             VARCHAR2(300),
  name                VARCHAR2(300),
  ywdate              VARCHAR2(300),
  operation_type      VARCHAR2(300),
  money_kind          VARCHAR2(300),
  init_money          VARCHAR2(300),
  init_date           VARCHAR2(300),
  validity_period     VARCHAR2(300),
  pay_limit           VARCHAR2(300),
  deposit_scale       VARCHAR2(300),
  assure_flag         VARCHAR2(300),
  diankuanflag        VARCHAR2(300),
  credit_status       VARCHAR2(300),
  logout_date         VARCHAR2(300),
  credit_balance      VARCHAR2(300),
  balance_report_date VARCHAR2(300),
  five_class          VARCHAR2(300),
  rpttype             VARCHAR2(300),
  orgcodechg          VARCHAR2(300),
  creditnochg         VARCHAR2(300),
  trust               VARCHAR2(300),
  traceno             VARCHAR2(300),
  realywdate          VARCHAR2(300),
  incenter            VARCHAR2(300),
  rptdate             VARCHAR2(300),
  step_id             VARCHAR2(5),
  bat_date            VARCHAR2(8),
  task_id             VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_DICTIONARYS
prompt ========================================
prompt
create table CCT_T_CONVERT_DICTIONARYS
(
  id       VARCHAR2(300),
  codetype VARCHAR2(300),
  code     VARCHAR2(300),
  valdesc  VARCHAR2(900),
  remark   VARCHAR2(300),
  orders   VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_DKMESSAGES
prompt =======================================
prompt
create table CCT_T_CONVERT_DKMESSAGES
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  dkyw_no        VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  traceno        VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  dkkind         VARCHAR2(300),
  oldyw_no       VARCHAR2(300),
  money_kind     VARCHAR2(300),
  dkmoney        VARCHAR2(300),
  dkdate         VARCHAR2(300),
  dk_balance     VARCHAR2(300),
  balance_date   VARCHAR2(300),
  return_type    VARCHAR2(300),
  four_class     VARCHAR2(300),
  five_class     VARCHAR2(300),
  rpttype        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  dkywnoold      VARCHAR2(300),
  dkywnochg      VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_DKRETURN
prompt =====================================
prompt
create table CCT_T_CONVERT_DKRETURN
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  dkyw_no        VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  money_kind     VARCHAR2(300),
  return_money   VARCHAR2(300),
  return_date    VARCHAR2(300),
  rpttype        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_DKRETURNS
prompt ======================================
prompt
create table CCT_T_CONVERT_DKRETURNS
(
  id           VARCHAR2(300),
  orgcode      VARCHAR2(300),
  dkyw_no      VARCHAR2(300),
  card_no      VARCHAR2(300),
  return_no    VARCHAR2(300),
  return_money VARCHAR2(300),
  money_kind   VARCHAR2(300),
  return_date  VARCHAR2(300),
  return_style VARCHAR2(300),
  dkkind       VARCHAR2(300),
  ywdate       VARCHAR2(300),
  delstats     VARCHAR2(300),
  step_id      VARCHAR2(5),
  bat_date     VARCHAR2(8),
  task_id      VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_ENSURECONTRACTS
prompt ============================================
prompt
create table CCT_T_CONVERT_ENSURECONTRACTS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  contract_no    VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  trustloan_type VARCHAR2(300),
  ensure_no      VARCHAR2(300),
  ensure_num     VARCHAR2(300),
  ensure_name    VARCHAR2(300),
  ensure_card    VARCHAR2(300),
  certify_type   VARCHAR2(300),
  certify_no     VARCHAR2(300),
  money_kind     VARCHAR2(300),
  ensure_money   VARCHAR2(300),
  sign_date      VARCHAR2(300),
  ensure_style   VARCHAR2(300),
  valid_status   VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  ensurenoold    VARCHAR2(300),
  ensurenochg    VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_ERRREGS
prompt ====================================
prompt
create table CCT_T_CONVERT_ERRREGS
(
  id         VARCHAR2(300),
  errcode    VARCHAR2(300),
  checked    VARCHAR2(300),
  location   VARCHAR2(300),
  feedflname VARCHAR2(300),
  tableid    VARCHAR2(300),
  rptflname  VARCHAR2(300),
  recordid   VARCHAR2(300),
  step_id    VARCHAR2(5),
  bat_date   VARCHAR2(8),
  task_id    VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_EVENTINFORMATION
prompt =============================================
prompt
create table CCT_T_CONVERT_EVENTINFORMATION
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  serial_no      VARCHAR2(300),
  name           VARCHAR2(300),
  description    VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  serial_noold   VARCHAR2(300),
  serial_nochg   VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FAMILYMEMBERS
prompt ==========================================
prompt
create table CCT_T_CONVERT_FAMILYMEMBERS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  mainid         VARCHAR2(300),
  card_no        VARCHAR2(300),
  membername     VARCHAR2(300),
  certify_type   VARCHAR2(300),
  certify_code   VARCHAR2(300),
  relation       VARCHAR2(300),
  in_corp        VARCHAR2(300),
  corp_card      VARCHAR2(300),
  incenter       VARCHAR2(300),
  operation_type VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FEEDBACKS
prompt ======================================
prompt
create table CCT_T_CONVERT_FEEDBACKS
(
  id          VARCHAR2(300),
  filename    VARCHAR2(300),
  rptfilename VARCHAR2(300),
  processed   VARCHAR2(300),
  url         VARCHAR2(300),
  rcvtime     VARCHAR2(300),
  step_id     VARCHAR2(5),
  bat_date    VARCHAR2(8),
  task_id     VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FIELDREGS
prompt ======================================
prompt
create table CCT_T_CONVERT_FIELDREGS
(
  id        VARCHAR2(300),
  filename  VARCHAR2(300),
  lineno    VARCHAR2(300),
  startcol  VARCHAR2(300),
  tablename VARCHAR2(300),
  tableid   VARCHAR2(300),
  field     VARCHAR2(300),
  recordid  VARCHAR2(300),
  err       VARCHAR2(300),
  errstatus VARCHAR2(300),
  step_id   VARCHAR2(5),
  bat_date  VARCHAR2(8),
  task_id   VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FINANCEBUSINESS
prompt ============================================
prompt
create table CCT_T_CONVERT_FINANCEBUSINESS
(
  id              VARCHAR2(300),
  orgcode         VARCHAR2(300),
  proto_no        VARCHAR2(300),
  ywnochg         VARCHAR2(300),
  ywnoold         VARCHAR2(300),
  card_no         VARCHAR2(300),
  name            VARCHAR2(300),
  ywdate          VARCHAR2(300),
  operation_type  VARCHAR2(300),
  yw_no           VARCHAR2(300),
  yw_kind         VARCHAR2(300),
  money_kind      VARCHAR2(300),
  finance_money   VARCHAR2(300),
  finance_balance VARCHAR2(300),
  exp_flag        VARCHAR2(300),
  four_class      VARCHAR2(300),
  five_class      VARCHAR2(300),
  start_date      VARCHAR2(300),
  end_date        VARCHAR2(300),
  rpttype         VARCHAR2(300),
  traceno         VARCHAR2(300),
  realywdate      VARCHAR2(300),
  incenter        VARCHAR2(300),
  rptdate         VARCHAR2(300),
  step_id         VARCHAR2(5),
  bat_date        VARCHAR2(8),
  task_id         VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FINANCECONTACTS
prompt ============================================
prompt
create table CCT_T_CONVERT_FINANCECONTACTS
(
  id                VARCHAR2(300),
  card_no           VARCHAR2(300),
  mainid            VARCHAR2(300),
  finance_link_mode VARCHAR2(300),
  orgcode           VARCHAR2(300),
  incenter          VARCHAR2(300),
  operation_type    VARCHAR2(300),
  step_id           VARCHAR2(5),
  bat_date          VARCHAR2(8),
  task_id           VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FINANCEEXPS
prompt ========================================
prompt
create table CCT_T_CONVERT_FINANCEEXPS
(
  id                VARCHAR2(300),
  orgcode           VARCHAR2(300),
  proto_no          VARCHAR2(300),
  card_no           VARCHAR2(300),
  name              VARCHAR2(300),
  ywdate            VARCHAR2(300),
  operation_type    VARCHAR2(300),
  yw_no             VARCHAR2(300),
  exp_times         VARCHAR2(300),
  exp_timesold      VARCHAR2(300),
  exptimechg        VARCHAR2(300),
  exp_money         VARCHAR2(300),
  start_date        VARCHAR2(300),
  end_date          VARCHAR2(300),
  rpttype           VARCHAR2(300),
  traceno           VARCHAR2(300),
  realywdate        VARCHAR2(300),
  incenter          VARCHAR2(300),
  rptdate           VARCHAR2(300),
  financebusinessid VARCHAR2(300),
  step_id           VARCHAR2(5),
  bat_date          VARCHAR2(8),
  task_id           VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FINANCEMONEYS
prompt ==========================================
prompt
create table CCT_T_CONVERT_FINANCEMONEYS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  proto_no       VARCHAR2(300),
  card_no        VARCHAR2(300),
  mainid         VARCHAR2(300),
  money_kind     VARCHAR2(300),
  proto_money    VARCHAR2(300),
  proto_balance  VARCHAR2(300),
  incenter       VARCHAR2(300),
  operation_type VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FINANCEPROTOS
prompt ==========================================
prompt
create table CCT_T_CONVERT_FINANCEPROTOS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  proto_no       VARCHAR2(300),
  proto_noold    VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  start_date     VARCHAR2(300),
  end_date       VARCHAR2(300),
  assure_flag    VARCHAR2(300),
  proto_status   VARCHAR2(300),
  rpttype        VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  protonochg     VARCHAR2(300),
  traceno        VARCHAR2(300),
  trustno        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_FINANCERETURNS
prompt ===========================================
prompt
create table CCT_T_CONVERT_FINANCERETURNS
(
  id                VARCHAR2(300),
  orgcode           VARCHAR2(300),
  proto_no          VARCHAR2(300),
  card_no           VARCHAR2(300),
  name              VARCHAR2(300),
  ywdate            VARCHAR2(300),
  operation_type    VARCHAR2(300),
  yw_no             VARCHAR2(300),
  return_times      VARCHAR2(300),
  return_money      VARCHAR2(300),
  return_date       VARCHAR2(300),
  return_way        VARCHAR2(300),
  rpttype           VARCHAR2(300),
  traceno           VARCHAR2(300),
  realywdate        VARCHAR2(300),
  incenter          VARCHAR2(300),
  rptdate           VARCHAR2(300),
  financebusinessid VARCHAR2(300),
  step_id           VARCHAR2(5),
  bat_date          VARCHAR2(8),
  task_id           VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_GRPCORPS
prompt =====================================
prompt
create table CCT_T_CONVERT_GRPCORPS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  mainid         VARCHAR2(300),
  super_name     VARCHAR2(300),
  super_card     VARCHAR2(300),
  super_orgcode  VARCHAR2(300),
  incenter       VARCHAR2(300),
  operation_type VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_IMPAWNCONTRACT
prompt ===========================================
prompt
create table CCT_T_CONVERT_IMPAWNCONTRACT
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  contract_no    VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  trustloan_type VARCHAR2(300),
  impawn_no      VARCHAR2(300),
  impawn_num     VARCHAR2(300),
  impawn_name    VARCHAR2(300),
  impawn_card    VARCHAR2(300),
  eval_kind      VARCHAR2(300),
  eval_val       VARCHAR2(300),
  sign_date      VARCHAR2(300),
  impawn_kind    VARCHAR2(300),
  money_kind     VARCHAR2(300),
  impawn_money   VARCHAR2(300),
  valid_status   VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  impawnnoold    VARCHAR2(300),
  impawnnochg    VARCHAR2(300),
  impawnnumold   VARCHAR2(300),
  impawnnumchg   VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_INVCAPITALS
prompt ========================================
prompt
create table CCT_T_CONVERT_INVCAPITALS
(
  id               VARCHAR2(300),
  orgcode          VARCHAR2(300),
  card_no          VARCHAR2(300),
  mainid           VARCHAR2(300),
  toinvest         VARCHAR2(300),
  toinvest_card    VARCHAR2(300),
  regcode          VARCHAR2(300),
  certifycode      VARCHAR2(300),
  certifytype      VARCHAR2(300),
  toinvest_orgcode VARCHAR2(300),
  money_kind       VARCHAR2(300),
  money            VARCHAR2(300),
  incenter         VARCHAR2(300),
  operation_type   VARCHAR2(300),
  moneykind3       VARCHAR2(300),
  moneykind2       VARCHAR2(300),
  money3           VARCHAR2(300),
  money2           VARCHAR2(300),
  step_id          VARCHAR2(5),
  bat_date         VARCHAR2(8),
  task_id          VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LACKOFINTERESTS
prompt ============================================
prompt
create table CCT_T_CONVERT_LACKOFINTERESTS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  qxyw_no        VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  money_kind     VARCHAR2(300),
  qxyu           VARCHAR2(300),
  qxtype         VARCHAR2(300),
  change_date    VARCHAR2(300),
  qxdesc         VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  cardnoold      VARCHAR2(300),
  cardnochg      VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LAWINFORMATION
prompt ===========================================
prompt
create table CCT_T_CONVERT_LAWINFORMATION
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  serial_no      VARCHAR2(300),
  name           VARCHAR2(300),
  lawname        VARCHAR2(300),
  money_kind     VARCHAR2(300),
  judge_money    VARCHAR2(300),
  judge_date     VARCHAR2(300),
  result         VARCHAR2(300),
  reason         VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  serial_noold   VARCHAR2(300),
  serial_nochg   VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LOANBILLS
prompt ======================================
prompt
create table CCT_T_CONVERT_LOANBILLS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  loancont_no    VARCHAR2(300),
  bill_no        VARCHAR2(300),
  bill_noold     VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  money_kind     VARCHAR2(300),
  bill_money     VARCHAR2(300),
  bill_ye        VARCHAR2(300),
  create_date    VARCHAR2(300),
  maturity_date  VARCHAR2(300),
  loan_oper_kind VARCHAR2(300),
  loan_type      VARCHAR2(300),
  loan_property  VARCHAR2(300),
  loan_where     VARCHAR2(300),
  loan_kind      VARCHAR2(300),
  exp_flag       VARCHAR2(300),
  four_class     VARCHAR2(300),
  five_class     VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  billnochg      VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  contract_id    VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LOANCONTRACTS
prompt ==========================================
prompt
create table CCT_T_CONVERT_LOANCONTRACTS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  loancont_no    VARCHAR2(300),
  loancont_noold VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  start_date     VARCHAR2(300),
  end_date       VARCHAR2(300),
  yintuan_flag   VARCHAR2(300),
  assure_flag    VARCHAR2(300),
  rpttype        VARCHAR2(300),
  effect_flag    VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  loancontnochg  VARCHAR2(300),
  traceno        VARCHAR2(300),
  trust          VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LOANMONEYS
prompt =======================================
prompt
create table CCT_T_CONVERT_LOANMONEYS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  loancont_no    VARCHAR2(300),
  card_no        VARCHAR2(300),
  mainid         VARCHAR2(300),
  money_kind     VARCHAR2(300),
  money          VARCHAR2(300),
  useable_money  VARCHAR2(300),
  incenter       VARCHAR2(300),
  operation_type VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LOANRETURNS
prompt ========================================
prompt
create table CCT_T_CONVERT_LOANRETURNS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  loancont_no    VARCHAR2(300),
  bill_no        VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  return_date    VARCHAR2(300),
  return_times   VARCHAR2(300),
  return_mode    VARCHAR2(300),
  return_money   VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  bill_id        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LOGDICS
prompt ====================================
prompt
create table CCT_T_CONVERT_LOGDICS
(
  id       VARCHAR2(300),
  logcode  VARCHAR2(300),
  logname  VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_LOGINFOS
prompt =====================================
prompt
create table CCT_T_CONVERT_LOGINFOS
(
  id              VARCHAR2(300),
  orgcode         VARCHAR2(300),
  businesscode    VARCHAR2(300),
  businesstype    VARCHAR2(300),
  usercode        VARCHAR2(300),
  username        VARCHAR2(300),
  operationtype   VARCHAR2(300),
  operationtime   VARCHAR2(300),
  operationstatus VARCHAR2(300),
  step_id         VARCHAR2(5),
  bat_date        VARCHAR2(8),
  task_id         VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_MESSAGEINFOS
prompt =========================================
prompt
create table CCT_T_CONVERT_MESSAGEINFOS
(
  id        VARCHAR2(300),
  filename  VARCHAR2(300),
  errlevel  VARCHAR2(300),
  gentime   VARCHAR2(300),
  checked   VARCHAR2(300),
  feeded    VARCHAR2(300),
  fileurl   VARCHAR2(300),
  reportman VARCHAR2(300),
  rpttype   VARCHAR2(300),
  step_id   VARCHAR2(5),
  bat_date  VARCHAR2(8),
  task_id   VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_MESSAGESTAT
prompt ========================================
prompt
create table CCT_T_CONVERT_MESSAGESTAT
(
  reportdate VARCHAR2(300),
  message    VARCHAR2(300),
  unfeeded   VARCHAR2(300),
  record     VARCHAR2(300),
  fail       VARCHAR2(300),
  needmod    VARCHAR2(300),
  success    VARCHAR2(300),
  unparse    VARCHAR2(300),
  step_id    VARCHAR2(5),
  bat_date   VARCHAR2(8),
  task_id    VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_NTT_DUMMY_ECARD
prompt ============================================
prompt
create table CCT_T_CONVERT_NTT_DUMMY_ECARD
(
  id              VARCHAR2(300),
  ensure_name_one VARCHAR2(300),
  ensure_name_two VARCHAR2(300),
  ensure_card     VARCHAR2(300),
  rpt_date        VARCHAR2(300),
  del_flag        VARCHAR2(300),
  step_id         VARCHAR2(5),
  bat_date        VARCHAR2(8),
  task_id         VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_NTT_REPLACE_LOG
prompt ============================================
prompt
create table CCT_T_CONVERT_NTT_REPLACE_LOG
(
  id             VARCHAR2(300),
  contract_no    VARCHAR2(300),
  ensure_no      VARCHAR2(300),
  ensure_name    VARCHAR2(300),
  ensure_card    VARCHAR2(300),
  paper_type     VARCHAR2(300),
  paper_no       VARCHAR2(300),
  contract_flag  VARCHAR2(300),
  rpt_date       VARCHAR2(300),
  trustloan_type VARCHAR2(300),
  replace_time   VARCHAR2(300),
  contract_type  VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_OPENAWARDTRUSTS
prompt ============================================
prompt
create table CCT_T_CONVERT_OPENAWARDTRUSTS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  proto_no       VARCHAR2(300),
  card_no        VARCHAR2(300),
  name           VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  money_kind     VARCHAR2(300),
  sxjy           VARCHAR2(300),
  start_date     VARCHAR2(300),
  end_date       VARCHAR2(300),
  logout_date    VARCHAR2(300),
  logout_reason  VARCHAR2(300),
  rpttype        VARCHAR2(300),
  traceno        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  protonoold     VARCHAR2(300),
  protonochg     VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_OPERATERS
prompt ======================================
prompt
create table CCT_T_CONVERT_OPERATERS
(
  id        VARCHAR2(300),
  usercode  VARCHAR2(300),
  username  VARCHAR2(300),
  password  VARCHAR2(300),
  power     VARCHAR2(300),
  orgcode   VARCHAR2(300),
  logintime VARCHAR2(300),
  status    VARCHAR2(300),
  step_id   VARCHAR2(5),
  bat_date  VARCHAR2(8),
  task_id   VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_OPTROLES
prompt =====================================
prompt
create table CCT_T_CONVERT_OPTROLES
(
  id       VARCHAR2(300),
  usercode VARCHAR2(300),
  role     VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_ORGMSGS
prompt ====================================
prompt
create table CCT_T_CONVERT_ORGMSGS
(
  id       VARCHAR2(300),
  orgcode  VARCHAR2(300),
  orgname  VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_PBCATCOL
prompt =====================================
prompt
create table CCT_T_CONVERT_PBCATCOL
(
  pbc_tnam VARCHAR2(300),
  pbc_tid  VARCHAR2(300),
  pbc_ownr VARCHAR2(300),
  pbc_cnam VARCHAR2(300),
  pbc_cid  VARCHAR2(300),
  pbc_labl VARCHAR2(300),
  pbc_lpos VARCHAR2(300),
  pbc_hdr  VARCHAR2(300),
  pbc_hpos VARCHAR2(300),
  pbc_jtfy VARCHAR2(300),
  pbc_mask VARCHAR2(300),
  pbc_case VARCHAR2(300),
  pbc_hght VARCHAR2(300),
  pbc_wdth VARCHAR2(300),
  pbc_ptrn VARCHAR2(300),
  pbc_bmap VARCHAR2(300),
  pbc_init VARCHAR2(300),
  pbc_cmnt VARCHAR2(300),
  pbc_edit VARCHAR2(300),
  pbc_tag  VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_PBCATEDT
prompt =====================================
prompt
create table CCT_T_CONVERT_PBCATEDT
(
  pbe_name VARCHAR2(300),
  pbe_edit VARCHAR2(300),
  pbe_type VARCHAR2(300),
  pbe_cntr VARCHAR2(300),
  pbe_seqn VARCHAR2(300),
  pbe_flag VARCHAR2(300),
  pbe_work VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_PBCATFMT
prompt =====================================
prompt
create table CCT_T_CONVERT_PBCATFMT
(
  pbf_name VARCHAR2(300),
  pbf_frmt VARCHAR2(300),
  pbf_type VARCHAR2(300),
  pbf_cntr VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_PBCATTBL
prompt =====================================
prompt
create table CCT_T_CONVERT_PBCATTBL
(
  pbt_tnam VARCHAR2(300),
  pbt_tid  VARCHAR2(300),
  pbt_ownr VARCHAR2(300),
  pbd_fhgt VARCHAR2(300),
  pbd_fwgt VARCHAR2(300),
  pbd_fitl VARCHAR2(300),
  pbd_funl VARCHAR2(300),
  pbd_fchr VARCHAR2(300),
  pbd_fptc VARCHAR2(300),
  pbd_ffce VARCHAR2(300),
  pbh_fhgt VARCHAR2(300),
  pbh_fwgt VARCHAR2(300),
  pbh_fitl VARCHAR2(300),
  pbh_funl VARCHAR2(300),
  pbh_fchr VARCHAR2(300),
  pbh_fptc VARCHAR2(300),
  pbh_ffce VARCHAR2(300),
  pbl_fhgt VARCHAR2(300),
  pbl_fwgt VARCHAR2(300),
  pbl_fitl VARCHAR2(300),
  pbl_funl VARCHAR2(300),
  pbl_fchr VARCHAR2(300),
  pbl_fptc VARCHAR2(300),
  pbl_ffce VARCHAR2(300),
  pbt_cmnt VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_PBCATVLD
prompt =====================================
prompt
create table CCT_T_CONVERT_PBCATVLD
(
  pbv_name VARCHAR2(300),
  pbv_vald VARCHAR2(300),
  pbv_type VARCHAR2(300),
  pbv_cntr VARCHAR2(300),
  pbv_msg  VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_PLEDGECONTRACTS
prompt ============================================
prompt
create table CCT_T_CONVERT_PLEDGECONTRACTS
(
  id              VARCHAR2(300),
  orgcode         VARCHAR2(300),
  contract_no     VARCHAR2(300),
  card_no         VARCHAR2(300),
  name            VARCHAR2(300),
  ywdate          VARCHAR2(300),
  operation_type  VARCHAR2(300),
  trustloan_type  VARCHAR2(300),
  pledge_no       VARCHAR2(300),
  pledge_num      VARCHAR2(300),
  pledge_name     VARCHAR2(300),
  pledge_card     VARCHAR2(300),
  eval_money_kind VARCHAR2(300),
  pledge_val      VARCHAR2(300),
  eval_date       VARCHAR2(300),
  eval_orgname    VARCHAR2(300),
  eval_orgcode    VARCHAR2(300),
  sign_date       VARCHAR2(300),
  pledge_kind     VARCHAR2(300),
  money_kind      VARCHAR2(300),
  pledge_money    VARCHAR2(300),
  login_org       VARCHAR2(300),
  login_date      VARCHAR2(300),
  pledge_desc     VARCHAR2(900),
  valid_status    VARCHAR2(300),
  rpttype         VARCHAR2(300),
  traceno         VARCHAR2(300),
  orgcodeold      VARCHAR2(300),
  orgcodechg      VARCHAR2(300),
  pledgenoold     VARCHAR2(300),
  pledgenochg     VARCHAR2(300),
  pledgenumold    VARCHAR2(300),
  pledgenumchg    VARCHAR2(300),
  realywdate      VARCHAR2(300),
  incenter        VARCHAR2(300),
  rptdate         VARCHAR2(300),
  step_id         VARCHAR2(5),
  bat_date        VARCHAR2(8),
  task_id         VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_PROFITS
prompt ====================================
prompt
create table CCT_T_CONVERT_PROFITS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  name           VARCHAR2(300),
  card_no        VARCHAR2(300),
  report_year    VARCHAR2(300),
  report_type    VARCHAR2(300),
  report_detail  VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  zyywsr         VARCHAR2(300),
  zscksr         VARCHAR2(300),
  zsjksr         VARCHAR2(300),
  zkycr          VARCHAR2(300),
  zysrje         VARCHAR2(300),
  zycb           VARCHAR2(300),
  zycbckcb       VARCHAR2(300),
  zysjfj         VARCHAR2(300),
  jyfy           VARCHAR2(300),
  qt1            VARCHAR2(300),
  dysy           VARCHAR2(300),
  dgdxsr         VARCHAR2(300),
  qt2            VARCHAR2(300),
  zylr           VARCHAR2(300),
  qtywlr         VARCHAR2(300),
  yyfy           VARCHAR2(300),
  glfy           VARCHAR2(300),
  cwfy           VARCHAR2(300),
  qt3            VARCHAR2(300),
  yylr           VARCHAR2(300),
  tzsy           VARCHAR2(300),
  qhsy           VARCHAR2(300),
  btsr           VARCHAR2(300),
  qkqybt         VARCHAR2(300),
  yywsr          VARCHAR2(300),
  ywsrczgzsr     VARCHAR2(300),
  ywsrfhbjysr    VARCHAR2(300),
  ywsrcswxsr     VARCHAR2(300),
  ywsrfkjsr      VARCHAR2(300),
  qt4            VARCHAR2(300),
  qtndgzjymblr   VARCHAR2(300),
  yywzc          VARCHAR2(300),
  ywzcczgzs      VARCHAR2(300),
  ywzczwczs      VARCHAR2(300),
  ywzcfkzc       VARCHAR2(300),
  ywzcjzzc       VARCHAR2(300),
  qtzc           VARCHAR2(300),
  qtzcjzjy       VARCHAR2(300),
  lrze           VARCHAR2(300),
  sds            VARCHAR2(300),
  ssgdsy         VARCHAR2(300),
  wqrdtzss       VARCHAR2(300),
  jlr            VARCHAR2(300),
  ncwfplr        VARCHAR2(300),
  yygjbk         VARCHAR2(300),
  qttzys         VARCHAR2(300),
  kgfpdlr        VARCHAR2(300),
  dxlylr         VARCHAR2(300),
  bcldzb         VARCHAR2(300),
  tqfdyygj       VARCHAR2(300),
  tqfdgyj        VARCHAR2(300),
  tqzgjlfl       VARCHAR2(300),
  tqcbjj         VARCHAR2(300),
  tqqyfzjj       VARCHAR2(300),
  lrghtz         VARCHAR2(300),
  qt5            VARCHAR2(300),
  kgtzzfp        VARCHAR2(300),
  yfyxggl        VARCHAR2(300),
  tqryyygj       VARCHAR2(300),
  yfptggl        VARCHAR2(300),
  zzzbptgl       VARCHAR2(300),
  qt6            VARCHAR2(300),
  wfplr          VARCHAR2(300),
  wfphndmb       VARCHAR2(300),
  rpttype        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  card_noold     VARCHAR2(300),
  report_yearold VARCHAR2(300),
  report_typeold VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  cardnochg      VARCHAR2(300),
  reportyearchg  VARCHAR2(300),
  reporttypechg  VARCHAR2(300),
  traceno        VARCHAR2(300),
  chkhouse       VARCHAR2(300),
  checker        VARCHAR2(300),
  chktime        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_RECORDREGS
prompt =======================================
prompt
create table CCT_T_CONVERT_RECORDREGS
(
  id            VARCHAR2(300),
  filename      VARCHAR2(300),
  lineno        VARCHAR2(300),
  maintablename VARCHAR2(300),
  maintableid   VARCHAR2(300),
  recordid      VARCHAR2(300),
  messagetype   VARCHAR2(300),
  traceno       VARCHAR2(300),
  errstatus     VARCHAR2(300),
  oldrpttype    VARCHAR2(300),
  step_id       VARCHAR2(5),
  bat_date      VARCHAR2(8),
  task_id       VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_REGCAPITALS
prompt ========================================
prompt
create table CCT_T_CONVERT_REGCAPITALS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  orgcodeold     VARCHAR2(300),
  card_no        VARCHAR2(300),
  card_noold     VARCHAR2(300),
  ywdate         VARCHAR2(300),
  operation_type VARCHAR2(300),
  money_kind     VARCHAR2(300),
  money          VARCHAR2(300),
  rpttype        VARCHAR2(300),
  orgcodechg     VARCHAR2(300),
  cardnochg      VARCHAR2(300),
  traceno        VARCHAR2(300),
  realywdate     VARCHAR2(300),
  incenter       VARCHAR2(300),
  rptdate        VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_REPORTFILES
prompt ========================================
prompt
create table CCT_T_CONVERT_REPORTFILES
(
  id          VARCHAR2(300),
  messagetype VARCHAR2(300),
  filetype    VARCHAR2(300),
  fileorder   VARCHAR2(300),
  step_id     VARCHAR2(5),
  bat_date    VARCHAR2(8),
  task_id     VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_ROLETYPES
prompt ======================================
prompt
create table CCT_T_CONVERT_ROLETYPES
(
  id       VARCHAR2(300),
  rolecode VARCHAR2(300),
  rolename VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_STOCKS
prompt ===================================
prompt
create table CCT_T_CONVERT_STOCKS
(
  id             VARCHAR2(300),
  mainid         VARCHAR2(300),
  card_no        VARCHAR2(300),
  stock_code     VARCHAR2(300),
  market_addr    VARCHAR2(300),
  orgcode        VARCHAR2(300),
  incenter       VARCHAR2(300),
  operation_type VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_SUPERMANS
prompt ======================================
prompt
create table CCT_T_CONVERT_SUPERMANS
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  card_no        VARCHAR2(300),
  mainid         VARCHAR2(300),
  super_name     VARCHAR2(300),
  certify_type   VARCHAR2(300),
  certify_code   VARCHAR2(300),
  super_kind     VARCHAR2(300),
  super_sex      VARCHAR2(300),
  super_birthday VARCHAR2(300),
  super_edu      VARCHAR2(300),
  super_exp      VARCHAR2(300),
  incenter       VARCHAR2(300),
  operation_type VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_SYSDATAS
prompt =====================================
prompt
create table CCT_T_CONVERT_SYSDATAS
(
  id       VARCHAR2(300),
  toporg   VARCHAR2(300),
  nodeid   VARCHAR2(300),
  step_id  VARCHAR2(5),
  bat_date VARCHAR2(8),
  task_id  VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_SYSLOGINFOS
prompt ========================================
prompt
create table CCT_T_CONVERT_SYSLOGINFOS
(
  id              VARCHAR2(300),
  orgcode         VARCHAR2(300),
  systemtype      VARCHAR2(300),
  usercode        VARCHAR2(300),
  username        VARCHAR2(300),
  operationtype   VARCHAR2(300),
  operationtime   VARCHAR2(300),
  operationstatus VARCHAR2(300),
  step_id         VARCHAR2(5),
  bat_date        VARCHAR2(8),
  task_id         VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_TABLEREGS
prompt ======================================
prompt
create table CCT_T_CONVERT_TABLEREGS
(
  id             VARCHAR2(300),
  tableid        VARCHAR2(300),
  tablelength    VARCHAR2(300),
  tablename      VARCHAR2(300),
  tabledes       VARCHAR2(300),
  bsytype        VARCHAR2(300),
  messagetype    VARCHAR2(300),
  nexttableid    VARCHAR2(300),
  segid          VARCHAR2(300),
  maintableid    VARCHAR2(300),
  ismain         VARCHAR2(300),
  inmessageorder VARCHAR2(300),
  maincontract   VARCHAR2(300),
  batchdel       VARCHAR2(300),
  ordercol       VARCHAR2(300),
  specprocess    VARCHAR2(300),
  borrowername   VARCHAR2(300),
  updateurl      VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_USERS
prompt ==================================
prompt
create table CCT_T_CONVERT_USERS
(
  id        VARCHAR2(300),
  user_name VARCHAR2(300),
  user_pass VARCHAR2(300),
  step_id   VARCHAR2(5),
  bat_date  VARCHAR2(8),
  task_id   VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_USER_ROLES
prompt =======================================
prompt
create table CCT_T_CONVERT_USER_ROLES
(
  id        VARCHAR2(300),
  user_name VARCHAR2(300),
  role_name VARCHAR2(300),
  step_id   VARCHAR2(5),
  bat_date  VARCHAR2(8),
  task_id   VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_WTJ
prompt ================================
prompt
create table CCT_T_CONVERT_WTJ
(
  orgcode      VARCHAR2(300),
  loancont_no  VARCHAR2(300),
  bill_no      VARCHAR2(300),
  return_money VARCHAR2(300),
  step_id      VARCHAR2(5),
  bat_date     VARCHAR2(8),
  task_id      VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_WTJ1
prompt =================================
prompt
create table CCT_T_CONVERT_WTJ1
(
  orgcode     VARCHAR2(300),
  loancont_no VARCHAR2(300),
  c           VARCHAR2(300),
  step_id     VARCHAR2(5),
  bat_date    VARCHAR2(8),
  task_id     VARCHAR2(5)
)
;

prompt
prompt Creating table CCT_T_CONVERT_WTJ2
prompt =================================
prompt
create table CCT_T_CONVERT_WTJ2
(
  id             VARCHAR2(300),
  orgcode        VARCHAR2(300),
  loancont_no    VARCHAR2(300),
  card_no        VARCHAR2(300),
  mainid         VARCHAR2(300),
  money_kind     VARCHAR2(300),
  money          VARCHAR2(300),
  useable_money  VARCHAR2(300),
  incenter       VARCHAR2(300),
  operation_type VARCHAR2(300),
  step_id        VARCHAR2(5),
  bat_date       VARCHAR2(8),
  task_id        VARCHAR2(5)
)
;


spool off
