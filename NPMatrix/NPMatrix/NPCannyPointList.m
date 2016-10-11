//
//  NPCannyPointList.m
//  Material Cutter
//
//  Created by Hydra on 15/8/18.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//

#import "NPCannyPointList.h"
#import "NPCommonAlgorithm.h"

struct canny_point_trace *trace_create(unsigned long node_count, unsigned long edge_count) {
    struct canny_point_trace *trace=malloc(sizeof(struct canny_point_trace));
    bzero(trace, sizeof(struct canny_point_trace));
    
    if (trace) {
        
        trace->all_nodes.count = node_count;
        if (node_count) {
            trace->all_nodes.list = calloc(node_count, sizeof(struct canny_point));
            if (trace->all_nodes.list==NULL) {
                goto err;
            }
            bzero(trace->all_nodes.list, node_count * sizeof(struct canny_point));
        }
        
        trace->edge_nodes.count = edge_count;
        if (edge_count) {
            trace->edge_nodes.list = calloc(edge_count, sizeof(struct canny_point));
            if (trace->edge_nodes.list==NULL) {
                goto err1;
            }
            bzero(trace->edge_nodes.list, edge_count * sizeof(struct canny_point));
        }
    }
    return trace;
    
err1:
    if (trace->edge_nodes.list) {
        free(trace->edge_nodes.list);
    }
err:
    free(trace);
    return NULL;
}

void trace_free(struct canny_point_trace *trace) {
    if (trace==NULL) {
        return;
    }
    
    if (trace->all_nodes.list) {
        free(trace->all_nodes.list);
    }
    
    if (trace->edge_nodes.list) {
        free(trace->edge_nodes.list);
    }
    
    free(trace);
    
}

BOOL pointlist_expand(struct canny_point_list *list, size_t count) {
    if (list==NULL) {
        return false;
    }
    
    CYPoint *pointsNew = expand_memory(list->list, list->count, count, sizeof(CYPoint));
    if (pointsNew) {
        list->list = pointsNew;
        list->count=count;
        return true;
    }
    return false;
}

BOOL pointlist_expand2x(struct canny_point_list *list) {
    return pointlist_expand(list, list->count?list->count*2:1);
}
