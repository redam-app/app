#!/bin/bash -e

currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

databaseHost=
databasePort=
databaseUser=
databasePassword=
databaseName=
file=
tempDir=
onlyColumns=
onlyRecords=
removeDatabase=

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
  databasePort="3306"
fi

if [[ -z "${databaseUser}" ]]; then
  >&2 echo "No database user specified!"
  usage
  exit 1
fi

if [[ -z "${databasePassword}" ]]; then
  >&2 echo "No database password specified!"
  usage
  exit 1
fi

if [[ -z "${databaseName}" ]]; then
  >&2 echo "No database name specified!"
  usage
  exit 1
fi

if [[ -z "${file}" ]]; then
  >&2 echo "No export file specified!"
  usage
  exit 1
fi

if [[ -z "${tempDir}" ]]; then
  tempDir="/tmp/mysql"
fi

if [[ ! -d "${tempDir}" ]]; then
  rm -rf "${tempDir}"

  echo "Creating temp directory at: ${tempDir}"
  mkdir -p "${tempDir}"
fi

if [[ -z "${onlyColumns}" ]] || [[ "${onlyColumns}" == 0 ]]; then
  onlyColumns="no"
elif [[ "${onlyColumns}" == 1 ]]; then
  onlyColumns="yes"
fi

if [[ -z "${onlyRecords}" ]] || [[ "${onlyRecords}" == 0 ]]; then
  onlyRecords="no"
elif [[ "${onlyRecords}" == 1 ]]; then
  onlyRecords="yes"
fi

if [[ -z "${removeDatabase}" ]] || [[ "${removeDatabase}" == 0 ]]; then
  removeDatabase="no"
elif [[ "${removeDatabase}" == 1 ]]; then
  removeDatabase="yes"
fi

if [[ -f "${file}" ]]; then
  echo "Removing previous export file at: ${file}"
  rm -rf "${file}"
fi

exportPath=$(dirname "$(realpath "${file}")")
exportFileName=$(basename "${file}")

cd "${tempDir}"

if [[ -f export.sql ]]; then
  echo "Removing previous export file at: export.sql"
  rm -rf export.sql
fi

echo "Exporting to file: ${tempDir}/export.sql"
touch export.sql

export MYSQL_PWD="${databasePassword}"

if [[ "${onlyRecords}" == "no" ]]; then
  echo "Exporting all table columns to file: export.sql"
  mysqldump -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" --no-tablespaces --no-create-db --lock-tables=false --disable-keys --default-character-set=utf8 --add-drop-table --no-data --skip-triggers "${databaseName}" > export.sql
fi

if [[ "${onlyColumns}" == "no" ]]; then
  echo "Exporting all table records to file: export.sql"
  if [[ $(mysql -B -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" "${databaseName}" --disable-column-names -e "show events;" >/dev/null 2>&1 && echo "true" || echo "false") == "true" ]]; then
    # shellcheck disable=SC2086
    mysqldump -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" --no-tablespaces --no-create-db --lock-tables=false --disable-keys --default-character-set=utf8 --skip-add-drop-table --no-create-info --max_allowed_packet=2G --events --routines --triggers "${databaseName}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e 's/DEFINER[ ]*=[^@]*@[^ ]*//' | sed -e '/^CREATE\sDATABASE/d' | sed -e '/^ALTER\sDATABASE/d' | sed -e 's/ROW_FORMAT=FIXED//g' >> export.sql
  else
    # shellcheck disable=SC2086
    mysqldump -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" --no-tablespaces --no-create-db --lock-tables=false --disable-keys --default-character-set=utf8 --skip-add-drop-table --no-create-info --max_allowed_packet=2G --routines --triggers "${databaseName}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e 's/DEFINER[ ]*=[^@]*@[^ ]*//' | sed -e '/^CREATE\sDATABASE/d' | sed -e '/^ALTER\sDATABASE/d' | sed -e 's/ROW_FORMAT=FIXED//g' >> export.sql
  fi
fi

cd "${exportPath}"

echo "Moving export.sql to path: ${exportPath}"
mv "${tempDir}/export.sql" .

echo "Preparing export file at: ${file}"
if [[ "${file: -7}" == ".tar.gz" ]]; then
  install-package tar
  tar -czf "${exportFileName}" export.sql
elif [[ "${file: -3}" == ".gz" ]] || [[ "${file: -7}" == ".sql.gz" ]]; then
  install-package gzip
  gzip export.sql
  if [[ "${exportFileName}" != "export.sql.gz" ]]; then
    mv export.sql.gz "${file}"
  fi
elif [[ "${file: -4}" == ".zip" ]]; then
  install-package zip
  zip -q -T -m "${file}" export.sql
elif [[ "${file: -4}" == ".sql" ]]; then
  if [[ "${exportFileName}" != "export.sql" ]]; then
    mv export.sql "${exportFileName}"
  fi
else
  echo "Unsupported file format"
  exit 1
fi

if [[ "${removeDatabase}" == "yes" ]]; then
  echo "Dropping database: ${databaseName}"
  mysql -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" -e "DROP DATABASE IF EXISTS \`${databaseName}\`;"
fi
