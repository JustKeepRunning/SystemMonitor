//
//  RAMInfoController.m
//  ActivityMonitor++
//
//  Created by st on 23/05/2013.
//  Copyright (c) 2013 st. All rights reserved.
//

#import <mach/mach.h>
#import <mach/mach_host.h>
#import "AMLog.h"
#import "AMUtils.h"
#import "RAMInfoController.h"

@interface RAMInfoController()
- (NSUInteger)getRAMTotalMB;
- (void)getRAMUsage:(RAMInfo*)ramInfo;
@end

@implementation RAMInfoController

#pragma mark - public

- (RAMInfo*)getRAMInfo
{
    RAMInfo *ramInfo = [[RAMInfo alloc] init];
    
    ramInfo.totalRam = [self getRAMTotalMB];
    [self getRAMUsage:ramInfo];
        
    return ramInfo;
}

#pragma mark - private

- (NSUInteger)getRAMTotalMB
{
    return B_TO_MB([NSProcessInfo processInfo].physicalMemory);
}

- (void)getRAMUsage:(RAMInfo*)ramInfo
{
    mach_port_t             host_port = mach_host_self();
    mach_msg_type_number_t  host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pageSize;
    vm_statistics_data_t    vm_stat;
    
    host_page_size(host_port, &pageSize);
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
    {
        AMWarn(@"%s: host_statistics() has failed.", __PRETTY_FUNCTION__);
        return;
    }
    
    ramInfo.usedRam = B_TO_MB((vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pageSize);
    ramInfo.activeRam = B_TO_MB(vm_stat.active_count * pageSize);
    ramInfo.inactiveRam = B_TO_MB(vm_stat.inactive_count * pageSize);
    ramInfo.wiredRam = B_TO_MB(vm_stat.wire_count * pageSize);    
}

@end