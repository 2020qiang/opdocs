## 系统基准性能测试工具

[https://www.geekbench.com/](https://www.geekbench.com/)  
下载

```
$ wget -c http://cdn.primatelabs.com/Geekbench-2.4.3-Linux.tar.gz
$ tar -xvf Geekbench-2.4.3-Linux.tar.gz
$ ./dist/Geekbench-2.4.3-Linux/geekbench
```

报错

```
-bash: ./geekbench: /lib/ld-linux.so.2: bad ELF interpreter: 没有那个文件或目录
```

解决

```
# yum install -y glibc.i686 libstdc++ libstdc++.i686 compat-libstdc++-33.i686
```

结果

```
Geekbench 2.4.3 Tryout for Linux x86 (32-bit)
Section             Description                                Score                  Geekbench Score
Integer                Processor integer performance               22402                      25217
Floating Point        Processor floating point performance       44411
Memory                Memory performance                           6085
Stream                Memory bandwidth performance               6159

系统信息
    Dell ROGUE12
    Operating System          Linux 2.6.32-696.16.1.el6.x86_64 x86_64
    Model                      Dell ROGUE12
    Processor                  Intel Xeon E5-2665 @ 2.40 GHz 2 processors, 16 cores, 32 threads
    Processor ID              GenuineIntel Family 6 Model 45 Stepping 7
    L1 Instruction Cache      32 KB x 8
    L1 Data Cache              32 KB x 8
    L2 Cache                  256 KB x 8
    L3 Cache                  20480 KB
    Motherboard                  Dell 0WTH3T
    BIOS                      Dell Inc. 2.5.3
    Memory                      32014 MB

整数性能
    Integer                    22402

    Blowfish                1990
    single-core scalar        87.4 MB/sec

    Blowfish                52260
    multi-core scalar       2.09 GB/sec

    Text Compress           2729
    single-core scalar        8.73 MB/sec

    Text Compress           41181
    multi-core scalar        135 MB/sec

    Text Decompress         2978
    single-core scalar        12.2 MB/sec

    Text Decompress         50893
    multi-core scalar        203 MB/sec

    Image Compress          2249
    single-core scalar        18.6 Mpixels/sec

    Image Compress          32547
    multi-core scalar        274 Mpixels/sec

    Image Decompress        2268
    single-core scalar        38.1 Mpixels/sec

    Image Decompress        29469
    multi-core scalar        481 Mpixels/sec

    Lua                     3915
    single-core scalar        1.51 Mnodes/sec

    Lua                     46346
    multi-core scalar        17.8 Mnodes/sec

浮点性能
    Floating Point            44411

    Mandelbrot              2592
    single-core scalar        1.72 Gflops

    Mandelbrot              69898
    multi-core scalar        45.7 Gflops

    Dot Product             4272
    single-core scalar        2.06 Gflops

    Dot Product             80155
    multi-core scalar        36.5 Gflops

    Dot Product             5093
    single-core vector        6.10 Gflops

    Dot Product             85734
    multi-core vector        89.2 Gflops

    LU Decomposition        3603
    single-core scalar        3.21 Gflops

    LU Decomposition        15105
    multi-core scalar        13.2 Gflops

    Primality Test          4434
    single-core scalar      662 Mflops

    Primality Test          62344
    multi-core scalar        11.6 Gflops

    Sharpen Image           10485
    single-core scalar        24.5 Mpixels/sec

    Sharpen Image           143682
    multi-core scalar        331 Mpixels/sec

    Blur Image              8152
    single-core scalar        6.45 Mpixels/sec

    Blur Image              126217
    multi-core scalar        99.2 Mpixels/sec

内存性能
    Memory                    6085

    Read Sequential         6639
    single-core scalar        8.13 GB/sec

    Write Sequential        11223
    single-core scalar        7.68 GB/sec

    Stdlib Allocate         4760
    single-core scalar        17.8 Mallocs/sec

    Stdlib Write            3174
    single-core scalar        6.57 GB/sec

    Stdlib Copy             4631
    single-core scalar        4.77 GB/sec

Stream 性能
    Stream                    6159

    Stream Copy             6124
    single-core scalar        8.38 GB/sec

    Stream Copy             6805
    single-core vector        8.82 GB/sec

    Stream Scale            6237
    single-core scalar        8.09 GB/sec

    Stream Scale            6537
    single-core vector        8.82 GB/sec

    Stream Add              5805
    single-core scalar        8.76 GB/sec

    Stream Add              6575
    single-core vector        9.15 GB/sec

    Stream Triad            6465
    single-core scalar        8.93 GB/sec

    Stream Triad            4730
    single-core vector        8.85 GB/sec
```



