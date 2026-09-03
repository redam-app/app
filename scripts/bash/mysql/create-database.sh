#!/bin/bash -e

currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

databaseHost=
databasePort=
databaseUser=
databasePassword=
databaseName=

if [[ -f prepare-parameters.sh ]]; then
  source prepare-parameters.sh
elif [[ -f /tmp/prepare-parameters.sh ]]; then
  source /tmp/prepare-parameters.sh
elif [[ -f "${currentPath}/../prepare-parameters.sh" ]]; then
  source "${currentPath}/../prepare-parameters.sh"
fi

if [[ -z "${databaseHost}" ]] || [[ "${databaseHost}" == "localhost" ]]; then
  databaseHost="127.0.0.1"
fi

if [[ -z "${databasePort}" ]]; then
  databasePort=3306
fi

if [[ -z "${databaseUser}" ]]; then
  >&2 echo "No database user specified!"
  exit 1
fi

if [[ -z "${databasePassword}" ]]; then
  >&2 echo "No database password specified!"
  exit 1
fi

if [[ -z "${databaseName}" ]]; then
  >&2 echo "No database name specified!"
  exit 1
fi

export MYSQL_PWD="${databasePassword}"

echo "Dropping database: ${databaseName}"
mysql -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" -e "DROP DATABASE IF EXISTS ${databaseName};"

echo "Creating database: ${databaseName}"
mysql -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" -e "CREATE DATABASE ${databaseName} CHARACTER SET utf8 COLLATE utf8_general_ci;";
