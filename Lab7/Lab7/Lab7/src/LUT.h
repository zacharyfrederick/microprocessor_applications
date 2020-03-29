/*
 * LUT.h
 *
 * Created: 11/24/2018 2:41:40 PM
 *  Author: Zachary
 */ 


#ifndef LUT_H_
#define LUT_H_

static const uint16_t lookupSine[] = 
{
	2048,2098,2148,2199,2249,2299,2349,2399,
	2448,2498,2547,2596,2644,2692,2740,2787,
	2834,2880,2926,2971,3016,3060,3104,3147,
	3189,3230,3271,3311,3351,3389,3427,3464,
	3500,3535,3569,3602,3635,3666,3697,3726,
	3754,3782,3808,3833,3857,3880,3902,3923,
	3943,3961,3979,3995,4010,4024,4036,4048,
	4058,4067,4074,4081,4086,4090,4093,4095,
	4095,4094,4092,4088,4084,4078,4071,4062,
	4053,4042,4030,4017,4002,3987,3970,3952,
	3933,3913,3891,3869,3845,3821,3795,3768,
	3740,3711,3681,3651,3619,3586,3552,3517,
	3482,3445,3408,3370,3331,3291,3251,3210,
	3168,3125,3082,3038,2994,2949,2903,2857,
	2811,2764,2716,2668,2620,2571,2522,2473,
	2424,2374,2324,2274,2224,2174,2123,2073,
	2022,1972,1921,1871,1821,1771,1721,1671,
	1622,1573,1524,1475,1427,1379,1331,1284,
	1238,1192,1146,1101,1057,1013,970,927,
	885,844,804,764,725,687,650,613,
	578,543,509,476,444,414,384,355,
	327,300,274,250,226,204,182,162,
	143,125,108,93,78,65,53,42,
	33,24,17,11,7,3,1,0,
	0,2,5,9,14,21,28,37,
	47,59,71,85,100,116,134,152,
	172,193,215,238,262,287,313,341,
	369,398,429,460,493,526,560,595,
	631,668,706,744,784,824,865,906,
	948,991,1035,1079,1124,1169,1215,1261,
	1308,1355,1403,1451,1499,1548,1597,1647,
	1696,1746,1796,1846,1896,1947,1997,2048,
};

static const uint16_t lookupSawtooth[] = {
	32,64,96,128,160,192,224,256,
	288,320,352,384,416,448,480,512,
	544,576,608,640,672,704,736,768,
	800,832,864,896,928,960,992,1024,
	1056,1088,1120,1152,1184,1216,1248,1280,
	1312,1344,1376,1408,1440,1472,1504,1536,
	1568,1600,1632,1664,1696,1728,1760,1792,
	1824,1856,1888,1920,1952,1984,2016,2048,
	2079,2111,2143,2175,2207,2239,2271,2303,
	2335,2367,2399,2431,2463,2495,2527,2559,
	2591,2623,2655,2687,2719,2751,2783,2815,
	2847,2879,2911,2943,2975,3007,3039,3071,
	3103,3135,3167,3199,3231,3263,3295,3327,
	3359,3391,3423,3455,3487,3519,3551,3583,
	3615,3647,3679,3711,3743,3775,3807,3839,
	3871,3903,3935,3967,3999,4031,4063,4095,
	4063,4031,3999,3967,3935,3903,3871,3839,
	3807,3775,3743,3711,3679,3647,3615,3583,
	3551,3519,3487,3455,3423,3391,3359,3327,
	3295,3263,3231,3199,3167,3135,3103,3071,
	3039,3007,2975,2943,2911,2879,2847,2815,
	2783,2751,2719,2687,2655,2623,2591,2559,
	2527,2495,2463,2431,2399,2367,2335,2303,
	2271,2239,2207,2175,2143,2111,2079,2048,
	2016,1984,1952,1920,1888,1856,1824,1792,
	1760,1728,1696,1664,1632,1600,1568,1536,
	1504,1472,1440,1408,1376,1344,1312,1280,
	1248,1216,1184,1152,1120,1088,1056,1024,
	992,960,928,896,864,832,800,768,
	736,704,672,640,608,576,544,512,
	480,448,416,384,352,320,288,256,
	224,192,160,128,96,64,32,0,
};

#endif /* LUT_H_ */