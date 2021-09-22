#!/usr/bin/env bash

# shellcheck disable=SC2154
if [[ ${farmer} == 'true' ]]; then
  mint start farmer-only
elif [[ ${harvester} == 'true' ]]; then
  if [[ -z ${farmer_address} || -z ${farmer_port} || -z ${ca} ]]; then
    echo "A farmer peer address, port, and ca path are required."
    exit
  else
    mint configure --set-farmer-peer "${farmer_address}:${farmer_port}"
    mint start harvester
  fi
else
  mint start farmer
fi

# Ensures the log file actually exists, so we can tail successfully
touch "$APP_ROOT/log/debug.log"
tail -f "$APP_ROOT/log/debug.log"
