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
     #column_names=$(sqlplus -l -s admin/Admin123@atlas.cwzimlcaxnee.us-west-2.rds.amazonaws.com/ORCL @get_columns_${table_names[$i]}.sql | tail -n +2 | sed -z 's/\n/,/g;s/,$/\n/')
     #column_names_without_Datetime=$(sqlplus -l -s admin/Admin123@atlas.cwzimlcaxnee.us-west-2.rds.amazonaws.com/ORCL @get_columns_${table_names[$i]}.sql | tail -n +2 | sed -z 's/\n/,/g;s/,$/\n/' | sed "s/Date,//" | sed "s/,CREATED_AT//")
     column_names_without_time=$(sqlplus -l -s admin/Admin123@atlas.cwzimlcaxnee.us-west-2.rds.amazonaws.com/ORCL @get_columns_${table_names[$i]}.sql | tail -n +2 | sed -z 's/\n/,/g;s/,$/\n/' | sed "s/,CREATED_AT//" | tr '[:upper:]' '[:lower:]' | sed "s/date/Date/")
     cat csv_export_template.sql | sed "s/COLUMN_NAMES/$column_names_without_time/" > csv_export_${table_names[$i]}.sql
     sed -i "s/Date/to_char(\"Date\", 'MM\/DD\/YYYY')/" csv_export_${table_names[$i]}.sql
     sed -i "s/TABLE_NAME/${table_names[$i]}/" csv_export_${table_names[$i]}.sql
     sed -i "s/INTERVAL/${intervals[$i]}/" csv_export_${table_names[$i]}.sql
     echo "#!/bin/bash" > export_data_${table_names[$i]}.sh
     echo >> export_data_${table_names[$i]}.sh
     echo "source /etc/profile" >> export_data_${table_names[$i]}.sh
     echo "sqlplus -l -s admin/Admin123@atlas.cwzimlcaxnee.us-west-2.rds.amazonaws.com/ORCL @csv_export_${table_names[$i]}.sql" >> export_data_${table_names[$i]}.sh
     #echo "sed -i '1i $column_names_without_time' ${table_names[$i]}.csv" >> export_data_${table_names[$i]}.sh
     echo "if [ -s ${table_names[$i]}.csv ]" >> export_data_${table_names[$i]}.sh
     echo "then" >> export_data_${table_names[$i]}.sh
     echo "    sed -i '1i $column_names_without_time' ${table_names[$i]}.csv" >> export_data_${table_names[$i]}.sh
     bucket_suffix=$(echo ${table_names[$i]} | sed "s/_/-/")
     echo "    /usr/bin/aws s3 cp ${table_names[$i]}.csv s3://s3-etl-pipeline-$bucket_suffix/source/${table_names[$i]}.csv" >> export_data_${table_names[$i]}.sh
     echo "    mv ${table_names[$i]}.csv uploaded/${table_names[$i]}_\$(date +%m%d%y_%H%M).csv" >> export_data_${table_names[$i]}.sh
     echo "fi" >> export_data_${table_names[$i]}.sh
     sudo chmod +x export_data_${table_names[$i]}.sh
     echo "*/${intervals[$i]} * * * * $USER $HOME/export_data_${table_names[$i]}.sh" > ${table_names[$i]}
     sudo chmod 644 ${table_names[$i]}
     sudo chown root:root ${table_names[$i]}
     sudo mv ${table_names[$i]} /etc/cron.d/
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

