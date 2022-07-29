#!/bin/bash

sqlplus -l -s admin/prabhu746@sample-db.crrgloneccu2.ap-south-1.rds.amazonaws.com/ORCL @csv_export.sql
tail -n +2 exported_data.csv > bank_data.csv
rm exported_data.csv
sed -i "s/.*DATEOF.*/Date,Description,Deposits,Withdrawls,Balance/g" bank_data.csv

/usr/local/bin/aws s3 cp bank_data.csv s3://s3-etl-pipeline/source/bank_data.csv
