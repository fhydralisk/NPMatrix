//
//  NPMatrixOperate.m
//  Material Cutter
//
//  Created by Hydra on 15/8/10.
//  Copyright (c) 2015年Hydra. All rights reserved.
//

#import "NPMatrixOperate.h"
#import "NPCommonMatrixes.h"
#import "NPMatrixUtilities.h"
#import "NPCommonAlgorithm.h"

#define SUM_ALL_ELEMENT(type, m, s) { \
    type *e = m->buf; \
    for (unsigned long index=0; index < (NPMATRIX_WIDTH(m) * NPMATRIX_HEIGHT(m)); index++) { \
        s+=e[index];\
    } \
}

#define SUM_ALL_ELEMENT_AND_ALL_TYPE(m, s) \
switch (m->info.type) { \
    case NPCharTypeMatrix: \
        SUM_ALL_ELEMENT(char, m, s); \
        break; \
    case NPUCharTypeMatrix: \
        SUM_ALL_ELEMENT(unsigned char, m, s); \
        break; \
    case NPShortTypeMatrix: \
        SUM_ALL_ELEMENT(short, m, s); \
        break; \
    case NPUShortTypeMatrix: \
        SUM_ALL_ELEMENT(unsigned short, m, s); \
        break; \
    case NPLongTypeMatrix: \
        SUM_ALL_ELEMENT(long, m, s); \
        break; \
    case NPULongTypeMatrix: \
        SUM_ALL_ELEMENT(unsigned long, m, s); \
        break; \
    case NPFloatTypeMatrix: \
        SUM_ALL_ELEMENT(float, m, s); \
        break; \
    case NPDoubleTypeMatrix: \
        SUM_ALL_ELEMENT(double, m, s); \
        break; \
    case NPLongDoubleTypeMatrix: \
        SUM_ALL_ELEMENT(long double, m, s); \
        break; \
    default: \
        return 0; \
}


long double NPMatrixSumElementsLDouble(NPMatrixType *mat) {
    long double sum=0;
    SUM_ALL_ELEMENT_AND_ALL_TYPE(mat, sum);
    return sum;
}
long NPMatrixSumElementsLong(NPMatrixType *mat) {
    long sum=0;
    SUM_ALL_ELEMENT_AND_ALL_TYPE(mat, sum);
    return sum;
}



#define CALC_ALL_ELEMENT(type, m, a, op) { \
    type *e = m->buf; \
    for (unsigned long index=0; index < (NPMATRIX_WIDTH(m) * NPMATRIX_HEIGHT(m)); index++) { \
        e[index] op a;\
    } \
}

#define CALC_ALL_ELEMENT_AND_ALL_TYPE(m, a, op) \
switch (m->info.type) { \
    case NPCharTypeMatrix: \
        CALC_ALL_ELEMENT(char, m, a, op); \
        break; \
    case NPUCharTypeMatrix: \
        CALC_ALL_ELEMENT(unsigned char, m, a, op); \
        break; \
    case NPShortTypeMatrix: \
        CALC_ALL_ELEMENT(short, m, a, op); \
        break; \
    case NPLongTypeMatrix: \
        CALC_ALL_ELEMENT(long, m, a, op); \
        break; \
    case NPUShortTypeMatrix: \
        CALC_ALL_ELEMENT(unsigned short, m, a, op); \
        break; \
    case NPULongTypeMatrix: \
        CALC_ALL_ELEMENT(unsigned long, m, a, op); \
        break; \
    case NPFloatTypeMatrix: \
        CALC_ALL_ELEMENT(float, m, a, op); \
        break; \
    case NPDoubleTypeMatrix: \
        CALC_ALL_ELEMENT(double, m, a, op); \
        break; \
    case NPLongDoubleTypeMatrix: \
        CALC_ALL_ELEMENT(long double, m, a, op); \
        break; \
    default: \
        return false; \
}

BOOL NPMatrixDotDivLDouble(NPMatrixType *mat, long double a) {
    if (mat==NULL) {
        return false;
    }
    if (a==0.0) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, /=);
    return true;
}

BOOL NPMatrixDotDivLong(NPMatrixType *mat, long a) {
    if (mat==NULL) {
        return false;
    }
    if (a==0) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, /=);
    return true;
}

BOOL NPMatrixDotMultiplyLDouble(NPMatrixType *mat, long double a) {
    if (mat==NULL) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, *=);
    return true;
}

BOOL NPMatrixDotMultiplyLong(NPMatrixType *mat, long a) {
    if (mat==NULL) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, *=);
    return true;
}

BOOL NPMatrixDotSumLDouble(NPMatrixType *mat, long double a) {
    if (mat==NULL) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, +=);
    return true;
}

BOOL NPMatrixDotSumLong(NPMatrixType *mat, long a) {
    if (mat==NULL) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, +=);
    return true;
}

BOOL NPMatrixDotSubLDouble(NPMatrixType *mat, long double a) {
    if (mat==NULL) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, -=);
    return true;
}

BOOL NPMatrixDotSubLong(NPMatrixType *mat, long a) {
    if (mat==NULL) {
        return false;
    }
    CALC_ALL_ELEMENT_AND_ALL_TYPE(mat, a, -=);
    return true;
}

#define CALC_MATRIX_DOT_OP(typem, typea, m, a, op) { \
    typem *matelem=m->buf; \
    typea *matelea=a->buf; \
    for (unsigned long index=0; index<(NPMATRIX_HEIGHT(m) * NPMATRIX_WIDTH(m)); index++) { \
        matelem[index] op matelea[index];\
    } \
}

#define CALC_MATRIX_DOT_OP_ALL_TYPE_A(typem, m, a, op) { \
    switch (a->info.type) { \
        case NPCharTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, char, m, a, op); \
            break; \
        case NPShortTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, short, m, a, op); \
            break; \
        case NPLongTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, long, m, a, op); \
            break; \
        case NPUCharTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, unsigned char, m, a, op); \
            break; \
        case NPUShortTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, unsigned short, m, a, op); \
            break; \
        case NPULongTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, unsigned long, m, a, op); \
            break; \
        case NPFloatTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, float, m, a, op); \
            break; \
        case NPDoubleTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, double, m, a, op); \
            break; \
        case NPLongDoubleTypeMatrix: \
            CALC_MATRIX_DOT_OP(typem, long double, m, a, op); \
            break; \
        default: \
            return false; \
    } \
}

#define CALC_MATRIX_DOT_OP_ALL_TYPE(m, a, op) \
switch (m->info.type) { \
    case NPCharTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(char, m, a, op); \
        break; \
    case NPShortTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(short, m, a, op); \
        break; \
    case NPLongTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(long, m, a, op); \
        break; \
    case NPUCharTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(unsigned char, m, a, op); \
        break; \
    case NPUShortTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(unsigned short, m, a, op); \
        break; \
    case NPULongTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(unsigned long, m, a, op); \
        break; \
    case NPFloatTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(float, m, a, op); \
        break; \
    case NPDoubleTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(double, m, a, op); \
        break; \
    case NPLongDoubleTypeMatrix: \
        CALC_MATRIX_DOT_OP_ALL_TYPE_A(long double, m, a, op); \
        break; \
    default: \
        return false; \
}

BOOL __checkMatrixEqualSize(NPMatrixType *mat1, NPMatrixType *mat2) {
    if (mat1 == NULL || mat2== NULL) {
        return false;
    }
    
    if (NPMATRIX_HEIGHT(mat1)!=NPMATRIX_HEIGHT(mat2) || NPMATRIX_WIDTH(mat1) != NPMATRIX_WIDTH(mat2)) {
        return false;
    }
    
    return true;
}

BOOL NPMatrixSum(NPMatrixType *mat, NPMatrixType *a) {
    if (!__checkMatrixEqualSize(mat, a)) {
        return false;
    }
    
    CALC_MATRIX_DOT_OP_ALL_TYPE(mat, a, +=);
    return true;
}
BOOL NPMatrixSub(NPMatrixType *mat, NPMatrixType *a) {
    if (!__checkMatrixEqualSize(mat, a)) {
        return false;
    }
    
    CALC_MATRIX_DOT_OP_ALL_TYPE(mat, a, -=);
    return true;

}

BOOL NPMatrixDotMutiplyMatrix(NPMatrixType *mat, NPMatrixType *a) {
    if (!__checkMatrixEqualSize(mat, a)) {
        return false;
    }
    
    CALC_MATRIX_DOT_OP_ALL_TYPE(mat, a, *=);
    return true;

}

BOOL NPMatrixDotDivMatrix(NPMatrixType *mat, NPMatrixType *a) {
    if (!__checkMatrixEqualSize(mat, a)) {
        return false;
    }
    
    for (unsigned long y=0; y<NPMATRIX_HEIGHT(a); y++) {
        for (unsigned long x=0; x<NPMATRIX_WIDTH(a); x++) {
            long double d;
            NPMATRIX_GET(d, a, x, y);
            if (d==0) {
                return false;
            }
        }
    }
    
    CALC_MATRIX_DOT_OP_ALL_TYPE(mat, a, /=);
    return true;

}


#define CALC_MATRIX_CONV(typem, typet, d, m, t, pminx, pmaxx, pminy, pmaxy) { \
    typem *matelem=m->buf; \
    typem *mateled=d->buf; \
    typet *matelet=t->buf; \
    for (unsigned long x=pminx; x<NPMATRIX_WIDTH(m)-pmaxx; x++) {\
        for (unsigned long y=pminy; y<NPMATRIX_HEIGHT(m)-pmaxy; y++) { \
            mateled[INDEX_OF_MATRIX(d, x, y)]=0; \
            for (unsigned long tx=0; tx<NPMATRIX_WIDTH(t); tx++) { \
                for (unsigned long ty=0; ty<NPMATRIX_HEIGHT(t); ty++) { \
                    mateled[INDEX_OF_MATRIX(d, x, y)] += matelem[INDEX_OF_MATRIX(m, x-pminx+tx, y-pminy+ty)] * matelet[INDEX_OF_MATRIX(t, tx, ty)]; \
                } \
            } \
        } \
    }\
}

#define CALC_MATRIX_CONV_ALL_TYPE_A(typem, d, m, t, pminx, pmaxx, pminy, pmaxy) { \
    switch (t->info.type) { \
        case NPCharTypeMatrix: \
            CALC_MATRIX_CONV(typem, char, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPShortTypeMatrix: \
            CALC_MATRIX_CONV(typem, short, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPLongTypeMatrix: \
            CALC_MATRIX_CONV(typem, long, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPUCharTypeMatrix: \
            CALC_MATRIX_CONV(typem, unsigned char, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPUShortTypeMatrix: \
            CALC_MATRIX_CONV(typem, unsigned short, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPULongTypeMatrix: \
            CALC_MATRIX_CONV(typem, unsigned long, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPFloatTypeMatrix: \
            CALC_MATRIX_CONV(typem, float, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPDoubleTypeMatrix: \
            CALC_MATRIX_CONV(typem, double, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        case NPLongDoubleTypeMatrix: \
            CALC_MATRIX_CONV(typem, long double, d, m, t, pminx, pmaxx, pminy, pmaxy); \
            break; \
        default: \
            goto err; \
    } \
}

#define CALC_MATRIX_CONV_ALL_TYPE(d, m, t, pminx, pmaxx, pminy, pmaxy) \
switch (m->info.type) { \
    case NPCharTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(char, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPShortTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(short, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPLongTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(long, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPUCharTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(unsigned char, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPUShortTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(unsigned short, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPULongTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(unsigned long, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPFloatTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(float, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPDoubleTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(double, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    case NPLongDoubleTypeMatrix: \
        CALC_MATRIX_CONV_ALL_TYPE_A(long double, d, m, t, pminx, pmaxx, pminy, pmaxy); \
        break; \
    default: \
        goto err; \
}

NPMatrixType *NPMatrixCreateFromTemplate(NPMatrixType *sourceMat, NPMatrixType *templateMat) {
    if (sourceMat==NULL || templateMat==NULL) {
        return NULL;
    }
    
    if (NPMATRIX_HEIGHT(sourceMat) < NPMATRIX_HEIGHT(templateMat) || NPMATRIX_WIDTH(sourceMat) < NPMATRIX_WIDTH(templateMat)) {
        return NULL;
    }

    NPMatrixType *matrix=NPMatrixCreate(NPMATRIX_HEIGHT(sourceMat),
                                    NPMATRIX_WIDTH(sourceMat),
                                    sourceMat->info.type);
    if (matrix) {
        unsigned long padMinX=(NPMATRIX_WIDTH(templateMat) - 1)/2;
        unsigned long padMaxX=(NPMATRIX_WIDTH(templateMat) - 1) - padMinX;
        
        unsigned long padMinY=(NPMATRIX_HEIGHT(templateMat) - 1)/2;
        unsigned long padMaxY=(NPMATRIX_HEIGHT(templateMat) - 1) - padMinY;
        
        CALC_MATRIX_CONV_ALL_TYPE(matrix, sourceMat, templateMat, padMinX, padMaxX, padMinY, padMaxY);
    }

    return matrix;
    
err:
    NPMatrixFree(matrix);
    return NULL;
}

// Pyx=M(y,:)*N(:,x)
// y=0..height of M, x=0..width of N
// Mh1w1*Nh2w2, w1=h2 Ph1w2

#define CALC_MATRIX_MULTIPLY_TYPE_1_2_D(type1, type2, typed, m1, m2, md) { \
    type1 num1; type2 num2; typed numd;\
    for (unsigned long y=0; y<NPMATRIX_HEIGHT(m1); y++) {\
        for (unsigned long x=0; x<NPMATRIX_WIDTH(m2); x++) { \
            numd=0; \
            for (unsigned long x1y2=0; x1y2<NPMATRIX_WIDTH(m1); x1y2++) { \
                NPMATRIX_GET(num1, m1, x1y2, y); \
                NPMATRIX_GET(num2, m2, x, x1y2); \
                numd += num1*num2; \
            } \
            NPMATRIX_PUT(numd, md, x, y); \
        } \
    } \
}

#define CALC_MATRIX_MULTIPLY_TYPE_1_2(type1, type2, m1, m2, md, err) { \
    switch(md->info.type) { \
        case NPCharTypeMatrix: \
        case NPShortTypeMatrix: \
        case NPLongTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1_2_D(type1, type2, long, m1, m2, md); \
            break; \
        case NPUCharTypeMatrix: \
        case NPUShortTypeMatrix: \
        case NPULongTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1_2_D(type1, type2, unsigned long, m1, m2, md); \
            break; \
        case NPFloatTypeMatrix: \
        case NPDoubleTypeMatrix: \
        case NPLongDoubleTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1_2_D(type1, type2, long double, m1, m2, md); \
            break; \
        default: \
            goto err; \
    } \
}

#define CALC_MATRIX_MULTIPLY_TYPE_1(type1, m1, m2, md, err) { \
    switch(m2->info.type) { \
        case NPCharTypeMatrix: \
        case NPShortTypeMatrix: \
        case NPLongTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1_2(type1, long, m1, m2, md, err); \
            break; \
        case NPUCharTypeMatrix: \
        case NPUShortTypeMatrix: \
        case NPULongTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1_2(type1, unsigned long, m1, m2, md, err); \
            break; \
        case NPFloatTypeMatrix: \
        case NPDoubleTypeMatrix: \
        case NPLongDoubleTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1_2(type1, long double, m1, m2, md, err); \
            break; \
        default: \
            goto err; \
    } \
}

#define CALC_MATRIX_MULTIPLY(m1, m2, md, err) { \
    switch(m1->info.type) { \
        case NPCharTypeMatrix: \
        case NPShortTypeMatrix: \
        case NPLongTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1(long, m1, m2, md, err); \
            break; \
        case NPUCharTypeMatrix: \
        case NPUShortTypeMatrix: \
        case NPULongTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1(unsigned long, m1, m2, md, err); \
            break; \
        case NPFloatTypeMatrix: \
        case NPDoubleTypeMatrix: \
        case NPLongDoubleTypeMatrix: \
            CALC_MATRIX_MULTIPLY_TYPE_1(long double, m1, m2, md, err); \
            break; \
        default: \
            goto err; \
    } \
}

NPMatrixType* NPMatrixCreateByMultiplyUsingType(NPMatrixType *mat1, NPMatrixType *mat2, NPMatrixTypeEnum type) {
    if (mat1==NULL || mat2==NULL) {
        return NULL;
    }
    
    if (NPMATRIX_WIDTH(mat1) != NPMATRIX_HEIGHT(mat2)) {
        return NULL;
    }
    
    NPMatrixType *matrix=NPMatrixCreate(NPMATRIX_HEIGHT(mat1), NPMATRIX_WIDTH(mat2), type);
    
    CALC_MATRIX_MULTIPLY(mat1, mat2, matrix, err);
    
    return matrix;
err:
    NPMatrixFree(matrix);
    return NULL;
}

NPMatrixType* NPMatrixCreateByMultiply(NPMatrixType *mat1, NPMatrixType *mat2) {
    return NPMatrixCreateByMultiplyUsingType(mat1, mat2, mat1->info.type);
}

/*
BOOL NPMatrixModifyElementUsingLongTypeFunction(NPMatrixType *mat, NPLongFuncPtr func, void *param, NPOrderOptions options) {
    if (mat==NULL) {
        return false;
    }
    
    
    for (unsigned long y=0; y<NPMATRIX_HEIGHT(mat); y++) {
        for (unsigned long x=0; x<NPMATRIX_WIDTH(mat); x++) {
            long e;
            BOOL stop=false;
            NPMATRIX_GET(e, mat, x, y);
            NPMATRIX_PUT(func(mat,e,x,y,param,&stop), mat, x, y);
            if (stop) {
                return true;
            }
        }
    }
    
    return true;
}*/


BOOL NPMatrixModifyElementUsingLongTypeFunction(NPMatrixType *mat, NPLongFuncPtr func, void *param, NPOrderOptions options) {
    if (mat==NULL) {
        return false;
    }
    
    long x,y,xDest,yDest,xOp,yOp;
    long *i,*j,iStart,iDest,jStart,jDest,iOp,jOp;
    
    if (options & 2) {
        x=NPMATRIX_WIDTH(mat) - 1;
        xDest=-1;
        xOp=-1;
    } else {
        x=0;
        xDest=NPMATRIX_WIDTH(mat);
        xOp=1;
    }
    
    if (options & 4) {
        y=NPMATRIX_HEIGHT(mat) - 1;
        yDest=-1;
        yOp=-1;
    } else {
        y=0;
        yDest=NPMATRIX_HEIGHT(mat);
        yOp=1;
    }

    
    if (options & 1) {
        i=&x;
        iStart=x;
        iDest=xDest;
        iOp=xOp;
        
        j=&y;
        jStart=y;
        jDest=yDest;
        jOp=yOp;
        
    } else {
        i=&y;
        iStart=y;
        iDest=yDest;
        iOp=yOp;
        
        j=&x;
        jStart=x;
        jDest=xDest;
        jOp=xOp;
    }
    
    for (*i=iStart; *i!=iDest; *i+=iOp) {
        for (*j=jStart; *j!=jDest; *j+=jOp) {
            long e;
            BOOL stop=false;
            NPMATRIX_GET(e, mat, x, y);
            NPMATRIX_PUT(func(mat,e,x,y,param,&stop), mat, x, y);
            if (stop) {
                return true;
            }
        }
    }
    
    return true;
}

BOOL NPMatrixModifyElementUsingLDoubleTypeFunction(NPMatrixType *mat, NPLDoubleFuncPtr func, void *param, NPOrderOptions options) {
    if (mat==NULL) {
        return false;
    }
    
    long x,y,xDest,yDest,xOp,yOp;
    long *i,*j,iStart,iDest,jStart,jDest,iOp,jOp;
    
    if (options & 2) {
        x=NPMATRIX_WIDTH(mat) - 1;
        xDest=-1;
        xOp=-1;
    } else {
        x=0;
        xDest=NPMATRIX_WIDTH(mat);
        xOp=1;
    }
    
    if (options & 4) {
        y=NPMATRIX_HEIGHT(mat) - 1;
        yDest=-1;
        yOp=-1;
    } else {
        y=0;
        yDest=NPMATRIX_HEIGHT(mat);
        yOp=1;
    }
    
    
    if (options & 1) {
        i=&x;
        iStart=x;
        iDest=xDest;
        iOp=xOp;
        
        j=&y;
        jStart=y;
        jDest=yDest;
        jOp=yOp;
        
    } else {
        i=&y;
        iStart=y;
        iDest=yDest;
        iOp=yOp;
        
        j=&x;
        jStart=x;
        jDest=xDest;
        jOp=xOp;
    }
    
    for (*i=iStart; *i!=iDest; *i+=iOp) {
        for (*j=jStart; *j!=jDest; *j+=jOp) {
            long double e;
            BOOL stop=false;
            NPMATRIX_GET(e, mat, x, y);
            NPMATRIX_PUT(func(mat,e,x,y,param,&stop), mat, x, y);
            if (stop) {
                return true;
            }
        }
    }
    
    return true;
}

BOOL NPMatrixModifyElementInRectUsingLongTypeFunction(NPMatrixType *mat, NPRect rect, NPLongFuncPtr func, void *param, NPOrderOptions options) {
    if (mat==NULL) {
        return false;
    }
    
    long x,y,xDest,yDest,xOp,yOp;
    long *i,*j,iStart,iDest,jStart,jDest,iOp,jOp;
    
    unsigned long xend,yend;
    xend=rect.origin.x+rect.size.width;
    yend=rect.origin.y+rect.size.height;
    
    if (xend>NPMATRIX_WIDTH(mat) || yend>NPMATRIX_HEIGHT(mat)) {
        return false;
    }
    
    if (options & 2) {
        x=xend - 1;
        xDest=rect.origin.x-1;
        xOp=-1;
    } else {
        x=rect.origin.x;
        xDest=xend;
        xOp=1;
    }
    
    if (options & 4) {
        y=yend - 1;
        yDest=rect.origin.y-1;
        yOp=-1;
    } else {
        y=rect.origin.y;
        yDest=yend;
        yOp=1;
    }
    
    
    if (options & 1) {
        i=&x;
        iStart=x;
        iDest=xDest;
        iOp=xOp;
        
        j=&y;
        jStart=y;
        jDest=yDest;
        jOp=yOp;
        
    } else {
        i=&y;
        iStart=y;
        iDest=yDest;
        iOp=yOp;
        
        j=&x;
        jStart=x;
        jDest=xDest;
        jOp=xOp;
    }
    
    for (*i=iStart; *i!=iDest; *i+=iOp) {
        for (*j=jStart; *j!=jDest; *j+=jOp) {
            long e;
            BOOL stop=false;
            NPMATRIX_GET(e, mat, x, y);
            NPMATRIX_PUT(func(mat,e,x,y,param,&stop), mat, x, y);
            if (stop) {
                return true;
            }
        }
    }
    
    return true;

}

BOOL NPMatrixModifyElementInRectUsingLDoubleTypeFunction(NPMatrixType *mat, NPRect rect, NPLDoubleFuncPtr func, void *param, NPOrderOptions options) {
    if (mat==NULL) {
        return false;
    }
    
    long x,y,xDest,yDest,xOp,yOp;
    long *i,*j,iStart,iDest,jStart,jDest,iOp,jOp;
    
    unsigned long xend,yend;
    xend=rect.origin.x+rect.size.width;
    yend=rect.origin.y+rect.size.height;
    
    if (xend>NPMATRIX_WIDTH(mat) || yend>NPMATRIX_HEIGHT(mat)) {
        return false;
    }
    
    if (options & 2) {
        x=xend - 1;
        xDest=rect.origin.x-1;
        xOp=-1;
    } else {
        x=rect.origin.x;
        xDest=xend;
        xOp=1;
    }
    
    if (options & 4) {
        y=yend - 1;
        yDest=rect.origin.y-1;
        yOp=-1;
    } else {
        y=rect.origin.y;
        yDest=yend;
        yOp=1;
    }
    
    
    if (options & 1) {
        i=&x;
        iStart=x;
        iDest=xDest;
        iOp=xOp;
        
        j=&y;
        jStart=y;
        jDest=yDest;
        jOp=yOp;
        
    } else {
        i=&y;
        iStart=y;
        iDest=yDest;
        iOp=yOp;
        
        j=&x;
        jStart=x;
        jDest=xDest;
        jOp=xOp;
    }
    
    for (*i=iStart; *i!=iDest; *i+=iOp) {
        for (*j=jStart; *j!=jDest; *j+=jOp) {
            long double e;
            BOOL stop=false;
            NPMATRIX_GET(e, mat, x, y);
            NPMATRIX_PUT(func(mat,e,x,y,param,&stop), mat, x, y);
            if (stop) {
                return true;
            }
        }
    }
    
    return true;

}



#pragma mark Not implemented yet...


NPMatrixType* NPMatrixCreateByDiv(NPMatrixType *matNum, NPMatrixType *matDen) {
    return NULL;
}

BOOL NPMatrixInv(NPMatrixType *mat) {
    return false;
}
BOOL NPMatrixTrans(NPMatrixType *mat) {
    return false;
}

#define IS_ODD(n) ((long)(n))%2==1

NPMatrixType* NPMatrixCreateAdjointMatrix(NPMatrixType *mat, unsigned long x, unsigned long y) {
    if (mat==NULL) {
        return NULL;
    }
    
    if (NPMATRIX_HEIGHT(mat)<=1 || NPMATRIX_WIDTH(mat) <=1) {
        return NULL;
    }
    
    NPMatrixType *matrix=NPMatrixCreate(NPMATRIX_HEIGHT(mat) - 1, NPMATRIX_WIDTH(mat) - 1, mat->info.type);
    
    char k=IS_ODD(x+y)?-1:1;
    
    switch (matrix->info.type) {
        case NPCharTypeMatrix:
        case NPShortTypeMatrix:
        case NPLongTypeMatrix:
            for (unsigned long yN=0; yN<NPMATRIX_HEIGHT(matrix); yN++) {
                for (unsigned long xN=0; xN<NPMATRIX_WIDTH(matrix); xN++) {
                    long e;
                    NPMATRIX_GET(e, mat, (xN<x?xN:xN+1), (yN<y?yN:yN+1));
                    e *= k;
                    NPMATRIX_PUT(e, matrix, xN, yN);
                }
            }
            break;
            
        case NPUCharTypeMatrix:
        case NPUShortTypeMatrix:
        case NPULongTypeMatrix:
            for (unsigned long yN=0; yN<NPMATRIX_HEIGHT(matrix); yN++) {
                for (unsigned long xN=0; xN<NPMATRIX_WIDTH(matrix); xN++) {
                    unsigned long e;
                    NPMATRIX_GET(e, mat, (xN<x?xN:xN+1), (yN<y?yN:yN+1));
                    // e *= k;
                    NPMATRIX_PUT(e, matrix, xN, yN);
                }
            }
            break;
            
        case NPFloatTypeMatrix:
        case NPDoubleTypeMatrix:
        case NPLongDoubleTypeMatrix:
            for (unsigned long yN=0; yN<NPMATRIX_HEIGHT(matrix); yN++) {
                for (unsigned long xN=0; xN<NPMATRIX_WIDTH(matrix); xN++) {
                    long double e;
                    NPMATRIX_GET(e, mat, (xN<x?xN:xN+1), (yN<y?yN:yN+1));
                    e *= k;
                    NPMATRIX_PUT(e, matrix, xN, yN);
                }
            }

            break;
            
        default:
            goto err;
    }
    
    
err:
    NPMatrixFree(matrix);
    return NULL;
}


#ifdef DEBUG
#define ASSERT_FALSE_WHEN_DEBUG assert(false)
#else
#define ASSERT_FALSE_WHEN_DEBUG
#endif

void __TriangleMatrixLong(NPMatrixType *mat, NPMatrixType *denMatrix) {
    
    long t1, t1den;
    
    for (unsigned long depth=0; depth<NPMATRIX_HEIGHT(mat) - 1; depth++) {
        NPMATRIX_GET_TYPE(long, t1, mat, depth, depth);
        NPMATRIX_GET_TYPE(long, t1den, denMatrix, depth, depth);
        
        for (unsigned long y=depth + 1; y<NPMATRIX_HEIGHT(mat); y++) {
            long e1, e1den;
            NPMATRIX_GET_TYPE(long, e1, mat, depth, y);
            NPMATRIX_GET_TYPE(long, e1den, denMatrix, depth, y);
            for (unsigned long x=depth; x<NPMATRIX_WIDTH(mat); x++) {
                long ex,exden,tx,txden;
                NPMATRIX_GET_TYPE(long, ex, mat, x, y);
                NPMATRIX_GET_TYPE(long, exden, denMatrix, x, y);
                NPMATRIX_GET_TYPE(long, tx, mat, x, depth);
                NPMATRIX_GET_TYPE(long, txden, denMatrix, x, depth);
                long nm = ex * txden * e1den * t1 - exden * tx * e1 * t1den;
                //        --------------------------------------------------   =  Exy|depth
                long dn =           exden * t1 * e1den * txden;
                
                if (nm==0) {
                    dn=1;
                } else {
                    unsigned long gcd= greatest_common_divisor(nm, dn);
                    nm /= gcd;
                    dn /= gcd;
                }
                NPMATRIX_PUT_TYPE(long, nm, mat, x, y);
                NPMATRIX_PUT_TYPE(long, dn, denMatrix, x, y);
            }
        }
    }
}


void __TriangleMatrixDouble(NPMatrixType *mat) {
    
    
    for (unsigned long depth=0; depth<NPMATRIX_HEIGHT(mat) - 1; depth++) {
        long double t1;
        NPMATRIX_GET_TYPE(long double, t1, mat, depth, depth);
        
        for (unsigned long y=depth + 1; y<NPMATRIX_HEIGHT(mat); y++) {
            long double e1;
            NPMATRIX_GET_TYPE(long double, e1, mat, depth, y);
            for (unsigned long x=depth; x<NPMATRIX_WIDTH(mat); x++) {
                long double ex,tx;
                NPMATRIX_GET_TYPE(long double, ex, mat, x, y);
                NPMATRIX_GET_TYPE(long double, tx, mat, x, depth);
                long double nm = ex-tx*e1/t1;
                //        --------------------------------------------------   =  Exy|depth
                
                NPMATRIX_PUT_TYPE(long double, nm, mat, x, y);
            }
        }
    }
}


long NPMatrixGetLongValueOfDeterminant(NPMatrixType *mat) {
    
    if (mat==NULL) {
        ASSERT_FALSE_WHEN_DEBUG;
        return 0;
    }
    
    if (NPMATRIX_HEIGHT(mat) != NPMATRIX_WIDTH(mat)) {
        ASSERT_FALSE_WHEN_DEBUG;
        return 0;
    }
    
    if (NPMATRIX_HEIGHT(mat)==1) {
        long e;
        NPMATRIX_GET(e, mat, 0, 0);
        return e;
    }
    
    if (NPMATRIX_HEIGHT(mat)==2) {
        long e1, e2, e3, e4;
        NPMATRIX_GET(e1, mat, 0, 0);
        NPMATRIX_GET(e2, mat, 0, 1);
        NPMATRIX_GET(e3, mat, 1, 0);
        NPMATRIX_GET(e4, mat, 1, 1);
        return e1*e3-e2*e4;
    }
    
    NPMatrixType *denMatrix = NPMatrixCreateZeroMatrix(NPMATRIX_HEIGHT(mat), NPMATRIX_WIDTH(mat), NPLongTypeMatrix);
    NPMatrixType *matrix = NPMatrixCopyToType(mat, NPLongTypeMatrix);
    NPMatrixDotSumLong(denMatrix, 1);
    
    __TriangleMatrixLong(matrix, denMatrix);
    
    long *nums=calloc(sizeof(long), NPMATRIX_HEIGHT(mat));
    long *dens=calloc(sizeof(long), NPMATRIX_HEIGHT(mat));
    for (unsigned long i=0; i<NPMATRIX_HEIGHT(matrix); i++) {
        NPMATRIX_GET_TYPE(long, nums[i], matrix, i, i);
        NPMATRIX_GET_TYPE(long, dens[i], denMatrix, i, i);
    }
    
    
    q_sort(nums, 0, NPMATRIX_HEIGHT(mat)-1);
    q_sort(dens, 0, NPMATRIX_HEIGHT(mat)-1);
    
    long result=1;
    
    for (unsigned long i=0; i<NPMATRIX_HEIGHT(mat); i++) {
        result *= nums[NPMATRIX_HEIGHT(mat) - i -1];
        result /= dens[i];
    }
    
    /*
    for (unsigned long i=0; i<NPMATRIX_HEIGHT(mat); i++) {
        //result *= NPMATRIX_HEIGHT(nums[mat) - i -1];
        result /= dens[i];
    }*/
   
    NPMatrixFree(denMatrix);
    NPMatrixFree(matrix);
    
    free(nums);
    free(dens);
    
    
    // should triangle here...
    return result;
}

long double NPMatrixGetLDoubleValueOfDeterminat(NPMatrixType *mat) {
    
    NPMatrixType *matrix = NPMatrixCopyToType(mat, NPLongDoubleTypeMatrix);
    
    __TriangleMatrixDouble(matrix);
    
    long double result=1;
    
    for (unsigned long i=0; i<NPMATRIX_HEIGHT(mat); i++) {
        long double e;
        NPMATRIX_GET_TYPE(long double, e, matrix, i, i);
        result *= e;
        //result /= dens[i];
    }
    
    NPMatrixFree(matrix);
    
    // should triangle here...
    return result;
}

