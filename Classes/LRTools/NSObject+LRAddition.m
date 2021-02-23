//
//  NSObject+LRAddition.m
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import "NSObject+LRAddition.h"

@implementation NSObject (LRAddition)

- (BOOL)lr_isNoEmpty {
    if ([self isKindOfClass:[NSNull class]]) {
        return NO;
    } else if ([self isKindOfClass:[NSString class]]) {
        return [(NSString *)self length] > 0;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [(NSData *)self length] > 0;
    } else if ([self isKindOfClass:[NSArray class]]) {
        return [(NSArray *)self count] > 0;
    } else if ([self isKindOfClass:[NSMutableArray class]]) {
        return [(NSMutableArray *)self count] > 0;
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)self count] > 0;
    } else if ([self isKindOfClass:[NSMutableDictionary class]]) {
        return [(NSDictionary *)self count] > 0;
    }
    return YES;
}

- (BOOL)lr_isEmpty {
    return ![self lr_isNoEmpty];
}

- (BOOL)lr_judgeTheillegalCharacter:(NSString *)content {
    // 提示 标签不能输入特殊字符
    NSString *str =@"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (![emailTest evaluateWithObject:content]) {
        return YES;
    }
    return NO;
}

- (NSDictionary *)lr_dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
//        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)lr_stringWithJsonObj:(NSDictionary *)dict {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&err];
    if (err) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
