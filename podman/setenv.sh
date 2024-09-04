#!/usr/bin/env bash

# Show env vars
grep -v '^#' .gitaction_env

# Export env vars
export $(grep -v '^#' .gitaction_env | xargs)
