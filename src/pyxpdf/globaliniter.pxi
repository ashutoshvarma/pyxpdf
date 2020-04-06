from cython.operator cimport preincrement as inc, predecrement as dec

from libcpp.string cimport string
from pyxpdf.includes.GlobalParams cimport GlobalParams, globalParams
from pyxpdf.includes.xpdf_error cimport ErrorCallback, setErrorCallback

cdef int GLOBAL_COUNT = 0
cdef string GLOBAL_CONFIG_FILE

cdef class GlobalParamsIniter:
    def __cinit__(self):
        global GLOBAL_COUNT
        global GLOBAL_CONFIG_FILE
        global globalParams
        if GLOBAL_COUNT == 0:
            global globalParams
            globalParams = new GlobalParams(<const char*>NULL if GLOBAL_CONFIG_FILE.size() == 0 else GLOBAL_CONFIG_FILE.c_str())

        # GLOBAL_COUNT++
        inc(GLOBAL_COUNT)
        # print(f"+ GLOBAL_COUNT = {GLOBAL_COUNT}")

    def __dealloc__(self):
        global GLOBAL_COUNT
        global globalParams
        dec(GLOBAL_COUNT)

        if GLOBAL_COUNT == 0:
            del globalParams
            globalParams = NULL
        # print(f"- GLOBAL_COUNT = {GLOBAL_COUNT}")


cdef set_global_config(object config_file):
    global GLOBAL_CONFIG_FILE
    GLOBAL_CONFIG_FILE = _chars(config_file)
