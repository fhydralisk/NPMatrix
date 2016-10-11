//
//  NPMatrixGraphics.m
//  Material Cutter
//
//  Created by Hydra on 15/8/19.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//

#import "NPMatrixGraphics.h"
#import "NPCommonMatrixes.h"
#import "NPMatrixUtilities.h"
#import "NPMatrixOperate.h"


struct point {
    long x;
    long y;
};

BOOL NPMatrixGraphicsErosion(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY) {
    if (G==NULL || core==NULL) {
        return false;
    }
    
    if (NPMATRIX_WIDTH(core)>NPMATRIX_WIDTH(G) || NPMATRIX_HEIGHT(core)>NPMATRIX_HEIGHT(G)) {
        return false;
    }
    
    if (originX>=NPMATRIX_WIDTH(core) || originY >=NPMATRIX_HEIGHT(core)) {
        return false;
    }
    
    BOOL result=false;

    struct point *points = calloc(NPMATRIX_AREA(core), sizeof(struct point));
    if (points==NULL) {
        goto err;
    }
    
    NPMatrixType *tempG = NPMatrixCreateZeroMatrix(NPMATRIX_HEIGHT(G), NPMATRIX_WIDTH(G), NPUCharTypeMatrix);
    if (tempG==NULL) {
        goto err1;
    }
    
    unsigned long nPoints=0;
    NPMATRIX_FOREACH_Y_X(core, x, y) {
        long e = NPMatrixGetLong(core, x, y);
        if (e) {
            points[nPoints].x=x-originX;
            points[nPoints].y=y-originY;
            nPoints++;
        }
    }
    
    
    NPMATRIX_FOREACH_Y_X(G, x, y) {
        
        long e=NPMatrixGetLong(G, x, y);
        if (e) {
            BOOL isP=true;
            for (unsigned long i=0; i<nPoints; i++) {
                long cx=x+points[i].x;
                long cy=y+points[i].y;
                
                if (POINT_IN_NPMATRIX(G, cx, cy)) {
                    long ein=NPMatrixGetLong(G, cx, cy);
                    if (ein==0) {
                        isP=false;
                        break;
                    }
                }
            }
            
            if (isP) {
                NPMATRIX_PUT_TYPE(unsigned char, 255, tempG, x, y);
            }
        }
        
    }
    
    result = NPMatrixReplaceWithMatrix(G, tempG);
    NPMatrixFree(tempG);
err1:
    free(points);
err:
    return result;
}

BOOL NPMatrixGraphicsDilation(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY) {
    if (G==NULL || core==NULL) {
        return false;
    }
    
    if (NPMATRIX_WIDTH(core)>NPMATRIX_WIDTH(G) || NPMATRIX_HEIGHT(core)>NPMATRIX_HEIGHT(G)) {
        return false;
    }
    
    if (originX>=NPMATRIX_WIDTH(core) || originY >=NPMATRIX_HEIGHT(core)) {
        return false;
    }
    
    BOOL result=false;
    
    struct point *points = calloc(NPMATRIX_AREA(core), sizeof(struct point));
    if (points==NULL) {
        goto err;
    }
    
    NPMatrixType *tempG = NPMatrixCreateZeroMatrix(NPMATRIX_HEIGHT(G), NPMATRIX_WIDTH(G), NPUCharTypeMatrix);
    if (tempG==NULL) {
        goto err1;
    }
    
    unsigned long nPoints=0;
    NPMATRIX_FOREACH_Y_X(core, x, y) {
        long e = NPMatrixGetLong(core, x, y);
        if (e) {
            points[nPoints].x=x-originX;
            points[nPoints].y=y-originY;
            nPoints++;
        }
    }
    
    
    NPMATRIX_FOREACH_Y_X(G, x, y) {
    
        BOOL isP=false;
        for (unsigned long i=0; i<nPoints; i++) {
            long cx=x+points[i].x;
            long cy=y+points[i].y;
            
            if (POINT_IN_NPMATRIX(G, cx, cy)) {
                long ein=NPMatrixGetLong(G, cx, cy);
                if (ein!=0) {
                    isP=true;
                    break;
                }
            }
        }
        
        if (isP) {
            NPMATRIX_PUT_TYPE(unsigned char, 255, tempG, x, y);
        }
        
    }
    
    result = NPMatrixReplaceWithMatrix(G, tempG);
    NPMatrixFree(tempG);
err1:
    free(points);
err:
    return result;
}

BOOL NPMatrixGraphicsOpen(NPMatrixType *G,
                          NPMatrixType *coreEro, unsigned long originEroX, unsigned long originEroY,
                          NPMatrixType *coreDila, unsigned long originDilaX, unsigned long originDilaY) {
    NPMatrixType *matrixBackup=NPMatrixCopy(G);
    BOOL result;
    
    result = NPMatrixGraphicsErosion(G, coreEro, originEroX, originEroY);
    if (!result) {
        return false;
    }
    
    result= NPMatrixGraphicsDilation(G, coreDila, originDilaX, originDilaY);
    if (!result) {
        // roll back to the backup
        NPMatrixReplaceWithMatrix(G, matrixBackup);
    }
    
    NPMatrixFree(matrixBackup);
    return result;
    
}

BOOL NPMatrixGraphicsClose(NPMatrixType *G,
                           NPMatrixType *coreEro, unsigned long originEroX, unsigned long originEroY,
                           NPMatrixType *coreDila, unsigned long originDilaX, unsigned long originDilaY) {
    NPMatrixType *matrixBackup=NPMatrixCopy(G);
    BOOL result = NPMatrixGraphicsDilation(G, coreDila, originDilaX, originDilaY);
    if (!result) {
        return false;
    }
    
    result = NPMatrixGraphicsErosion(G, coreEro, originEroX, originEroY);
    if (!result) {
        // roll back to the backup
        NPMatrixReplaceWithMatrix(G, matrixBackup);
    }
    
    NPMatrixFree(matrixBackup);
    return result;
}

BOOL NPMatrixGraphicsOpen1Core(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY){
    return NPMatrixGraphicsOpen(G, core, originX, originY, core, originX, originY);
}

BOOL NPMatrixGraphicsClose1Core(NPMatrixType *G, NPMatrixType *core, unsigned long originX, unsigned long originY) {
    return NPMatrixGraphicsClose(G, core, originX, originY, core, originX, originY);
}
