# How to run the tests

Should have:
0 <= RELIABILITY <= 100

## Locally

`TIMEOUT=1000 MAX_BROADCAST=1000 RELIABILITY=100 SYSTEM=6 LOC=true make run`

## On docker containers
`TIMEOUT=1000 MAX_BROADCAST=1000 RELIABILITY=100 SYSTEM=6 LOC=false make up`