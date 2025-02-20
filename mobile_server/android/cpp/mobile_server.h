#ifndef MOBILE_SERVER_H
#define MOBILE_SERVER_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Starts the Actix Web server inside a dedicated thread
 */
void start_server(void);

#endif  /* MOBILE_SERVER_H */
