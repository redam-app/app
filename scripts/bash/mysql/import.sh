#!/bin/bash -e

currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

databaseHost=
databasePort=
databaseUser=
databasePassword=
databaseName=
file=
reset=
tempDir=
remove=

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
  echo "No database user specified!"
  usage
  exit 1
fi

if [[ -z "${databasePassword}" ]]; then
  echo "No database password specified!"
  usage
  exit 1
fi

if [[ -z "${databaseName}" ]]; then
  echo "No database name specified!"
  usage
  exit 1
fi

if [[ -z "${file}" ]]; then
  echo "No import file specified!"
  usage
  exit 1
fi

if [[ -z "${reset}" ]] || [[ "${reset}" == 0 ]]; then
  reset="no"
elif [[ "${reset}" == 1 ]]; then
  reset="yes"
fi

if [[ -z "${tempDir}" ]]; then
  tempDir="/tmp/mysql"
fi

if [[ ! -d "${tempDir}" ]]; then
  rm -rf "${tempDir}"

  echo "Creating temp directory at: ${tempDir}"
  mkdir -p "${tempDir}"
fi

if [[ -z "${remove}" ]] || [[ "${remove}" == 0 ]]; then
  remove="no"
elif [[ "${remove}" == 1 ]]; then
  remove="yes"
fi

tempImportFile="${tempDir}"/$(basename "${file}")

copied=0
if [[ "${file}" != "${tempImportFile}" ]]; then
  echo "Copying import file from: ${file} to: ${tempImportFile}"
  cp "${file}" "${tempImportFile}"
  copied=1
fi

echo "Preparing import file at: ${tempDir}/import.sql"
if [[ "${tempImportFile: -7}" == ".tar.gz" ]]; then
  tar -xOzf "${tempImportFile}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e '/^CREATE\sDATABASE/d' | sed -e '/^DROP\sDATABASE/d' | sed -e '/^USE\s/d' | sed -e '/^ALTER\sDATABASE/d' | sed -e 's/ROW_FORMAT=FIXED//g' > "${tempDir}/import.sql"
elif [[ "${tempImportFile: -3}" == ".gz" ]] || [[ "${tempImportFile: -7}" == ".sql.gz" ]]; then
  cat "${tempImportFile}" | gzip -d -q | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e '/^CREATE\sDATABASE/d' | sed -e '/^DROP\sDATABASE/d' | sed -e '/^USE\s/d' | sed -e '/^ALTER\sDATABASE/d' | sed -e 's/ROW_FORMAT=FIXED//g' > "${tempDir}/import.sql"
elif [[ "${tempImportFile: -4}" == ".zip" ]]; then
  unzip -p "${tempImportFile}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e '/^CREATE\sDATABASE/d' | sed -e '/^DROP\sDATABASE/d' | sed -e '/^USE\s/d' | sed -e '/^ALTER\sDATABASE/d' | sed -e 's/ROW_FORMAT=FIXED//g' > "${tempDir}/import.sql"
elif [[ "${tempImportFile: -4}" == ".sql" ]]; then
  cat "${tempImportFile}" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e '/^CREATE\sDATABASE/d' | sed -e '/^DROP\sDATABASE/d' | sed -e '/^USE\s/d' | sed -e '/^ALTER\sDATABASE/d' | sed -e 's/ROW_FORMAT=FIXED//g' > "${tempDir}/import.sql"
else
  echo "Unsupported file format"
  exit 1
fi

if [[ "${copied}" == 1 ]]; then
  echo "Removing import file at: ${tempImportFile}"
  rm -rf "${tempImportFile}"
fi

export MYSQL_PWD="${databasePassword}"

if [[ "${reset}" == "yes" ]]; then
  echo "Dropping database: ${databaseName}"
  mysql -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" -e "DROP DATABASE IF EXISTS \`${databaseName}\`;"

  echo "Creating database: ${databaseName}"
  mysql -h"${databaseHost}" -P"${databasePort}" -u"${databaseUser}" -e "CREATE DATABASE \`${databaseName}\` CHARACTER SET utf8 COLLATE utf8_general_ci;";
fi

echo "Importing dump from file: ${tempDir}/import.sql"
mysql "-h${databaseHost}" "-P${databasePort}" "-u${databaseUser}" --binary-mode --default-character-set=utf8 --max_allowed_packet=2G --init-command="SET SESSION FOREIGN_KEY_CHECKS=0;" "${databaseName}" < "${tempDir}/import.sql"

echo "Removing prepared import file at: ${tempDir}/import.sql"
rm -rf "${tempDir}/import.sql"

if [[ "${remove}" == "yes" ]]; then
  echo "Removing import file at: ${file}"
  rm -rf "${file}"
fi
