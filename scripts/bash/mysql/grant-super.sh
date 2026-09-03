#!/bin/bash -e

currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

databaseRootUser=
databaseRootPassword=
databaseHost=
databasePort=
databaseUser=
databaseName=

if [[ -f prepare-parameters.sh ]]; then
  source prepare-parameters.sh
elif [[ -f /tmp/prepare-parameters.sh ]]; then
  source /tmp/prepare-parameters.sh
elif [[ -f "${currentPath}/../prepare-parameters.sh" ]]; then
  source "${currentPath}/../prepare-parameters.sh"
fi

if [[ -z "${databaseRootUser}" ]]; then
  databaseRootUser="root"
fi

if [[ -z "${databaseRootPassword}" ]]; then
  >&2 echo "No database root password specified!"
  exit 1
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

if [[ -z "${databaseName}" ]]; then
  >&2 echo "No database name specified!"
  exit 1
fi

userNames=( "'${databaseUser}'@'%'" "'${databaseUser}'@'127.0.0.1'" "'${databaseUser}'@'localhost'" )

export MYSQL_PWD="${databaseRootPassword}"

for userName in "${userNames[@]}"; do
  echo "Granting super rights to user: ${userName}"
  mysql -h"${databaseHost}" -P"${databasePort}" -u"${databaseRootUser}" -e "GRANT SUPER ON *.* TO ${userName};"
done

echo "Flushing privileges"
mysql -h"${databaseHost}" -P"${databasePort}" -u"${databaseRootUser}" -e "FLUSH PRIVILEGES;"
