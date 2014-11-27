//
//  main.m
//  rmapp
//
//  Created by BlueCocoa on 14/11/27.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <spawn.h>
#import <sys/types.h>
#import <sys/wait.h>
#import <UIKit/UIKit.h>

#ifndef MOBILEINSTALLATION_H_
#define MOBILEINSTALLATION_H_
typedef void (*MobileInstallationCallback)(CFDictionaryRef information);
extern int MobileInstallationUninstallForLaunchServices(CFStringRef bundleIdentifier, CFDictionaryRef parameters, MobileInstallationCallback callback, void *unknown);
#endif

extern char **environ;

void uicache(void);

void uicache(void){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="uicache";
    char *args[2];
    args[0]=cmd;
    args[1]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/usr/bin/uicache",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

void rm(NSString *);

void rm(NSString *path){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="rm";
    char opt[]="-rf";
    char *args[4];
    args[0]=cmd;
    args[1]=opt;
    args[2]=(char *)[path UTF8String];
    args[3]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/bin/rm",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

NSString * BundlePathWithBundleID(NSString *bundle);

NSString * BundlePathWithBundleID(NSString *bundle){
    NSFileManager * fileManager = [NSFileManager defaultManager];
    for (NSString * appRealPath in [fileManager contentsOfDirectoryAtPath:@"/var/mobile/Applications/" error:nil]) {
        NSString * realPath = [@"/var/mobile/Applications/" stringByAppendingFormat:@"%@/",appRealPath];
        NSEnumerator *enumerator = [fileManager enumeratorAtPath:realPath];
        NSString *path;
        while ((path = [enumerator nextObject]))
        {
            if ([path hasSuffix:@"app"]) {
                break;
            }
        }
        NSString *bundlePath = @"NOT EXISTS";
        if (path.length != 0) {
            bundlePath = [realPath stringByAppendingString:path];
        }
        NSString *infoPath = [realPath stringByAppendingFormat:@"%@/Info.plist",path];
        NSDictionary *infoData = [[NSDictionary alloc] initWithContentsOfFile:infoPath];
        NSString *key = [infoData valueForKey:@"CFBundleIdentifier"];
        
        if (key.length > 0 && [key isEqualToString:bundle]) {
            return realPath;
        }
    }
    return @"NOT EXISTS";
}

int main (int argc, const char * argv[])
{
    @autoreleasepool
    {
        if (argc > 1) {
            for (int i = 1; i < argc; i++) {
                CFStringRef identifier = CFStringCreateWithCString(kCFAllocatorDefault, argv[i], kCFStringEncodingUTF8);
                if (identifier == NULL) {
                    continue;
                }
                if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
                    MobileInstallationUninstallForLaunchServices(identifier, NULL, NULL, NULL);
                } else {
                    rm(BundlePathWithBundleID((__bridge NSString *)(identifier)));
                }
                CFRelease(identifier);
            }
            uicache();
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
            
            }
        }
    }
    return 0;
}
