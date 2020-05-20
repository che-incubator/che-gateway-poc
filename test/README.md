# Eclipse Che single-host POC performance testsuite

## HOWTO Run tests

### Prerequisites
  - have Openshift cluster running and `oc` working
  - have `docker` (works with podman, but we're running `docker` command here so `sudo dnf install -y podman-docker` :) )
  - have `jq`

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
#### 01_prepare.sh
Prepares whole infrastructure and folder structure for given `gateway` and `testcase`.

#### 02_run.sh
Performs given `testcase` with given `gateway` and write the report.

#### 99_cleanup.sh
Cleans the cluster (deletes projects with common prefix) and remove local workdir folder. It keeps the test report.

### Testcases

All common logic of testcases is at `<che-gateway-poc>/test/testcases/tc_<testcase>`. Gateway specific functions are then at `<che-gateway-poc>/<gateway>/functions` folder.

#### Testcase 0 (`tc_0`)
  - testcase for debugging these scripts

#### Testcase 1 (`tc_1`)
TBD

#### Testcase 2 (`tc_2`)
##### params
  - duration: 60s
  - assert: 1500ms latency, response code 200, response payload '1'
  - threads: 25
  - target throughput: 3000op/min

##### scenario
  - prepare 30 workspaces
  - `N=25`
  - configure gateway for `N` workspaces and load them
  - repeat 5x
    - load `N` workspaces for 60s
    - after 30s add 1 prepared workspace to gateway
    - `N++`

#### Testcase 3 (`tc_3`)
##### params
  - duration: 300s
  - assert: 2000ms latency, response code 200, response payload '1'
  - threads: 25
  - target throughput: 3000op/min

##### scenario
  - prepare 1 workspace
  - repeat 5x
    - load for 300s

#### Testcase 4 (`tc_4`)
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
    - files `env.sh`, `functions/gateway.sh` and `functions/prepare.sh`

#### `env.sh`
Variables needed by gateway implementation (e.g. gateway specific config files). Example: [`haproxy-scripted/env.sh`](../haproxy-scripted/env.sh)

#### `functions/prepare.sh`
**Must** implement `PrepareGatewayInfra`.

This functions should prepare gateway pod with label `app: che-gateway` and listening on port `8080` and with initial configuration (route everything to `che:80`). Service and Route are already prepared.

Example: [`haproxy-scripted/functions/prepare.sh`](../haproxy-scripted/functions/prepare.sh)

#### `functions/gateway.sh`
**Must** implement `FullGatewayReconfig` function. This function should read `${WORKSPACES_DB}` file, and reconfigure gateway with it's values.

`${WORKSPACES_DB}` is csv file with following format:
```
request_path,target_service_dnsname
```

Gateway should be configured so `/<request_path>` will be directed into `<target_service_dnsname>` AND path-rewrite will remove the `<request_path>` from request path.

Example: [`haproxy-scripted/functions/gateway.sh`](../haproxy-scripted/functions/gateway.sh)
