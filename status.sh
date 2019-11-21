#!/bin/bash
set -e

APP_NAME=${1-"demo-t"}
CMD=${2-".java-buildpack/open_jdk_jre/bin/java org.springframework.boot.loader.JarLauncher --sleep=2000 --wait=3000"}
API_ENDPOINT=${3-"https://donotuseapi.run.pivotal.io/v3/apps"}
TOKEN=$(cf oauth-token)

function creat_task() {
  local status_url=$(curl --silent "${API_ENDPOINT}/$1/tasks" \
  -X POST \
  -H "Authorization: ${TOKEN}" \
  -H "Content-type: application/json" \
  -d "{ \"command\": \"$CMD\" }" | jq -r ".links.self.href")

 echo ${status_url}
}

function get_task_status() {
local payload=$(curl --silent $1 \
  -X GET \
  -H "Authorization: ${TOKEN}")

local state=$(echo $payload | jq -r ".state")
local failure_reason=$(echo $payload | jq -r ".result.failure_reason")

echo "${state}|${failure_reason}"
}

function get_app_guid() {
local payload=$(curl --silent "${API_ENDPOINT}?names=${APP_NAME}" \
  -X GET \
  -H "Authorization: ${TOKEN}")

local guid=$(echo $payload | jq -r ".resources[0].guid")
echo "${guid}"
}

app_guid=$(get_app_guid)
echo -e "${APP_NAME} guid:${app_guid}"

task_url=$(creat_task ${app_guid})
echo -e "Task status track url:${task_url}"

task_info=$(get_task_status ${task_url})
task_status=$(echo $task_info | cut -d'|' -f 1)
task_failure_reason=$(echo $task_info | cut -d'|' -f 2)

echo -e "Task status: ${task_status}, failure reason is: ${task_failure_reason}"

while [ $task_status = 'RUNNING' ]
do
    sleep 5

    task_info=$(get_task_status ${task_url})
    task_status=$( echo $task_info | cut -d'|' -f 1 )
    task_failure_reason=$( echo $task_info | cut -d'|' -f 2 )

    echo -e "Task status: ${task_status}, failure reason is: ${task_failure_reason}"
done

exit $([ $task_status = 'SUCCEEDED' ])