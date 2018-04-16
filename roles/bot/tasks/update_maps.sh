#!/bin/bash

set -eu

function main() {

  downloadMaps 1
  downloadMaps 2
}

function downloadMaps() {
   local pageNumber=$1

   local maps_folder="/home/triplea/maps"
   mkdir -p ${maps_folder}

   # note page size max is 100 (even if you specify a larger number)
   curl -sq "https://api.github.com/orgs/triplea-maps/repos?per_page=100&page=${pageNumber}" \
      | egrep -h "html_url|updated_at" | grep -B1 "updated_at" | grep -v "^--" \
      | while read line; do

    read last_updated_on

    local url=$(echo $line | sed 's/.*https/https/' | sed 's/".*//')/archive/master.zip
    local repo_name=$(echo $line | sed 's|.*/||' | sed 's|".*||')
    local dl_file=${maps_folder}/${repo_name}-master.zip
    local updated_on_file="${maps_folder}/$repo_name"

    if [ ! -f "${updated_on_file}" ]; then
      rm -f ${dl_file}
      wget -O ${dl_file} $url

      # ensure file exists after download
      if [ ! -f "${dl_file}" ]; then
        echo "Failed to DL file: ${dl_file} from ${url}"
        exit 1
      fi
      echo "${last_updated_on}" > ${updated_on_file}
      echo "Downloaded new map file: ${repo_name}  ${last_updated_on}"
    else
      existing_updated_on=$(cat ${updated_on_file})
      if [ "${existing_updated_on}" != "${last_updated_on}" ]; then
        rm -f ${dl_file}
        wget -O ${dl_file} ${url}
        echo "${last_updated_on}" > ${updated_on_file}
        echo "updated repo: ${repo_name} to latest: ${last_updated_on} from: ${existing_updated_on}"
      fi
    fi
  done

}

main
