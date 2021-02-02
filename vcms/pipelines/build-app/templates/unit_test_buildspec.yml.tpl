---
version: 0.2
phases:
  build:
    commands:
      - $(aws ecr get-login --no-include-email --region eu-west-2)
      - bash deployment/unit-tests.sh || exit 1
reports:
  unit-test-reports:
    files:
      - "unit-test/*.xml"
    file-format: "JUNITXML"
