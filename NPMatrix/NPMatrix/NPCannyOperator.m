//
//  CannyCalc.m
//  Material Cutter
//
//  Created by Hydra on 15/8/9.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//


#import <math.h>

#import "NPCannyOperator.h"
#import "NPCannyPointList.h"

#import "NPMatrixType.h"
#import "NPMatrixOperate.h"
#import "NPMatrixGraphics.h"
#import "NPCommonMatrixes.h"
#import "NPMatrixUtilities.h"
#import "NPCommonAlgorithm.h"


long sqrtself(NPMatrixType *self, long element, unsigned long x, unsigned long y, void *param, BOOL *stop) {
    return (long)sqrtl(element);
}

//  Non-Maximum Suppression
long nms(NPMatrixType *self, long element, unsigned long x, unsigned long y, void *param, BOOL *stop) {
    NPMatrixType **mats = (NPMatrixType **)param;
    
    NPMatrixType *gradMagnitude=mats[0];
    NPMatrixType *gradX=mats[1];
    NPMatrixType *gradY=mats[2];
    
    // Get rid of edge points.
    if (x==0 || y==0 || x==NPMATRIX_WIDTH(self)-1 || y==NPMATRIX_HEIGHT(self)-1) {
        return 0;
    }
    
    long front, behind, e, dx, dy;
    
    NPMATRIX_GET_TYPE(long, e, gradMagnitude, x, y);
    NPMATRIX_GET_TYPE(long, dx, gradX, x, y);
    NPMATRIX_GET_TYPE(long, dy, gradY, x, y);
    if (dx==dy && dx==0) {
        return 0;
    }
    
    if (labs(dx)>labs(dy)) {
        long l,r,l1,r1;
        NPMATRIX_GET_TYPE(long, l, gradMagnitude, x-1, y);
        NPMATRIX_GET_TYPE(long, r, gradMagnitude, x+1, y);
        
        if (dx*dy>0) {
            NPMATRIX_GET_TYPE(long, l1, gradMagnitude, x-1, y-1);
            NPMATRIX_GET_TYPE(long, r1, gradMagnitude, x+1, y+1);
        } else {
            NPMATRIX_GET_TYPE(long, l1, gradMagnitude, x-1, y+1);
            NPMATRIX_GET_TYPE(long, r1, gradMagnitude, x+1, y-1);
        }
        
        front = l + (l1-l) * labs(dy) / labs(dx);
        behind = r + (r1-r) * labs(dy) / labs(dx);
        
    } else {
        long u,d, u1, d1;
        NPMATRIX_GET_TYPE(long, u, gradMagnitude, x, y-1);
        NPMATRIX_GET_TYPE(long, d, gradMagnitude, x, y+1);
        
        if (dx*dy>0) {
            NPMATRIX_GET_TYPE(long, u1, gradMagnitude, x-1, y-1);
            NPMATRIX_GET_TYPE(long, d1, gradMagnitude, x+1, y+1);
        } else {
            NPMATRIX_GET_TYPE(long, u1, gradMagnitude, x+1, y-1);
            NPMATRIX_GET_TYPE(long, d1, gradMagnitude, x-1, y+1);
        }
        
        front = u + (u1 - u) * labs(dx) / labs(dy);
        behind = d + (d1-d) *labs(dx) / labs(dy);
    }

    return (e > front && e >= behind) ? e : 0;
    
}

void select_threshold(NPMatrixType *mat, long *min_thresh, long *max_thresh) {
    //hist
    unsigned long max=512;
    unsigned long *hist = calloc(sizeof(long), max);
    bzero(hist, 256 * sizeof(long));
    
    for (unsigned long y=0; y<NPMATRIX_HEIGHT(mat); y++) {
        for (unsigned long x=0; x<NPMATRIX_WIDTH(mat); x++) {
            long e;
            NPMATRIX_GET_TYPE(long, e, mat, x, y);
            if (e<0) {
#ifdef DEBUG
                assert(false);
#endif
                e=0;
            }
            
            // expand if needed
            while (e>=max) {
                unsigned long *hist_expand = calloc(sizeof(long), max * 2);
                memcpy(hist_expand, hist, max * sizeof(long));
                bzero(hist_expand + max, max * sizeof(long));
                free(hist);
                hist = hist_expand;
                max *= 2;
            }
            
            hist[e]++;
        }
    }
    
    // CDF
    for (unsigned long i=2; i<max; i++) {
        hist[i]+=hist[i-1];
    }
    
    
#ifdef DEBUG
    assert(hist[0] + hist[max-1]==NPMATRIX_WIDTH(mat) * NPMATRIX_HEIGHT(mat));
#endif
    
    // select threshold
    unsigned long maxTh=0, minTh=0;
    for (long i=1; i<max; i++) {
        if (hist[i]*100/hist[max-1] >= 65) {
            maxTh=i;
            break;
        }
    }
    
    minTh=maxTh * 0.4;
    
    // special considerations...
    if (maxTh == 0) {
        maxTh = 2;
    }
    
    if (minTh == 0) {
        minTh = 1;
    }
    
    /*minTh=1;
     maxTh=2;*/
    
    free(hist);
    
    *max_thresh=maxTh;
    *min_thresh=minTh;

}

#define CHECK_SUCCESS(s, l) if (!s) goto l

NPMatrixType* NPMatrixCreateByUsingCannyOperator(NPMatrixType *mat, size_t gauss_radius, long double sigma) {
    
    
    NPMatrixType *lmat=NPMatrixCopyToType(mat, NPLongTypeMatrix);
    
    NPMatrixType *gauss = gauss_radius ? NPMatrixCreateGaussTemplate(gauss_radius, sigma) : NULL;
    NPMatrixType *fmat= gauss ? NPMatrixCreateFromTemplate(lmat, gauss) : lmat;
    
    NPMatrixFree(gauss);
    
    if (fmat != lmat) {
        NPMatrixFree(lmat);
    }
    
    NPMatrixType *sobleX=NPMatrixCreateSobleXTemplate();
    NPMatrixType *sobleY=NPMatrixCreateSobleYTemplate();
    
    NPMatrixType *gradX=NPMatrixCreateFromTemplate(fmat, sobleX);
    NPMatrixType *gradY=NPMatrixCreateFromTemplate(fmat, sobleY);
    
    NPMatrixDotDivLong(gradX, 4);
    NPMatrixDotDivLong(gradY, 4);
    
    NPMatrixFree(fmat);
    NPMatrixFree(sobleX);
    NPMatrixFree(sobleY);
    
    NPMatrixType *gradX2=NPMatrixCopy(gradX);
    NPMatrixType *gradY2=NPMatrixCopy(gradY);
    
    
    NPMatrixDotMutiplyMatrix(gradX2, gradX2);
    NPMatrixDotMutiplyMatrix(gradY2, gradY2);
    
    NPMatrixSum(gradX2, gradY2);
    NPMatrixModifyElementUsingLongTypeFunction(gradX2, sqrtself, NULL, NPDefaultOrder);
    NPMatrixType *gradMagnitude = gradX2;
    
    NPMatrixFree(gradY2);
    gradX2=NULL;
    
    
    // select threshold
    long minThreshold, maxThreshold;
    
    select_threshold(gradMagnitude, &minThreshold, &maxThreshold);
    
    // NMS
    NPMatrixType *nmsMatrix=NPMatrixCreate(NPMATRIX_HEIGHT(gradMagnitude), NPMATRIX_WIDTH(gradMagnitude), NPLongTypeMatrix);
    NPMatrixType *nmsCalcMats[3]={gradMagnitude, gradX, gradY};
    
    NPMatrixModifyElementUsingLongTypeFunction(nmsMatrix, nms, nmsCalcMats, NPDefaultOrder);
    
    NPMatrixFree(gradX);
    NPMatrixFree(gradY);
    NPMatrixFree(gradMagnitude);
    
    
    
    // double threshold operate
    
    NPMatrixType *resultMatrix = NPMatrixCreateZeroMatrix(NPMATRIX_HEIGHT(mat),
                                                          NPMATRIX_WIDTH(mat),
                                                          NPUCharTypeMatrix);
    
    unsigned char neighbours = 8;
    const CYPoint neighbour[8] =   {
                                    {.x=-1, .y=-1},
                                    {.x=-1, .y= 0},
                                    {.x=-1, .y= 1},
                                    {.x= 0, .y=-1},
                                    {.x= 0, .y= 1},
                                    {.x= 1, .y=-1},
                                    {.x= 1, .y= 0},
                                    {.x= 1, .y= 1},
                                   };
    
    size_t pointsMax = MIN(2048, NPMATRIX_WIDTH(nmsMatrix)*NPMATRIX_HEIGHT(nmsMatrix));
    CYPoint *scanPoints = calloc(sizeof(CYPoint), pointsMax);
    
    for (unsigned long y=1; y<NPMATRIX_HEIGHT(nmsMatrix)-1; y++) {
        for (unsigned long x=1; x<NPMATRIX_WIDTH(nmsMatrix)-1; x++) {
            long e;
            NPMATRIX_GET_TYPE(long, e, nmsMatrix, x, y);
            if (e >= maxThreshold) {
                NPMATRIX_PUT_TYPE(unsigned char, 255, resultMatrix, x, y);
            } else if (e>=minThreshold) {
                // trace un-determined edge points.
                unsigned long cur=0, tail=1;
                BOOL isTraceValid = false;
                
                scanPoints[0].x=x;
                scanPoints[0].y=y;
                NPMATRIX_PUT_TYPE(long, 0, nmsMatrix, x, y);
                
                while (cur < tail) {
                    
                    for (unsigned long i=0; i<neighbours; i++) {
                        long nextX=scanPoints[cur].x + neighbour[i].x;
                        long nextY=scanPoints[cur].y + neighbour[i].y;
                        
                        if (nextX < 0 || nextX >= NPMATRIX_WIDTH(nmsMatrix) ||
                            nextY < 0 || nextY >= NPMATRIX_HEIGHT(nmsMatrix)) {
                            continue;
                        }
                        
                        long p;
                        NPMATRIX_GET_TYPE(long, p, nmsMatrix, nextX, nextY);
                        if (p >= maxThreshold) {
                            isTraceValid = true;
                        } else if (p >= minThreshold) {
#ifdef DEBUG
                            if(tail >= NPMATRIX_HEIGHT(nmsMatrix) * NPMATRIX_WIDTH(nmsMatrix)) {
                                assert(false);
                            }
#endif
                            
                            if (tail >= pointsMax) {
                                // expand list
                                size_t pointsMaxNext = MIN(pointsMax * 2, NPMATRIX_HEIGHT(nmsMatrix) * NPMATRIX_WIDTH(nmsMatrix));
                                CYPoint *scanPoints_expand = calloc(sizeof(CYPoint), pointsMaxNext);
                                bzero(scanPoints_expand + pointsMax, (pointsMaxNext-pointsMax) * sizeof(CYPoint));
                                memcpy(scanPoints_expand, scanPoints, pointsMax * sizeof(CYPoint));
                                free(scanPoints);
                                scanPoints=scanPoints_expand;
                                pointsMax=pointsMaxNext;
                            }
                            
                            scanPoints[tail].x=nextX;
                            scanPoints[tail].y=nextY;
                            NPMATRIX_PUT_TYPE(long, 0, nmsMatrix, nextX, nextY);
                            tail++;
                        }
                    }
                    cur++;
                }
                
                if (isTraceValid) {
                    for (unsigned long i=0; i<tail; i++) {
                        NPMATRIX_PUT_TYPE(unsigned char, 255, resultMatrix, scanPoints[i].x, scanPoints[i].y);
                    }
                }
                
            }
            
        }
    }
    
    free(scanPoints);
    NPMatrixFree(nmsMatrix);
    
    return resultMatrix;
    
}

struct seal_paths {
    unsigned long count;
    struct canny_point_trace *traces;
};

void pathsFree(struct seal_paths *paths) {
    if (paths==NULL) {
        return;
    }
    
    for (unsigned long i=0; i<paths->count; i++) {
        if (paths->traces[i].edge_nodes.list) {
            free(paths->traces[i].edge_nodes.list);
        }
        if (paths->traces[i].all_nodes.list) {
            free(paths->traces[i].all_nodes.list);
        }
    }
    
    free(paths->traces);
    free(paths);
}

BOOL tracePoints(NPMatrixType *cannyCopy, struct canny_point_trace *trace, unsigned long x, unsigned long y) {
    const unsigned char neighbours = 8;
    const CYPoint neighbour[8] = {
        {.x=-1, .y=-1},
        {.x=-1, .y= 0},
        {.x=-1, .y= 1},
        {.x= 0, .y=-1},
        {.x= 0, .y= 1},
        {.x= 1, .y=-1},
        {.x= 1, .y= 0},
        {.x= 1, .y= 1},
    };
    
    CYPoint *points=calloc(NPMATRIX_AREA(cannyCopy), sizeof(CYPoint));
    if (points==NULL) {
        return false;
    }

    CYPoint *pointsEdge = calloc(NPMATRIX_AREA(cannyCopy), sizeof(CYPoint));
    if (pointsEdge==NULL) {
        free(points);
        return false;
    }
    
    unsigned long current=0, tail=1, ecurrent=0;
    points[0].x=x;
    points[0].y=y;
    NPMATRIX_PUT(128, cannyCopy, x, y);
    
    while (current<tail) {
        unsigned long cx,cy,ecount;
        cx=points[current].x;
        cy=points[current].y;
#ifdef DEBUG
        assert(cx<NPMATRIX_WIDTH(cannyCopy) && cy<NPMATRIX_HEIGHT(cannyCopy));
#endif
        ecount=0;
        
        for (int i=0; i<neighbours; i++) {
            long ccx,ccy;
            ccx=cx+neighbour[i].x;
            ccy=cy+neighbour[i].y;
            if (POINT_IN_NPMATRIX(cannyCopy, ccx, ccy)) {
                
                unsigned long e=NPMatrixGetLong(cannyCopy, ccx, ccy);
                if (e!=0) {
                    ecount++;
                    if (e==255) {
#ifdef DEBUG
                        assert(tail<NPMATRIX_AREA(cannyCopy));
#endif
                        points[tail].x=ccx;
                        points[tail].y=ccy;
                        NPMATRIX_PUT(128, cannyCopy, ccx, ccy);
                        tail++;
                    }
                }
            }
        }
        
        if (ecount <= 1) {
#ifdef DEBUG
            assert(ecurrent<NPMATRIX_AREA(cannyCopy));
#endif
            pointsEdge[ecurrent].x=cx;
            pointsEdge[ecurrent].y=cy;
            ecurrent++;
        }
        
        current++;

    }
    
    // zero the marked points
    
    for (unsigned long i=0; i<current; i++) {
        NPMATRIX_PUT(0, cannyCopy, points[i].x, points[i].y);
    }
    
    trace->all_nodes.count=current;
    if (current) {
        if (trace->all_nodes.list) {
            free(trace->all_nodes.list);
        }
        
        trace->all_nodes.list=calloc(current, sizeof(CYPoint));
        memcpy(trace->all_nodes.list, points, current*sizeof(CYPoint));
    } else {
        if (trace->all_nodes.list) {
            free(trace->all_nodes.list);
        }
        trace->all_nodes.list=NULL;
    }
    
    trace->edge_nodes.count=ecurrent;
    if (ecurrent) {
        if (trace->edge_nodes.list) {
            free(trace->edge_nodes.list);
        }
        
        trace->edge_nodes.list=calloc(ecurrent, sizeof(CYPoint));
        memcpy(trace->edge_nodes.list, pointsEdge, ecurrent*sizeof(CYPoint));
    } else {
        if (trace->edge_nodes.list) {
            free(trace->edge_nodes.list);
        }
        trace->edge_nodes.list=NULL;
    }
    
    free(points);
    free(pointsEdge);
    
    return true;

}

struct seal_paths * pathCreateBySeekSeal(NPMatrixType *cannyCopy) {
    
    
    size_t nPathsBuf=1024;
    struct canny_point_trace *traces = calloc(nPathsBuf, sizeof(struct canny_point_trace));
    bzero(traces, nPathsBuf * sizeof(struct canny_point_trace));
    
    unsigned long currentTrace=0;
    
    for (unsigned long y=0; y<NPMATRIX_HEIGHT(cannyCopy); y++) {
        for (unsigned long x=0; x<NPMATRIX_WIDTH(cannyCopy); x++) {
            unsigned long e = NPMatrixGetLong(cannyCopy, x, y);
            
            if (e == 255) {
                if (currentTrace == nPathsBuf) {
                    traces = expand_memory(traces, nPathsBuf, nPathsBuf * 2, sizeof(struct canny_point_trace));
                    nPathsBuf *= 2;
                }
                tracePoints(cannyCopy, &traces[currentTrace], x, y);
                currentTrace++;
            }
            
        }
    }
    struct seal_paths *path = malloc(sizeof(struct seal_paths));
    bzero(path, sizeof(struct seal_paths));
    
    path->count=currentTrace;
    
    if (currentTrace) {
        path->traces = calloc(currentTrace, sizeof(struct canny_point_trace));
        memcpy(path->traces, traces, currentTrace * sizeof(struct canny_point_trace));
    }
    
    free(traces);
    
    return path;
}

BOOL CannySeal(NPMatrixType *mat) {
    if (mat==NULL) {
        return false;
    }
    
    // check if it is a canny matrix
    for (unsigned long y=0; y<NPMATRIX_HEIGHT(mat); y++) {
        for (unsigned long x=0; x<NPMATRIX_WIDTH(mat); x++) {
            unsigned char e = NPMatrixGetLong(mat, x, y);
            if (e!=0 && e!=255) {
                return false;
            }
        }
    }
    
    NPMatrixType *cannyCopy=NPMatrixCopy(mat);

    // seek for paths
    struct seal_paths *paths; // remember to free traces
    //bzero(&paths, sizeof(paths));
    
    paths = pathCreateBySeekSeal(cannyCopy);
    NPMatrixFree(cannyCopy);
    cannyCopy=NULL;
    
    // sort path
    // threshold:
    unsigned long minPathNodes=3;
    
    unsigned long current=0, tail=paths->count;
    while (current<tail) {
        struct canny_point_trace *currentTrace=&paths->traces[current];
        if (currentTrace->all_nodes.count<=minPathNodes) {
            //swap
            tail--;
            struct canny_point_trace temp;
            memcpy(&temp, &paths->traces[tail], sizeof(struct canny_point_trace));
            memcpy(&paths->traces[tail], currentTrace, sizeof(struct canny_point_trace));
            memcpy(currentTrace, &temp, sizeof(struct canny_point_trace));
        }
        current++;
    }
    
    cannyCopy = NPMatrixCopy(mat);
    for (unsigned long i=tail; i<paths->count; i++) {
        for (unsigned long j=0; j<paths->traces[i].all_nodes.count; j++) {
            NPMATRIX_PUT(0, cannyCopy, paths->traces[i].all_nodes.list[j].x, paths->traces[i].all_nodes.list[j].y);
        }
    }
    
    NPMatrixType *cannyCopy2 = NPMatrixCopy(cannyCopy);
    NPMatrixType *core = NPMatrixCreate(3, 3, NPUCharTypeMatrix);
    NPMATRIX_FOREACH_Y_X(core, x, y) {
        NPMATRIX_PUT_TYPE(unsigned char, 1, core, x, y);
    }
    
    NPMatrixGraphicsClose1Core(cannyCopy2, core, 1, 1);
    
    NPMatrixFree(core);
    
    NPMatrixSub(cannyCopy2, cannyCopy);
    
    // seek for closed points that near the "edge" points.
    unsigned long seeksize=5;
    for (unsigned long i=0; i<tail; i++) {
        for (unsigned long j=0; j<paths->traces[i].edge_nodes.count; j++) {
            unsigned long cx=paths->traces[i].edge_nodes.list[j].x;
            unsigned long cy=paths->traces[i].edge_nodes.list[j].y;
            
            for (unsigned long x=0; x<seeksize; x++) {
                for (unsigned long y=0; y<seeksize; y++) {
                    long ccx=cx + x - seeksize/2;
                    long ccy=cy + y - seeksize/2;
                    if (POINT_IN_NPMATRIX(cannyCopy2, ccx, ccy)) {
                        long e=NPMatrixGetLong(cannyCopy2, ccx, ccy);
                        if (e) {
                            NPMATRIX_PUT(e, cannyCopy, ccx, ccy);
                        }
                    }
                }
            }
        }
    }
    
    NPMatrixFree(cannyCopy2);
    NPMatrixReplaceWithMatrix(mat, cannyCopy);
    NPMatrixFree(cannyCopy);
    
    pathsFree(paths);
    
    return true;
}

