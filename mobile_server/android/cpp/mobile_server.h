#ifndef MOBILE_SERVER_H
#define MOBILE_SERVER_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * **Hàm gọi từ Android để chạy server**
 */
jstring Java_com_rustserver_MainActivity_start_1server(JNIEnv env, JClass);

#endif  /* MOBILE_SERVER_H */
