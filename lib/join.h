#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "cpct.h"

int nestedLoopJoin (column_customer *c_customer, column_orders *c_orders, int tamCustomer, int tamOrders, float * t_result);
int hashJoin (column_customer *c_customer, column_orders *c_orders, int tamCustomer, int tamOrders, float * t_result);