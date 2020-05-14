# Eclipse Che single-host POC with HAProxy

## HOWTO
 - have Openshift cluster running and `oc` working
 - go to POC folder
 - `sh 01_cheOS.sh` will create namespace with "Che" and `che-gateway` pods. Script will print the url at the end.
 - `sh 02_addWorkspace.sh` will create a "workspace" with random name and reconfigure haproxy with everything needed to live reload the config. It will print the urls of all existing workspaces at the end of the script.
 - `sh 03_cleanup.sh` will remove all openshift projects that name starts with `che`

## Performance test
 - have **JMeter**
 - have clean cluster and run `sh 01_cheOS.sh`
 - run `sh perftest.sh`

### What does it do
`01_cheOS.sh` and `02_addWorkspace.sh` scripts are adding "Che" and "Workspaces" URLs into `urls.csv` file. Testsuite runs `request_threads` threads like this:
```
Thread {
  while true {
    foreach url in read('urls.csv') {
      request(url)
    }
    sleep(`loop_delay`)
  }
}
```

In other thread, it's adding workspaces with `02_addWorkspace.sh` script with `workspace_create_delay` delay, up to `workspaces` workspaces.

Whole testsuite is limited by overall duration `duration`.

`duration`, `request_threads`, `loop_delay`, `workspaces`, `workspace_create_delay` are configurable parameters (https://github.com/sparkoo/che-singlehost-haproxy-POC/blob/master/perftest.jmx#L15)
