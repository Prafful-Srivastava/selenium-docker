#!/usr/bin/env bash
# Environment Variables
# HUB_HOST
# BROWSER
# MODULE
set -e
echo "Checking if hub is ready - $HUB_HOST"

MAX_RETRIES=10
RETRY_INTERVAL=1
retry_count=0

# Function to exit the script with an error message
exit_with_error() {
  local message=$1
  echo "Error: $message"
  exit 1
}

while (( retry_count < MAX_RETRIES ))
do
  response=$(curl -s http://$HUB_HOST:4444/wd/hub/status)
  ready=$(echo "$response" | jq -r .value.ready)

  if [[ "$ready" == "true" ]]; then
    break
  fi

  retry_count=$((retry_count + 1))

  if (( retry_count > MAX_RETRIES )); then
    exit_with_error "Selenium Hub did not become ready after $MAX_RETRIES retries."
  fi

  # Sleep for the specified interval before the next retry
  sleep $RETRY_INTERVAL
done

echo "Selenium Hub is ready. Starting test execution..."

# start the java command
java -cp selenium-docker.jar;selenium-docker-tests.jar;libs/* \
    -DHUB_HOST=$HUB_HOST \
    -DBROWSER=$BROWSER \
    org.testng.TestNG $MODULE