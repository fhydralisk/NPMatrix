//
//  NPCommonAlgorithm.m
//  Material Cutter
//
//  Created by Hydra on 15/8/12.
//  Copyright (c) 2015年 Hydra. All rights reserved.
//

#import "NPCommonAlgorithm.h"

void swap(long *x,long *y)
{
    long temp;
    temp = *x;
    *x = *y;
    *y = temp;
}

unsigned long choose_pivot(unsigned long i,unsigned long j )
{
    return((i+j) /2);
}

void q_sort(long list[],unsigned long m,unsigned long n)
{
    long key,i,j,k;
    if( m < n)
    {
        k = choose_pivot(m,n);
        swap(&list[m],&list[k]);
        key = list[m];
        i = m+1;
        j = n;
        while(i <= j)
        {
            while((i <= n) && (list[i] <= key))
                i++;
            while((j >= m) && (list[j] > key))
                j--;
            if( i < j)
                swap(&list[i],&list[j]);
        }
        // 交换两个元素的位置
        swap(&list[m],&list[j]);
        // 递归地对较小的数据序列进行排序
        
        q_sort(list,m,j-1);
        q_sort(list,j+1,n);
    }
}


unsigned long greatest_common_divisor(long a, long b) {
    long c;
    a=labs(a);
    b=labs(b);
    c=a%b;
    while( c!=0 )
    {
        a=b;
        b=c;
        c=a%b;
    }
    return b;
}

void* expand_memory(void* old_ptr, size_t old_count, size_t new_count, size_t element_size) {
    
#ifdef DEBUG
    assert((old_ptr==NULL && old_count==0) || (old_count!=0 && old_ptr!=NULL));
    assert(element_size!=0);
    assert(new_count > old_count);
#endif
    
    if (element_size*new_count==0 || new_count<old_count) {
        return NULL;
    }
    
    if (new_count==old_count) {
        return old_ptr;
    }
    
    void *new_ptr=calloc(new_count, element_size);
    
    if (new_ptr) {
        bzero(new_ptr + old_count, element_size * ( new_count - old_count ));
        if (old_ptr!=NULL) {
            memcpy(new_ptr, old_ptr, element_size * old_count);
            free(old_ptr);
        }
    }
    
    return new_ptr;
}

