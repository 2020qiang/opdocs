```
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 10 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 10s ] thds: 8 tps: 1472.56 qps: 29461.56 (r/w/o: 20625.01/5890.63/2945.92) lat (ms,95%): 6.21 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 1463.33 qps: 29265.74 (r/w/o: 20484.38/5854.91/2926.45) lat (ms,95%): 6.09 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 1424.91 qps: 28499.05 (r/w/o: 19951.38/5697.65/2850.03) lat (ms,95%): 6.43 err/s: 0.00 reconn/s: 0.00
[ 40s ] thds: 8 tps: 1423.78 qps: 28476.51 (r/w/o: 19933.06/5695.90/2847.55) lat (ms,95%): 6.32 err/s: 0.00 reconn/s: 0.00
[ 50s ] thds: 8 tps: 1440.02 qps: 28799.39 (r/w/o: 20160.08/5759.28/2880.04) lat (ms,95%): 6.21 err/s: 0.00 reconn/s: 0.00
[ 60s ] thds: 8 tps: 1436.39 qps: 28719.94 (r/w/o: 20101.22/5745.95/2872.77) lat (ms,95%): 6.43 err/s: 0.00 reconn/s: 0.00
[ 70s ] thds: 8 tps: 1360.20 qps: 27211.80 (r/w/o: 19051.00/5440.40/2720.40) lat (ms,95%): 7.30 err/s: 0.00 reconn/s: 0.00
[ 80s ] thds: 8 tps: 1400.02 qps: 28001.10 (r/w/o: 19601.01/5600.06/2800.03) lat (ms,95%): 7.30 err/s: 0.00 reconn/s: 0.00
[ 90s ] thds: 8 tps: 1412.30 qps: 28245.89 (r/w/o: 19772.09/5649.20/2824.60) lat (ms,95%): 6.79 err/s: 0.00 reconn/s: 0.00
[ 100s ] thds: 8 tps: 1327.69 qps: 26546.39 (r/w/o: 18580.25/5310.76/2655.38) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 110s ] thds: 8 tps: 1392.21 qps: 27855.70 (r/w/o: 19499.24/5572.04/2784.42) lat (ms,95%): 7.17 err/s: 0.00 reconn/s: 0.00
[ 120s ] thds: 8 tps: 1316.80 qps: 26334.71 (r/w/o: 18434.74/5266.38/2633.59) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            2361968
        write:                           674848
        other:                           337424
        total:                           3374240
    transactions:                        168712 (1405.87 per sec.)
    queries:                             3374240 (28117.49 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          120.0037s
    total number of events:              168712

Latency (ms):
         min:                                    2.04
         avg:                                    5.69
         max:                                  163.19
         95th percentile:                        6.67
         sum:                               959694.69

Threads fairness:
    events (avg/stddev):           21089.0000/77.95
    execution time (avg/stddev):   119.9618/0.00
```



