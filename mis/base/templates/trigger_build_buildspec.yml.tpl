---
version: 0.2
env:
  variables:
    PROFILE: build_profile

phases:
  pre_build:
    commands:
    - |-
        case "$ENV_NAME" in
            delius-mis-dev) ACCOUNT_ID="479759138745"
            ;;
            delius-auto-test)    ACCOUNT_ID="431912413968"
            ;;
            delius-stage)   ACCOUNT_ID="205048117103"
            ;;
            delius-preprod) ACCOUNT_ID="010587221707"
            ;;
            delius-prod)    ACCOUNT_ID="050243167760"
            ;;
            *)       echo "$ENV_NAME unknown!"
                     exit 1
            ;;
        esac

    - echo "AccountID is $ACCOUNT_ID"
    - echo "Env is $ENV_NAME"
    - mkdir $HOME/.aws
    - temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT_ID:role/terraform --role-session-name deploy-session --duration-seconds 3600)
    - aws_access_key_id=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
    - aws_secret_access_key=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
    - aws_session_token=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
    - echo [$PROFILE]                                         > $HOME/.aws/credentials
    - echo aws_access_key_id = $aws_access_key_id            >> $HOME/.aws/credentials
    - echo aws_secret_access_key = $aws_secret_access_key    >> $HOME/.aws/credentials
    - echo aws_session_token = $aws_session_token            >> $HOME/.aws/credentials

  build:
    commands:
      - echo "Triggering codebuild project $PROJECT_NAME in $ACCOUNT_ID"

      - |-
          if [ -z "$ENV_VAR_OVERIDES" ]; then
            echo "aws codebuild start-build  --project-name $PROJECT_NAME --profile $PROFILE --region $REGION"
            BUILD_ID=$(aws codebuild start-build  --project-name $PROJECT_NAME --profile $PROFILE --region $REGION | jq -r .build.id) || exit 1
          else
            echo "aws codebuild start-build  --project-name $PROJECT_NAME --environment-variables-override $ENV_VAR_OVERIDES  --profile $PROFILE --region $REGION"
            BUILD_ID=$(aws codebuild start-build  --project-name $PROJECT_NAME --environment-variables-override $ENV_VAR_OVERIDES  --profile $PROFILE --region $REGION | jq -r .build.id) || exit 1
          fi

      - BUILD_STATUS=$(aws codebuild batch-get-builds --ids $BUILD_ID --profile $PROFILE --region $REGION  | jq -r .builds[0].buildStatus) || exit 1

      - |-
           while [ $BUILD_STATUS == "IN_PROGRESS" ]
           do
            echo "PROJECT_NAME $PROJECT_NAME  BUILD_ID $BUILD_ID status is $BUILD_STATUS"
             sleep 15
             BUILD_STATUS=$(aws codebuild batch-get-builds --ids $BUILD_ID --profile $PROFILE --region $REGION  | jq -r .builds[0].buildStatus) || exit 1
           done

      - |-
          if [ "$BUILD_STATUS" != "SUCCEEDED" ]; then
            echo "PROJECT_NAME $PROJECT_NAME  BUILD_ID $BUILD_ID status is $BUILD_STATUS"
            echo exiting
            exit 1
          fi

      - echo "PROJECT_NAME $PROJECT_NAME  BUILD_ID $BUILD_ID status is $BUILD_STATUS"

    finally:
      - rm -rf $HOME/.aws
