/*  This is a helper class for OutputProfileInspector.m  4/93  */

#import "ColorLinks.h"
 

/*  These are the reference colors the user will mix print colors against.  When printed, 
     they will be run thru the current transform (by PrinterChipsView) 
     Namely, RcHn reference colors...		                                             */

ColorV referenceRGB [36] =
{
{1.0, 0.0, 0.0, 0.0},
{0.0, 1.0, 0.0, 0.0},
{0.0, 0.0, 1.0, 0.0},
{0.0, 1.0, 1.0, 0.0},
{1.0, 0.0, 1.0, 0.0},  
{1.0, 1.0, 0.0, 0.0},  

{1.0, .5, .5, 0.0},
{.5, 1.0, .5, 0.0},
{.5, .5, 1.0, 0.0},
{.5, 1.0, 1.0, 0.0},
{1.0, .5, 1.0, 0.0},  
{1.0, 1.0, .5, 0.0},  

{0.5, 0.0, 0.0, 0.0},
{0.0, 0.5, 0.0, 0.0},
{0.0, 0.0, 0.5, 0.0},
{0.0, 0.5, 0.5, 0.0},
{0.5, 0.0, 0.5, 0.0},  
{0.5, 0.5, 0.0, 0.0},  

{1.0, 0.5, 0.0, 0.0},
{0.0, 1.0, 0.5, 0.0},
{0.5, 0.0, 1.0, 0.0},
{0.0, 0.5, 1.0, 0.0},
{1.0, 0.0, 0.5, 0.0},  
{0.5, 1.0, 0.0, 0.0},  

{1.0, 0.75, 0.5, 0.0},
{0.5, 1.0, 0.75, 0.0},
{0.75, 0.5, 1.0, 0.0},
{0.5, 0.75, 1.0, 0.0},
{1.0, 0.5, 0.75, 0.0},  
{0.75, 1.0, 0.5, 0.0},  

{0.5, 0.25, 0.0, 0.0},
{0.0, 0.5, 0.25, 0.0},
{0.25, 0.0, 0.5, 0.0},
{0.0, 0.25, 0.5, 0.0},
{0.5, 0.0, 0.25, 0.0},  
{0.25, 0.5, 0.0, 0.0}  
};


ColorV altReferenceRGB [36] =
{
{0.90, 0.09, 0.09, 0.0},
{0.09, 0.90, 0.09, 0.0},
{0.09, 0.09, 0.90, 0.0},
{0.09, 0.90, 0.90, 0.0},
{0.90, 0.09, 0.90, 0.0},  
{0.90, 0.90, 0.09, 0.0}, 

{0.91, 0.45, 0.45, 0.0},
{0.45, 0.91, 0.45, 0.0},
{0.45, 0.45, 0.91, 0.0},
{0.45, 0.91, 0.91, 0.0},
{0.91, 0.45, 0.91, 0.0},  
{0.91, 0.91, 0.45, 0.0},  

{0.50, 0.05, 0.05, 0.0},
{0.05, 0.50, 0.05, 0.0},
{0.05, 0.05, 0.50, 0.0},
{0.05, 0.50, 0.50, 0.0},
{0.50, 0.05, 0.50, 0.0},  
{0.50, 0.50, 0.05, 0.0},  

{0.90, 0.49, 0.09, 0.0},
{0.09, 0.90, 0.49, 0.0},
{0.49, 0.09, 0.90, 0.0},
{0.09, 0.49, 0.90, 0.0},
{0.90, 0.09, 0.49, 0.0},  
{0.49, 0.90, 0.09, 0.0},  

{0.90, 0.68, 0.45, 0.0},
{0.45, 0.90, 0.68, 0.0},
{0.68, 0.45, 0.90, 0.0},
{0.45, 0.68, 0.90, 0.0},
{0.90, 0.45, 0.68, 0.0},  
{0.68, 0.90, 0.45, 0.0},  

{0.50, 0.27, 0.05, 0.0},
{0.05, 0.50, 0.27, 0.0},
{0.27, 0.05, 0.50, 0.0},
{0.05, 0.27, 0.50, 0.0},
{0.50, 0.05, 0.27, 0.0},  
{0.27, 0.50, 0.05, 0.0}  
};

ColorV bigReferenceRGB [NUM_RCHNCOLORS];

ColorV sdsnReferenceRGB [216] =
{
{.1804,   .2717,   .5214, 	0.0},
{.2735,   .3710,   .6261, 	0.0},
{.3650,   .4574,   .7117, 	0.0},
{.4697,   .5404,   .7691, 	0.0},
{.5972,   .6194,   .8144, 	0.0},
{.6898,   .6610,   .8604, 	0.0},
{.2107,   .3078,   .5775, 	0.0},
{.3133,   .4164,   .6881, 	0.0},
{.4307,   .5263,   .7760, 	0.0},
{.5507,   .6339,   .8548, 	0.0},
{.6918,   .7498,   .9349, 	0.0},
{.8384,   .8699,   .9999, 	0.0},
{.0926,   .1226,   .3273, 	0.0},
{.1475,   .1624,   .3890, 	0.0},
{.1996,   .1861,   .4216, 	0.0},
{.2799,   .2210,   .4518, 	0.0},
{.3673,   .2562,   .4719, 	0.0},
{.4012,   .2618,   .4757, 	0.0},
{.1329,   .1997,   .4398, 	0.0},
{.2262,   .2937,   .5593, 	0.0},
{.3133,   .3604,   .6247, 	0.0},
{.4127,   .4135,   .6722, 	0.0},
{.5421,   .4777,   .7282, 	0.0},
{.5905,   .4963,   .7442, 	0.0},
{.0331,   .0203,   .1297, 	0.0},
{.0467,   .0254,   .1431, 	0.0},
{.0831,   .0394,   .1578, 	0.0},
{.1415,   .0635,   .1704, 	0.0},
{.2041,   .0883,   .1749, 	0.0},
{.2155,   .0919,   .1761, 	0.0},
{.0475,   .0404,   .1878, 	0.0},
{.0701,   .0496,   .2122, 	0.0},
{.1225,   .0744,   .2458, 	0.0},
{.1859,   .0992,   .2607, 	0.0},
{.2551,   .1246,   .2669, 	0.0},
{.2735,   .1333,   .2755, 	0.0},
{.1859,   .2788,   .5222, 	0.0},
{.2743,   .3740,   .6084, 	0.0},
{.3719,   .4676,   .6679, 	0.0},
{.4788,   .5511,   .7033, 	0.0},
{.5889,   .6117,   .7372, 	0.0},
{.6642,   .6507,   .7310, 	0.0},
{.1866,   .2867,   .5009, 	0.0},
{.2831,   .3939,   .5831, 	0.0},
{.3916,   .5025,   .6394, 	0.0},
{.4923,   .5966,   .6809, 	0.0},
{.6341,   .7190,   .7393, 	0.0},
{.7733,   .8386,   .7341, 	0.0},
{.0970,   .1252,   .3327, 	0.0},
{.1528,   .1661,   .3948, 	0.0},
{.2044,   .1897,   .4280, 	0.0},
{.2891,   .2325,   .4629, 	0.0},
{.4034,   .2945,   .5153, 	0.0},
{.4189,   .2848,   .4952, 	0.0},
{.1516,   .2201,   .4679, 	0.0},
{.2363,   .3026,   .5681, 	0.0},
{.3143,   .3594,   .6127, 	0.0},
{.4022,   .4013,   .6409, 	0.0},
{.5612,   .5107,   .7261, 	0.0},
{.5846,   .5035,   .6928, 	0.0},
{.0321,   .0191,   .1276, 	0.0},
{.0487,   .0255,   .1423, 	0.0},
{.0863,   .0403,   .1561, 	0.0},
{.1502,   .0665,   .1682, 	0.0},
{.2135,   .0911,   .1738, 	0.0},
{.2133,   .0905,   .1721, 	0.0},
{.0494,   .0437,   .1952, 	0.0},
{.0782,   .0577,   .2289, 	0.0},
{.1347,   .0862,   .2687, 	0.0},
{.2126,   .1216,   .2994, 	0.0},
{.2971,   .1571,   .3234, 	0.0},
{.2964,   .1525,   .3129, 	0.0},
{.1576,   .2609,   .3958, 	0.0},
{.2360,   .3516,   .4465, 	0.0},
{.3204,   .4395,   .4628, 	0.0},
{.4188,   .5196,   .4758, 	0.0},
{.5585,   .6123,   .5219, 	0.0},
{.6176,   .6364,   .4911, 	0.0},
{.1450,   .2569,   .3330, 	0.0},
{.2329,   .3636,   .3841, 	0.0},
{.3240,   .4608,   .3936, 	0.0},
{.4326,   .5678,   .4152, 	0.0},
{.6072,   .7197,   .4536, 	0.0},
{.7163,   .8167,   .4280, 	0.0},
{.0977,   .1250,   .3182, 	0.0},
{.1566,   .1737,   .3871, 	0.0},
{.2203,   .2146,   .4380, 	0.0},
{.3234,   .2774,   .4614, 	0.0},
{.4083,   .3126,   .4455, 	0.0},
{.4154,   .3011,   .4163, 	0.0},
{.1388,   .2101,   .3940, 	0.0},
{.2228,   .2943,   .4736, 	0.0},
{.3159,   .3751,   .5191, 	0.0},
{.4282,   .4567,   .5491, 	0.0},
{.5228,   .4921,   .5180, 	0.0},
{.5452,   .4955,   .4872, 	0.0},
{.0313,   .0185,   .1251, 	0.0},
{.0500,   .0255,   .1406, 	0.0},
{.0912,   .0421,   .1555, 	0.0},
{.1591,   .0701,   .1680, 	0.0},
{.2200,   .0959,   .1859, 	0.0},
{.2110,   .0895,   .1668, 	0.0},
{.0519,   .0482,   .2044, 	0.0},
{.0952,   .0775,   .2671, 	0.0},
{.1680,   .1212,   .3261, 	0.0},
{.2709,   .1742,   .3792, 	0.0},
{.3540,   .2125,   .3935, 	0.0},
{.3312,   .1898,   .3471, 	0.0},
{.1181,   .2347,   .2185, 	0.0},
{.1886,   .3224,   .2427, 	0.0},
{.2641,   .4030,   .2315, 	0.0},
{.3809,   .5033,   .2613, 	0.0},
{.5241,   .6044,   .2880, 	0.0},
{.6022,   .6529,   .2755, 	0.0},
{.0959,   .2175,   .1311, 	0.0},
{.1791,   .3260,   .1544, 	0.0},
{.2713,   .4248,   .1709, 	0.0},
{.4069,   .5605,   .2061, 	0.0},
{.5843,   .7144,   .2121, 	0.0},
{.6814,   .7979,   .2244, 	0.0},
{.0904,   .1361,   .2205, 	0.0},
{.1522,   .1887,   .2845, 	0.0},
{.2166,   .2384,   .2854, 	0.0},
{.2828,   .2584,   .2744, 	0.0},
{.3628,   .2885,   .2405, 	0.0},
{.3723,   .2864,   .2279, 	0.0},
{.1124,   .2032,   .2358, 	0.0},
{.1873,   .2786,   .2851, 	0.0},
{.2735,   .3559,   .2974, 	0.0},
{.3710,   .4216,   .3186, 	0.0},
{.4819,   .4769,   .3021, 	0.0},
{.5092,   .4870,   .3021, 	0.0},
{.0310,   .0181,   .1234, 	0.0},
{.0520,   .0261,   .1406, 	0.0},
{.0972,   .0449,   .1552, 	0.0},
{.1817,   .0854,   .1748, 	0.0},
{.2262,   .1056,   .1653, 	0.0},
{.2007,   .0879,   .1225, 	0.0},
{.0520,   .0543,   .1865, 	0.0},
{.1015,   .0886,   .2596, 	0.0},
{.1757,   .1384,   .2875, 	0.0},
{.2487,   .1720,   .2717, 	0.0},
{.3301,   .2118,   .2635, 	0.0},
{.3153,   .1947,   .2425, 	0.0},
{.0739,   .1861,   .0626, 	0.0},
{.1403,   .2767,   .0744, 	0.0},
{.2152,   .3593,   .0860, 	0.0},
{.3429,   .4761,   .1228, 	0.0},
{.5009,   .5948,   .1224, 	0.0},
{.5747,   .6367,   .1146, 	0.0},
{.0632,   .1697,   .0524, 	0.0},
{.1449,   .2846,   .0610, 	0.0},
{.2387,   .3910,   .0694, 	0.0},
{.3807,   .5327,   .0811, 	0.0},
{.5589,   .6865,   .0856, 	0.0},
{.6587,   .7716,   .1009, 	0.0},
{.0659,   .1284,   .0808, 	0.0},
{.1235,   .1819,   .1184, 	0.0},
{.1801,   .2147,   .1320, 	0.0},
{.2267,   .2168,   .1015, 	0.0},
{.3336,   .2713,   .0901, 	0.0},
{.3370,   .2708,   .0833, 	0.0},
{.0751,   .1749,   .0745, 	0.0},
{.1393,   .2440,   .0999, 	0.0},
{.2139,   .3055,   .1266, 	0.0},
{.3167,   .3795,   .1362, 	0.0},
{.4519,   .4591,   .1310, 	0.0},
{.4776,   .4758,   .1361, 	0.0},
{.0268,   .0196,   .0924, 	0.0},
{.0554,   .0327,   .0978, 	0.0},
{.0879,   .0459,   .0634, 	0.0},
{.1469,   .0715,   .0480, 	0.0},
{.1869,   .0897,   .0441, 	0.0},
{.1829,   .0842,   .0494, 	0.0},
{.0368,   .0620,   .0631, 	0.0},
{.1020,   .1144,   .1329, 	0.0},
{.1483,   .1267,   .1194, 	0.0},
{.1981,   .1419,   .0859, 	0.0},
{.2755,   .1845,   .0739, 	0.0},
{.2754,   .1801,   .0874, 	0.0},
{.0592,   .1625,   .0539, 	0.0},
{.1259,   .2569,   .0576, 	0.0},
{.2040,   .3492,   .0598, 	0.0},
{.3302,   .4667,   .0677, 	0.0},
{.4991,   .5940,   .0664, 	0.0},
{.5739,   .6354,   .0645, 	0.0},
{.0539,   .1535,   .0490, 	0.0},
{.1322,   .2681,   .0565, 	0.0},
{.2336,   .3855,   .0665, 	0.0},
{.3713,   .5208,   .0671, 	0.0},
{.5447,   .6700,   .0667, 	0.0},
{.6558,   .7632,   .0738, 	0.0},
{.0545,   .1242,   .0485, 	0.0},
{.1066,   .1707,   .0461, 	0.0},
{.1606,   .1994,   .0402, 	0.0},
{.2049,   .1949,   .0298, 	0.0},
{.3199,   .2591,   .0307, 	0.0},
{.3240,   .2631,   .0301, 	0.0},
{.0584,   .1549,   .0487, 	0.0},
{.1168,   .2226,   .0521, 	0.0},
{.1905,   .2882,   .0552, 	0.0},
{.2719,   .3315,   .0501, 	0.0},
{.4444,   .4513,   .0528, 	0.0},
{.4687,   .4723,   .0549, 	0.0},
{.0115,   .0135,   .0149, 	0.0},
{.0406,   .0278,   .0150, 	0.0},
{.0744,   .0412,   .0099, 	0.0},
{.1499,   .0734,   .0085, 	0.0},
{.1699,   .0813,   .0081, 	0.0},
{.1665,   .0786,   .0073, 	0.0},
{.0346,   .0679,   .0342, 	0.0},
{.0831,   .1030,   .0325, 	0.0},
{.1217,   .1058,   .0261, 	0.0},
{.1782,   .1262,   .0205, 	0.0},
{.2556,   .1712,   .0228, 	0.0},
{.2570,   .1718,   .0251, 	0.0}
};

ColorV defaultInkmodel [320] =		// This is a Matchprint Inkmodel
{
{0.060,	0.060,	0.060,	0.0},
{0.430,	0.230,	0.120,	0.0},
{0.760,	0.360,	0.160,	0.0},
{1.240,	0.460,	0.200,	0.0},
{0.120,	0.460,	0.300,	0.0},
{0.450,	0.550,	0.330,	0.0},
{0.770,	0.630,	0.350,	0.0},
{1.250,	0.730,	0.380,	0.0},
{0.160,	0.830,	0.480,	0.0},
{0.480,	0.900,	0.500,	0.0},
{0.810,	0.980,	0.530,	0.0},
{1.280,	1.050,	0.560,	0.0},
{0.200,	1.500,	0.660,	0.0},
{0.500,	1.550,	0.680,	0.0},
{0.820,	1.590,	0.700,	0.0},
{1.280,	1.640,	0.720,	0.0},
{0.070,	0.080,	0.380,	0.0},
{0.420,	0.250,	0.420,	0.0},
{0.760,	0.370,	0.460,	0.0},
{1.240,	0.480,	0.480,	0.0},
{0.120,	0.450,	0.530,	0.0},
{0.450,	0.560,	0.570,	0.0},
{0.780,	0.650,	0.600,	0.0},
{1.250,	0.730,	0.610,	0.0},
{0.160,	0.830,	0.680,	0.0},
{0.480,	0.910,	0.700,	0.0},
{0.800,	0.980,	0.730,	0.0},
{1.270,	1.050,	0.750,	0.0},
{0.200,	1.510,	0.830,	0.0},
{0.510,	1.550,	0.860,	0.0},
{0.820,	1.610,	0.880,	0.0},
{1.290,	1.660,	0.900,	0.0},
{0.070,	0.090,	0.700,	0.0},
{0.420,	0.260,	0.730,	0.0},
{0.760,	0.380,	0.750,	0.0},
{1.250,	0.500,	0.780,	0.0},
{0.120,	0.470,	0.810,	0.0},
{0.460,	0.570,	0.840,	0.0},
{0.780,	0.660,	0.860,	0.0},
{1.280,	0.760,	0.890,	0.0},
{0.170,	0.840,	0.930,	0.0},
{0.490,	0.920,	0.960,	0.0},
{0.810,	1.000,	0.980,	0.0},
{1.290,	1.080,	1.010,	0.0},
{0.210,	1.520,	1.070,	0.0},
{0.520,	1.570,	1.090,	0.0},
{0.830,	1.630,	1.110,	0.0},
{1.310,	1.690,	1.130,	0.0},
{0.080,	0.110,	1.110,	0.0},
{0.430,	0.270,	1.130,	0.0},
{0.770,	0.400,	1.150,	0.0},
{1.280,	0.530,	1.170,	0.0},
{0.130,	0.480,	1.200,	0.0},
{0.460,	0.580,	1.210,	0.0},
{0.790,	0.680,	1.220,	0.0},
{1.290,	0.780,	1.250,	0.0},
{0.180,	0.850,	1.280,	0.0},
{0.490,	0.930,	1.290,	0.0},
{0.820,	1.010,	1.310,	0.0},
{1.310,	1.100,	1.340,	0.0},
{0.220,	1.540,	1.370,	0.0},
{0.520,	1.590,	1.390,	0.0},
{0.840,	1.640,	1.390,	0.0},
{1.340,	1.700,	1.430,	0.0},
{0.450,	0.450,	0.440,	0.0},
{0.710,	0.560,	0.480,	0.0},
{1.000,	0.650,	0.500,	0.0},
{1.420,	0.740,	0.530,	0.0},
{0.480,	0.730,	0.600,	0.0},
{0.740,	0.810,	0.630,	0.0},
{1.020,	0.890,	0.650,	0.0},
{1.440,	0.970,	0.670,	0.0},
{0.510,	1.060,	0.760,	0.0},
{0.760,	1.120,	0.780,	0.0},
{1.030,	1.180,	0.790,	0.0},
{1.440,	1.250,	0.820,	0.0},
{0.540,	1.660,	0.920,	0.0},
{0.790,	1.700,	0.940,	0.0},
{1.050,	1.730,	0.950,	0.0},
{1.460,	1.770,	0.970,	0.0},
{0.430,	0.440,	0.660,	0.0},
{0.700,	0.550,	0.680,	0.0},
{0.980,	0.650,	0.720,	0.0},
{1.400,	0.740,	0.740,	0.0},
{0.470,	0.730,	0.790,	0.0},
{0.730,	0.810,	0.810,	0.0},
{1.000,	0.890,	0.830,	0.0},
{1.420,	0.970,	0.860,	0.0},
{0.500,	1.060,	0.910,	0.0},
{0.750,	1.110,	0.930,	0.0},
{1.020,	1.180,	0.950,	0.0},
{1.440,	1.250,	0.980,	0.0},
{0.530,	1.670,	1.060,	0.0},
{0.770,	1.680,	1.070,	0.0},
{1.040,	1.720,	1.090,	0.0},
{1.440,	1.770,	1.110,	0.0},
{0.430,	0.450,	0.930,	0.0},
{0.700,	0.560,	0.960,	0.0},
{0.990,	0.660,	0.970,	0.0},
{1.430,	0.760,	1.000,	0.0},
{0.470,	0.740,	1.030,	0.0},
{0.730,	0.820,	1.060,	0.0},
{1.010,	0.900,	1.080,	0.0},
{1.440,	0.990,	1.100,	0.0},
{0.510,	1.070,	1.150,	0.0},
{0.760,	1.140,	1.170,	0.0},
{1.030,	1.200,	1.180,	0.0},
{1.450,	1.270,	1.200,	0.0},
{0.530,	1.670,	1.270,	0.0},
{0.780,	1.720,	1.290,	0.0},
{1.050,	1.740,	1.290,	0.0},
{1.460,	1.780,	1.310,	0.0},
{0.440,	0.460,	1.300,	0.0},
{0.710,	0.580,	1.320,	0.0},
{1.000,	0.680,	1.340,	0.0},
{1.450,	0.780,	1.350,	0.0},
{0.470,	0.750,	1.370,	0.0},
{0.740,	0.830,	1.390,	0.0},
{1.020,	0.910,	1.390,	0.0},
{1.460,	1.000,	1.420,	0.0},
{0.500,	1.060,	1.440,	0.0},
{0.760,	1.140,	1.460,	0.0},
{1.040,	1.210,	1.470,	0.0},
{1.480,	1.280,	1.490,	0.0},
{0.530,	1.670,	1.520,	0.0},
{0.790,	1.710,	1.540,	0.0},
{1.060,	1.750,	1.550,	0.0},
{1.490,	1.800,	1.570,	0.0},
{0.890,	0.890,	0.890,	0.0},
{1.090,	0.970,	0.910,	0.0},
{1.330,	1.040,	0.920,	0.0},
{1.660,	1.110,	0.940,	0.0},
{0.910,	1.110,	1.000,	0.0},
{1.100,	1.160,	1.010,	0.0},
{1.330,	1.230,	1.030,	0.0},
{1.670,	1.290,	1.040,	0.0},
{0.930,	1.380,	1.120,	0.0},
{1.120,	1.420,	1.130,	0.0},
{1.340,	1.460,	1.140,	0.0},
{1.680,	1.530,	1.160,	0.0},
{0.940,	1.840,	1.240,	0.0},
{1.140,	1.870,	1.260,	0.0},
{1.360,	1.880,	1.260,	0.0},
{1.690,	1.920,	1.290,	0.0},
{0.870,	0.890,	1.050,	0.0},
{1.070,	0.960,	1.060,	0.0},
{1.300,	1.020,	1.080,	0.0},
{1.660,	1.100,	1.100,	0.0},
{0.900,	1.110,	1.150,	0.0},
{1.090,	1.160,	1.160,	0.0},
{1.320,	1.220,	1.180,	0.0},
{1.660,	1.300,	1.200,	0.0},
{0.920,	1.370,	1.250,	0.0},
{1.110,	1.420,	1.270,	0.0},
{1.340,	1.470,	1.280,	0.0},
{1.680,	1.530,	1.300,	0.0},
{0.940,	1.840,	1.370,	0.0},
{1.140,	1.860,	1.380,	0.0},
{1.360,	1.880,	1.390,	0.0},
{1.690,	1.910,	1.410,	0.0},
{0.870,	0.890,	1.250,	0.0},
{1.080,	0.970,	1.270,	0.0},
{1.310,	1.040,	1.280,	0.0},
{1.650,	1.110,	1.290,	0.0},
{0.890,	1.110,	1.330,	0.0},
{1.100,	1.180,	1.360,	0.0},
{1.330,	1.240,	1.380,	0.0},
{1.670,	1.310,	1.380,	0.0},
{0.920,	1.380,	1.430,	0.0},
{1.120,	1.440,	1.450,	0.0},
{1.360,	1.500,	1.470,	0.0},
{1.700,	1.560,	1.480,	0.0},
{0.940,	1.850,	1.520,	0.0},
{1.140,	1.880,	1.540,	0.0},
{1.380,	1.900,	1.560,	0.0},
{1.710,	1.920,	1.560,	0.0},
{0.850,	0.880,	1.530,	0.0},
{1.070,	0.970,	1.550,	0.0},
{1.320,	1.050,	1.560,	0.0},
{1.680,	1.130,	1.580,	0.0},
{0.880,	1.110,	1.590,	0.0},
{1.100,	1.170,	1.600,	0.0},
{1.340,	1.250,	1.650,	0.0},
{1.680,	1.320,	1.630,	0.0},
{0.920,	1.390,	1.660,	0.0},
{1.120,	1.430,	1.650,	0.0},
{1.350,	1.490,	1.650,	0.0},
{1.700,	1.550,	1.680,	0.0},
{0.940,	1.850,	1.720,	0.0},
{1.150,	1.870,	1.720,	0.0},
{1.370,	1.890,	1.720,	0.0},
{1.720,	1.920,	1.730,	0.0},
{1.720,	1.730,	1.730,	0.0},
{1.830,	1.767,	1.730,	0.0},
{1.940,	1.803,	1.730,	0.0},
{2.050,	1.840,	1.730,	0.0},
{1.723,	1.847,	1.770,	0.0},
{1.832,	1.870,	1.769,	0.0},
{1.941,	1.893,	1.768,	0.0},
{2.050,	1.917,	1.767,	0.0},
{1.727,	1.963,	1.810,	0.0},
{1.834,	1.973,	1.808,	0.0},
{1.942,	1.983,	1.806,	0.0},
{2.050,	1.993,	1.803,	0.0},
{1.730,	2.080,	1.850,	0.0},
{1.837,	2.077,	1.847,	0.0},
{1.943,	2.073,	1.843,	0.0},
{2.050,	2.070,	1.840,	0.0},
{1.703,	1.730,	1.790,	0.0},
{1.819,	1.766,	1.790,	0.0},
{1.934,	1.801,	1.790,	0.0},
{2.050,	1.837,	1.790,	0.0},
{1.712,	1.850,	1.821,	0.0},
{1.828,	1.874,	1.827,	0.0},
{1.943,	1.897,	1.833,	0.0},
{2.059,	1.921,	1.839,	0.0},
{1.721,	1.970,	1.852,	0.0},
{1.837,	1.982,	1.864,	0.0},
{1.952,	1.994,	1.876,	0.0},
{2.068,	2.006,	1.888,	0.0},
{1.730,	2.090,	1.883,	0.0},
{1.846,	2.090,	1.901,	0.0},
{1.961,	2.090,	1.919,	0.0},
{2.077,	2.090,	1.937,	0.0},
{1.687,	1.730,	1.850,	0.0},
{1.808,	1.764,	1.850,	0.0},
{1.929,	1.799,	1.850,	0.0},
{2.050,	1.833,	1.850,	0.0},
{1.701,	1.853,	1.872,	0.0},
{1.823,	1.877,	1.885,	0.0},
{1.946,	1.901,	1.898,	0.0},
{2.068,	1.926,	1.911,	0.0},
{1.716,	1.977,	1.894,	0.0},
{1.839,	1.990,	1.920,	0.0},
{1.962,	2.004,	1.946,	0.0},
{2.086,	2.018,	1.972,	0.0},
{1.730,	2.100,	1.917,	0.0},
{1.854,	2.103,	1.956,	0.0},
{1.979,	2.107,	1.994,	0.0},
{2.103,	2.110,	2.033,	0.0},
{1.670,	1.730,	1.910,	0.0},
{1.797,	1.763,	1.910,	0.0},
{1.923,	1.797,	1.910,	0.0},
{2.050,	1.830,	1.910,	0.0},
{1.690,	1.857,	1.923,	0.0},
{1.819,	1.881,	1.943,	0.0},
{1.948,	1.906,	1.963,	0.0},
{2.077,	1.930,	1.983,	0.0},
{1.710,	1.983,	1.937,	0.0},
{1.841,	1.999,	1.977,	0.0},
{1.972,	2.014,	2.017,	0.0},
{2.103,	2.030,	2.057,	0.0},
{1.730,	2.110,	1.950,	0.0},
{1.863,	2.117,	2.010,	0.0},
{1.997,	2.123,	2.070,	0.0},
{2.130,	2.130,	2.130,	0.0},
{0.060,	0.060,	0.060,	0.0},
{0.137,	0.097,	0.074,	0.0},
{0.213,	0.133,	0.086,	0.0},
{0.287,	0.167,	0.098,	0.0},
{0.359,	0.199,	0.110,	0.0},
{0.430,	0.230,	0.120,	0.0},
{0.496,	0.259,	0.129,	0.0},
{0.558,	0.286,	0.137,	0.0},
{0.619,	0.312,	0.145,	0.0},
{0.685,	0.337,	0.152,	0.0},
{0.760,	0.360,	0.160,	0.0},
{0.844,	0.382,	0.168,	0.0},
{0.934,	0.404,	0.176,	0.0},
{1.030,	0.424,	0.184,	0.0},
{1.132,	0.442,	0.192,	0.0},
{1.240,	0.460,	0.200,	0.0},
{0.060,	0.060,	0.060,	0.0},
{0.074,	0.142,	0.113,	0.0},
{0.086,	0.224,	0.163,	0.0},
{0.098,	0.304,	0.211,	0.0},
{0.110,	0.382,	0.257,	0.0},
{0.120,	0.460,	0.300,	0.0},
{0.129,	0.531,	0.340,	0.0},
{0.137,	0.596,	0.376,	0.0},
{0.145,	0.662,	0.411,	0.0},
{0.152,	0.737,	0.445,	0.0},
{0.160,	0.830,	0.480,	0.0},
{0.168,	0.940,	0.516,	0.0},
{0.176,	1.062,	0.552,	0.0},
{0.184,	1.196,	0.588,	0.0},
{0.192,	1.342,	0.624,	0.0},
{0.200,	1.500,	0.660,	0.0},
{0.060,	0.060,	0.060,	0.0},
{0.063,	0.065,	0.124,	0.0},
{0.065,	0.069,	0.188,	0.0},
{0.067,	0.073,	0.252,	0.0},
{0.069,	0.077,	0.316,	0.0},
{0.070,	0.080,	0.380,	0.0},
{0.070,	0.082,	0.443,	0.0},
{0.070,	0.084,	0.504,	0.0},
{0.070,	0.086,	0.566,	0.0},
{0.070,	0.088,	0.630,	0.0},
{0.070,	0.090,	0.700,	0.0},
{0.071,	0.093,	0.775,	0.0},
{0.073,	0.097,	0.853,	0.0},
{0.075,	0.101,	0.935,	0.0},
{0.077,	0.105,	1.021,	0.0},
{0.080,	0.110,	1.110,	0.0},
{0.060,	0.060,	0.060,	0.0},
{0.134,	0.134,	0.130,	0.0},
{0.210,	0.210,	0.204,	0.0},
{0.288,	0.288,	0.280,	0.0},
{0.368,	0.368,	0.358,	0.0},
{0.450,	0.450,	0.440,	0.0},
{0.529,	0.528,	0.519,	0.0},
{0.604,	0.603,	0.596,	0.0},
{0.684,	0.683,	0.679,	0.0},
{0.776,	0.776,	0.774,	0.0},
{0.890,	0.890,	0.890,	0.0},
{1.025,	1.026,	1.027,	0.0},
{1.175,	1.178,	1.179,	0.0},
{1.341,	1.346,	1.347,	0.0},
{1.523,	1.530,	1.531,	0.0},
{1.720,	1.730,	1.730,	0.00}
};



@implementation ColorLinks

- (int) makeMnMdLink: (float) redMonGamma: (float) greenMonGamma: (float) blueMonGamma
{
	MnMdPars 	MnMd;
		
	NX_DURING

	MnMd.compand.type 	= CI_CT_GAMMA;
	MnMd.compand.pars [0] = redMonGamma;
	MnMd.compand.pars [1] = greenMonGamma;
	MnMd.compand.pars [2] = blueMonGamma;	
 
	if (CiLinkCreate (CI_LT_MNMD, &MnMd) != CE_OK)
		NX_RAISE (Err_TransformError8, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	NX_ENDHANDLER 
	return 0;
}

- (int) makeRcMnLink: (float) redChroma_x: (float) redChroma_y: (float) greenChroma_x:
	(float) greenChroma_y: (float) blueChroma_x: (float) blueChroma_y: (float) whitePoint

{
	RcMnPars	RcMn;

	NX_DURING

	RcMn.prim [0] [0] = redChroma_x;	
	RcMn.prim [0] [1] = redChroma_y;	
	RcMn.prim [0] [2] = 0;	

	RcMn.prim [1] [0] = greenChroma_x;	
	RcMn.prim [1] [1] = greenChroma_y;	
	RcMn.prim [1] [2] = 0;	

	RcMn.prim [2] [0] = blueChroma_x;	
	RcMn.prim [2] [1] = blueChroma_y;	
	RcMn.prim [2] [2] = 0;	
	
	RcMn.refWhite = (ulong) whitePoint;

	if (CiLinkCreate (CI_LT_RCMN, &RcMn) != CE_OK)
		NX_RAISE (Err_TransformError8, NULL, NULL);
		
	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	NX_ENDHANDLER 
	return 0;
}

- (int) makeSdSnLink: (ColorV *) colors: (int)  numColors
{
	SdSnPars	SdSn;
	int	i, j;

	NX_DURING
	memset (&SdSn, 0, sizeof (SdSnPars));
	SdSn.set.nPairs = numColors;

	NX_MALLOC (SdSn.set.pairs, ColorPair, SdSn.set.nPairs);
	if (! SdSn.set.pairs)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	for (i = 0; i < numColors; i++)
	{
		for (j = 0; j < 4; j++)
		{
			SdSn.set.pairs [i].reference [j] = ((Flt) i / 15);
			SdSn.set.pairs [i].response [j] = colors [i] [j];
		}
	}	

	if (CiLinkCreate (CI_LT_SDSN, &SdSn) != CE_OK)
		NX_RAISE (Err_TransformError8, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (SdSn.set.pairs)
		NX_FREE (SdSn.set.pairs);

	NX_ENDHANDLER
	return 0;
}

- (int) makeSnRcLink: (ColorV *) colors: (int)  numColors
{
	SnRcPars	SnRc;
	int	i, j;

	NX_DURING
	memset (&SnRc, 0, sizeof (SnRcPars));
	SnRc.set.nPairs = numColors;

	NX_MALLOC (SnRc.set.pairs, ColorPair, SnRc.set.nPairs);
	if (! SnRc.set.pairs)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	for (i = 0; i < numColors; i++)
	{
		CiCmsRcsColor (CI_XYZ_TO_RCS, sdsnReferenceRGB [i], SnRc.set.pairs [i].reference);
		for (j = 0; j < 4; j++)
			SnRc.set.pairs [i].response [j] = colors [i] [j];
	}	

	if (CiLinkCreate (CI_LT_SNRC, &SnRc) != CE_OK)
		NX_RAISE (Err_TransformError8, NULL, NULL);

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (SnRc.set.pairs)
		NX_FREE (SnRc.set.pairs);

	NX_ENDHANDLER
	return 0;
}

- (int) addRcHnLink: (ColorV *) rcsColors: (ColorV *) referenceColors: (BOOL *) rchnColorsUsed
				: (int)  numColors: (int) direction
{
	RcHnPars *RcHn = NULL;
	int		i;
	int		numPairs;
	ColorV	colorV;

	NX_DURING
	NX_MALLOC (RcHn, RcHnPars, 1);
	if (! RcHn)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	memset (RcHn, 0, sizeof (RcHnPars));

	RcHn -> set.nPairs = numColors;
	NX_MALLOC (RcHn -> set.pairs, ColorPair, RcHn -> set.nPairs);
	memset (RcHn -> set.pairs, 0, (RcHn -> set.nPairs * sizeof (ColorPair)));
	
	numPairs = 0;

	for (i = 0; i < numColors; i++)
	{
		/*  First see if this is a color we should include  */

		if (rchnColorsUsed [i])
		{
			/*  Setup reference and response colors  */

			memcpy (colorV, referenceColors [i], sizeof (ColorV));
			RcHn -> set.pairs [numPairs].reference [RGB_R] = colorV [RGB_R];
			RcHn -> set.pairs [numPairs].reference [RGB_G] = colorV [RGB_G];
			RcHn -> set.pairs [numPairs].reference [RGB_B] = colorV [RGB_B];
 
			memcpy (colorV, rcsColors [i], sizeof (ColorV));

 			RcHn -> set.pairs [numPairs].response [RGB_R] = colorV [0];
 			RcHn -> set.pairs [numPairs].response [RGB_G] = colorV [1];
 			RcHn -> set.pairs [numPairs].response [RGB_B] = colorV [2];

			numPairs++;
		}
	}

	/*  Fix up actual number of pairs and close monitor link  */

	RcHn -> set.nPairs = numPairs;

   	if (CiLinkCreate (CI_LT_RCHN, RcHn) != CE_OK)
		NX_RAISE (Err_TransformError10, NULL, NULL);
		
	#ifdef WRITELINKS
	CiLinkWrite ("/me/RcHn.link");
	#endif

	#ifdef LOGERROR
	{
		char szBuffer [80];
		sprintf (szBuffer, "Included %d pairs", numPairs);
		NXLogError(szBuffer);
	}
	#endif

	if (direction == CI_FDIR_INVERSE)
		CiLinkFDirSet (CI_FDIR_INVERSE);

 	CiLinkAdd();
	CiLinkClose();

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (RcHn -> set.pairs)
		NX_FREE (RcHn -> set.pairs);
	if (RcHn)
		NX_FREE (RcHn);
	NX_ENDHANDLER
	return 0;
}


- (int) addHnPnLink: (OutputProfile *) profile: (int) direction: (BOOL) useRelaxedInkmodel
{
	int			i; 
	HnPnPars 	*HnPn 	= NULL;
	NXStream	*stream 	= NULL;
	struct		stat st;
	ColorV		*inkmodel;

	NX_DURING

	NX_MALLOC (HnPn, HnPnPars, 1);
	if (! HnPn)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	memset (HnPn, 0, sizeof (HnPnPars));

	HnPn -> blackPoint = profile -> blackPoint;

	HnPn -> Gcr.nSteps = 5;
	NX_MALLOC (HnPn -> Gcr.toneVal, Flt, HnPn -> Gcr.nSteps);
	if (! HnPn -> Gcr.toneVal)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
		
	HnPn -> Gcr.toneVal [0] = 0.00;
	HnPn -> Gcr.toneVal [1] = 0.25;
	HnPn -> Gcr.toneVal [2] = 0.50;
	HnPn -> Gcr.toneVal [3] = 0.75;
	HnPn -> Gcr.toneVal [4] = 1.00;

	NX_MALLOC (HnPn -> Gcr.gcrVal, Flt, HnPn -> Gcr.nSteps);
	if (! HnPn -> Gcr.gcrVal)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	for (i = 0; i < 5; i++)
		HnPn -> Gcr.gcrVal [i] = profile -> GCR [i];
	
	HnPn -> Ucr.TAC 			= profile -> TAC;
	HnPn -> Ucr.ucrType 		= CI_UCR_PRINT;
	HnPn -> Ucr.DotGain.nPairs 	= (int)
	HnPn -> Ucr.DotGain.pairs	= NULL;
	
	/*  Make a tempfile inkmodel  */

	NX_MALLOC (HnPn -> inkModel, char, MAXPATHSIZE);   // Need this?
	if (! HnPn -> inkModel)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
	
	strcpy (HnPn -> inkModel, "HEREXXXXXX");
	HnPn -> inkModel = mktemp (HnPn -> inkModel);
	stream = NXOpenMemory (NULL, 0, NX_READWRITE); 
	if (! stream)
		NX_RAISE (Err_FileOpenError, NULL, NULL);
	
	/*  Determine if we should use what's in the profile or the other (that hides degeneracies) */

	if (useRelaxedInkmodel)
	{
		inkmodel = defaultInkmodel;	

      		/*  Also set UCR / GCR / Blackpoint zero   */

		HnPn -> Ucr.TAC 			= 4.0;
		HnPn -> blackPoint		= 0.0;
		for (i = 0; i < 5; i++)
			HnPn -> Gcr.gcrVal [i] = 0.0;

	}
	else
	{
		inkmodel = profile -> inkDensities;	
	}

	for (i = 0; i < 320; i++)
	{
		NXPrintf (stream, "%7.3f\t%7.3f\t%7.3f\n",
		inkmodel [i] [0],
		inkmodel [i] [1],
		inkmodel [i] [2]);
	}

	if (NXSaveToFile (stream, HnPn -> inkModel) == -1)
		NX_RAISE (Err_FileWriteError, NULL, NULL);

	if (CiLinkCreate (CI_LT_HNPN, HnPn) != CE_OK)
		NX_RAISE (Err_TransformError11, NULL, NULL);

	#ifdef WRITELINKS
	CiLinkWrite ("/me/HnPn.link");
	#endif

	if (direction == CI_FDIR_INVERSE)
		CiLinkFDirSet (CI_FDIR_INVERSE);

 	CiLinkAdd();
	CiLinkClose();

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (stream)
		NXCloseMemory (stream, NX_FREEBUFFER);
	if (stat (HnPn -> inkModel, &st) == 0)
		unlink (HnPn -> inkModel);
	if (HnPn -> inkModel)
		NX_FREE (HnPn -> inkModel);
	if (HnPn -> Gcr.toneVal)
		NX_FREE (HnPn -> Gcr.toneVal);
	if (HnPn -> Gcr.gcrVal)
		NX_FREE (HnPn -> Gcr.gcrVal);
	if (HnPn)
		NX_FREE (HnPn);
	NX_ENDHANDLER
	return 0;
}

- (int) addPnPdLink: (OutputProfile *) profile: (int) direction
{
	int 	i;
	int	c;
	PnPdPars *PnPd = NULL;
	float	printRed, printGreen, printBlue, printGray;

	NX_DURING

	NX_MALLOC (PnPd, PnPdPars, 1);
	if (! PnPd)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	memset (PnPd, 0, sizeof (PnPdPars));

	PnPd -> set.nPairs = 16;
	NX_MALLOC (PnPd -> set.pairs,  ColorPair, PnPd -> set.nPairs);
	if (! PnPd -> set.pairs)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	for (i = 0; i < PnPd -> set.nPairs; i++)
	{
		for (c = 0; c < 4; c++)
			PnPd -> set.pairs [i].reference [c] = ((Flt) i / 15);
	
		printRed 		= (profile -> inkDensities [256 + i] [0]);
		printGreen 	= (profile -> inkDensities [256 + 16 + i] [1]);
		printBlue 	= (profile -> inkDensities [256 + 32 + i] [2]);
		printGray 	=  (profile -> inkDensities [256 + 48 + i] [0] +
		 				profile -> inkDensities [256 + 48 + i] [1] +
		 				 profile -> inkDensities [256 + 48 + i] [2]) / 3;


		PnPd -> set.pairs [i].response [CMYK_C]  = printRed;                         
		PnPd -> set.pairs [i].response [CMYK_M] = printGreen;
		PnPd -> set.pairs [i].response [CMYK_Y]  = printBlue;
		PnPd -> set.pairs [i].response [CMYK_K]  = printGray;
	}
		
	if (CiLinkCreate (CI_LT_PNPD, PnPd) != CE_OK)
		NX_RAISE (Err_TransformError12, NULL, NULL);

	#ifdef WRITELINKS
	CiLinkWrite ("/me/PnPd.link");
	#endif

	if (direction == CI_FDIR_INVERSE)
		CiLinkFDirSet (CI_FDIR_INVERSE);

   	CiLinkAdd();
	CiLinkClose ();

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (PnPd -> set.pairs)
		NX_FREE (PnPd -> set.pairs);
	if (PnPd)
		NX_FREE (PnPd);
	NX_ENDHANDLER
	return 0;
}
 
- (int) monitorColorToRCS: (ColorV) rcsColor: (NXColor) monitorColor: (MonitorSpace *) space
{
	float		red, green, blue, alpha;	
	ColorV	sourceV, destV;

	NX_DURING

	NXConvertColorToRGBA (monitorColor, &red, &green, &blue, &alpha);

	/*  For each monitor color, run MdMn -> MnRc  */

 	[self makeMnMdLink: space->redGamma: space-> greenGamma: space->blueGamma];
	
	sourceV [0]	= red;
	sourceV [1]	= green;
	sourceV [2]	= blue;

	CiLinkColor (sourceV, destV, CI_DIR_BACKWARD);
	CiLinkClose();	

 	[self makeRcMnLink: space -> redChroma_x: space -> redChroma_y: space -> greenChroma_x:
		space -> greenChroma_y: space -> blueChroma_x: space -> blueChroma_y: 
		space -> whitePoint];

	memcpy (sourceV, destV, sizeof (ColorV));
	
	if (CiLinkColor (sourceV, destV, CI_DIR_BACKWARD) != CE_OK)
		NX_RAISE (Err_TransformError7, NULL, NULL);
	
	CiLinkClose();	

	rcsColor [0] = destV [0]; 
	rcsColor [1] = destV [1]; 
	rcsColor [2] = destV [2]; 
	
	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER

	NX_ENDHANDLER
	return 0;
}

- (NXColor) rcsColorToMonitor: (ColorV) rcsColor: (MonitorSpace *) space
{
	ColorV	sourceV, destV;
	NXColor	monitorColor;

	NX_DURING

 	[self makeRcMnLink: space -> redChroma_x: space -> redChroma_y: space -> greenChroma_x:
		space -> greenChroma_y: space -> blueChroma_x: space -> blueChroma_y: 
		space -> whitePoint];

	sourceV [0] = rcsColor [0];
	sourceV [1] = rcsColor [1];
	sourceV [2] = rcsColor [2];
	sourceV [3] = 0;

	if (CiLinkColor (sourceV, destV, CI_DIR_FORWARD) != CE_OK)
		NX_RAISE (Err_TransformError7, NULL, NULL);

	CiLinkClose();

 	[self makeMnMdLink: space->redGamma: space-> greenGamma: space->blueGamma];

	memcpy (sourceV, destV, sizeof (ColorV));
	
	if (CiLinkColor (sourceV, destV, CI_DIR_FORWARD) != CE_OK)
		NX_RAISE (Err_TransformError7, NULL, NULL);
	
	monitorColor  = NXConvertRGBAToColor (destV [0], destV [1], 
									destV [2], NX_NOALPHA);

	CiLinkClose();	 

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER

	NX_ENDHANDLER
	return monitorColor;
}

 
- (int) addHnHdLink: (OutputProfile *) profile: (int) direction
{
	int 	i;
	HnHdPars *HnHd = NULL;

	NX_DURING

	NX_MALLOC (HnHd, HnHdPars, 1);
	if (! HnHd)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);
	
	memset (HnHd, 0, sizeof (HnHdPars));
	
	HnHd -> set.nPairs = 16;
	NX_MALLOC (HnHd -> set.pairs,  ColorPair, HnHd -> set.nPairs);
	if (! HnHd -> set.pairs)
		NX_RAISE (Err_MemoryAllocationError, NULL, NULL);

	for (i = 0; i < HnHd -> set.nPairs; i++)
	{
		HnHd -> set.pairs [i].reference [RGB_R] =
		HnHd -> set.pairs [i].reference [RGB_G] =
		HnHd -> set.pairs [i].reference [RGB_B] = (Flt) i / (Flt) (HnHd -> set.nPairs - 1);

		HnHd -> set.pairs [i].response [RGB_R] = profile -> inkDensities [i] [0];
		HnHd -> set.pairs [i].response [RGB_G] = profile -> inkDensities [i] [1];
		HnHd -> set.pairs [i].response [RGB_B] = profile -> inkDensities [i] [2]; 
	}
		
	if (CiLinkCreate (CI_LT_HNHD, HnHd) != CE_OK)
		NX_RAISE (Err_TransformError13, NULL, NULL);

	#ifdef WRITELINKS
	CiLinkWrite ("/me/HnHd.link");
	#endif

	if (direction == CI_FDIR_INVERSE)
		CiLinkFDirSet (CI_FDIR_INVERSE);

   	CiLinkAdd();
	CiLinkClose ();

	NX_RAISE (Err_NoError, NULL, NULL);
	NX_HANDLER
	if (HnHd -> set.pairs)
		NX_FREE (HnHd -> set.pairs);
	if (HnHd)
		NX_FREE (HnHd);
	NX_ENDHANDLER
	return 0;
}

- (ColorV *) referenceRGB: (int) teachMeType
{
	if (teachMeType == TEACHME_VISUAL)
		return referenceRGB;
	else
	#ifdef BIGRCHN
	{
		int	ir, ig, ib;
		int	index = 0;
		int	increment = 85;

		stream = NXOpenMemory (NULL, 0, NX_READWRITE);

		for (ib = 0; ib < 256; ib += increment)
			for (ig = 0; ig < 256; ig += increment)
				for (ir = 0; ir < 256; ir += increment)
				{
					bigReferenceRGB [index] [0] = (float) ir / 255;
					bigReferenceRGB [index] [1] = (float) ig / 255;
					bigReferenceRGB [index] [2] = (float) ib / 255;
					bigReferenceRGB [index] [3] = 0;
					index++;
				}
			return	bigReferenceRGB;
	}
	#endif
	#ifdef BIGGERRCHN
	{
		int	ir, ig, ib;
		int	index = 0;
		NXStream *stream;
		char	buffer [260];
		int	increment = 51;

		#ifdef WRITELINKS
		stream = NXOpenMemory (NULL, 0, NX_READWRITE);
		#endif

		for (ib = 0; ib < 256; ib += increment)
			for (ig = 0; ig < 256; ig += increment)
				for (ir = 0; ir < 256; ir += increment)
				{
					#ifdef WRITELINKS
					sprintf (buffer, "%3.2f %3.2f %3.2f\n", (float) ir / 255, (float) ig / 255, (float) ib / 255);
					NXWrite (stream, buffer, strlen (buffer));
					#endif

					bigReferenceRGB [index] [0] = (float) ir / 255;
					bigReferenceRGB [index] [1] = (float) ig / 255;
					bigReferenceRGB [index] [2] = (float) ib / 255;
					bigReferenceRGB [index] [3] = 0;
					index++;
				}
		#ifdef WRITELINKS
		NXSaveToFile (stream, "/me/sourcecolors");
		NXCloseMemory (stream, NX_FREEBUFFER);
		#endif
		return	bigReferenceRGB;
	}
	#endif
}

- (ColorV *) altReferenceRGB
{
	return altReferenceRGB;
}




