-------------------------------------------
-- Export file for user MBT              --
-- Created by 136 on 2018/5/18, 10:35:55 --
-------------------------------------------

set define off
spool imp_mbt.log

prompt
prompt Creating function CCI_GET_CNAPS_CODE
prompt ====================================
prompt
CREATE OR REPLACE FUNCTION MBT."CCI_GET_CNAPS_CODE"  --获取所属机构代码
(
   I_TP_SYSTEM       VARCHAR,
   I_SCB_BRANCH      VARCHAR
 )
RETURN VARCHAR2 IS
  O_CODE                    VARCHAR2(20);
BEGIN
  O_CODE := null;
    BEGIN
        SELECT NVL(T.REPORTING_BRANCH,T.PBOC_BRANCH)
        INTO O_CODE
        FROM CCI_PARAM_ETL_STD_BRANCH T
       WHERE TRIM(T.TP_SYSTEM)  = TRIM(I_TP_SYSTEM)
         AND TRIM(T.SCB_BRANCH) = TRIM(I_SCB_BRANCH);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        O_CODE := null;
    END;

  RETURN O_CODE;
END CCI_GET_CNAPS_CODE;
/

prompt
prompt Creating function CCI_GET_SERIAL_NO
prompt ===================================
prompt
CREATE OR REPLACE FUNCTION MBT.CCI_GET_SERIAL_NO -- 获取17位序列号，由14位日期时间 + 3位流水号组成
RETURN CHAR
IS
    v_seq NUMBER;
BEGIN
    SELECT CCI_S_SEQ.NEXTVAL INTO v_seq
    FROM   DUAL;

    RETURN TO_CHAR(SYSDATE, 'yyyymmddhh24miss')||lpad(v_seq, 3, '0');

EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function CCI_GET_USD
prompt =============================
prompt
CREATE OR REPLACE FUNCTION MBT.CCI_GET_USD(I_MONEY_ID  IN VARCHAR, --币种
                                       I_AMOUNT    IN NUMBER, --金额
                                       I_DATA_DATE IN VARCHAR) --日期
 RETURN NUMBER IS
  O_USD_AMOUNT NUMBER;
BEGIN
  BEGIN
    IF I_MONEY_ID = 'USD' THEN
      O_USD_AMOUNT := I_AMOUNT;
    ELSE
      SELECT NVL(RATE * I_AMOUNT, 0)
        INTO O_USD_AMOUNT
        FROM CCI_DF_SAFE_RATE
       WHERE MONEY_ID = I_MONEY_ID
         AND ROWNUM = 1;
      /* AND TO_CHAR(TO_DATE(DATA_DATE, 'YYYY/MM/DD'), 'YYYYMM') =
      SUBSTR(I_DATA_DATE, 0, 6)*/
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_USD_AMOUNT := 0;
  END;
  RETURN O_USD_AMOUNT;
END CCI_GET_USD;
/

prompt
prompt Creating function CCI_GET_WORK_DATE
prompt ===================================
prompt
CREATE OR REPLACE FUNCTION MBT."CCI_GET_WORK_DATE"  --获取工作日，i_type为自然数，正数表示传入的日期往后推，负数表示当前日期往前推
(
   i_date VARCHAR2,
   i_type NUMBER
)
 RETURN VARCHAR2
 IS v_date VARCHAR(8);
    o_date VARCHAR(8);
 BEGIN
    o_date := i_date;
 IF i_type > 0 THEN
 SELECT BAT_DATE INTO v_date FROM
  (SELECT T.*, ROWNUM RN FROM
    (SELECT * FROM BAT_DATE_INFO WHERE WORKDAY = 'Y'
     AND BAT_DATE > i_date ORDER BY BAT_DATE ASC) T)
     WHERE RN = abs(i_type);
 ELSIF i_type < 0 THEN
 SELECT BAT_DATE INTO v_date FROM
  (SELECT T.*, ROWNUM RN FROM
    (SELECT * FROM BAT_DATE_INFO WHERE WORKDAY = 'Y'AND BAT_DATE < i_date ORDER BY BAT_DATE DESC) T)WHERE RN = abs(i_type);
 ELSE
   SELECT BAT_DATE INTO v_date FROM
   (SELECT T.*, ROWNUM RN FROM
    (SELECT * FROM BAT_DATE_INFO WHERE WORKDAY = 'Y'AND BAT_DATE <= i_date ORDER BY BAT_DATE DESC) T)WHERE RN = 1;
 END IF;
 o_date := v_date ;
 RETURN o_date;
 EXCEPTION WHEN OTHERS THEN
   RETURN NULL;
 END;
/

prompt
prompt Creating procedure CCI_INSERT_LOG_ERROR
prompt =======================================
prompt
CREATE OR REPLACE PROCEDURE MBT."CCI_INSERT_LOG_ERROR"
(
    i_biz_type     IN  VARCHAR,
    i_err_level    IN  NUMBER,
    i_err_code     IN  VARCHAR,
    i_err_msg      IN  VARCHAR2,
    i_record_key   IN  VARCHAR2,
    i_send_status  IN  CHAR,
    i_serial_no    IN  VARCHAR2
)
IS
BEGIN
    INSERT INTO CCI_PROC_ERROR_LOG(id,
                                   biz_type,
                                   err_levet,
                                   err_code,
                                   err_msg,
                                   record_key,
                                   err_datetime,
                                   send_status,
                                   serial_no,
                                   rsv1,
                                   ops,
                                   owner,
                                   err_col)
    VALUES      (lpad(TO_CHAR(SYSDATE, 'yyyymmddhh24miss')|| CCI_S_SEQ.NEXTVAL, 32, '0'),
                 i_biz_type,
                 i_err_level,
                 i_err_code,
                 i_err_msg,
                 i_record_key,
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss'),
                 i_send_status,
                 i_serial_no,
                 null,
                 null,
                 null,
                 null);
EXCEPTION
    WHEN OTHERS THEN
    NULL;
END;
/

prompt
prompt Creating procedure CCI_ETL_TO_FULL_D
prompt ====================================
prompt
CREATE OR REPLACE PROCEDURE MBT.CCI_ETL_TO_FULL_D(I_DATA_DATE  IN VARCHAR2,
                                              O_ERROR_CODE OUT VARCHAR2, -- ERROR CODE
                                              O_ERROR_MSG  OUT VARCHAR2 -- ERROR MESSAGE
                                              ) IS

  -- THE SERIAL NUMBER
  V_SERIAL_NO CHAR(17);
  T_1         CHAR(8);
  T_10        CHAR(8);
  JOB_NAME_LOCAL CONSTANT VARCHAR2(120) := 'CCI_ETL_TO_FULL_D';
BEGIN
  V_SERIAL_NO := CCI_GET_SERIAL_NO();
  T_1         := CCI_GET_WORK_DATE(I_DATA_DATE, -1);
  T_10        := CCI_GET_WORK_DATE(I_DATA_DATE, -10);

  --接口表到历史表

  INSERT INTO CCI_ETL_CONTRACT_INF_H
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     CREDIT_AGREEMENT_NO,
     START_DATE,
     EXPIRY_DATE,
     BANK_GROUP_FLAG,
     GUARANTEE_FLAG,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     CREDIT_ID,
     LIMIT_ID,
     CREDIT_AGREEMENT_NO1,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           CREDIT_AGREEMENT_NO,
           START_DATE,
           EXPIRY_DATE,
           BANK_GROUP_FLAG,
           GUARANTEE_FLAG,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           CREDIT_ID,
           LIMIT_ID,
           CREDIT_AGREEMENT_NO1,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_CONTRACT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CONTRACT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_CONTRACT_AMOUNT_INF_H
    (LOAN_CONTRACT_NO,
     CURRENCY,
     AMOUNT,
     BALANCE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE,
     BUSI_DATE,
     LOAN_CARD_NO)
    SELECT LOAN_CONTRACT_NO,
           CURRENCY,
           AMOUNT,
           BALANCE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE,
           BUSI_DATE,
           LOAN_CARD_NO
      FROM CCI_ETL_CONTRACT_AMOUNT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CONTRACT_AMOUNT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_LOAN_RECEIPT_INF_H
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     RECIEPT_NO,
     CURRENCY,
     RECIEPT_AMOUNT,
     RECIEPT_BALANCE,
     START_DATE,
     EXPIRY_DATE,
     LOAN_BUSI_TYPE,
     LOAN_FORM,
     LOAN_PROPERTY,
     LOAN_ORIENTATION,
     LOAN_TYPE,
     EXTENSION_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE,
     BORROWER_NAME)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           RECIEPT_NO,
           CURRENCY,
           RECIEPT_AMOUNT,
           RECIEPT_BALANCE,
           START_DATE,
           EXPIRY_DATE,
           LOAN_BUSI_TYPE,
           LOAN_FORM,
           LOAN_PROPERTY,
           LOAN_ORIENTATION,
           LOAN_TYPE,
           EXTENSION_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE,
           BORROWER_NAME
      FROM CCI_ETL_LOAN_RECEIPT_INF
     WHERE DATA_DATE = T_1;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_LOAN_RECEIPT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_LOAN_REPAYMENT_INF_H
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     RECIEPT_NO,
     REPAYMENT_DATE,
     REPAYMENT_COUNT,
     REPAYMENT_TYPE,
     REPAYMENT_AMOUNT,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE,
     BORROWER_NAME)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           RECIEPT_NO,
           REPAYMENT_DATE,
           REPAYMENT_COUNT,
           REPAYMENT_TYPE,
           REPAYMENT_AMOUNT,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE,
           BORROWER_NAME
      FROM CCI_ETL_LOAN_REPAYMENT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_LOAN_REPAYMENT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_LOAN_EXTENSION_INF_H
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     RECIEPT_NO,
     EXTENSION_COUNT,
     AMOUNT,
     START_DATE,
     EXPIRY_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE,
     BORROWER_NAME)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           RECIEPT_NO,
           EXTENSION_COUNT,
           AMOUNT,
           START_DATE,
           EXPIRY_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE,
           BORROWER_NAME
      FROM CCI_ETL_LOAN_EXTENSION_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_LOAN_EXTENSION_INF';
  COMMIT;

  INSERT INTO CCI_ETL_INTEREST_OWE_INF_H
    (LOAN_CARD_NO,
     BUSI_DATE,
     CURRENCY,
     OWE_INTEREST_BALANCE,
     OWE_INTEREST_TYPE,
     OWE_INTEREST_CHANGE_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           BUSI_DATE,
           CURRENCY,
           OWE_INTEREST_BALANCE,
           OWE_INTEREST_TYPE,
           OWE_INTEREST_CHANGE_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_INTEREST_OWE_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_INTEREST_OWE_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_07_ASSETS_H
    (BORROWER_NAME,
     LOAN_CARD_NO,
     REPORT_YEAR,
     REPORT_TYPE,
     REPORT_TYPE_SUBDIVISION,
     AUDIT_FIRM_NAME,
     AUDITOR_NAME,
     CHECK_TIME_C,
     BUSI_DATE,
     CURRENCY_CAPITAL,
     TRADING_FINANCIAL_ASSETS,
     NOTES_RECEIVABLE,
     ACCOUNTS_RECEIVABLE,
     ADVANCE_PAYMENT,
     INTEREST_RECEIVABLE,
     DIVIDENDS_RECEIVABLE,
     OTHER_ACCOUNTS_RECEIVABLE,
     STOCK,
     NONCURRENCY_ASSETS_IN_ONE_YEAR,
     OTHER_FLOW_CAPITAL,
     FLOW_CAPITAL_IN_TOTAL,
     FINA_ASSE_AVAI_FOR_SALE,
     INVESTMENT_HOLD_TO_MATURITY,
     LONG_TERM_EQUITY_INVESTMENT,
     LONG_TERM_ACCOUNTS_RECEIVABLE,
     INVESTMENT_REAL_ESTATE,
     FIXED_ASSETS,
     UNDER_CONSTRUCTION,
     ENGINEERING_MATERIALS,
     FIXED_ASSET_CLEAR,
     PRODUCTIVE_BIOLOGICAL_ASSETS,
     OIL_AND_GAS_ASSETS,
     INTANGIBLE_ASSETS,
     DEVELOPMENT_EXPENSES,
     GOODWILL,
     LONG_TERM_PREPAID_EXPENSES,
     DEFERRED_INCOME_TAX_ASSETS,
     OTHER_NONCURRENT_ASSETS,
     TOTAL_NONCURRENT_ASSETS,
     TOTAL_ASSETS,
     SHORT_TERM_BORROWING,
     TRADING_FINANCIAL_LIABILITY,
     NOTES_PAYABLE,
     ACCOUNTS_PAYABLE,
     ACCOUNTS_COLLECT_IN_ADVANCE,
     INTERESTS_RECEIVABLE,
     WAGE_PAYABLE,
     TAX_PAYABLE,
     DIVIDEND_PAYABLE,
     OTHER_PAYMENT,
     NONC_LIAB_IN_ONE_YEAR,
     OTHER_CURRENT_LIABILITIES,
     TOTAL_CURRENT_LIABILITIES,
     LONG_TERM_BORROWING,
     BONDS_PAYMENT,
     LONG_TERM_ACCOUNTS_PAYABLE,
     SPECIAL_PAYMENT,
     EXPECTED_LIABILITY,
     DEFERRED_TAX_CREDIT_LIABILITY,
     OTHER_NONCURRENT_LIABILITIES,
     TOTAL_NONCURRENT_LIABILITIES,
     TOTAL_LIABILITIES,
     REAL_INCOME_CAPITAL,
     CAPITAL_RESERVE,
     SURPLUS_RESERVE,
     NONDISTRIBUTED_PROFIT,
     TOTAL_OWNERS_EQUITY,
     TOTA_LIAB_AND_OWNE_EQUI,
     INVENTORY_REDUCTION_UNIT,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT BORROWER_NAME,
           LOAN_CARD_NO,
           REPORT_YEAR,
           REPORT_TYPE,
           REPORT_TYPE_SUBDIVISION,
           AUDIT_FIRM_NAME,
           AUDITOR_NAME,
           CHECK_TIME_C,
           BUSI_DATE,
           CURRENCY_CAPITAL,
           TRADING_FINANCIAL_ASSETS,
           NOTES_RECEIVABLE,
           ACCOUNTS_RECEIVABLE,
           ADVANCE_PAYMENT,
           INTEREST_RECEIVABLE,
           DIVIDENDS_RECEIVABLE,
           OTHER_ACCOUNTS_RECEIVABLE,
           STOCK,
           NONCURRENCY_ASSETS_IN_ONE_YEAR,
           OTHER_FLOW_CAPITAL,
           FLOW_CAPITAL_IN_TOTAL,
           FINA_ASSE_AVAI_FOR_SALE,
           INVESTMENT_HOLD_TO_MATURITY,
           LONG_TERM_EQUITY_INVESTMENT,
           LONG_TERM_ACCOUNTS_RECEIVABLE,
           INVESTMENT_REAL_ESTATE,
           FIXED_ASSETS,
           UNDER_CONSTRUCTION,
           ENGINEERING_MATERIALS,
           FIXED_ASSET_CLEAR,
           PRODUCTIVE_BIOLOGICAL_ASSETS,
           OIL_AND_GAS_ASSETS,
           INTANGIBLE_ASSETS,
           DEVELOPMENT_EXPENSES,
           GOODWILL,
           LONG_TERM_PREPAID_EXPENSES,
           DEFERRED_INCOME_TAX_ASSETS,
           OTHER_NONCURRENT_ASSETS,
           TOTAL_NONCURRENT_ASSETS,
           TOTAL_ASSETS,
           SHORT_TERM_BORROWING,
           TRADING_FINANCIAL_LIABILITY,
           NOTES_PAYABLE,
           ACCOUNTS_PAYABLE,
           ACCOUNTS_COLLECT_IN_ADVANCE,
           INTERESTS_RECEIVABLE,
           WAGE_PAYABLE,
           TAX_PAYABLE,
           DIVIDEND_PAYABLE,
           OTHER_PAYMENT,
           NONC_LIAB_IN_ONE_YEAR,
           OTHER_CURRENT_LIABILITIES,
           TOTAL_CURRENT_LIABILITIES,
           LONG_TERM_BORROWING,
           BONDS_PAYMENT,
           LONG_TERM_ACCOUNTS_PAYABLE,
           SPECIAL_PAYMENT,
           EXPECTED_LIABILITY,
           DEFERRED_TAX_CREDIT_LIABILITY,
           OTHER_NONCURRENT_LIABILITIES,
           TOTAL_NONCURRENT_LIABILITIES,
           TOTAL_LIABILITIES,
           REAL_INCOME_CAPITAL,
           CAPITAL_RESERVE,
           SURPLUS_RESERVE,
           NONDISTRIBUTED_PROFIT,
           TOTAL_OWNERS_EQUITY,
           TOTA_LIAB_AND_OWNE_EQUI,
           INVENTORY_REDUCTION_UNIT,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_FINANCE_07_ASSETS_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_07_ASSETS_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_07_PROFIT_H
    (BORROWER_NAME,
     LOAN_CARD_NO,
     REPORT_YEAR,
     REPORT_TYPE,
     REPORT_TYPE_SUBDIVISION,
     AUDIT_FIRM_NAME,
     AUDITOR_NAME,
     CHECK_TIME_C,
     BUSI_DATE,
     BUSI_INCOME,
     BUSI_COST,
     BUSI_TAX_ADD,
     SALE_EXPENSE,
     MANAGE_EXPENSE,
     FINANCIAL_EXPENSE,
     ASSET_REDUCTION_LOSS,
     NET_INCOME_OF_FAIR_VALUE,
     INVESTMENT_NET,
     INVE_REVE_TO_ENTE,
     BUSI_PROFIT,
     BESIDE_BUSI_INCOME,
     BESIDE_BUSI_EXPENSE,
     LOSS_OF_NONCURRENT_ASSETS,
     TOTAL_PROFIT,
     INCOME_TAX_EXPENSE,
     PROFIT_NET,
     BASIC_EARNINGS_PER_SHARE,
     DILUTED_EARNINGS_PER_SHARE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT BORROWER_NAME,
           LOAN_CARD_NO,
           REPORT_YEAR,
           REPORT_TYPE,
           REPORT_TYPE_SUBDIVISION,
           AUDIT_FIRM_NAME,
           AUDITOR_NAME,
           CHECK_TIME_C,
           BUSI_DATE,
           BUSI_INCOME,
           BUSI_COST,
           BUSI_TAX_ADD,
           SALE_EXPENSE,
           MANAGE_EXPENSE,
           FINANCIAL_EXPENSE,
           ASSET_REDUCTION_LOSS,
           NET_INCOME_OF_FAIR_VALUE,
           INVESTMENT_NET,
           INVE_REVE_TO_ENTE,
           BUSI_PROFIT,
           BESIDE_BUSI_INCOME,
           BESIDE_BUSI_EXPENSE,
           LOSS_OF_NONCURRENT_ASSETS,
           TOTAL_PROFIT,
           INCOME_TAX_EXPENSE,
           PROFIT_NET,
           BASIC_EARNINGS_PER_SHARE,
           DILUTED_EARNINGS_PER_SHARE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_FINANCE_07_PROFIT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_07_PROFIT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_CREDIT_INF_H
    (CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     LOAN_CREDIT,
     START_DATE,
     EXPIRY_DATE,
     LOAN_CREDIT_START_DATE,
     LOAN_CREDIT_CANCEL_REASON,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     LE_ID,
     CUSTOMER_DEPT,
     MASTER_NO,
     RELATIONSHIP_NO,
     ACCOUNT_NO,
     CREDIT_SOURCE,
     CREDIT_STATUS,
     CREDIT_TYPE,
     JOB_NAME,
     DATA_DATE,
     PRODUCT_DESCRIPTION,
     MAKER_CHECKER_STAFF_ID)
    SELECT CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           LOAN_CREDIT,
           START_DATE,
           EXPIRY_DATE,
           LOAN_CREDIT_START_DATE,
           LOAN_CREDIT_CANCEL_REASON,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           LE_ID,
           CUSTOMER_DEPT,
           MASTER_NO,
           RELATIONSHIP_NO,
           ACCOUNT_NO,
           CREDIT_SOURCE,
           CREDIT_STATUS,
           CREDIT_TYPE,
           JOB_NAME,
           DATA_DATE,
           PRODUCT_DESCRIPTION,
           MAKER_CHECKER_STAFF_ID
      FROM CCI_ETL_CREDIT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CREDIT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_GUARANTEE_INF_H
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     GUARANTEE_CONTRACT_NO,
     GUARANTEE_NAME,
     GUARANTEE_LOAN_CARD_NO,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     GUARANTEE_AMOUNT,
     CONTRACT_SIGN_DATE,
     GUARANTEE_TYPE,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     LIMIT_ID,
     SECURITY_ID,
     DATA_ID,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           GUARANTEE_CONTRACT_NO,
           GUARANTEE_NAME,
           GUARANTEE_LOAN_CARD_NO,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           GUARANTEE_AMOUNT,
           CONTRACT_SIGN_DATE,
           GUARANTEE_TYPE,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           REPORT_TYPE,
           LIMIT_ID,
           SECURITY_ID,
           DATA_ID,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_GUARANTEE_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_GUARANTEE_INF';

  INSERT INTO CCI_ETL_MORTGAGE_INF_H
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     MORTGAGE_CONTRACT_NO,
     MORTGAGE_NO,
     MORTGAGER_NAME,
     MORTGAGER_LOAN_CARD_NO,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     MORTGAGE_ASSESS_VALUE,
     ASSESS_DATE,
     ASSESS_ORG_NAME,
     ASSESS_ORG_CODE,
     CONTRACT_SIGN_DATE,
     MORTGAGE_TYPE,
     MORTGAGE_CURRENCY,
     MORTGAGE_AMOUNT,
     ISSUE_ORG_NAME,
     ISSUE_DATE,
     MORTGAGE_INSTRUCTION,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     LIMIT_ID,
     SECURITY_ID,
     DATA_ID,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           MORTGAGE_CONTRACT_NO,
           MORTGAGE_NO,
           MORTGAGER_NAME,
           MORTGAGER_LOAN_CARD_NO,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           MORTGAGE_ASSESS_VALUE,
           ASSESS_DATE,
           ASSESS_ORG_NAME,
           ASSESS_ORG_CODE,
           CONTRACT_SIGN_DATE,
           MORTGAGE_TYPE,
           MORTGAGE_CURRENCY,
           MORTGAGE_AMOUNT,
           ISSUE_ORG_NAME,
           ISSUE_DATE,
           MORTGAGE_INSTRUCTION,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           REPORT_TYPE,
           LIMIT_ID,
           SECURITY_ID,
           DATA_ID,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_MORTGAGE_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_MORTGAGE_INF';
  COMMIT;

  INSERT INTO CCI_ETL_PLEDGE_INF_H
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     PLEDGE_CONTRACT_NO,
     PLEDGE_NO,
     PLEDGER_NAME,
     PLEDGER_LOAN_CARD_NO,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     PLEDGE_VALUE,
     CONTRACT_SIGN_DATE,
     PLEDGE_TYPE,
     PLEDGE_CURRENCY,
     PLEDGE_AMOUNT,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     LIMIT_ID,
     SECURITY_ID,
     DATA_ID,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           PLEDGE_CONTRACT_NO,
           PLEDGE_NO,
           PLEDGER_NAME,
           PLEDGER_LOAN_CARD_NO,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           PLEDGE_VALUE,
           CONTRACT_SIGN_DATE,
           PLEDGE_TYPE,
           PLEDGE_CURRENCY,
           PLEDGE_AMOUNT,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           REPORT_TYPE,
           LIMIT_ID,
           SECURITY_ID,
           DATA_ID,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_PLEDGE_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_PLEDGE_INF';
  COMMIT;

  --TRADE

  INSERT INTO CCI_ETL_BILL_DISCOUNT_INF_H
    (BILL_INTERNAL_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BILL_TYPE,
     DISCOUNT_APPLICANT_NAME,
     LOAN_CARD_NO,
     ACCEPTOR_NAME,
     ORG_CODE,
     CURRENCY,
     DISCOUNT_AMOUNT,
     DISCOUNT_DATE,
     ACCEPT_EXPIRY_DATE,
     BILL_AMOUNT,
     BILL_STATUS,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     DISC_APPL_LOAN_CARD_NO,
     ACCEPTOR_LOAN_CARD_NO,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT BILL_INTERNAL_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BILL_TYPE,
           DISCOUNT_APPLICANT_NAME,
           LOAN_CARD_NO,
           ACCEPTOR_NAME,
           ORG_CODE,
           CURRENCY,
           DISCOUNT_AMOUNT,
           DISCOUNT_DATE,
           ACCEPT_EXPIRY_DATE,
           BILL_AMOUNT,
           BILL_STATUS,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           DISC_APPL_LOAN_CARD_NO,
           ACCEPTOR_LOAN_CARD_NO,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_BILL_DISCOUNT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_BILL_DISCOUNT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FACTORING_INF_H
    (FACTORING_AGREEMENT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     PRODUCT_TYPE,
     BUSI_STATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     CONTINUE_AMOUNT,
     CONTINUE_DATE,
     CONTINUE_BALANCE,
     CONTINUE_CHANGE_DATE,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT FACTORING_AGREEMENT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           PRODUCT_TYPE,
           BUSI_STATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           CONTINUE_AMOUNT,
           CONTINUE_DATE,
           CONTINUE_BALANCE,
           CONTINUE_CHANGE_DATE,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_FACTORING_INF
     WHERE DATA_DATE = T_1;

  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FACTORING_INF';
  COMMIT;

  INSERT INTO CCI_ETL_INDEMNITY_INF_H
    (INDEMNITY_CODE,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     INDEMNITY_TYPE,
     INDEMNITY_STATE,
     CURRENCY,
     AMOUNT,
     START_DATE,
     EXPIRY_DATE,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     BALANCE,
     BALANCE_OCC_DATE,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT INDEMNITY_CODE,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           INDEMNITY_TYPE,
           INDEMNITY_STATE,
           CURRENCY,
           AMOUNT,
           START_DATE,
           EXPIRY_DATE,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           BALANCE,
           BALANCE_OCC_DATE,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_INDEMNITY_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_INDEMNITY_INF';
  COMMIT;

  INSERT INTO CCI_ETL_CARD_INF_H
    (LETTER_OF_CREDIT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     ISSUE_AMOUNT,
     ISSUE_DATE,
     VALIDITY_PERIOD,
     PAYMENT_TERM,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     LETTER_OF_CREDIT_STATUS,
     CANCELLATION_DATE,
     LETTER_OF_CREDIT_BALANCE,
     BALANCE_REPORT_DATE,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT LETTER_OF_CREDIT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           ISSUE_AMOUNT,
           ISSUE_DATE,
           VALIDITY_PERIOD,
           PAYMENT_TERM,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           LETTER_OF_CREDIT_STATUS,
           CANCELLATION_DATE,
           LETTER_OF_CREDIT_BALANCE,
           BALANCE_REPORT_DATE,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_CARD_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CARD_INF';
  COMMIT;

  INSERT INTO CCI_ETL_BANK_ACCEPT_INF_H
    (ACCEPTANCE_AGREEMENT_NO,
     DRAFT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     DRAWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     DRAFT_AMOUNT,
     DRAFT_ACCEPTANCE_DATE,
     DRAFT_EXPIRY_DATE,
     DRAFT_PAYMENT_DATE,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     DRAFT_STATUS,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT ACCEPTANCE_AGREEMENT_NO,
           DRAFT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           DRAWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           DRAFT_AMOUNT,
           DRAFT_ACCEPTANCE_DATE,
           DRAFT_EXPIRY_DATE,
           DRAFT_PAYMENT_DATE,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           DRAFT_STATUS,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_BANK_ACCEPT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_BANK_ACCEPT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_ADVANCE_INF_H
    (ADVANCE_BUSINESS_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     ADVANCE_TYPE,
     ORIGIN_BUSI_NO,
     CURRENCY,
     ADVANCE_AMOUNT,
     ADVANCE_DATE,
     ADVANCE_BALANCE,
     ADVANCE_OCC_DATE,
     ADVANCE_FORM,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT ADVANCE_BUSINESS_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           ADVANCE_TYPE,
           ORIGIN_BUSI_NO,
           CURRENCY,
           ADVANCE_AMOUNT,
           ADVANCE_DATE,
           ADVANCE_BALANCE,
           ADVANCE_OCC_DATE,
           ADVANCE_FORM,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_ADVANCE_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ADVANCE_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_INF_H
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     CREDIT_AGREEMENT_NO,
     START_DATE,
     EXPIRY_DATE,
     GUARANTEE_FLAG,
     AGREEMENT_EFFIECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           CREDIT_AGREEMENT_NO,
           START_DATE,
           EXPIRY_DATE,
           GUARANTEE_FLAG,
           AGREEMENT_EFFIECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_FINANCE_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_AMT_INF_H
    (FINANCING_AGREEMENT_NO,
     CURRENCY,
     FINANCING_AGREEMENT_AMOUNT,
     FINANCING_AGREEMENT_BALANCE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE,
     BUSI_DATE,
     LOAN_CARD_NO)
    SELECT FINANCING_AGREEMENT_NO,
           CURRENCY,
           FINANCING_AGREEMENT_AMOUNT,
           FINANCING_AGREEMENT_BALANCE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE,
           BUSI_DATE,
           LOAN_CARD_NO
      FROM CCI_ETL_FINANCE_AMT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_AMT_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_BS_INF_H
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     FINANCING_NO,
     FINANCING_FORM,
     CURRENCY,
     FINANCING_AMOUNT,
     FINANCING_BALANCE,
     START_DATE,
     EXPIRY_DATE,
     EXTENSION_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           FINANCING_NO,
           FINANCING_FORM,
           CURRENCY,
           FINANCING_AMOUNT,
           FINANCING_BALANCE,
           START_DATE,
           EXPIRY_DATE,
           EXTENSION_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_FINANCE_BS_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_BS_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_REPAY_INF_H
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     FINANCING_NO,
     REPAYMENT_COUNT,
     REPAYMENT_AMOUNT,
     REPAYMENT_DATE,
     REPAYMENT_TYPE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           FINANCING_NO,
           REPAYMENT_COUNT,
           REPAYMENT_AMOUNT,
           REPAYMENT_DATE,
           REPAYMENT_TYPE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_FINANCE_REPAY_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_REPAY_INF';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_EXTEN_INF_H
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     FINANCING_NO,
     EXTENSION_COUNT,
     EXTENSION_AMOUNT,
     START_DATE,
     EXPIRY_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           FINANCING_NO,
           EXTENSION_COUNT,
           EXTENSION_AMOUNT,
           START_DATE,
           EXPIRY_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_FINANCE_EXTEN_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_EXTEN_INF';
  COMMIT;

  --ORG

  INSERT INTO CCI_ETL_ORG_BASIC_INF_H
    (MANAGEMENT_ROW_CODE,
     CUSTOMER_TYPE,
     ORG_CREDIT_CODE_A,
     ORG_CODE_A,
     REGISTRATION_CODE_TYPE_A,
     REGISTRATION_CODE_A,
     TAX_IDENTIFY_CODE_NA,
     TAX_IDENTIFY_CODE_ST,
     OPEN_ACCOUNT_APPROVAL_NO,
     LOAN_CARD_NO,
     DATA_ABSTRACT_DATE,
     RSV_A,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT MANAGEMENT_ROW_CODE,
           CUSTOMER_TYPE,
           ORG_CREDIT_CODE_A,
           ORG_CODE_A,
           REGISTRATION_CODE_TYPE_A,
           REGISTRATION_CODE_A,
           TAX_IDENTIFY_CODE_NA,
           TAX_IDENTIFY_CODE_ST,
           OPEN_ACCOUNT_APPROVAL_NO,
           LOAN_CARD_NO,
           DATA_ABSTRACT_DATE,
           RSV_A,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_ORG_BASIC_INF
     WHERE DATA_DATE = T_1;

  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_BASIC_INF';
  COMMIT;

  --基本属性

  INSERT INTO CCI_ETL_ORG_PROPERTY_INF_H
    (ORG_CN_NAME,
     ORG_EN_NAME,
     REGISTATION_ADDRESS,
     NATIONNALITY,
     REGISTATION_AREA_DIVISION,
     ESTABLISH_DATE,
     PAPER_EXPIRY_DATE,
     OPERATING_RANGE,
     REGISTERED_CAPITAL_CURRENCY,
     REGISTERED_AMOUNT,
     ORG_TYPE,
     ORG_TYPE_CLASSIFY,
     ECONOMIC_CLASSIFY,
     ECONOMIC_TYPE,
     INFORMATION_UPDATE_DATE_B,
     RSV_B,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT ORG_CN_NAME,
           ORG_EN_NAME,
           REGISTATION_ADDRESS,
           NATIONNALITY,
           REGISTATION_AREA_DIVISION,
           ESTABLISH_DATE,
           PAPER_EXPIRY_DATE,
           OPERATING_RANGE,
           REGISTERED_CAPITAL_CURRENCY,
           REGISTERED_AMOUNT,
           ORG_TYPE,
           ORG_TYPE_CLASSIFY,
           ECONOMIC_CLASSIFY,
           ECONOMIC_TYPE,
           INFORMATION_UPDATE_DATE_B,
           RSV_B,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_ORG_PROPERTY_INF
     WHERE DATA_DATE = T_1;

  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_PROPERTY_INF';
  COMMIT;

  --机构状态

  INSERT INTO CCI_ETL_ORG_STATUS_INF_H
    (BASIC_STATUS,
     ENTERPRISE_SCALE,
     ORG_STATUS,
     INFORMATION_UPDATE_DATE_D,
     RSV_D,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT BASIC_STATUS,
           ENTERPRISE_SCALE,
           ORG_STATUS,
           INFORMATION_UPDATE_DATE_D,
           RSV_D,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_ORG_STATUS_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_STATUS_INF';
  COMMIT;

  --高管及主要关系人信息

  INSERT INTO CCI_ETL_ORG_EXECUTIVE_INF_H
    (RELATION_PARTY_TYPE,
     NAME,
     PAPER_TYPE,
     PAPER_CODE,
     INFORMATION_UPDATE_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT RELATION_PARTY_TYPE,
           NAME,
           PAPER_TYPE,
           PAPER_CODE,
           INFORMATION_UPDATE_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_ORG_EXECUTIVE_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_EXECUTIVE_INF';
  COMMIT;

  --重要股东信息
  INSERT INTO CCI_ETL_ORG_IMPORT_S_H_INF_H
    (SHAREHOLDER_TYPE,
     SHAREHOLDER_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     ORG_CODE,
     ORG_CREDIT_CODE,
     SHAREHOLDING_RATIO,
     INFORMATION_UPDATE_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT SHAREHOLDER_TYPE,
           SHAREHOLDER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           ORG_CODE,
           ORG_CREDIT_CODE,
           SHAREHOLDING_RATIO,
           INFORMATION_UPDATE_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_ORG_IMPORT_S_H_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_IMPORT_S_H_INF';
  COMMIT;
  --机构联络信息
  INSERT INTO CCI_ETL_ORG_CONTACT_INF_H
    (ORG_WORK_ADDRESS,
     TELEPHONE,
     FINANCE_DEPARTMENT_TELEPHONE,
     INFORMATION_UPDATE_DATE_C,
     RSV_C,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     JOB_NAME,
     DATA_DATE)
    SELECT ORG_WORK_ADDRESS,
           TELEPHONE,
           FINANCE_DEPARTMENT_TELEPHONE,
           INFORMATION_UPDATE_DATE_C,
           RSV_C,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           JOB_NAME,
           DATA_DATE
      FROM CCI_ETL_ORG_CONTACT_INF
     WHERE DATA_DATE = T_1;
  COMMIT;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_CONTACT_INF';
  COMMIT;

  O_ERROR_CODE := '000000';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --ERROR MSG
    O_ERROR_CODE := SQLCODE;
    O_ERROR_MSG  := SQLERRM;
    -- SYSTEM ERROR
    CCI_INSERT_LOG_ERROR(JOB_NAME_LOCAL,
                         9,
                         O_ERROR_CODE,
                         O_ERROR_MSG,
                         NULL,
                         '0',
                         V_SERIAL_NO);
    COMMIT;

END CCI_ETL_TO_FULL_D;
/

prompt
prompt Creating procedure CCI_PRO_TO_ETL_D
prompt ===================================
prompt
CREATE OR REPLACE PROCEDURE MBT.CCI_PRO_TO_ETL_D(I_DATA_DATE  IN VARCHAR2, -- WORK DAY
                                             O_ERROR_CODE OUT VARCHAR2, -- ERROR CODE
                                             O_ERROR_MSG  OUT VARCHAR2 -- ERROR MESSAGE
                                             ) IS

  --=========================================================================================
  --Auther: by MiaoShenglong
  --Creatdate:2017-04-26
  --Descruption:将产品端记录同步到接口全量表，机构同步反馈成功数据，其他同步已上报数据
  --========================================================================================
  -- THE SERIAL NUMBER
  V_SERIAL_NO CHAR(17);
  --T-1
  T1_DATE VARCHAR2(8) := CCI_GET_WORK_DATE(I_DATA_DATE, '-1');
  C_JOB_ID CONSTANT VARCHAR2(120) := 'CCI_PRO_TO_ETL_D';

  -- CONSTANTS

BEGIN
  V_SERIAL_NO := CCI_GET_SERIAL_NO();

  --=============================================================================
  --产品表到接口表全量表同步(从产品端取最新一笔记录)
  --=============================================================================
  --授信信息 (BB无条件筛选，CRC只同步审核通过，校验通过的记录(韩20170622) )
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CREDIT_FULL';
  INSERT INTO CCI_ETL_CREDIT_FULL
    (CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     LOAN_CREDIT,
     START_DATE,
     EXPIRY_DATE,
     LOAN_CREDIT_START_DATE,
     LOAN_CREDIT_CANCEL_REASON,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE,
     LE_ID,
     MAKER_CHECKER_STAFF_ID,
     LOAN_CREDIT_OLD)
    SELECT CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           LOAN_CREDIT,
           START_DATE,
           EXPIRY_DATE,
           LOAN_CREDIT_START_DATE,
           LOAN_CREDIT_CANCEL_REASON,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE,
           LE_ID,
           MAKER_CHECKER_STAFF_ID,
           LOAN_CREDIT_OLD
      FROM (SELECT S.*,
                   ROW_NUMBER() OVER(PARTITION BY S.CREDIT_AGREEMENT_NO, S.BRANCH_ID ORDER BY S.BUSI_DATE DESC, S.FILE_SEND_DATE DESC) RN
              FROM (SELECT A.*,
                           B.BRANCH_ID,
                           B.BRANCH_NO,
                           B.DEPT_ID,
                           B.MSG_RECORD_OPERATE_TYPE,
                           NVL(B.FILE_SEND_DATE, '0') AS FILE_SEND_DATE
                      FROM CCI_PUBLIC_CREDIT_INFO_H A,
                           CCI_REPORT_SYSTEM_CTL_H  B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.OPERATING_STATE IN ('22', '31')
                       AND A.RSV_03 = 'CRC'
                    UNION ALL
                    SELECT NULL AS SEQ_NUM,
                           C.*,
                           D.BRANCH_ID,
                           D.BRANCH_NO,
                           D.DEPT_ID,
                           D.MSG_RECORD_OPERATE_TYPE,
                           NVL(D.FILE_SEND_DATE, '0') AS FILE_SEND_DATE
                      FROM CCI_PUBLIC_CREDIT_INFO C, CCI_REPORT_SYSTEM_CTL D
                     WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
                       AND D.LOGIC_DELETE_FLAG = '0'
                       AND D.OPERATING_STATE IN ('22', '31')
                       AND C.RSV_03 = 'CRC') S)
     WHERE RN = 1;
  COMMIT;

  INSERT INTO CCI_ETL_CREDIT_FULL
    (CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     LOAN_CREDIT,
     START_DATE,
     EXPIRY_DATE,
     LOAN_CREDIT_START_DATE,
     LOAN_CREDIT_CANCEL_REASON,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE,
     LE_ID,
     MAKER_CHECKER_STAFF_ID,
     LOAN_CREDIT_OLD)
    SELECT CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           LOAN_CREDIT,
           START_DATE,
           EXPIRY_DATE,
           LOAN_CREDIT_START_DATE,
           LOAN_CREDIT_CANCEL_REASON,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE,
           LE_ID,
           MAKER_CHECKER_STAFF_ID,
           LOAN_CREDIT_OLD
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY CREDIT_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_PUBLIC_CREDIT_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.RSV_03 = 'RLS-BB')
     WHERE RN = 1;
  COMMIT;

  --保函业务记录
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_INDEMNITY_FULL';
  INSERT INTO CCI_ETL_INDEMNITY_FULL
    (INDEMNITY_CODE,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     INDEMNITY_TYPE,
     INDEMNITY_STATE,
     CURRENCY,
     AMOUNT,
     START_DATE,
     EXPIRY_DATE,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     BALANCE,
     BALANCE_OCC_DATE,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT INDEMNITY_CODE,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           INDEMNITY_TYPE,
           INDEMNITY_STATE,
           CURRENCY,
           AMOUNT,
           START_DATE,
           EXPIRY_DATE,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           BALANCE,
           BALANCE_OCC_DATE,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY INDEMNITY_CODE, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_INDEMNITY_BUSI C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;

  COMMIT;

  --保理业务信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FACTORING_FULL';
  INSERT INTO CCI_ETL_FACTORING_FULL
    (FACTORING_AGREEMENT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     PRODUCT_TYPE,
     BUSI_STATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     CONTINUE_AMOUNT,
     CONTINUE_DATE,
     CONTINUE_BALANCE,
     CONTINUE_CHANGE_DATE,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT FACTORING_AGREEMENT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           PRODUCT_TYPE,
           BUSI_STATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           CONTINUE_AMOUNT,
           CONTINUE_DATE,
           CONTINUE_BALANCE,
           CONTINUE_CHANGE_DATE,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY FACTORING_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_FACTORING_BUSI C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;
  COMMIT;

  --贷款业务合同信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CONTRACT_FULL';
  INSERT INTO CCI_ETL_CONTRACT_FULL
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     CREDIT_AGREEMENT_NO,
     START_DATE,
     EXPIRY_DATE,
     BANK_GROUP_FLAG,
     GUARANTEE_FLAG,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           CREDIT_AGREEMENT_NO,
           START_DATE,
           EXPIRY_DATE,
           BANK_GROUP_FLAG,
           GUARANTEE_FLAG,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY LOAN_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL)
     WHERE RN = 1;
  COMMIT;

  --贷款业务金额信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CONTRACT_AMOUNT_FULL';
  INSERT INTO CCI_ETL_CONTRACT_AMOUNT_FULL
    (LOAN_CONTRACT_NO,
     CURRENCY,
     AMOUNT,
     BALANCE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE,
     BUSI_DATE,
     LOAN_CARD_NO)
    SELECT T.LOAN_CONTRACT_NO,
           T.CURRENCY,
           T.AMOUNT,
           T.BALANCE,
           A.CUSTOMER_CODE           AS CUSTOMER_CODE,
           B.BRANCH_ID,
           B.BRANCH_ID,
           NULL                      AS DEPT_ID,
           B.MSG_RECORD_OPERATE_TYPE,
           T.RSV_01,
           T.RSV_02,
           A.RSV_03,
           T.RSV_04,
           T.RSV_05,
           T.RSV_06,
           T1_DATE,
           A.BUSI_DATE,
           A.LOAN_CARD_NO
      FROM CCI_CONTRACT_AMOUNT_INFO T,
           CCI_CONTRACT_INFO        A,
           CCI_REPORT_SYSTEM_CTL    B
     WHERE T.PARENT_I = A.SYS_CTL_ID
       AND A.SYS_CTL_ID = B.SYS_CTL_ID
       AND T.PARENT_I IN
           (SELECT SYS_CTL_ID
              FROM (SELECT C.*,
                           D.BRANCH_ID,
                           D.BRANCH_NO,
                           D.DEPT_ID,
                           D.MSG_RECORD_OPERATE_TYPE,
                           ROW_NUMBER() OVER(PARTITION BY LOAN_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO ORDER BY BUSI_DATE DESC) RN
                      FROM CCI_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
                     WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
                       AND D.LOGIC_DELETE_FLAG = '0'
                       AND C.LOAN_CARD_NO IS NOT NULL)
             WHERE RN = 1);
  COMMIT;

  --贷款业务借据信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_LOAN_RECEIPT_FULL';
  INSERT INTO CCI_ETL_LOAN_RECEIPT_FULL
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     RECIEPT_NO,
     CURRENCY,
     RECIEPT_AMOUNT,
     RECIEPT_BALANCE,
     START_DATE,
     EXPIRY_DATE,
     LOAN_BUSI_TYPE,
     LOAN_FORM,
     LOAN_PROPERTY,
     LOAN_ORIENTATION,
     LOAN_TYPE,
     EXTENSION_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           RECIEPT_NO,
           CURRENCY,
           RECIEPT_AMOUNT,
           RECIEPT_BALANCE,
           START_DATE,
           EXPIRY_DATE,
           LOAN_BUSI_TYPE,
           LOAN_FORM,
           LOAN_PROPERTY,
           LOAN_ORIENTATION,
           LOAN_TYPE,
           EXTENSION_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY LOAN_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, RECIEPT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_LOAN_RECEIPT_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL)
     WHERE RN = 1;
  COMMIT;

  --贷款业务还款信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_LOAN_REPAYMENT_FULL';
  INSERT INTO CCI_ETL_LOAN_REPAYMENT_FULL
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     RECIEPT_NO,
     REPAYMENT_DATE,
     REPAYMENT_COUNT,
     REPAYMENT_TYPE,
     REPAYMENT_AMOUNT,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           RECIEPT_NO,
           REPAYMENT_DATE,
           REPAYMENT_COUNT,
           REPAYMENT_TYPE,
           REPAYMENT_AMOUNT,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           B.MSG_RECORD_OPERATE_TYPE,
           A.RSV_01,
           A.RSV_02,
           A.RSV_03,
           A.RSV_04,
           A.RSV_05,
           A.RSV_06,
           T1_DATE
      FROM CCI_LOAN_REPAYMENT A, CCI_REPORT_SYSTEM_CTL B
     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
       AND B.LOGIC_DELETE_FLAG = '0';
  COMMIT;

  --贷款业务展期信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_LOAN_EXTENSION_FULL';
  INSERT INTO CCI_ETL_LOAN_EXTENSION_FULL
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     RECIEPT_NO,
     EXTENSION_COUNT,
     AMOUNT,
     START_DATE,
     EXPIRY_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           RECIEPT_NO,
           EXTENSION_COUNT,
           AMOUNT,
           START_DATE,
           EXPIRY_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           A.RSV_01,
           A.RSV_02,
           A.RSV_03,
           A.RSV_04,
           A.RSV_05,
           A.RSV_06,
           T1_DATE
      FROM CCI_LOAN_EXTENSION_INFO A, CCI_REPORT_SYSTEM_CTL B
     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
       AND B.LOGIC_DELETE_FLAG = '0';

  COMMIT;

  --保证合同信息(取最新，有效且不是逻辑删除的记录)
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_GUARANTEE_FULL';
  INSERT INTO CCI_ETL_GUARANTEE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     GUARANTEE_CONTRACT_NO,
     GUARANTEE_NAME,
     GUARANTEE_LOAN_CARD_NO,
     CURRENCY,
     GUARANTEE_AMOUNT,
     CONTRACT_SIGN_DATE,
     GUARANTEE_TYPE,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           GUARANTEE_CONTRACT_NO,
           GUARANTEE_NAME,
           GUARANTEE_LOAN_CARD_NO,
           CURRENCY,
           GUARANTEE_AMOUNT,
           CONTRACT_SIGN_DATE,
           GUARANTEE_TYPE,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '02', --非自然人保证
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, GUARANTEE_LOAN_CARD_NO, GUARANTEE_CONTRACT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_GUARANTEE_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL)
     WHERE RN = 1;

  COMMIT;

  --抵押合同信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_MORTGAGE_FULL';
  INSERT INTO CCI_ETL_MORTGAGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     MORTGAGE_CONTRACT_NO,
     MORTGAGE_NO,
     MORTGAGER_NAME,
     MORTGAGER_LOAN_CARD_NO,
     CURRENCY,
     MORTGAGE_ASSESS_VALUE,
     ASSESS_DATE,
     ASSESS_ORG_NAME,
     ASSESS_ORG_CODE,
     CONTRACT_SIGN_DATE,
     MORTGAGE_TYPE,
     MORTGAGE_CURRENCY,
     MORTGAGE_AMOUNT,
     ISSUE_ORG_NAME,
     ISSUE_DATE,
     MORTGAGE_INSTRUCTION,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           MORTGAGE_CONTRACT_NO,
           MORTGAGE_NO,
           MORTGAGER_NAME,
           MORTGAGER_LOAN_CARD_NO,
           CURRENCY,
           MORTGAGE_ASSESS_VALUE,
           ASSESS_DATE,
           ASSESS_ORG_NAME,
           ASSESS_ORG_CODE,
           CONTRACT_SIGN_DATE,
           MORTGAGE_TYPE,
           MORTGAGE_CURRENCY,
           MORTGAGE_AMOUNT,
           ISSUE_ORG_NAME,
           ISSUE_DATE,
           MORTGAGE_INSTRUCTION,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '02', --非自然人抵押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, MORTGAGER_LOAN_CARD_NO, MORTGAGE_NO, MORTGAGE_CONTRACT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_MORTGAGE_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL)
     WHERE RN = 1;

  COMMIT;

  --质押合同信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_PLEDGE_FULL';
  INSERT INTO CCI_ETL_PLEDGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     PLEDGE_CONTRACT_NO,
     PLEDGE_NO,
     PLEDGER_NAME,
     PLEDGER_LOAN_CARD_NO,
     CURRENCY,
     PLEDGE_VALUE,
     CONTRACT_SIGN_DATE,
     PLEDGE_TYPE,
     PLEDGE_CURRENCY,
     PLEDGE_AMOUNT,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           PLEDGE_CONTRACT_NO,
           PLEDGE_NO,
           PLEDGER_NAME,
           PLEDGER_LOAN_CARD_NO,
           CURRENCY,
           PLEDGE_VALUE,
           CONTRACT_SIGN_DATE,
           PLEDGE_TYPE,
           PLEDGE_CURRENCY,
           PLEDGE_AMOUNT,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '02', --非自然人质押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, PLEDGER_LOAN_CARD_NO, PLEDGE_NO, PLEDGE_CONTRACT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_PLEDGE_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL)
     WHERE RN = 1;

  COMMIT;

  --自然人保证合同信息
  INSERT INTO CCI_ETL_GUARANTEE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     GUARANTEE_CONTRACT_NO,
     GUARANTEE_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     GUARANTEE_AMOUNT,
     CONTRACT_SIGN_DATE,
     GUARANTEE_TYPE,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           GUARANTEE_CONTRACT_NO,
           GUARANTEER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           GUARANTEE_AMOUNT,
           CONTRACT_SIGN_DATE,
           GUARANTEE_TYPE,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '01', --自然人保证
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, GUARANTEE_CONTRACT_NO, PAPER_TYPE, PAPER_CODE, GUARANTEER_NAME ORDER BY BUSI_DATE DESC) RN
              FROM CCI_GUARANTEE_CON_INFO_NA C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;
  COMMIT;

  --自然人抵押合同信息
  INSERT INTO CCI_ETL_MORTGAGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     MORTGAGE_CONTRACT_NO,
     MORTGAGE_NO,
     MORTGAGER_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     MORTGAGE_ASSESS_VALUE,
     ASSESS_DATE,
     ASSESS_ORG_NAME,
     ASSESS_ORG_CODE,
     CONTRACT_SIGN_DATE,
     MORTGAGE_TYPE,
     MORTGAGE_CURRENCY,
     MORTGAGE_AMOUNT,
     ISSUE_ORG_NAME,
     ISSUE_DATE,
     MORTGAGE_INSTRUCTION,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           MORTGAGE_CONTRACT_NO,
           MORTGAGE_NO,
           MORTGAGER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           MORTGAGE_ASSESS_VALUE,
           ASSESS_DATE,
           ASSESS_ORG_NAME,
           ASSESS_ORG_CODE,
           CONTRACT_SIGN_DATE,
           MORTGAGE_TYPE,
           MORTGAGE_CURRENCY,
           MORTGAGE_AMOUNT,
           ISSUE_ORG_NAME,
           ISSUE_DATE,
           MORTGAGE_INSTRUCTION,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '01', --自然人抵押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, MORTGAGE_CONTRACT_NO, MORTGAGE_NO, PAPER_TYPE, PAPER_CODE ORDER BY BUSI_DATE DESC) RN
              FROM CCI_MORTGAGE_CON_INFO_NA C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;
  COMMIT;

  --自然人质押合同信息
  INSERT INTO CCI_ETL_PLEDGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     PLEDGE_CONTRACT_NO,
     PLEDGE_NO,
     PLEDGER_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     PLEDGE_VALUE,
     CONTRACT_SIGN_DATE,
     PLEDGE_TYPE,
     PLEDGE_CURRENCY,
     PLEDGE_AMOUNT,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           PLEDGE_CONTRACT_NO,
           PLEDGE_NO,
           PLEDGER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           PLEDGE_VALUE,
           CONTRACT_SIGN_DATE,
           PLEDGE_TYPE,
           PLEDGE_CURRENCY,
           PLEDGE_AMOUNT,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '01', --自然人质押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, PLEDGE_CONTRACT_NO, PLEDGE_NO, PAPER_TYPE, PAPER_CODE ORDER BY BUSI_DATE DESC) RN
              FROM CCI_PLEDGE_CONTRACT_INFO_NA C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;
  COMMIT;

  --融资协议信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_FULL';
  INSERT INTO CCI_ETL_FINANCE_FULL
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     CREDIT_AGREEMENT_NO,
     START_DATE,
     EXPIRY_DATE,
     GUARANTEE_FLAG,
     AGREEMENT_EFFIECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           CREDIT_AGREEMENT_NO,
           START_DATE,
           EXPIRY_DATE,
           GUARANTEE_FLAG,
           AGREEMENT_EFFIECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY FINANCING_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_FINANCE_AGREEMENT_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;

  COMMIT;

  --融资协议金额信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_AMT_FULL';
  INSERT INTO CCI_ETL_FINANCE_AMT_FULL
    (FINANCING_AGREEMENT_NO,
     CURRENCY,
     FINANCING_AGREEMENT_AMOUNT,
     FINANCING_AGREEMENT_BALANCE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE,
     BUSI_DATE,
     LOAN_CARD_NO)
    SELECT A.FINANCING_AGREEMENT_NO,
           A.CURRENCY,
           A.FINANCING_AGREEMENT_AMOUNT,
           A.FINANCING_AGREEMENT_BALANCE,
           T.CUSTOMER_CODE,
           B.BRANCH_ID,
           B.BRANCH_NO,
           B.DEPT_ID,
           B.MSG_RECORD_OPERATE_TYPE,
           A.RSV_01,
           A.RSV_02,
           T.RSV_03,
           A.RSV_04,
           A.RSV_05,
           A.RSV_06,
           T1_DATE,
           T.BUSI_DATE,
           T.LOAN_CARD_NO
      FROM CCI_FINAN_AGR_AMOUNT_INFO  A,
           CCI_REPORT_SYSTEM_CTL      B,
           CCI_FINANCE_AGREEMENT_INFO T
     WHERE A.PARENT_I = B.SYS_CTL_ID
       AND B.SYS_CTL_ID = T.SYS_CTL_ID
       AND A.PARENT_I IN (SELECT SYS_CTL_ID
                            FROM (SELECT C.*,
                                         D.BRANCH_ID,
                                         D.BRANCH_NO,
                                         D.DEPT_ID,
                                         D.MSG_RECORD_OPERATE_TYPE,
                                         ROW_NUMBER() OVER(PARTITION BY FINANCING_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
                                    FROM CCI_FINANCE_AGREEMENT_INFO C,
                                         CCI_REPORT_SYSTEM_CTL      D
                                   WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
                                     AND D.LOGIC_DELETE_FLAG = '0')
                           WHERE RN = 1);
  COMMIT;

  --融资业务信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_BS_FULL';
  INSERT INTO CCI_ETL_FINANCE_BS_FULL
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     FINANCING_NO,
     FINANCING_FORM,
     CURRENCY,
     FINANCING_AMOUNT,
     FINANCING_BALANCE,
     START_DATE,
     EXPIRY_DATE,
     EXTENSION_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           FINANCING_NO,
           FINANCING_FORM,
           CURRENCY,
           FINANCING_AMOUNT,
           FINANCING_BALANCE,
           START_DATE,
           EXPIRY_DATE,
           EXTENSION_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY FINANCING_AGREEMENT_NO, BRANCH_ID, FINANCING_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_FINANCE_BUSI_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;

  COMMIT;

  --融资业务还款信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_REPAY_FULL';
  INSERT INTO CCI_ETL_FINANCE_REPAY_FULL
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     FINANCING_NO,
     REPAYMENT_COUNT,
     REPAYMENT_AMOUNT,
     REPAYMENT_DATE,
     REPAYMENT_TYPE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           FINANCING_NO,
           REPAYMENT_COUNT,
           REPAYMENT_AMOUNT,
           REPAYMENT_DATE,
           REPAYMENT_TYPE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           A.RSV_01,
           A.RSV_02,
           A.RSV_03,
           A.RSV_04,
           A.RSV_05,
           A.RSV_06,
           T1_DATE
      FROM CCI_FINANCE_BUSI_REPAY_INFO A, CCI_REPORT_SYSTEM_CTL B
     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
       AND B.LOGIC_DELETE_FLAG = '0';

  COMMIT;

  --融资业务展期信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_EXTEN_FULL';
  INSERT INTO CCI_ETL_FINANCE_EXTEN_FULL
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     FINANCING_NO,
     EXTENSION_COUNT,
     EXTENSION_AMOUNT,
     START_DATE,
     EXPIRY_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           FINANCING_NO,
           EXTENSION_COUNT,
           EXTENSION_AMOUNT,
           START_DATE,
           EXPIRY_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           A.RSV_01,
           A.RSV_02,
           A.RSV_03,
           A.RSV_04,
           A.RSV_05,
           A.RSV_06,
           T1_DATE
      FROM CCI_FINANCE_BUSI_EXTEN_INFO A, CCI_REPORT_SYSTEM_CTL B
     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
       AND B.LOGIC_DELETE_FLAG = '0';

  COMMIT;

  --垫款信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ADVANCE_FULL';
  INSERT INTO CCI_ETL_ADVANCE_FULL
    (ADVANCE_BUSINESS_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     ADVANCE_TYPE,
     ORIGIN_BUSI_NO,
     CURRENCY,
     ADVANCE_AMOUNT,
     ADVANCE_DATE,
     ADVANCE_BALANCE,
     ADVANCE_OCC_DATE,
     ADVANCE_FORM,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT ADVANCE_BUSINESS_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           ADVANCE_TYPE,
           ORIGIN_BUSI_NO,
           CURRENCY,
           ADVANCE_AMOUNT,
           ADVANCE_DATE,
           ADVANCE_BALANCE,
           ADVANCE_OCC_DATE,
           ADVANCE_FORM,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY ADVANCE_BUSINESS_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_ADVANCE_BUSINESS_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;

  COMMIT;

  --票据贴现业务信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_BILL_DISCOUNT_FULL';
  INSERT INTO CCI_ETL_BILL_DISCOUNT_FULL
    (BILL_INTERNAL_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BILL_TYPE,
     DISCOUNT_APPLICANT_NAME,
     LOAN_CARD_NO,
     ACCEPTOR_NAME,
     ORG_CODE,
     CURRENCY,
     DISCOUNT_AMOUNT,
     DISCOUNT_DATE,
     ACCEPT_EXPIRY_DATE,
     BILL_AMOUNT,
     BILL_STATUS,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     DISC_APPL_LOAN_CARD_NO,
     ACCEPTOR_LOAN_CARD_NO,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT BILL_INTERNAL_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BILL_TYPE,
           DISCOUNT_APPLICANT_NAME,
           LOAN_CARD_NO,
           ACCEPTOR_NAME,
           ORG_CODE,
           CURRENCY,
           DISCOUNT_AMOUNT,
           DISCOUNT_DATE,
           ACCEPT_EXPIRY_DATE,
           BILL_AMOUNT,
           BILL_STATUS,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           DISC_APPL_LOAN_CARD_NO,
           ACCEPTOR_LOAN_CARD_NO,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY BILL_INTERNAL_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_BILL_DISCOUNT_BUSI_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;

  COMMIT;

  --信用证业务信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_CARD_FULL';
  INSERT INTO CCI_ETL_CARD_FULL
    (LETTER_OF_CREDIT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     ISSUE_AMOUNT,
     ISSUE_DATE,
     VALIDITY_PERIOD,
     PAYMENT_TERM,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     LETTER_OF_CREDIT_STATUS,
     CANCELLATION_DATE,
     LETTER_OF_CREDIT_BALANCE,
     BALANCE_REPORT_DATE,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LETTER_OF_CREDIT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           ISSUE_AMOUNT,
           ISSUE_DATE,
           VALIDITY_PERIOD,
           PAYMENT_TERM,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           LETTER_OF_CREDIT_STATUS,
           CANCELLATION_DATE,
           LETTER_OF_CREDIT_BALANCE,
           BALANCE_REPORT_DATE,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY LETTER_OF_CREDIT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_CREDIT_LETTER_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;

  COMMIT;

  --银行承兑汇票业务信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_BANK_ACCEPT_FULL';
  INSERT INTO CCI_ETL_BANK_ACCEPT_FULL
    (ACCEPTANCE_AGREEMENT_NO,
     DRAFT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     DRAWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     DRAFT_AMOUNT,
     DRAFT_ACCEPTANCE_DATE,
     DRAFT_EXPIRY_DATE,
     DRAFT_PAYMENT_DATE,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     DRAFT_STATUS,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT ACCEPTANCE_AGREEMENT_NO,
           DRAFT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           DRAWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           DRAFT_AMOUNT,
           DRAFT_ACCEPTANCE_DATE,
           DRAFT_EXPIRY_DATE,
           DRAFT_PAYMENT_DATE,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           DRAFT_STATUS,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY DRAFT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_BANK_ACCEPT_BUSI_INFO C, CCI_REPORT_SYSTEM_CTL D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;
  COMMIT;

  --=============================================================================
  --产品表到接口表全量表同步(从产品端取第一条后，额外处理操作类型删除的记录)
  --=============================================================================
  --授信信息
  DELETE FROM CCI_ETL_CREDIT_FULL T
   WHERE T.CREDIT_AGREEMENT_NO || T.BRANCH_ID IN
         (SELECT C.CREDIT_AGREEMENT_NO || D.BRANCH_ID
            FROM CCI_PUBLIC_CREDIT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2');
  COMMIT;
  INSERT INTO CCI_ETL_CREDIT_FULL
    (CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     LOAN_CREDIT,
     START_DATE,
     EXPIRY_DATE,
     LOAN_CREDIT_START_DATE,
     LOAN_CREDIT_CANCEL_REASON,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE,
     LE_ID,
     MAKER_CHECKER_STAFF_ID,
     LOAN_CREDIT_OLD)
    SELECT CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           LOAN_CREDIT,
           START_DATE,
           EXPIRY_DATE,
           LOAN_CREDIT_START_DATE,
           LOAN_CREDIT_CANCEL_REASON,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE,
           LE_ID,
           MAKER_CHECKER_STAFF_ID,
           LOAN_CREDIT_OLD
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY CREDIT_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_PUBLIC_CREDIT_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_PUBLIC_CREDIT_INFO A, CCI_REPORT_SYSTEM_CTL B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.CREDIT_AGREEMENT_NO = C.CREDIT_AGREEMENT_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;
  COMMIT;

  --保函业务记录
  DELETE FROM CCI_ETL_INDEMNITY_FULL T
   WHERE T.INDEMNITY_CODE || T.BRANCH_ID IN
         (SELECT C.INDEMNITY_CODE || D.BRANCH_ID
            FROM CCI_INDEMNITY_BUSI C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2');

  INSERT INTO CCI_ETL_INDEMNITY_FULL
    (INDEMNITY_CODE,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     INDEMNITY_TYPE,
     INDEMNITY_STATE,
     CURRENCY,
     AMOUNT,
     START_DATE,
     EXPIRY_DATE,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     BALANCE,
     BALANCE_OCC_DATE,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT INDEMNITY_CODE,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           INDEMNITY_TYPE,
           INDEMNITY_STATE,
           CURRENCY,
           AMOUNT,
           START_DATE,
           EXPIRY_DATE,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           BALANCE,
           BALANCE_OCC_DATE,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY INDEMNITY_CODE, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_INDEMNITY_BUSI_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_INDEMNITY_BUSI A, CCI_REPORT_SYSTEM_CTL B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.INDEMNITY_CODE = C.INDEMNITY_CODE
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --保理业务信息
  DELETE FROM CCI_ETL_FACTORING_FULL T
   WHERE T.FACTORING_AGREEMENT_NO || T.BRANCH_ID IN
         (SELECT C.FACTORING_AGREEMENT_NO || D.BRANCH_ID
            FROM CCI_FACTORING_BUSI C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2');
  COMMIT;
  INSERT INTO CCI_ETL_FACTORING_FULL
    (FACTORING_AGREEMENT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     PRODUCT_TYPE,
     BUSI_STATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     CONTINUE_AMOUNT,
     CONTINUE_DATE,
     CONTINUE_BALANCE,
     CONTINUE_CHANGE_DATE,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT FACTORING_AGREEMENT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           PRODUCT_TYPE,
           BUSI_STATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           CONTINUE_AMOUNT,
           CONTINUE_DATE,
           CONTINUE_BALANCE,
           CONTINUE_CHANGE_DATE,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY FACTORING_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_FACTORING_BUSI_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_FACTORING_BUSI A, CCI_REPORT_SYSTEM_CTL B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.FACTORING_AGREEMENT_NO =
                           C.FACTORING_AGREEMENT_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;
  COMMIT;

  --贷款业务合同信息
  DELETE FROM CCI_ETL_CONTRACT_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.BRANCH_ID = D.BRANCH_ID);
  COMMIT;
  INSERT INTO CCI_ETL_CONTRACT_FULL
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     CREDIT_AGREEMENT_NO,
     START_DATE,
     EXPIRY_DATE,
     BANK_GROUP_FLAG,
     GUARANTEE_FLAG,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           CREDIT_AGREEMENT_NO,
           START_DATE,
           EXPIRY_DATE,
           BANK_GROUP_FLAG,
           GUARANTEE_FLAG,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY LOAN_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_CONTRACT_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL
               AND EXISTS
             (SELECT 1
                      FROM CCI_CONTRACT_INFO A, CCI_REPORT_SYSTEM_CTL B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.LOAN_CARD_NO IS NOT NULL
                       AND A.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
                       AND A.LOAN_CARD_NO = C.LOAN_CARD_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;
  COMMIT;

  --贷款业务金额信息
  DELETE FROM CCI_ETL_CONTRACT_AMOUNT_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.BRANCH_ID = D.BRANCH_ID);
  COMMIT;
  INSERT INTO CCI_ETL_CONTRACT_AMOUNT_FULL
    (LOAN_CONTRACT_NO,
     CURRENCY,
     AMOUNT,
     BALANCE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE,
     BUSI_DATE,
     LOAN_CARD_NO)
    SELECT T.LOAN_CONTRACT_NO,
           T.CURRENCY,
           T.AMOUNT,
           T.BALANCE,
           A.CUSTOMER_CODE    AS CUSTOMER_CODE,
           B.BRANCH_ID,
           B.BRANCH_ID,
           NULL               AS DEPT_ID,
           '1',
           T.RSV_01,
           T.RSV_02,
           A.RSV_03,
           T.RSV_04,
           T.RSV_05,
           T.RSV_06,
           T1_DATE,
           A.BUSI_DATE,
           A.LOAN_CARD_NO
      FROM CCI_CONTRACT_AMOUNT_INFO T,
           CCI_CONTRACT_INFO        A,
           CCI_REPORT_SYSTEM_CTL    B
     WHERE T.PARENT_I = A.SYS_CTL_ID
       AND A.SYS_CTL_ID = B.SYS_CTL_ID
       AND T.PARENT_I IN
           (SELECT SYS_CTL_ID
              FROM (SELECT C.*,
                           D.BRANCH_ID,
                           D.BRANCH_NO,
                           D.DEPT_ID,
                           D.MSG_RECORD_OPERATE_TYPE,
                           ROW_NUMBER() OVER(PARTITION BY LOAN_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO ORDER BY BUSI_DATE DESC) RN
                      FROM CCI_CONTRACT_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
                     WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
                       AND D.LOGIC_DELETE_FLAG = '0'
                       AND C.LOAN_CARD_NO IS NOT NULL
                       AND EXISTS
                     (SELECT 1
                              FROM CCI_CONTRACT_INFO     A,
                                   CCI_REPORT_SYSTEM_CTL B
                             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                               AND B.LOGIC_DELETE_FLAG = '0'
                               AND B.MSG_RECORD_OPERATE_TYPE = '4'
                               AND B.REPORT_FLAG = '2'
                               AND A.LOAN_CARD_NO IS NOT NULL
                               AND A.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
                               AND A.LOAN_CARD_NO = C.LOAN_CARD_NO
                               AND B.BRANCH_ID = D.BRANCH_ID
                               AND A.BUSI_DATE > C.BUSI_DATE))
             WHERE RN = 1);
  COMMIT;
  --贷款业务借据信息
  DELETE FROM CCI_ETL_LOAN_RECEIPT_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_LOAN_RECEIPT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.RECIEPT_NO = C.RECIEPT_NO
             AND T.BRANCH_ID = D.BRANCH_ID);
  COMMIT;
  INSERT INTO CCI_ETL_LOAN_RECEIPT_FULL
    (LOAN_CARD_NO,
     LOAN_CONTRACT_NO,
     BUSI_DATE,
     RECIEPT_NO,
     CURRENCY,
     RECIEPT_AMOUNT,
     RECIEPT_BALANCE,
     START_DATE,
     EXPIRY_DATE,
     LOAN_BUSI_TYPE,
     LOAN_FORM,
     LOAN_PROPERTY,
     LOAN_ORIENTATION,
     LOAN_TYPE,
     EXTENSION_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           LOAN_CONTRACT_NO,
           BUSI_DATE,
           RECIEPT_NO,
           CURRENCY,
           RECIEPT_AMOUNT,
           RECIEPT_BALANCE,
           START_DATE,
           EXPIRY_DATE,
           LOAN_BUSI_TYPE,
           LOAN_FORM,
           LOAN_PROPERTY,
           LOAN_ORIENTATION,
           LOAN_TYPE,
           EXTENSION_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY LOAN_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, RECIEPT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_LOAN_RECEIPT_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL
               AND EXISTS
             (SELECT 1
                      FROM CCI_LOAN_RECEIPT_INFO A, CCI_REPORT_SYSTEM_CTL B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.LOAN_CARD_NO IS NOT NULL
                       AND A.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
                       AND A.LOAN_CARD_NO = C.LOAN_CARD_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.RECIEPT_NO = C.RECIEPT_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;
  COMMIT;

  --贷款业务还款信息
  DELETE FROM CCI_ETL_LOAN_REPAYMENT_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_LOAN_REPAYMENT C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.RECIEPT_NO = C.RECIEPT_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.BUSI_DATE >= C.BUSI_DATE);
  COMMIT;

  --贷款业务展期信息
  DELETE FROM CCI_ETL_LOAN_EXTENSION_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_LOAN_EXTENSION_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.LOAN_CONTRACT_NO = C.LOAN_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.RECIEPT_NO = C.RECIEPT_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.BUSI_DATE >= C.BUSI_DATE);
  COMMIT;

  --保证合同信息(取最新，有效且不是逻辑删除的记录)
  DELETE FROM CCI_ETL_GUARANTEE_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_GUARANTEE_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.GUARANTEE_LOAN_CARD_NO = C.GUARANTEE_LOAN_CARD_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.GUARANTEE_CONTRACT_NO = C.GUARANTEE_CONTRACT_NO);
  COMMIT;
  INSERT INTO CCI_ETL_GUARANTEE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     GUARANTEE_CONTRACT_NO,
     GUARANTEE_NAME,
     GUARANTEE_LOAN_CARD_NO,
     CURRENCY,
     GUARANTEE_AMOUNT,
     CONTRACT_SIGN_DATE,
     GUARANTEE_TYPE,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           GUARANTEE_CONTRACT_NO,
           GUARANTEE_NAME,
           GUARANTEE_LOAN_CARD_NO,
           CURRENCY,
           GUARANTEE_AMOUNT,
           CONTRACT_SIGN_DATE,
           GUARANTEE_TYPE,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '02', --非自然人保证
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, GUARANTEE_LOAN_CARD_NO, GUARANTEE_CONTRACT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_GUARANTEE_CONTRACT_INFO_H C,
                   CCI_REPORT_SYSTEM_CTL_H       D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL
               AND EXISTS
             (SELECT 1
                      FROM CCI_GUARANTEE_CONTRACT_INFO A,
                           CCI_REPORT_SYSTEM_CTL       B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
                       AND A.LOAN_CARD_NO = C.LOAN_CARD_NO
                       AND A.GUARANTEE_LOAN_CARD_NO =
                           C.GUARANTEE_LOAN_CARD_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.GUARANTEE_CONTRACT_NO = C.GUARANTEE_CONTRACT_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --抵押合同信息
  DELETE FROM CCI_ETL_MORTGAGE_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_MORTGAGE_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.MORTGAGER_LOAN_CARD_NO = C.MORTGAGER_LOAN_CARD_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.MORTGAGE_CONTRACT_NO = C.MORTGAGE_CONTRACT_NO
             AND T.MORTGAGE_NO = C.MORTGAGE_NO);
  COMMIT;
  INSERT INTO CCI_ETL_MORTGAGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     MORTGAGE_CONTRACT_NO,
     MORTGAGE_NO,
     MORTGAGER_NAME,
     MORTGAGER_LOAN_CARD_NO,
     CURRENCY,
     MORTGAGE_ASSESS_VALUE,
     ASSESS_DATE,
     ASSESS_ORG_NAME,
     ASSESS_ORG_CODE,
     CONTRACT_SIGN_DATE,
     MORTGAGE_TYPE,
     MORTGAGE_CURRENCY,
     MORTGAGE_AMOUNT,
     ISSUE_ORG_NAME,
     ISSUE_DATE,
     MORTGAGE_INSTRUCTION,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           MORTGAGE_CONTRACT_NO,
           MORTGAGE_NO,
           MORTGAGER_NAME,
           MORTGAGER_LOAN_CARD_NO,
           CURRENCY,
           MORTGAGE_ASSESS_VALUE,
           ASSESS_DATE,
           ASSESS_ORG_NAME,
           ASSESS_ORG_CODE,
           CONTRACT_SIGN_DATE,
           MORTGAGE_TYPE,
           MORTGAGE_CURRENCY,
           MORTGAGE_AMOUNT,
           ISSUE_ORG_NAME,
           ISSUE_DATE,
           MORTGAGE_INSTRUCTION,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '02', --非自然人抵押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, MORTGAGER_LOAN_CARD_NO, MORTGAGE_NO, MORTGAGE_CONTRACT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_MORTGAGE_CONTRACT_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL
               AND EXISTS
             (SELECT 1
                      FROM CCI_MORTGAGE_CONTRACT_INFO A,
                           CCI_REPORT_SYSTEM_CTL      B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
                       AND A.LOAN_CARD_NO = C.LOAN_CARD_NO
                       AND A.MORTGAGER_LOAN_CARD_NO =
                           C.MORTGAGER_LOAN_CARD_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.MORTGAGE_CONTRACT_NO = C.MORTGAGE_CONTRACT_NO
                       AND A.MORTGAGE_NO = C.MORTGAGE_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --质押合同信息
  DELETE FROM CCI_ETL_PLEDGE_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_PLEDGE_CONTRACT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
             AND T.LOAN_CARD_NO = C.LOAN_CARD_NO
             AND T.PLEDGER_LOAN_CARD_NO = C.PLEDGER_LOAN_CARD_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.PLEDGE_CONTRACT_NO = C.PLEDGE_CONTRACT_NO
             AND T.PLEDGE_NO = C.PLEDGE_NO);
  COMMIT;
  INSERT INTO CCI_ETL_PLEDGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     PLEDGE_CONTRACT_NO,
     PLEDGE_NO,
     PLEDGER_NAME,
     PLEDGER_LOAN_CARD_NO,
     CURRENCY,
     PLEDGE_VALUE,
     CONTRACT_SIGN_DATE,
     PLEDGE_TYPE,
     PLEDGE_CURRENCY,
     PLEDGE_AMOUNT,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           PLEDGE_CONTRACT_NO,
           PLEDGE_NO,
           PLEDGER_NAME,
           PLEDGER_LOAN_CARD_NO,
           CURRENCY,
           PLEDGE_VALUE,
           CONTRACT_SIGN_DATE,
           PLEDGE_TYPE,
           PLEDGE_CURRENCY,
           PLEDGE_AMOUNT,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '02', --非自然人质押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, LOAN_CARD_NO, PLEDGER_LOAN_CARD_NO, PLEDGE_NO, PLEDGE_CONTRACT_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_PLEDGE_CONTRACT_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND C.LOAN_CARD_NO IS NOT NULL
               AND EXISTS
             (SELECT 1
                      FROM CCI_PLEDGE_CONTRACT_INFO A,
                           CCI_REPORT_SYSTEM_CTL    B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
                       AND A.LOAN_CARD_NO = C.LOAN_CARD_NO
                       AND A.PLEDGER_LOAN_CARD_NO = C.PLEDGER_LOAN_CARD_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.PLEDGE_CONTRACT_NO = C.PLEDGE_CONTRACT_NO
                       AND A.PLEDGE_NO = C.PLEDGE_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --自然人保证合同信息
  DELETE FROM CCI_ETL_GUARANTEE_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_GUARANTEE_CON_INFO_NA C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
             AND T.PAPER_TYPE = C.PAPER_TYPE
             AND T.GUARANTEE_CONTRACT_NO = C.GUARANTEE_CONTRACT_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.PAPER_CODE = C.PAPER_CODE
             AND T.GUARANTEE_NAME = C.GUARANTEER_NAME);
  COMMIT;
  INSERT INTO CCI_ETL_GUARANTEE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     GUARANTEE_CONTRACT_NO,
     GUARANTEE_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     GUARANTEE_AMOUNT,
     CONTRACT_SIGN_DATE,
     GUARANTEE_TYPE,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           GUARANTEE_CONTRACT_NO,
           GUARANTEER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           GUARANTEE_AMOUNT,
           CONTRACT_SIGN_DATE,
           GUARANTEE_TYPE,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '01', --自然人保证
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, GUARANTEE_CONTRACT_NO, PAPER_TYPE, PAPER_CODE, GUARANTEER_NAME ORDER BY BUSI_DATE DESC) RN
              FROM CCI_GUARANTEE_CON_INFO_NA_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_GUARANTEE_CON_INFO_NA A,
                           CCI_REPORT_SYSTEM_CTL     B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
                       AND A.PAPER_TYPE = C.PAPER_TYPE
                       AND A.GUARANTEE_CONTRACT_NO = C.GUARANTEE_CONTRACT_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.PAPER_CODE = C.PAPER_CODE
                       AND A.GUARANTEER_NAME = C.GUARANTEER_NAME
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;
  COMMIT;

  --自然人抵押合同信息
  DELETE FROM CCI_ETL_MORTGAGE_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_MORTGAGE_CON_INFO_NA C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
             AND T.MORTGAGE_CONTRACT_NO = C.MORTGAGE_CONTRACT_NO
             AND T.MORTGAGE_NO = C.MORTGAGE_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.PAPER_CODE = C.PAPER_CODE
             AND T.PAPER_TYPE = C.PAPER_TYPE);
  COMMIT;
  INSERT INTO CCI_ETL_MORTGAGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     MORTGAGE_CONTRACT_NO,
     MORTGAGE_NO,
     MORTGAGER_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     MORTGAGE_ASSESS_VALUE,
     ASSESS_DATE,
     ASSESS_ORG_NAME,
     ASSESS_ORG_CODE,
     CONTRACT_SIGN_DATE,
     MORTGAGE_TYPE,
     MORTGAGE_CURRENCY,
     MORTGAGE_AMOUNT,
     ISSUE_ORG_NAME,
     ISSUE_DATE,
     MORTGAGE_INSTRUCTION,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           MORTGAGE_CONTRACT_NO,
           MORTGAGE_NO,
           MORTGAGER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           MORTGAGE_ASSESS_VALUE,
           ASSESS_DATE,
           ASSESS_ORG_NAME,
           ASSESS_ORG_CODE,
           CONTRACT_SIGN_DATE,
           MORTGAGE_TYPE,
           MORTGAGE_CURRENCY,
           MORTGAGE_AMOUNT,
           ISSUE_ORG_NAME,
           ISSUE_DATE,
           MORTGAGE_INSTRUCTION,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '01', --自然人抵押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, MORTGAGE_CONTRACT_NO, MORTGAGE_NO, PAPER_TYPE, PAPER_CODE ORDER BY BUSI_DATE DESC) RN
              FROM CCI_MORTGAGE_CON_INFO_NA_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_MORTGAGE_CON_INFO_NA A,
                           CCI_REPORT_SYSTEM_CTL    B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
                       AND A.MORTGAGE_CONTRACT_NO = C.MORTGAGE_CONTRACT_NO
                       AND A.MORTGAGE_NO = C.MORTGAGE_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.PAPER_CODE = C.PAPER_CODE
                       AND A.PAPER_TYPE = C.PAPER_TYPE
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;
  COMMIT;

  --自然人质押合同信息
  DELETE FROM CCI_ETL_PLEDGE_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_PLEDGE_CONTRACT_INFO_NA C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
             AND T.PLEDGE_CONTRACT_NO = C.PLEDGE_CONTRACT_NO
             AND T.PLEDGE_NO = C.PLEDGE_NO
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.PAPER_CODE = C.PAPER_CODE
             AND T.PAPER_TYPE = C.PAPER_TYPE);
  COMMIT;
  INSERT INTO CCI_ETL_PLEDGE_FULL
    (LOAN_CARD_NO,
     MAJOR_CONTRACT_NO,
     BUSI_TYPE,
     BUSI_DATE,
     PLEDGE_CONTRACT_NO,
     PLEDGE_NO,
     PLEDGER_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     CURRENCY,
     PLEDGE_VALUE,
     CONTRACT_SIGN_DATE,
     PLEDGE_TYPE,
     PLEDGE_CURRENCY,
     PLEDGE_AMOUNT,
     CONTRACT_EFFECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     REPORT_TYPE,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           MAJOR_CONTRACT_NO,
           BUSI_TYPE,
           BUSI_DATE,
           PLEDGE_CONTRACT_NO,
           PLEDGE_NO,
           PLEDGER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           CURRENCY,
           PLEDGE_VALUE,
           CONTRACT_SIGN_DATE,
           PLEDGE_TYPE,
           PLEDGE_CURRENCY,
           PLEDGE_AMOUNT,
           CONTRACT_EFFECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           '01', --自然人质押
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY MAJOR_CONTRACT_NO, BRANCH_ID, PLEDGE_CONTRACT_NO, PLEDGE_NO, PAPER_TYPE, PAPER_CODE ORDER BY BUSI_DATE DESC) RN
              FROM CCI_PLEDGE_CONTRACT_INFO_NA_H C,
                   CCI_REPORT_SYSTEM_CTL_H       D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_PLEDGE_CONTRACT_INFO_NA A,
                           CCI_REPORT_SYSTEM_CTL       B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND A.MAJOR_CONTRACT_NO = C.MAJOR_CONTRACT_NO
                       AND A.PLEDGE_CONTRACT_NO = C.PLEDGE_CONTRACT_NO
                       AND A.PLEDGE_NO = C.PLEDGE_NO
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.PAPER_CODE = C.PAPER_CODE
                       AND A.PAPER_TYPE = C.PAPER_TYPE
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;
  COMMIT;

  --融资协议信息
  DELETE FROM CCI_ETL_FINANCE_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_FINANCE_AGREEMENT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.FINANCING_AGREEMENT_NO = C.FINANCING_AGREEMENT_NO);
  COMMIT;
  INSERT INTO CCI_ETL_FINANCE_FULL
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     CREDIT_AGREEMENT_NO,
     START_DATE,
     EXPIRY_DATE,
     GUARANTEE_FLAG,
     AGREEMENT_EFFIECTIVE_STATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           CREDIT_AGREEMENT_NO,
           START_DATE,
           EXPIRY_DATE,
           GUARANTEE_FLAG,
           AGREEMENT_EFFIECTIVE_STATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY FINANCING_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_FINANCE_AGREEMENT_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS (SELECT 1
                      FROM CCI_FINANCE_AGREEMENT_INFO A,
                           CCI_REPORT_SYSTEM_CTL      B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.FINANCING_AGREEMENT_NO =
                           C.FINANCING_AGREEMENT_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --融资协议金额信息
  DELETE FROM CCI_ETL_FINANCE_AMT_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_FINANCE_AGREEMENT_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.FINANCING_AGREEMENT_NO = C.FINANCING_AGREEMENT_NO);
  COMMIT;
  INSERT INTO CCI_ETL_FINANCE_AMT_FULL
    (FINANCING_AGREEMENT_NO,
     CURRENCY,
     FINANCING_AGREEMENT_AMOUNT,
     FINANCING_AGREEMENT_BALANCE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE,
     BUSI_DATE,
     LOAN_CARD_NO)
    SELECT A.FINANCING_AGREEMENT_NO,
           A.CURRENCY,
           A.FINANCING_AGREEMENT_AMOUNT,
           A.FINANCING_AGREEMENT_BALANCE,
           T.CUSTOMER_CODE,
           B.BRANCH_ID,
           B.BRANCH_NO,
           B.DEPT_ID,
           B.MSG_RECORD_OPERATE_TYPE,
           A.RSV_01,
           A.RSV_02,
           T.RSV_03,
           A.RSV_04,
           A.RSV_05,
           A.RSV_06,
           T1_DATE,
           T.BUSI_DATE,
           T.LOAN_CARD_NO
      FROM CCI_FINAN_AGR_AMOUNT_INFO  A,
           CCI_REPORT_SYSTEM_CTL      B,
           CCI_FINANCE_AGREEMENT_INFO T
     WHERE A.PARENT_I = B.SYS_CTL_ID
       AND B.SYS_CTL_ID = T.SYS_CTL_ID
       AND A.PARENT_I IN (SELECT SYS_CTL_ID
                            FROM (SELECT C.*,
                                         D.BRANCH_ID,
                                         D.BRANCH_NO,
                                         D.DEPT_ID,
                                         D.MSG_RECORD_OPERATE_TYPE,
                                         ROW_NUMBER() OVER(PARTITION BY FINANCING_AGREEMENT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
                                    FROM CCI_FINANCE_AGREEMENT_INFO_H C,
                                         CCI_REPORT_SYSTEM_CTL_H      D
                                   WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
                                     AND D.LOGIC_DELETE_FLAG = '0'
                                     AND EXISTS
                                   (SELECT 1
                                            FROM CCI_FINANCE_AGREEMENT_INFO A,
                                                 CCI_REPORT_SYSTEM_CTL      B
                                           WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                                             AND B.LOGIC_DELETE_FLAG = '0'
                                             AND B.MSG_RECORD_OPERATE_TYPE = '4'
                                             AND B.REPORT_FLAG = '2'
                                             AND B.BRANCH_ID = D.BRANCH_ID
                                             AND A.FINANCING_AGREEMENT_NO =
                                                 C.FINANCING_AGREEMENT_NO
                                             AND A.BUSI_DATE > C.BUSI_DATE))
                           WHERE RN = 1);
  COMMIT;

  --融资业务信息
  DELETE FROM CCI_ETL_FINANCE_BS_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_FINANCE_BUSI_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.FINANCING_AGREEMENT_NO = C.FINANCING_AGREEMENT_NO
             AND T.FINANCING_NO = C.FINANCING_NO);
  COMMIT;
  INSERT INTO CCI_ETL_FINANCE_BS_FULL
    (LOAN_CARD_NO,
     FINANCING_AGREEMENT_NO,
     BUSI_DATE,
     FINANCING_NO,
     FINANCING_FORM,
     CURRENCY,
     FINANCING_AMOUNT,
     FINANCING_BALANCE,
     START_DATE,
     EXPIRY_DATE,
     EXTENSION_FLAG,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LOAN_CARD_NO,
           FINANCING_AGREEMENT_NO,
           BUSI_DATE,
           FINANCING_NO,
           FINANCING_FORM,
           CURRENCY,
           FINANCING_AMOUNT,
           FINANCING_BALANCE,
           START_DATE,
           EXPIRY_DATE,
           EXTENSION_FLAG,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY FINANCING_AGREEMENT_NO, BRANCH_ID, FINANCING_NO ORDER BY BUSI_DATE DESC) RN
              FROM CCI_FINANCE_BUSI_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_FINANCE_BUSI_INFO A, CCI_REPORT_SYSTEM_CTL B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.FINANCING_AGREEMENT_NO =
                           C.FINANCING_AGREEMENT_NO
                       AND A.FINANCING_NO = C.FINANCING_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --融资业务还款信息
  DELETE FROM CCI_ETL_FINANCE_REPAY_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_FINANCE_BUSI_REPAY_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.FINANCING_AGREEMENT_NO = C.FINANCING_AGREEMENT_NO
             AND T.FINANCING_NO = C.FINANCING_NO
             AND T.BUSI_DATE >= C.BUSI_DATE);
  COMMIT;

  --融资业务展期信息
  DELETE FROM CCI_ETL_FINANCE_EXTEN_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_FINANCE_BUSI_EXTEN_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.FINANCING_AGREEMENT_NO = C.FINANCING_AGREEMENT_NO
             AND T.FINANCING_NO = C.FINANCING_NO
             AND T.BUSI_DATE >= C.BUSI_DATE);
  COMMIT;

  --垫款信息
  DELETE FROM CCI_ETL_ADVANCE_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_ADVANCE_BUSINESS_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.ADVANCE_BUSINESS_NO = C.ADVANCE_BUSINESS_NO);
  COMMIT;
  INSERT INTO CCI_ETL_ADVANCE_FULL
    (ADVANCE_BUSINESS_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     ADVANCE_TYPE,
     ORIGIN_BUSI_NO,
     CURRENCY,
     ADVANCE_AMOUNT,
     ADVANCE_DATE,
     ADVANCE_BALANCE,
     ADVANCE_OCC_DATE,
     ADVANCE_FORM,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT ADVANCE_BUSINESS_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           ADVANCE_TYPE,
           ORIGIN_BUSI_NO,
           CURRENCY,
           ADVANCE_AMOUNT,
           ADVANCE_DATE,
           ADVANCE_BALANCE,
           ADVANCE_OCC_DATE,
           ADVANCE_FORM,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY ADVANCE_BUSINESS_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_ADVANCE_BUSINESS_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_ADVANCE_BUSINESS_INFO A,
                           CCI_REPORT_SYSTEM_CTL     B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.ADVANCE_BUSINESS_NO = C.ADVANCE_BUSINESS_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --票据贴现业务信息
  DELETE FROM CCI_ETL_BILL_DISCOUNT_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_BILL_DISCOUNT_BUSI_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.BILL_INTERNAL_NO = C.BILL_INTERNAL_NO);
  COMMIT;
  INSERT INTO CCI_ETL_BILL_DISCOUNT_FULL
    (BILL_INTERNAL_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BILL_TYPE,
     DISCOUNT_APPLICANT_NAME,
     LOAN_CARD_NO,
     ACCEPTOR_NAME,
     ORG_CODE,
     CURRENCY,
     DISCOUNT_AMOUNT,
     DISCOUNT_DATE,
     ACCEPT_EXPIRY_DATE,
     BILL_AMOUNT,
     BILL_STATUS,
     FOUR_STAGE_CLASSIFICATION,
     FIVE_STAGE_CLASSIFICATION,
     DISC_APPL_LOAN_CARD_NO,
     ACCEPTOR_LOAN_CARD_NO,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT BILL_INTERNAL_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BILL_TYPE,
           DISCOUNT_APPLICANT_NAME,
           LOAN_CARD_NO,
           ACCEPTOR_NAME,
           ORG_CODE,
           CURRENCY,
           DISCOUNT_AMOUNT,
           DISCOUNT_DATE,
           ACCEPT_EXPIRY_DATE,
           BILL_AMOUNT,
           BILL_STATUS,
           FOUR_STAGE_CLASSIFICATION,
           FIVE_STAGE_CLASSIFICATION,
           DISC_APPL_LOAN_CARD_NO,
           ACCEPTOR_LOAN_CARD_NO,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY BILL_INTERNAL_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_BILL_DISCOUNT_BUSI_INFO_H C,
                   CCI_REPORT_SYSTEM_CTL_H       D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_BILL_DISCOUNT_BUSI_INFO A,
                           CCI_REPORT_SYSTEM_CTL       B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.BILL_INTERNAL_NO = C.BILL_INTERNAL_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --信用证业务信息
  DELETE FROM CCI_ETL_CARD_FULL T
   WHERE EXISTS
   (SELECT 1
            FROM CCI_CREDIT_LETTER_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.LETTER_OF_CREDIT_NO = C.LETTER_OF_CREDIT_NO);
  COMMIT;
  INSERT INTO CCI_ETL_CARD_FULL
    (LETTER_OF_CREDIT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     BORROWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     ISSUE_AMOUNT,
     ISSUE_DATE,
     VALIDITY_PERIOD,
     PAYMENT_TERM,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     LETTER_OF_CREDIT_STATUS,
     CANCELLATION_DATE,
     LETTER_OF_CREDIT_BALANCE,
     BALANCE_REPORT_DATE,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT LETTER_OF_CREDIT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           BORROWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           ISSUE_AMOUNT,
           ISSUE_DATE,
           VALIDITY_PERIOD,
           PAYMENT_TERM,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           LETTER_OF_CREDIT_STATUS,
           CANCELLATION_DATE,
           LETTER_OF_CREDIT_BALANCE,
           BALANCE_REPORT_DATE,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY LETTER_OF_CREDIT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_CREDIT_LETTER_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS
             (SELECT 1
                      FROM CCI_CREDIT_LETTER_INFO A, CCI_REPORT_SYSTEM_CTL B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.LETTER_OF_CREDIT_NO = C.LETTER_OF_CREDIT_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --银行承兑汇票业务信息
  DELETE FROM CCI_ETL_BANK_ACCEPT_FULL T
   WHERE EXISTS (SELECT 1
            FROM CCI_BANK_ACCEPT_BUSI_INFO C, CCI_REPORT_SYSTEM_CTL D
           WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
             AND D.LOGIC_DELETE_FLAG = '0'
             AND D.MSG_RECORD_OPERATE_TYPE = '4'
             AND D.REPORT_FLAG = '2'
             AND T.BRANCH_ID = D.BRANCH_ID
             AND T.DRAFT_NO = C.DRAFT_NO);
  COMMIT;
  INSERT INTO CCI_ETL_BANK_ACCEPT_FULL
    (ACCEPTANCE_AGREEMENT_NO,
     DRAFT_NO,
     CREDIT_AGREEMENT_NO,
     BUSI_DATE,
     DRAWER_NAME,
     LOAN_CARD_NO,
     CURRENCY,
     DRAFT_AMOUNT,
     DRAFT_ACCEPTANCE_DATE,
     DRAFT_EXPIRY_DATE,
     DRAFT_PAYMENT_DATE,
     MARGIN_RATIO,
     GUARANTEE_FLAG,
     ADVANCE_FLAG,
     DRAFT_STATUS,
     FIVE_STAGE_CLASSIFICATION,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT ACCEPTANCE_AGREEMENT_NO,
           DRAFT_NO,
           CREDIT_AGREEMENT_NO,
           BUSI_DATE,
           DRAWER_NAME,
           LOAN_CARD_NO,
           CURRENCY,
           DRAFT_AMOUNT,
           DRAFT_ACCEPTANCE_DATE,
           DRAFT_EXPIRY_DATE,
           DRAFT_PAYMENT_DATE,
           MARGIN_RATIO,
           GUARANTEE_FLAG,
           ADVANCE_FLAG,
           DRAFT_STATUS,
           FIVE_STAGE_CLASSIFICATION,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT C.*,
                   D.BRANCH_ID,
                   D.BRANCH_NO,
                   D.DEPT_ID,
                   D.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY DRAFT_NO, BRANCH_ID ORDER BY BUSI_DATE DESC) RN
              FROM CCI_BANK_ACCEPT_BUSI_INFO_H C, CCI_REPORT_SYSTEM_CTL_H D
             WHERE C.SYS_CTL_ID = D.SYS_CTL_ID
               AND D.LOGIC_DELETE_FLAG = '0'
               AND EXISTS (SELECT 1
                      FROM CCI_BANK_ACCEPT_BUSI_INFO A,
                           CCI_REPORT_SYSTEM_CTL     B
                     WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
                       AND B.LOGIC_DELETE_FLAG = '0'
                       AND B.MSG_RECORD_OPERATE_TYPE = '4'
                       AND B.REPORT_FLAG = '2'
                       AND B.BRANCH_ID = D.BRANCH_ID
                       AND A.DRAFT_NO = C.DRAFT_NO
                       AND A.BUSI_DATE > C.BUSI_DATE))
     WHERE RN = 1;

  COMMIT;

  --机构基础信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_BASIC_FULL';
  COMMIT;

  INSERT INTO CCI_ETL_ORG_BASIC_FULL
    (MANAGEMENT_ROW_CODE,
     CUSTOMER_TYPE,
     ORG_CREDIT_CODE_A,
     ORG_CODE_A,
     REGISTRATION_CODE_TYPE_A,
     REGISTRATION_CODE_A,
     TAX_IDENTIFY_CODE_NA,
     TAX_IDENTIFY_CODE_ST,
     OPEN_ACCOUNT_APPROVAL_NO,
     LOAN_CARD_NO,
     DATA_ABSTRACT_DATE,
     RSV_A,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT MANAGEMENT_ROW_CODE,
           CUSTOMER_TYPE,
           ORG_CREDIT_CODE_A,
           ORG_CODE_A,
           REGISTRATION_CODE_TYPE_A,
           REGISTRATION_CODE_A,
           TAX_IDENTIFY_CODE_NA,
           TAX_IDENTIFY_CODE_ST,
           OPEN_ACCOUNT_APPROVAL_NO,
           LOAN_CARD_NO,
           DATA_ABSTRACT_DATE,
           RSV_A,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.CUSTOMER_CODE, B.BRANCH_ID ORDER BY A.DATA_ABSTRACT_DATE DESC) RN
              FROM CCI_ORGINFO_BASIC A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --机构基本属性信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_PROPERTY_FULL';
  COMMIT;

  INSERT INTO CCI_ETL_ORG_PROPERTY_FULL
    (ORG_CN_NAME,
     ORG_EN_NAME,
     REGISTATION_ADDRESS,
     NATIONNALITY,
     REGISTATION_AREA_DIVISION,
     ESTABLISH_DATE,
     PAPER_EXPIRY_DATE,
     OPERATING_RANGE,
     REGISTERED_CAPITAL_CURRENCY,
     REGISTERED_AMOUNT,
     ORG_TYPE,
     ORG_TYPE_CLASSIFY,
     ECONOMIC_CLASSIFY,
     ECONOMIC_TYPE,
     INFORMATION_UPDATE_DATE_B,
     RSV_B,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT ORG_CN_NAME,
           ORG_EN_NAME,
           REGISTATION_ADDRESS,
           NATIONNALITY,
           REGISTATION_AREA_DIVISION,
           ESTABLISH_DATE,
           PAPER_EXPIRY_DATE,
           OPERATING_RANGE,
           REGISTERED_CAPITAL_CURRENCY,
           REGISTERED_AMOUNT,
           ORG_TYPE,
           ORG_TYPE_CLASSIFY,
           ECONOMIC_CLASSIFY,
           ECONOMIC_TYPE,
           INFORMATION_UPDATE_DATE_B,
           RSV_B,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.CUSTOMER_CODE, B.BRANCH_ID ORDER BY A.INFORMATION_UPDATE_DATE_B DESC) RN
              FROM CCI_ORGINFO_BASIC_PROPERTY A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --机构状态信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_STATUS_FULL';
  COMMIT;

  INSERT INTO CCI_ETL_ORG_STATUS_FULL
    (BASIC_STATUS,
     ENTERPRISE_SCALE,
     ORG_STATUS,
     INFORMATION_UPDATE_DATE_D,
     RSV_D,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT BASIC_STATUS,
           ENTERPRISE_SCALE,
           ORG_STATUS,
           INFORMATION_UPDATE_DATE_D,
           RSV_D,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.CUSTOMER_CODE, B.BRANCH_ID ORDER BY A.INFORMATION_UPDATE_DATE_D DESC) RN
              FROM CCI_ORGINFO_ORG_STATUS A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --机构高管及主要关系人信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_EXECUTIVE_FULL';
  COMMIT;

  INSERT INTO CCI_ETL_ORG_EXECUTIVE_FULL
    (RELATION_PARTY_TYPE,
     NAME,
     PAPER_TYPE,
     PAPER_CODE,
     INFORMATION_UPDATE_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT RELATION_PARTY_TYPE,
           NAME,
           PAPER_TYPE,
           PAPER_CODE,
           INFORMATION_UPDATE_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.CUSTOMER_CODE, B.BRANCH_ID, A.RELATION_PARTY_TYPE, A.NAME ORDER BY A.INFORMATION_UPDATE_DATE DESC) RN
              FROM CCI_ORGINFO_EXECUTIVE_RELA A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --机构重要股东信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_IMPORT_S_H_FULL';
  COMMIT;

  INSERT INTO CCI_ETL_ORG_IMPORT_S_H_FULL
    (SHAREHOLDER_TYPE,
     SHAREHOLDER_NAME,
     PAPER_TYPE,
     PAPER_CODE,
     ORG_CODE,
     ORG_CREDIT_CODE,
     SHAREHOLDING_RATIO,
     INFORMATION_UPDATE_DATE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT SHAREHOLDER_TYPE,
           SHAREHOLDER_NAME,
           PAPER_TYPE,
           PAPER_CODE,
           ORG_CODE,
           ORG_CREDIT_CODE,
           SHAREHOLDING_RATIO,
           INFORMATION_UPDATE_DATE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.CUSTOMER_CODE, B.BRANCH_ID, A.SHAREHOLDER_NAME ORDER BY A.INFORMATION_UPDATE_DATE DESC) RN
              FROM CCI_ORGINFO_IMPORT_S_H A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --机构联络段信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_CONTACT_FULL';
  COMMIT;

  INSERT INTO CCI_ETL_ORG_CONTACT_FULL
    (ORG_WORK_ADDRESS,
     TELEPHONE,
     FINANCE_DEPARTMENT_TELEPHONE,
     INFORMATION_UPDATE_DATE_C,
     RSV_C,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT ORG_WORK_ADDRESS,
           TELEPHONE,
           FINANCE_DEPARTMENT_TELEPHONE,
           INFORMATION_UPDATE_DATE_C,
           RSV_C,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.CUSTOMER_CODE, B.BRANCH_ID ORDER BY A.INFORMATION_UPDATE_DATE_C DESC) RN
              FROM CCI_ORGINFO_CONTACT A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --2007版利润及利润分配表信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_07_PROFIT_FULL';
  COMMIT;
  INSERT INTO CCI_ETL_FINANCE_07_PROFIT_FULL
    (BORROWER_NAME,
     LOAN_CARD_NO,
     REPORT_YEAR,
     REPORT_TYPE,
     REPORT_TYPE_SUBDIVISION,
     AUDIT_FIRM_NAME,
     AUDITOR_NAME,
     CHECK_TIME_C,
     BUSI_DATE,
     BUSI_INCOME,
     BUSI_COST,
     BUSI_TAX_ADD,
     SALE_EXPENSE,
     MANAGE_EXPENSE,
     FINANCIAL_EXPENSE,
     ASSET_REDUCTION_LOSS,
     NET_INCOME_OF_FAIR_VALUE,
     INVESTMENT_NET,
     INVE_REVE_TO_ENTE,
     BUSI_PROFIT,
     BESIDE_BUSI_INCOME,
     BESIDE_BUSI_EXPENSE,
     LOSS_OF_NONCURRENT_ASSETS,
     TOTAL_PROFIT,
     INCOME_TAX_EXPENSE,
     PROFIT_NET,
     BASIC_EARNINGS_PER_SHARE,
     DILUTED_EARNINGS_PER_SHARE,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT BORROWER_NAME,
           LOAN_CARD_NO,
           REPORT_YEAR,
           REPORT_TYPE,
           REPORT_TYPE_SUBDIVISION,
           AUDIT_FIRM_NAME,
           AUDITOR_NAME,
           CHECK_TIME_C,
           BUSI_DATE,
           BUSI_INCOME,
           BUSI_COST,
           BUSI_TAX_ADD,
           SALE_EXPENSE,
           MANAGE_EXPENSE,
           FINANCIAL_EXPENSE,
           ASSET_REDUCTION_LOSS,
           NET_INCOME_OF_FAIR_VALUE,
           INVESTMENT_NET,
           INVE_REVE_TO_ENTE,
           BUSI_PROFIT,
           BESIDE_BUSI_INCOME,
           BESIDE_BUSI_EXPENSE,
           LOSS_OF_NONCURRENT_ASSETS,
           TOTAL_PROFIT,
           INCOME_TAX_EXPENSE,
           PROFIT_NET,
           BASIC_EARNINGS_PER_SHARE,
           DILUTED_EARNINGS_PER_SHARE,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.LOAN_CARD_NO, A.REPORT_YEAR, A.REPORT_TYPE, A.REPORT_TYPE_SUBDIVISION, B.BRANCH_ID ORDER BY A.BUSI_DATE DESC) RN
              FROM CCI_PROFIT_DISTRIBUT_2007 A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --2007版资产负债表信息
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_FINANCE_07_ASSETS_FULL';
  COMMIT;

  INSERT INTO CCI_ETL_FINANCE_07_ASSETS_FULL
    (BORROWER_NAME,
     LOAN_CARD_NO,
     REPORT_YEAR,
     REPORT_TYPE,
     REPORT_TYPE_SUBDIVISION,
     AUDIT_FIRM_NAME,
     AUDITOR_NAME,
     CHECK_TIME_C,
     BUSI_DATE,
     CURRENCY_CAPITAL,
     TRADING_FINANCIAL_ASSETS,
     NOTES_RECEIVABLE,
     ACCOUNTS_RECEIVABLE,
     ADVANCE_PAYMENT,
     INTEREST_RECEIVABLE,
     DIVIDENDS_RECEIVABLE,
     OTHER_ACCOUNTS_RECEIVABLE,
     STOCK,
     NONCURRENCY_ASSETS_IN_ONE_YEAR,
     OTHER_FLOW_CAPITAL,
     FLOW_CAPITAL_IN_TOTAL,
     FINA_ASSE_AVAI_FOR_SALE,
     INVESTMENT_HOLD_TO_MATURITY,
     LONG_TERM_EQUITY_INVESTMENT,
     LONG_TERM_ACCOUNTS_RECEIVABLE,
     INVESTMENT_REAL_ESTATE,
     FIXED_ASSETS,
     UNDER_CONSTRUCTION,
     ENGINEERING_MATERIALS,
     FIXED_ASSET_CLEAR,
     PRODUCTIVE_BIOLOGICAL_ASSETS,
     OIL_AND_GAS_ASSETS,
     INTANGIBLE_ASSETS,
     DEVELOPMENT_EXPENSES,
     GOODWILL,
     LONG_TERM_PREPAID_EXPENSES,
     DEFERRED_INCOME_TAX_ASSETS,
     OTHER_NONCURRENT_ASSETS,
     TOTAL_NONCURRENT_ASSETS,
     TOTAL_ASSETS,
     SHORT_TERM_BORROWING,
     TRADING_FINANCIAL_LIABILITY,
     NOTES_PAYABLE,
     ACCOUNTS_PAYABLE,
     ACCOUNTS_COLLECT_IN_ADVANCE,
     INTERESTS_RECEIVABLE,
     WAGE_PAYABLE,
     TAX_PAYABLE,
     DIVIDEND_PAYABLE,
     OTHER_PAYMENT,
     NONC_LIAB_IN_ONE_YEAR,
     OTHER_CURRENT_LIABILITIES,
     TOTAL_CURRENT_LIABILITIES,
     LONG_TERM_BORROWING,
     BONDS_PAYMENT,
     LONG_TERM_ACCOUNTS_PAYABLE,
     SPECIAL_PAYMENT,
     EXPECTED_LIABILITY,
     DEFERRED_TAX_CREDIT_LIABILITY,
     OTHER_NONCURRENT_LIABILITIES,
     TOTAL_NONCURRENT_LIABILITIES,
     TOTAL_LIABILITIES,
     REAL_INCOME_CAPITAL,
     CAPITAL_RESERVE,
     SURPLUS_RESERVE,
     NONDISTRIBUTED_PROFIT,
     TOTAL_OWNERS_EQUITY,
     TOTA_LIAB_AND_OWNE_EQUI,
     INVENTORY_REDUCTION_UNIT,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT BORROWER_NAME,
           LOAN_CARD_NO,
           REPORT_YEAR,
           REPORT_TYPE,
           REPORT_TYPE_SUBDIVISION,
           AUDIT_FIRM_NAME,
           AUDITOR_NAME,
           CHECK_TIME_C,
           BUSI_DATE,
           CURRENCY_CAPITAL,
           TRADING_FINANCIAL_ASSETS,
           NOTES_RECEIVABLE,
           ACCOUNTS_RECEIVABLE,
           ADVANCE_PAYMENT,
           INTEREST_RECEIVABLE,
           DIVIDENDS_RECEIVABLE,
           OTHER_ACCOUNTS_RECEIVABLE,
           STOCK,
           NONCURRENCY_ASSETS_IN_ONE_YEAR,
           OTHER_FLOW_CAPITAL,
           FLOW_CAPITAL_IN_TOTAL,
           FINA_ASSE_AVAI_FOR_SALE,
           INVESTMENT_HOLD_TO_MATURITY,
           LONG_TERM_EQUITY_INVESTMENT,
           LONG_TERM_ACCOUNTS_RECEIVABLE,
           INVESTMENT_REAL_ESTATE,
           FIXED_ASSETS,
           UNDER_CONSTRUCTION,
           ENGINEERING_MATERIALS,
           FIXED_ASSET_CLEAR,
           PRODUCTIVE_BIOLOGICAL_ASSETS,
           OIL_AND_GAS_ASSETS,
           INTANGIBLE_ASSETS,
           DEVELOPMENT_EXPENSES,
           GOODWILL,
           LONG_TERM_PREPAID_EXPENSES,
           DEFERRED_INCOME_TAX_ASSETS,
           OTHER_NONCURRENT_ASSETS,
           TOTAL_NONCURRENT_ASSETS,
           TOTAL_ASSETS,
           SHORT_TERM_BORROWING,
           TRADING_FINANCIAL_LIABILITY,
           NOTES_PAYABLE,
           ACCOUNTS_PAYABLE,
           ACCOUNTS_COLLECT_IN_ADVANCE,
           INTERESTS_RECEIVABLE,
           WAGE_PAYABLE,
           TAX_PAYABLE,
           DIVIDEND_PAYABLE,
           OTHER_PAYMENT,
           NONC_LIAB_IN_ONE_YEAR,
           OTHER_CURRENT_LIABILITIES,
           TOTAL_CURRENT_LIABILITIES,
           LONG_TERM_BORROWING,
           BONDS_PAYMENT,
           LONG_TERM_ACCOUNTS_PAYABLE,
           SPECIAL_PAYMENT,
           EXPECTED_LIABILITY,
           DEFERRED_TAX_CREDIT_LIABILITY,
           OTHER_NONCURRENT_LIABILITIES,
           TOTAL_NONCURRENT_LIABILITIES,
           TOTAL_LIABILITIES,
           REAL_INCOME_CAPITAL,
           CAPITAL_RESERVE,
           SURPLUS_RESERVE,
           NONDISTRIBUTED_PROFIT,
           TOTAL_OWNERS_EQUITY,
           TOTA_LIAB_AND_OWNE_EQUI,
           INVENTORY_REDUCTION_UNIT,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.LOAN_CARD_NO, A.REPORT_YEAR, A.REPORT_TYPE, A.REPORT_TYPE_SUBDIVISION, B.BRANCH_ID ORDER BY A.BUSI_DATE DESC) RN
              FROM CCI_ASSETS_LIABILITY_2007 A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0'
               AND B.REPORT_FLAG = '2')
     WHERE RN = 1;
  COMMIT;

  --机构基础信息(同步产品端所有非删除记录，给财报抽取信息用)
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CCI_ETL_ORG_BASIC_FULL_ALL';
  COMMIT;

  INSERT INTO CCI_ETL_ORG_BASIC_FULL_ALL
    (MANAGEMENT_ROW_CODE,
     CUSTOMER_TYPE,
     ORG_CREDIT_CODE_A,
     ORG_CODE_A,
     REGISTRATION_CODE_TYPE_A,
     REGISTRATION_CODE_A,
     TAX_IDENTIFY_CODE_NA,
     TAX_IDENTIFY_CODE_ST,
     OPEN_ACCOUNT_APPROVAL_NO,
     LOAN_CARD_NO,
     DATA_ABSTRACT_DATE,
     RSV_A,
     CUSTOMER_CODE,
     BRANCH_ID,
     BRANCH_NO,
     DEPT_ID,
     MSG_RECORD_OPERATE_TYPE,
     RSV_01,
     RSV_02,
     RSV_03,
     RSV_04,
     RSV_05,
     RSV_06,
     DATA_DATE)
    SELECT MANAGEMENT_ROW_CODE,
           CUSTOMER_TYPE,
           ORG_CREDIT_CODE_A,
           ORG_CODE_A,
           REGISTRATION_CODE_TYPE_A,
           REGISTRATION_CODE_A,
           TAX_IDENTIFY_CODE_NA,
           TAX_IDENTIFY_CODE_ST,
           OPEN_ACCOUNT_APPROVAL_NO,
           LOAN_CARD_NO,
           DATA_ABSTRACT_DATE,
           RSV_A,
           CUSTOMER_CODE,
           BRANCH_ID,
           BRANCH_NO,
           DEPT_ID,
           MSG_RECORD_OPERATE_TYPE,
           RSV_01,
           RSV_02,
           RSV_03,
           RSV_04,
           RSV_05,
           RSV_06,
           T1_DATE
      FROM (SELECT A.*,
                   B.BRANCH_ID,
                   B.BRANCH_NO,
                   B.DEPT_ID,
                   B.MSG_RECORD_OPERATE_TYPE,
                   ROW_NUMBER() OVER(PARTITION BY A.CUSTOMER_CODE, B.BRANCH_ID ORDER BY A.DATA_ABSTRACT_DATE DESC) RN
              FROM CCI_ORGINFO_BASIC A, CCI_REPORT_SYSTEM_CTL B
             WHERE A.SYS_CTL_ID = B.SYS_CTL_ID
               AND B.LOGIC_DELETE_FLAG = '0')
     WHERE RN = 1;
  COMMIT;


  O_ERROR_CODE := '000000';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --ERROR MSG
    O_ERROR_CODE := SQLCODE;
    O_ERROR_MSG  := SQLERRM;
    -- SYSTEM ERROR
    CCI_INSERT_LOG_ERROR(C_JOB_ID,
                         9,
                         O_ERROR_CODE,
                         O_ERROR_MSG,
                         NULL,
                         '0',
                         V_SERIAL_NO);
    COMMIT;
END;
/


spool off
