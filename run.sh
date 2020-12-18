#!/bin/sh

set -e

#Usage
# Scripts takes 2 arguments: environment_name and action
# environment_name: target environment example dev prod
# ACTION_TYPE: task to complete example plan apply test clean
# AWS_TOKEN: token to use when running locally eg hmpps-token

# Error handler function
exit_on_error() {
  exit_code=$1
  last_command=${@:2}
  if [ $exit_code -ne 0 ]; then
      >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
      exit ${exit_code}
  fi
}

if [ -z "${HMPPS_BUILD_WORK_DIR}" ]
then
    echo "--> Using default workdir"
    env_config_dir="${HOME}/data/env_configs"
else
    echo "USING CUSTOM WORKDIR for configs: $HMPPS_BUILD_WORK_DIR"
    env_config_dir="${HMPPS_BUILD_WORK_DIR}/env_configs"
fi

ENVIRONMENT_NAME_ARG=$1
ACTION_TYPE=$2
COMPONENT=${3}

if [ -z "${ENVIRONMENT_NAME_ARG}" ]
then
    echo "environment_name argument not supplied, please provide an argument!"
    exit 1
fi

echo "Output -> environment_name set to: ${ENVIRONMENT_NAME_ARG}"

if [ -z "${ACTION_TYPE}" ]
then
    echo "ACTION_TYPE argument not supplied."
    echo "--> Defaulting to plan ACTION_TYPE"
    ACTION_TYPE="plan"
fi

echo "Output -> ACTION_TYPE set to: ${ACTION_TYPE}"

if [ -z "${COMPONENT}" ]
then
    echo "COMPONENT argument not supplied."
    echo "--> Defaulting to common component"
    COMPONENT="common"
fi

#check env vars for RUNNING_IN_CONTAINER switch
if [[ ${RUNNING_IN_CONTAINER} == True ]]
then
    workDirContainer=${3}
    echo "Output -> environment stage"
    source ${env_config_dir}/${ENVIRONMENT_NAME_ARG}.properties
    exit_on_error $? !!
    echo "Output ---> set environment stage complete"
    # set runCmd
    ACTION_TYPE="docker-${ACTION_TYPE}"
    export workDir=${workDirContainer}
    cd ${workDir}
    mkdir -p "${HOME}/data/${workDirContainer}"
    export PLAN_RET_FILE=${HOME}/data/${workDirContainer}_plan_ret
    echo "Output -> Container workDir: ${workDir}"
fi

if [ ${ACTION_TYPE} == "docker-ansible" ]
then
    export AWS_DEFAULT_REGION=${TF_VAR_region}
    temp_creds_file="${HOME}/temp_creds"
    temp_role=$(aws sts assume-role --role-arn ${TERRAGRUNT_IAM_ROLE} --role-session-name infra --duration-seconds 900) > ${temp_creds_file}
    exit_on_error $? !!
    echo "unset AWS_PROFILE
    export AWS_ACCESS_KEY=$(echo ${temp_role} | jq .Credentials.AccessKeyId | xargs)
    export AWS_SECRET_KEY=$(echo ${temp_role} | jq .Credentials.SecretAccessKey | xargs)
    export AWS_SECURITY_TOKEN=$(echo ${temp_role} | jq .Credentials.SessionToken | xargs)" > ${temp_creds_file}
    source ${temp_creds_file}
    exit_on_error $? !!
    rm -rf ${temp_creds_file}
fi

case ${ACTION_TYPE} in
  docker-ansible)
    echo "Running ansible playbook action"
    ansible-playbook playbook.yml
    exit_on_error $? !!
    ;;
  docker-plan)
    echo "Running docker plan action"
    rm -rf *.plan
    terragrunt init
    exit_on_error $? !!
    terragrunt plan -detailed-exitcode --out ${ENVIRONMENT_NAME_ARG}.plan || export tf_exit_code="$?"
    if [ -z ${tf_exit_code} ]
    then
      export tf_exit_code="0"
    fi
    echo "export exitcode=${tf_exit_code}" > ${PLAN_RET_FILE}
    exit_on_error $? !!
    ;;
  docker-apply)
    echo "Running docker apply action"
    terragrunt apply ${ENVIRONMENT_NAME_ARG}.plan || export tf_exit_code="$?"
    if [ -z ${tf_exit_code} ]
    then
      export tf_exit_code="0"
    fi
    echo "export exitcode=${tf_exit_code}" > ${PLAN_RET_FILE}
    ;;
  docker-destroy)
    echo "Running docker destroy action"
    rm -rf *.plan
    terragrunt init
    terragrunt destroy -force
    exit_on_error $? !!
    ;;
  docker-test)
    echo "Running docker test action"
    for cmp in ${components_list}
    do
      output_file="${inspec_profile_files_path}/output-${cmp}.json"
      rm -rf ${output_file}
      cd ${workingDir}/${cmp}
      terragrunt output -json > ${output_file}
      exit_on_error $? !!
    done
    exit_on_error $? !!
    temp_role=$(aws sts assume-role --role-arn ${TERRAGRUNT_IAM_ROLE} --role-session-name testing --duration-seconds 900)
    echo "unset AWS_PROFILE
    export AWS_ACCESS_KEY_ID=$(echo ${temp_role} | jq .Credentials.AccessKeyId | xargs)
    export AWS_SECRET_ACCESS_KEY=$(echo ${temp_role} | jq .Credentials.SecretAccessKey | xargs)
    export AWS_SESSION_TOKEN=$(echo ${temp_role} | jq .Credentials.SessionToken | xargs)" > ${inspec_creds_file}
    source ${inspec_creds_file}
    exit_on_error $? !!
    cd ${workingDir}
    inspec exec ${inspec_profile} -t aws://${TG_REGION}
    exit_on_error $? !!
    rm -rf ${inspec_creds_file} ${inspec_profile_files_path}/output*.json
    ;;
  docker-output)
    echo "Running docker output action"
    terragrunt output
    exit_on_error $? !!
    ;;
  *)
    echo "${ACTION_TYPE} is not a valid argument. init - apply - test - output - destroy"
  ;;
esac

set -o pipefail
set -x
