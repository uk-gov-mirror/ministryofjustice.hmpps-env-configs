# HMPPS-ENGINEERING-PIPELINES

Seed Pipeline -> common/seed_pipeline.tf

## Terraform builds

A makefile has been created to orchestrate the container locally using docker-compose. 

CI processes call the same makefile.

### Docker-Compose

Create .env file using example below, adjust accordingly to the target environment or component.

.env file is ignored by version control

AWS profile relates to the aws credentials to assume the iam roles used for builds.

```
    AWS_PROFILE="aws profile"
    ENVIRONMENT_NAME="enviroronment name"
    COMPONENT=common
    GITHUB_TOKEN="token"
```

### Commands

```
    start -> make start
    stop -> make stop
    reload env vars -> make restart or make start
    plan -> make local_plan 
    apply -> make local_apply
```
