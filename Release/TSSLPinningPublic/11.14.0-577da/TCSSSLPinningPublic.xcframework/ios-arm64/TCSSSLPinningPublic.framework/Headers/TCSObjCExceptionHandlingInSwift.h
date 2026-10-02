//
//  TCSObjCExceptionHandlingInSwift.h
//  TCSSSLPinning
//
//  Created by g.novik on 31.07.17.
//  Copyright © 2017 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

#import <Foundation/Foundation.h>

// Сделали динамическое имя файла, которое зависит от значения OBJC_EXCEPTION_HANDLING_CLASS_NAME
// Это позволяет задать уникальное имя этого класса для TCSSSLPinningPublic и TCSSSLPinning модулей. Они оба компилируют этот файл.
// OBJC_EXCEPTION_HANDLING_CLASS_NAME задается в настройках сборки в ключе GCC_PREPROCESSOR_DEFINITIONS
#if defined(OBJC_EXCEPTION_HANDLING_CLASS_NAME)
#define ObjCExceptionHandlingInSwiftClassName OBJC_EXCEPTION_HANDLING_CLASS_NAME
#endif

/// Класс-обертка, добавляющий возможность ловить ObjC-exceptions в Swift
@interface ObjCExceptionHandlingInSwiftClassName : NSObject

/// Метод для отлавливания NSException в Swift
+ (BOOL)catchException:(void (^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

// Важно объявить алиас после объявления класса, иначе компиляция упадет в местах использования алиаса с ошибкой Cannot find 'TCSObjCExceptionHandlingInSwift' in scope
#if defined(OBJC_EXCEPTION_HANDLING_CLASS_NAME)
@compatibility_alias TCSObjCExceptionHandlingInSwift OBJC_EXCEPTION_HANDLING_CLASS_NAME;
#endif
