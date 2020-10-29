if [ -f $HOME/.aws/profile.src.me ]; then
  source $HOME/.aws/profile.src.me
fi

if [ -f '/usr/local/bin/aws_completer' ]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi

function agp() {
  echo $AWS_PROFILE
}

function aws_profiles() {
  [[ -r "${AWS_CONFIG_FILE:-$HOME/.aws/config}" ]] || return 1
  grep -Eo '\[.*\]' "$HOME/.aws/config" | sed -E 's/^[[:space:]]*\[(profile)?[[:space:]]*([-_[:alnum:]]+)\][[:space:]]*$/\2/g'
}

# AWS profile selection
function asp() {
  if [[ -z "$1" ]]; then
    unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    if [ -f $HOME/.aws/profile.src.me ]; then
      rm -f $HOME/.aws/profile.src.me
    fi
    echo AWS profile cleared.
    return
  fi

  local found=false
  while read profile; do
    if [ "$profile" == "$1" ]; then
      found=true
      break
    fi
  done <<< $(aws_profiles)

  if [ "$found" != "true" ]; then
    echo "error: $1 - profile not found"
    return 1
  fi

  local exists="$(aws configure get aws_access_key_id --profile $1)"
  local role_arn="$(aws configure get role_arn --profile $1)"
  local aws_access_key_id=""
  local aws_secret_access_key=""
  local aws_session_token=""

  if [ -n "$role_arn" ]; then
    local mfa_serial="$(aws configure get mfa_serial --profile $1)"
    local mfa_token=""
    local mfa_opt=""
    if [ -n "$mfa_serial" ]; then
      echo "Please enter your MFA token for $mfa_serial:"
      read mfa_token
      mfa_opt="--serial-number $mfa_serial --token-code $mfa_token --duration-seconds 43200"
    fi

    local ext_id="$(aws configure get external_id --profile $1)"
    local extid_opt=""
    if [ -n "$ext_id" ]; then
      extid_opt="--external-id $ext_id"
    fi

    local profile=$1
    local source_profile="$(aws configure get source_profile --profile $1)"
    if [ -n "$source_profile" ]; then
      profile=$source_profile
    fi

    echo "Assuming role $role_arn using profile $profile"
    local assume_cmd=(aws sts assume-role "--profile=$profile" "--role-arn $role_arn" "--role-session-name "$profile"" "$mfa_opt" "$extid_opt")
    local JSON="$(eval ${assume_cmd[@]})"

    aws_access_key_id="$(echo $JSON | jq -r '.Credentials.AccessKeyId')"
    aws_secret_access_key="$(echo $JSON | jq -r '.Credentials.SecretAccessKey')"
    aws_session_token="$(echo $JSON | jq -r '.Credentials.SessionToken')"
  elif [ -n "$exists" ]; then
    aws_access_key_id="$(aws configure get aws_access_key_id --profile $1)"
    aws_secret_access_key="$(aws configure get aws_secret_access_key --profile $1)"
    aws_session_token=""
  else
    echo "error: failed to retrive role arn or access key id"
    return 1
  fi

  echo "export AWS_DEFAULT_PROFILE=$1"                               > $HOME/.aws/profile.src.me
  echo "export AWS_PROFILE=$1"                                      >> $HOME/.aws/profile.src.me
  echo "export AWS_EB_PROFILE=$1"                                   >> $HOME/.aws/profile.src.me
  echo "export AWS_ACCESS_KEY_ID=$aws_access_key_id"                >> $HOME/.aws/profile.src.me
  echo "export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key"        >> $HOME/.aws/profile.src.me
  echo "export AWS_SESSION_TOKEN=$aws_session_token"                >> $HOME/.aws/profile.src.me
  echo "[[ -z "\$AWS_SESSION_TOKEN" ]] && unset AWS_SESSION_TOKEN"  >> $HOME/.aws/profile.src.me

  source $HOME/.aws/profile.src.me
  kubectl config use-context $1         # since we can't use any other context, we may as well switch
  echo "Switched to AWS Profile: $1";
}

function aws_change_access_key() {
  if [[ -z "$1" ]]; then
    echo "usage: $0 <profile>"
    return 1
  fi

  echo Insert the credentials when asked.
  asp "$1" || return 1
  AWS_PAGER="" aws iam create-access-key
  AWS_PAGER="" aws configure --profile "$1"

  echo You can now safely delete the old access key running \`aws iam delete-access-key --access-key-id ID\`
  echo Your current keys are:
  AWS_PAGER="" aws iam list-access-keys
}

