#!/bin/bash

. /pgsql/.bash_profile

dbname="backupdb"
dbuser="backup"
psql="/opt/pgpro/std-10/bin/psql -t -A"
query="select case when pg_is_in_recovery() then 0 else 1 end as leader;"
command=$1

is_leader=$($psql -U $dbuser $dbname -c "$query")

[ $is_leader -eq 1 ] && eval $command
