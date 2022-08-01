#!/bin/bash

sqlplus -l -s admin/prabhu746@sample-db.crrgloneccu2.ap-south-1.rds.amazonaws.com/ORCL @csv_export.sql
tail -n +2 exported_data.csv > names.csv
rm exported_data.csv
sed -i "s/.*DATE.*/Date,first_name,last_name/g" names.csv

/usr/local/bin/aws s3 cp names.csv s3://s3-etl-pipeline-names/source/names.csv
