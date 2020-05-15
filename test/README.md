# Eclipse Che single-host POC performance testsuite

## HOWTO Run tests

### Prerequisites
  - have Openshift cluster running and `oc` working
  - have [*JMeter*](https://jmeter.apache.org/download_jmeter.cgi)

### Run
  - go to `<che-gateway-poc>/test` (scripts expects to be run here)
  - all main scripts (prefixed with number and has `+x` permission) accepts 2 parameters `<gateway>` and `<testcase>` (example: `./01_prepare haproxy-scripted 1`). These can be set as environment variables as well. If so, no parameters are needed. *Default values are `haproxy-scripted` and `0`. This is used for testing.*
    - `<gateway>` - folder name of gateway implementation (exapmle: `haproxy-scripted`, `nginx-custom-image`, ...). Can be set with `GATEWAY` env variable.
    - `<testcase>` - number of test case (example: `0`, `1`, ...). Can be set with `TESTCASE` env variable.
  - You should run all scripts with same `gateway` and `testcase`. (*Prepare* for one testcase and *run* for another will lead to unpredictable outcome.)
  - see [`<che-gateway-poc>/test/env.sh`](env.sh) for global variables that are used across the scripts. E.g. `HOST` is hostname of the main Route and is important to be set correctly.

  1. run `./01_prepare.sh`
  1. run `./02_run.sh`
  1. run `./99_cleanup.sh`

### Main scripts
## 01_prepare.sh
Prepares whole infrastructure and folder structure for given `gateway` and `testcase`.

## 02_run.sh
Performs given `testcase` with given `gateway` and write the report.

## 99_cleanup.sh
Cleans the cluster (deletes projects with common prefix) and remove local workdir folder. It keeps the test report.

## Testcases

All common logic of testcases is at `<che-gateway-poc>/test/testcases/tc_<testcase>`. Gateway specific functions are then at `<che-gateway-poc>/<gateway>/functions` folder.

### Testcase 0 (`tc_0`)
  - testcase for debugging these scripts

### Testcase 1 (`tc_1`)
TBD

### Testcase 2 (`tc_2`)
TBD

### Testcase 3 (`tc_3`)
TBD

### Testcase 4 (`tc_4`)
TBD


## HOWTO Implement new gateway

### What is already prepared by generic functions
  - *Che* pod and service
    - reachable at `che:80` within same namespace as Gateway
  - Public route with gateway service
    - Service is set to label `app: che-gateway` port `8080`

### Useful variables
  - `${WORKDIR}` - folder created for specific test run. Is cleaned
  - `${WORKSPACES_DB}` - CSV file with all *workspaces* that shouls be routed by gateway
  - `${POC_NAMESPACE}` - main namespace where is *Che*+service, Gateway+service pods, and public Route

### Implementation
  - Every gateway implementation must have:
    - folder at root of the repo. Folder name is then referenced with `GATEWAY` variable.
    - file `env.sh`
    - folder `functions` with `gateway.sh` and `prepare.sh`

#### `env.sh`
Variables needed by gateway implementation, like specific config files.

#### `functions/prepare.sh`
**Must** implement `PrepareGatewayInfra`.

This functions should prepare gateway pod with label `app: che-gateway` and listening on port `8080` and with initial configuration (route everything to `che:80`). Service and Route are already prepared.

#### `functions/gateway.sh`
**Must** implement `FullGatewayReconfig` function. This function should read `${WORKSPACES_DB}` file, and reconfigure gateway with it's values.

`${WORKSPACES_DB}` is csv file with following format:
```
request_path,target_service_dnsname
```

Gateway should be configured so `/<request_path>` will be directed into `<target_service_dnsname>` AND path-rewrite will remove the `<request_path>` from request path.