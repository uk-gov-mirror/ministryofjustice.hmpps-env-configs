---
version: 0.2
env:
  parameter-store:
    API_TOKEN: "/vcms/snyk/api/token"

phases:
  pre_build:
    commands:
      - snyk auth $API_TOKEN
  build:
    commands:
      - snyk test --all-projects --org=moj-vcms   --severity-threshold=high --json-file-output=vulnerability_test/vcms_snyk.json || echo "Ignoring failures temporarily"
      - snyk monitor
reports:
  unit-test-reports:
    files:
      - "vulnerability_test/*.json"
    file-format: CUCUMBERJSON
