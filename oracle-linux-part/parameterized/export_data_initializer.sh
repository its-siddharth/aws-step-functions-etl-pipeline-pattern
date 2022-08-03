#!/bin/bash

Help()
{
   # Display Help
   echo "Help Menu"
   echo
   echo "Syntax: export_data [ -h | -f | -i INTERVAL_VALUE -t TABLE_NAME ]"
   echo "options:"
   echo "-h     Print this Help"
   echo "-f     Parameters file path"
   echo "-i     Time interval in incremental data fetch from table"
   echo "-t     Table name to fetch data from"
   echo
}

File()
{
   table_names=($(cat $OPTARG | jq .TableConfig[].Name --raw-output))
   intervals=($(cat $OPTARG | jq .TableConfig[].IntervalInMinutes --raw-output))
   for i in ${!table_names[@]}
   do
     cat get_columns_template.sql | sed "s/TABLE_NAME/${table_names[$i]}/g" > get_columns_${table_names[$i]}.sql
     column_names=$(sqlplus -l -s admin/prabhu746@sample-db.crrgloneccu2.ap-south-1.rds.amazonaws.com/ORCL @get_columns_${table_names[$i]}.sql | tail -n +2 | sed -z 's/\n/,/g;s/,$/\n/')
     column_names_without_Date=$(sqlplus -l -s admin/prabhu746@sample-db.crrgloneccu2.ap-south-1.rds.amazonaws.com/ORCL @get_columns_${table_names[$i]}.sql | tail -n +2 | sed -z 's/\n/,/g;s/,$/\n/' | sed "s/Date,//")
     cat csv_export_template.sql | sed "s/COLUMN_NAMES/$column_names_without_Date/" > csv_export_${table_names[$i]}.sql
     sed -i "s/TABLE_NAME/${table_names[$i]}/" csv_export_${table_names[$i]}.sql
     sed -i "s/INTERVAL/${intervals[$i]}/" csv_export_${table_names[$i]}.sql
     echo "#!/bin/bash" > export_data_${table_names[$i]}.sh
     echo >> export_data_${table_names[$i]}.sh
     echo "sqlplus -l -s admin/prabhu746@sample-db.crrgloneccu2.ap-south-1.rds.amazonaws.com/ORCL @csv_export_${table_names[$i]}.sql" >> export_data_${table_names[$i]}.sh
     echo "rm exported_data_${table_names[$i]}.csv" >> export_data_${table_names[$i]}.sh
     echo "#/usr/local/bin/aws s3 cp ${table_names[$i]}.csv s3://s3-etl-pipeline-${table_names[$i]}/source/${table_names[$i]}.csv" >> export_data_${table_names[$i]}.sh
     sudo chmod +x export_data_${table_names[$i]}.sh
     echo "${intervals[$i]} * * * * $USER bash $HOME/export_data_${table_names[$i]}.sh" > ${table_names[$i]}.cron
     sudo chmod 644 ${table_names[$i]}.cron
     sudo chown root:root ${table_names[$i]}.cron
     sudo mv ${table_names[$i]}.cron /etc/cron.d/
   done
}

while getopts ":hf:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      f) File
         exit;;
   esac
done

#sqlplus -l -s admin/prabhu746@sample-db.crrgloneccu2.ap-south-1.rds.amazonaws.com/ORCL @csv_export.sql
#tail -n +2 exported_data.csv > names.csv
#rm exported_data.csv
#sed -i "s/.*DATE.*/Date,first_name,last_name/g" names.csv

#/usr/local/bin/aws s3 cp names.csv s3://s3-etl-pipeline-names/source/names.csv

