---
version: 0.2
env:
  variables:
    GITHUB_REPO: "github.com/ministryofjustice/hmpps-vcms"

  parameter-store:
    HMPPS_GITHUB_USER: "/dev/jenkins/hmpps/integration/user/name"
    HMPPS_GITHUB_TOKEN: "/manually/created/engineering/dev/codepipeline/github/accesstoken"
    HMPPS_GITHUB_EMAIL: "/jenkins/github/email"

phases:
  install:
    commands:
      - pip install git+https://github.com/ministryofjustice/semvertag.git@1.1.0
  build:
    commands:
      - sh deployment/get_branch.sh
      - cd builds
      - git config --global user.email "HMPPS_GITHUB_EMAIL" || exit 1
      - git config --global user.name "$HMPPS_GITHUB_USER"  || exit 1
      - source git_tagging.sh && tag   || exit 1
artifacts:
  files:
    - '**/*'
