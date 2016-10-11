//
//  NPCannyPointList.h
//  Material Cutter
//
//  Created by Hydra on 15/8/18.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct canny_point {
    long x;
    long y;
} CYPoint;

typedef struct canny_point_list {
    unsigned long count;
    struct canny_point *list;
} CYPointList;

typedef struct canny_point_trace {
    struct canny_point_list all_nodes;
    // nodes
    struct canny_point_list edge_nodes;
} CYPointTrace;

struct canny_point_trace *trace_create(unsigned long node_count, unsigned long edge_count);
void trace_free(struct canny_point_trace *trace);
BOOL pointlist_expand(struct canny_point_list *list, size_t count);
BOOL pointlist_expand2x(struct canny_point_list *list);