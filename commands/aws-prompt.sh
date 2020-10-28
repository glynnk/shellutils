#!/bin/bash

if [ -n "$AWS_PROFILE" ]; then
  echo -e "\e[2m<aws:$AWS_PROFILE>\e[22m"
fi
