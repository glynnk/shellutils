#!/bin/bash

profile=$(aws configure list 2>/dev/null | egrep "^\s*profile" | awk '{print $2}')

if [[ "$profile" =~ ^[a-z].* ]]; then
  echo -e "\e[2m<aws:$profile>\e[22m"
fi
