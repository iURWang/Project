//
//  NSString+UI.m
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "NSString+UI.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

#define MD5_CHAR_TO_STRING_16 [NSString stringWithFormat:               \
@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",    \
result[0], result[1], result[2], result[3],                             \
result[4], result[5], result[6], result[7],                             \
result[8], result[9], result[10], result[11],                           \
result[12], result[13], result[14], result[15]]                         \

@implementation NSString (UI)

- (BOOL)includesString:(NSString *)string {
  if (!string || string.length <= 0) {
    return NO;
  }
  
  if ([self respondsToSelector:@selector(containsString:)]) {
    return [self containsString:string];
  }
  
  return [self rangeOfString:string].location != NSNotFound;
}

- (NSString *)trim {
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trimAllWhiteSpace {
  return [self stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)trimLineBreakCharacter {
  return [self stringByReplacingOccurrencesOfString:@"[\r\n]" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)md5 {
  const char *cStr = [self UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
  return MD5_CHAR_TO_STRING_16;
}

+ (NSString *)hexLetterStringWithInteger:(NSInteger)integer {
  NSAssert(integer < 16, @"要转换的数必须是16进制里的个位数，也即小于16，但你传给我是%@", @(integer));
  
  NSString *letter = nil;
  switch (integer) {
    case 10:
      letter = @"A";
      break;
    case 11:
      letter = @"B";
      break;
    case 12:
      letter = @"C";
      break;
    case 13:
      letter = @"D";
      break;
    case 14:
      letter = @"E";
      break;
    case 15:
      letter = @"F";
      break;
    default:
      letter = [[NSString alloc]initWithFormat:@"%@", @(integer)];
      break;
  }
  return letter;
}

+ (NSString *)hexStringWithInteger:(NSInteger)integer {
  NSString *hexString = @"";
  NSInteger remainder = 0;
  for (NSInteger i = 0; i < 9; i++) {
    remainder = integer % 16;
    integer = integer / 16;
    NSString *letter = [self hexLetterStringWithInteger:remainder];
    hexString = [letter stringByAppendingString:hexString];
    if (integer == 0) {
      break;
    }
    
  }
  return hexString;
}

+ (NSString *)stringByConcat:(id)firstArgv, ... {
  if (firstArgv) {
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"%@", firstArgv];
    
    va_list argumentList;
    va_start(argumentList, firstArgv);
    id argument;
    while ((argument = va_arg(argumentList, id))) {
      [result appendFormat:@"%@", argument];
    }
    va_end(argumentList);
    
    return [result copy];
  }
  return nil;
}

+ (NSString *)timeStringWithMinsAndSecsFromSecs:(double)seconds {
  NSUInteger min = floor(seconds / 60);
  NSUInteger sec = floor(seconds - min * 60);
  return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
}

- (NSString *)removeMagicalChar {
  if (self.length == 0) {
    return self;
  }
  
  NSError *error = nil;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\u0300-\u036F]" options:NSRegularExpressionCaseInsensitive error:&error];
  NSString *modifiedString = [regex stringByReplacingMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length) withTemplate:@""];
  return modifiedString;
}

- (NSUInteger)lengthWhenCountingNonASCIICharacterAsTwo {
  NSUInteger characterLength = 0;
  char *p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
  for (NSInteger i = 0, l = [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i < l; i++) {
    if (*p) {
      characterLength++;
    }
    p++;
  }
  return characterLength;
}

- (NSUInteger)transformIndexToDefaultModeWithIndex:(NSUInteger)index {
  CGFloat strlength = 0.f;
  NSInteger i = 0;
  for (i = 0; i < self.length; i++) {
    unichar character = [self characterAtIndex:i];
    if (isascii(character)) {
      strlength += 1;
    } else {
      strlength += 2;
    }
    if (strlength >= index + 1) return i;
  }
  return 0;
}

- (NSRange)transformRangeToDefaultModeWithRange:(NSRange)range {
  CGFloat strlength = 0.f;
  NSRange resultRange = NSMakeRange(NSNotFound, 0);
  NSInteger i = 0;
  for (i = 0; i < self.length; i++) {
    unichar character = [self characterAtIndex:i];
    if (isascii(character)) {
      strlength += 1;
    } else {
      strlength += 2;
    }
    if (strlength >= range.location + 1) {
      if (resultRange.location == NSNotFound) {
        resultRange.location = i;
      }
      
      if (range.length > 0 && strlength >= NSMaxRange(range)) {
        resultRange.length = i - resultRange.location + (strlength == NSMaxRange(range) ? 1 : 0);
        return resultRange;
      }
    }
  }
  return resultRange;
}

- (NSString *)substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
  index = countingNonASCIICharacterAsTwo ? [self transformIndexToDefaultModeWithIndex:index] : index;
  NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:index];
  return [self substringFromIndex:lessValue ? NSMaxRange(range) : range.location];
}

- (NSString *)substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index {
  return [self substringAvoidBreakingUpCharacterSequencesFromIndex:index lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (NSString *)substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
  index = countingNonASCIICharacterAsTwo ? [self transformIndexToDefaultModeWithIndex:index] : index;
  NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:index];
  return [self substringToIndex:lessValue ? range.location : NSMaxRange(range)];
}

- (NSString *)substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index {
  return [self substringAvoidBreakingUpCharacterSequencesToIndex:index lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (NSString *)substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
  range = countingNonASCIICharacterAsTwo ? [self transformRangeToDefaultModeWithRange:range] : range;
  NSRange characterSequencesRange = lessValue ? [self downRoundRangeOfComposedCharacterSequencesForRange:range] : [self rangeOfComposedCharacterSequencesForRange:range];
  NSString *resultString = [self substringWithRange:characterSequencesRange];
  return resultString;
}

- (NSString *)substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range {
  return [self substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (NSRange)downRoundRangeOfComposedCharacterSequencesForRange:(NSRange)range {
  if (range.length == 0) {
    return range;
  }
  
  NSRange resultRange = [self rangeOfComposedCharacterSequencesForRange:range];
  if (NSMaxRange(resultRange) > NSMaxRange(range)) {
    return [self downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(range.location, range.length - 1)];
  }
  return resultRange;
}

- (NSString *)stringByRemoveCharacterAtIndex:(NSUInteger)index {
  NSRange rangeForRemove = [self rangeOfComposedCharacterSequenceAtIndex:index];
  NSString *resultString = [self stringByReplacingCharactersInRange:rangeForRemove withString:@""];
  return resultString;
}

- (NSString *)stringByRemoveLastCharacter {
  return [self stringByRemoveCharacterAtIndex:self.length - 1];
}

@end

@implementation NSString (StringFormat)
+ (instancetype)stringWithNSInteger:(NSInteger)integerValue {
  return [NSString stringWithFormat:@"%@", @(integerValue)];
}

+ (instancetype)stringWithCGFloat:(CGFloat)floatValue {
  return [NSString stringWithCGFloat:floatValue decimal:2];
}

+ (instancetype)stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal {
  NSString *formatString = [NSString stringWithFormat:@"%%.%@f", @(decimal)];
  return [NSString stringWithFormat:formatString, floatValue];
}
@end
