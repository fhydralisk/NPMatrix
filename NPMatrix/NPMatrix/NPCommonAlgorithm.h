//
//  NPCommonAlgorithm.h
//  Material Cutter
//
//  Created by Hydra on 15/8/12.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//

#import <Foundation/Foundation.h>

void q_sort(long list[],unsigned long m,unsigned long n);
unsigned long greatest_common_divisor(long a, long b);
void* expand_memory(void* old_ptr, size_t old_count, size_t new_count, size_t element_size);