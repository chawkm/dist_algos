# How to run the tests

Should have:
0 <= RELIABILITY <= 100

## Locally

`TIMEOUT=1000 MAX_BROADCAST=1000 RELIABILITY=100 SYSTEM=6 make run`

## On docker containers
`TIMEOUT=1000 MAX_BROADCAST=1000 RELIABILITY=100 SYSTEM=6 make up`

## On Lab machines
Should be logged in to a lab machine then run
./xxx
make labs