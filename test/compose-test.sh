#!/usr/bin/env bash

# set -e: exit asap if a command exits with a non-zero status
# set -x: print each command right before it is executed
set -xe

# echo fn that outputs to stderr http://stackoverflow.com/a/2990533/511069
echoerr() {
  cat <<< "$@" 1>&2;
}

# print error and exit
die () {
  echoerr "ERROR: $1"
  # if $2 is defined AND NOT EMPTY, use $2; otherwise, set to "160"
  errnum=${2-160}
  exit $errnum
}

# Required params or defaults
[ -z "${NUM_NODES}" ] && die "Required env var NUM_NODES"
[ -z "${SELENIUM_HUB_PORT}" ] && die "Required env var SELENIUM_HUB_PORT"
[ -z "${WAIT_TIMEOUT}" ] && export WAIT_TIMEOUT="15s"
[ -z "${WAIT_ALL_DONE}" ] && export WAIT_ALL_DONE="40s"

# Compose up!
docker-compose -p selenium scale hub=1 chrome=${NUM_NODES} firefox=${NUM_NODES}

# Wait then show errors, if any
docker exec selenium_hub_1 wait_all_done ${WAIT_ALL_DONE}
docker exec selenium_hub_1 errors || true
for i in $(seq 1 ${NUM_NODES}); do
  docker exec selenium_chrome_${NUM_NODES} wait_all_done ${WAIT_ALL_DONE}
  docker exec selenium_chrome_${i} errors || true
  docker exec selenium_firefox_${NUM_NODES} wait_all_done ${WAIT_ALL_DONE}
  docker exec selenium_firefox_${i} errors || true
done

# Tests can run anywere, in the hub, in the host, doesn't matter
for i in $(seq 1 ${NUM_NODES}); do
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
  docker exec -t selenium_chrome_${i} run_test &
done

# not so verbose from here
set -e +x

# http://jeremy.zawodny.com/blog/archives/010717.html
FAIL=0
for job in `jobs -p`; do
  wait $job || let "FAIL+=1"
done

# Show logs also
docker logs selenium_hub_1
for i in $(seq 1 ${NUM_NODES}); do
  docker logs selenium_chrome_${i}
  docker logs selenium_firefox_${i}
done

# Cleanup
docker-compose down

# Results
if [ "$FAIL" == "0" ]; then
  echo "Awesome! $FAIL tests failed"
else
  die "In total $FAIL tests failed"
fi
