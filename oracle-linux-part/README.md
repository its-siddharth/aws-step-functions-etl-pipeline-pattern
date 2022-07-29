
# Install sqlplus on Oracle Linux

wget https://download.oracle.com/otn_software/linux/instantclient/1916000/oracle-instantclient19.16-basic-19.16.0.0.0-1.x86_64.rpm
sudo yum localinstall oracle-instantclient19.16-basic-19.16.0.0.0-1.x86_64.rpm

wget https://download.oracle.com/otn_software/linux/instantclient/1916000/oracle-instantclient19.16-sqlplus-19.16.0.0.0-1.x86_64.rpm
sudo yum localinstall oracle-instantclient19.16-sqlplus-19.16.0.0.0-1.x86_64.rpm


# Place the files export_data.sh, csv_export.sql and bank_data.csv at the home folder


# Install awscli on Oracle Linux

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws configure


# Enter the AWS Key, Secret and Region and press enter


# Run the shell script for exporting the csv from Oracle DB bank_data table

./export_data.sh

# PS: this shell script uses csv_export.sql, so any changes for how to export and what to export can be made there
