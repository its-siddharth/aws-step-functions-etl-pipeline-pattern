set markup csv on quote off
set feedback off
spool exported_data.csv
select to_char(dateof, 'MM/DD/YYYY'),description,deposits,withdrawls,balance from bank_data where createdat > systimestamp - interval '10' minute;
spool off
exit;
/
