//
//  SetHostnameTrigger.m
//  iTerm2
//
//  Created by George Nachman on 11/9/15.
//
//

#import "SetHostnameTrigger.h"
#import "VT100Screen+Mutation.h"

@implementation SetHostnameTrigger

+ (NSString *)title {
    return @"Report User & Host";
}

- (BOOL)takesParameter{
    return YES;
}

- (NSString *)triggerOptionalParameterPlaceholderWithInterpolation:(BOOL)interpolation {
    return @"username@hostname";
}

- (BOOL)isIdempotent {
    return YES;
}

- (BOOL)performActionWithCapturedStrings:(NSArray<NSString *> *)stringArray
                          capturedRanges:(const NSRange *)capturedRanges
                               inSession:(id<iTermTriggerSession>)aSession
                                onString:(iTermStringLine *)stringLine
                    atAbsoluteLineNumber:(long long)lineNumber
                        useInterpolation:(BOOL)useInterpolation
                                    stop:(BOOL *)stop {
    // Need to stop the world to get scope, provided it is needed. Hostname changes are slow & rare that this is ok.
    [[self paramWithBackreferencesReplacedWithValues:stringArray
                                               scope:[aSession triggerSessionVariableScopeProvider:self]
                                               owner:aSession
                                    useInterpolation:useInterpolation] then:^(NSString * _Nonnull remoteHost) {
        if (remoteHost.length) {
            [aSession triggerSession:self setRemoteHostName:remoteHost];
        }
    }];
    return YES;
}

@end
