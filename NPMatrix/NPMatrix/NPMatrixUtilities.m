//
//  NPMatrixUtilities.m
//  Material Cutter
//
//  Created by Hydra on 15/8/9.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//

#import "NPMatrixUtilities.h"

/**************************************************
 
                getIndexOfMatrix
 
 A[1000] -> store -> A[10][100]
 A[getIndexOfMatrix(10,100,x,y)] -> query -> A[y][x]
 
 ***************************************************/


BOOL NPMatrixWriteToFile(NPMatrixType *mat, const char *filename) {
    if (mat==NULL) {
        return false;
    }
    
    FILE *f=fopen(filename, "w");
    if (f==NULL) {
        return false;
    }
    
    for (unsigned long y=0; y<NPMATRIX_HEIGHT(mat); y++) {
        for (unsigned long x=0; x<NPMATRIX_WIDTH(mat); x++) {
            switch (mat->info.type) {
                case NPCharTypeMatrix:
                case NPShortTypeMatrix:
                case NPLongTypeMatrix:
                {
                    long e=NPMatrixGetLong(mat, x, y);
                    fprintf(f, "%ld ", e);
                }
                    break;
                    
                case NPUCharTypeMatrix:
                case NPUShortTypeMatrix:
                case NPULongTypeMatrix:
                {
                    unsigned long e;
                    NPMATRIX_GET(e, mat, x, y);
                    fprintf(f, "%lu ", e);
                }

                    break;
                    
                case NPFloatTypeMatrix:
                case NPDoubleTypeMatrix:
                case NPLongDoubleTypeMatrix:
                {
                    long double e=NPMatrixGetLDouble(mat, x, y);
                    fprintf(f, "%Lf ", e);
                }
                    
                    break;
                default:
                    return false;
            }
        }
        fprintf(f, "\n");
    }
    
    
    fclose(f);
    return true;
}

long NPMatrixGetLong(NPMatrixType *mat, unsigned long x, unsigned long y) {
    long e;
    NPMATRIX_GET(e, mat, x, y);
    return e;
}

long double NPMatrixGetLDouble(NPMatrixType *mat, unsigned long x, unsigned long y) {
    long double e;
    NPMATRIX_GET(e, mat, x, y);
    return e;
}
