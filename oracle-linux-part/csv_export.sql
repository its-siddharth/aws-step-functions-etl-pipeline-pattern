set markup csv on quote off
set feedback off
spool exported_data.csv
select to_char("Date", 'MM/DD/YYYY'),first_name,last_name from names where created_at > systimestamp - interval '10' minute;
spool off
exit;
/
