set markup csv on quote off
set heading off
set feedback off
spool TABLE_NAME.csv
select COLUMN_NAMES from TABLE_NAME where created_at > sysdate - interval 'INTERVAL' minute;
spool off
exit;
/
