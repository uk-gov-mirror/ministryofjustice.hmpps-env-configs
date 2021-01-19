---
version: 0.2
phases:
  build:
    commands:
      - bash deployment/unit-tests.sh || exit 1
reports:
  unit-test-reports:
    files:
      - "unit-test/*.xml"
    file-format: "JUNITXML"
