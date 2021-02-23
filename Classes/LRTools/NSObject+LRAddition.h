//
//  NSObject+LRAddition.h
//  LRAD
//
//  Created by 张维凡 on 2020/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LRAddition)

/**
 判断
 对象是否 非 nil, NSNull
 数组是否非空
 字典是否非空
 字符串是否非空
 */
- (BOOL)lr_isNoEmpty;

- (BOOL)lr_isEmpty;

/**
 判断是否含有特殊字符 （是指 除数字 字母 文字以外的所有字符）
 **/
- (BOOL)lr_judgeTheillegalCharacter:(NSString *)content;

- (NSDictionary *)lr_dictionaryWithJsonString:(NSString *)jsonString;

- (NSString *)lr_stringWithJsonObj:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
