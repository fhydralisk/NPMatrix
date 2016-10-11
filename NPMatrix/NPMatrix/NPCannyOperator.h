//
//  CannyCalc.h
//  Material Cutter
//
//  Created by Hydra on 15/8/9.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NPMatrixType.h"

typedef struct grey_map_element {
    unsigned char brightness;
} GreyMapElement;

typedef struct rgb_map_element {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char alpha;
} RGBMapElement;

typedef struct canny_size {
    long width;
    long height;
} CYSize;

NPMatrixType* NPMatrixCreateByUsingCannyOperator(NPMatrixType *mat, size_t gauss_radius, long double sigma);
BOOL CannySeal(NPMatrixType *mat);

