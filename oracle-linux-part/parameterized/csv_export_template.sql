set markup csv on quote off
set heading off
set feedback off
spool TABLE_NAME.csv
select to_char("Date", 'MM/DD/YYYY'),COLUMN_NAMES from TABLE_NAME where created_at > systimestamp - interval 'INTERVAL' minute;
spool off
exit;
/
