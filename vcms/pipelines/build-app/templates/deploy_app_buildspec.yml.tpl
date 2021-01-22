---
version: 0.2
env:
  variables:
    PROFILE: "deploy_profile"
    REGION: "eu-west-2"
phases:
  pre_build:
    commands:
    - echo "AccountID is $ACCOUNT_ID"
    - echo "Env is $ENVIRONMENT_TYPE"
    - echo "Assuming role arn:aws:iam::$ACCOUNT_ID:role/terraform "
    - temp_role=$(aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT_ID:role/terraform --role-session-name deploy-session --duration-seconds 3600) || exit 1
    - aws_access_key_id=$(echo $temp_role | jq .Credentials.AccessKeyId | xargs)
    - aws_secret_access_key=$(echo $temp_role | jq .Credentials.SecretAccessKey | xargs)
    - aws_session_token=$(echo $temp_role | jq .Credentials.SessionToken | xargs)
    - mkdir -p $HOME/.aws || exit 1
    - echo "[$PROFILE]"                                        > $HOME/.aws/credentials
    - echo "aws_access_key_id = $aws_access_key_id"          >> $HOME/.aws/credentials
    - echo "aws_secret_access_key = $aws_secret_access_key"  >> $HOME/.aws/credentials
    - echo "aws_session_token = $aws_session_token"          >> $HOME/.aws/credentials
    - TEMP_APP_VERSION=$(aws ssm get-parameters --region $REGION --names "/codepipeline/temp/deploy/version/vcms-$ENVIRONMENT_TYPE-deploy-app" --query "Parameters[0]"."Value" --output text)
    - |-
          if [ "$TEMP_APP_VERSION" != "None" ]; then
               APP_VERSION=$TEMP_APP_VERSION
               echo "export APP_VERSION=$APP_VERSION" > temp_app_version.txt
          fi

    - |-
          if [ "$APP_VERSION" == "current_eb_version" ] || [ -z $APP_VERSION ]; then
              source configs/$ENVIRONMENT_TYPE.properties
          fi

    - echo "APP_VERSION is $APP_VERSION"

    - aws s3 ls s3://vcms-$ENVIRONMENT_TYPE.artefacts/Dockerrun.aws.json.$APP_VERSION.zip --region $REGION --profile $PROFILE  && artefact_found=$? || artefact_found=$?

    - |-
          if [ "$artefact_found" == "0" ]; then
            echo Source bundle already exists in S3
          else
            aws s3 cp s3://vcms-$ENVIRONMENT_TYPE.artefacts/Dockerrun.aws.json.template.zip ./Dockerrun.aws.json.template.zip --region $REGION --profile $PROFILE          || exit 1
            unzip ./Dockerrun.aws.json.template.zip                                                                                                                        || exit 1
            sed -i "s/vcms:template/vcms:$APP_VERSION/" ./Dockerrun.aws.json                                                                                               || exit 1
            zip -r ./Dockerrun.aws.json.$APP_VERSION.zip ./Dockerrun.aws.json ./.ebextensions                                                                              || exit 1
            aws s3 cp ./Dockerrun.aws.json.$APP_VERSION.zip s3://vcms-$ENVIRONMENT_TYPE.artefacts/Dockerrun.aws.json.$APP_VERSION.zip  --region $REGION --profile $PROFILE || exit 1
          fi
    - COUNT=$(aws elasticbeanstalk describe-application-versions --version-labels "$APP_VERSION" --region $REGION  --profile $PROFILE | jq '.ApplicationVersions | length')

    - |-
          if [ "$COUNT" == "1" ]; then
            echo Application version already exists in EB
          else
            aws elasticbeanstalk create-application-version --application-name vcms --version-label $APP_VERSION --description $APP_VERSION --source-bundle S3Bucket="vcms-$ENVIRONMENT_TYPE.artefacts",S3Key="Dockerrun.aws.json.$APP_VERSION.zip" --region $REGION  --profile $PROFILE || exit 1
          fi

  build:
    commands:
      - aws elasticbeanstalk update-environment --environment-name vcms-$ENVIRONMENT_TYPE --version-label $APP_VERSION --region $REGION  --profile $PROFILE   || exit 1
      - sleep 10
      - EB_STATUS=$(aws elasticbeanstalk describe-environment-health --environment-name vcms-$ENVIRONMENT_TYPE --attribute-names Status --region $REGION  --profile $PROFILE | jq -r ."Status")
      - |-
          while [ $EB_STATUS != "Ready" ]
          do
            echo "Elastic Beanstalk Environment status is $EB_STATUS"
            sleep 15
            EB_STATUS=$(aws elasticbeanstalk describe-environment-health --environment-name vcms-$ENVIRONMENT_TYPE --attribute-names Status --region $REGION  --profile $PROFILE | jq -r ."Status")
          done
      - echo "Elastic Beanstalk Environment upgrade completed"

    finally:
      - rm -rf $HOME/.aws

artifacts:
  files:
    - '**/*'
