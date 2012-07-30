//
//  sqlite3_extension_functions.c
//  ColorName
//
//  Created by Osamu Noguchi on 7/25/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#include "sqlite3.h"
#include "sqlite3_extension_functions.h"
#include "math.h"
#include "assert.h"

void sqlite3_extension_pow(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    assert(argc == 2);
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL){
        sqlite3_result_null(context);
        return;
    }
    double value1 = sqlite3_value_double(argv[0]);
    double value2 = sqlite3_value_double(argv[1]);
    sqlite3_result_double(context, pow(value1, value2));
}
