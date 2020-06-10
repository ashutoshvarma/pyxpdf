# adapted from https://github.com/lxml/lxml/blob/master/setupinfo.py

import sys
import io
import os
import os.path
import subprocess
from distutils.core import Extension
from distutils.errors import CompileError, DistutilsOptionError
from distutils.command.build_ext import build_ext as _build_ext
from versioninfo import get_base_dir

try:
    import Cython.Compiler.Version
    CYTHON_INSTALLED = True
except ImportError:
    CYTHON_INSTALLED = False

SOURCE_PATH = "src"
INCLUDE_PACKAGE_PATH = os.path.join(SOURCE_PATH, 'pyxpdf', 'includes')
EXT_CXX_INCLUDE = os.path.join(SOURCE_PATH, "pyxpdf", "cpp")

EXT_MODULES = ["pyxpdf.xpdf", ]
EXT_MODULES_EXTRA_SRC = {
    "pyxpdf.xpdf": [os.path.join(SOURCE_PATH, 'pyxpdf', 'cpp', 'BitmapOutputDev.cc'), ]
}
# COMPILED_MODULES = ['pyxpdf.pdf']
COMPILED_MODULES = []
HEADER_FILES = ['pyxpdf_defs.h', ]

if hasattr(sys, 'pypy_version_info') or (
    getattr(sys, 'implementation', None) and sys.implementation.name != 'cpython'):
    # disable Cython compilation of Python modules in PyPy and other non-CPythons
    del COMPILED_MODULES[:]


if sys.version_info[0] >= 3:
    _system_encoding = sys.getdefaultencoding()
    if _system_encoding is None:
        _system_encoding = "iso-8859-1"  # :-)

    def decode_input(data):
        if isinstance(data, str):
            return data
        return data.decode(_system_encoding)
else:
    def decode_input(data):
        return data


def env_var(name):
    value = os.getenv(name)
    if value:
        value = decode_input(value)
        if sys.platform == 'win32' and ';' in value:
            return value.split(';')
        else:
            return value.split()
    else:
        return []


def _prefer_reldirs(base_dir, dirs):
    return [
        os.path.relpath(path) if path.startswith(base_dir) else path
        for path in dirs
    ]


def ext_modules(static_include_dirs, static_library_dirs,
                static_cflags, static_binaries):
    from get_libxpdf import get_prebuilt_libxpdf
    get_prebuilt_libxpdf(
        OPTION_DOWNLOAD_DIR, static_include_dirs, static_library_dirs)

    modules = EXT_MODULES + COMPILED_MODULES

    module_files = list(os.path.join(SOURCE_PATH, *module.split('.'))
                        for module in modules)
    cpp_files_exist = [os.path.exists(module + '.cpp')
                       for module in module_files]

    use_cython = True
    if CYTHON_INSTALLED and (OPTION_WITH_CYTHON or not all(cpp_files_exist)):
        print("Building with Cython %s." % Cython.Compiler.Version.version)
        # generate module cleanup code
        from Cython.Compiler import Options
        Options.generate_cleanup_code = 3
        Options.clear_to_none = False
    elif not OPTION_WITHOUT_CYTHON and not all(cpp_files_exist):
        for exists, module in zip(cpp_files_exist, module_files):
            if not exists:
                raise RuntimeError(
                    "ERROR: Trying to build without Cython, but pre-generated '%s.cpp' "
                    "is not available (pass --without-cython to ignore this error)." % module)
    else:
        if not all(cpp_files_exist):
            for exists, module in zip(cpp_files_exist, module_files):
                if not exists:
                    print("WARNING: Trying to build without Cython, but pre-generated "
                          "'%s.cpp' is not available." % module)
        use_cython = False
        print("Building without Cython.")


    base_dir = get_base_dir()
    _include_dirs = _prefer_reldirs(
        base_dir, include_dirs(static_include_dirs) + [
            SOURCE_PATH,
            INCLUDE_PACKAGE_PATH,
            EXT_CXX_INCLUDE,
        ])
    _library_dirs = _prefer_reldirs(
        base_dir, library_dirs(static_library_dirs))
    _cflags = cflags(static_cflags)
    _ldflags = ['-isysroot', get_xcode_isysroot()
                ] if sys.platform == 'darwin' else None
    _define_macros = define_macros()
    _libraries = libraries()

    if _library_dirs:
        message = "Building against libxpdf in "
        print(message + "the following directory: " +
              _library_dirs[0])

    if OPTION_AUTO_RPATH:
        runtime_library_dirs = _library_dirs
    else:
        runtime_library_dirs = []

    if CYTHON_INSTALLED and OPTION_SHOW_WARNINGS:
        from Cython.Compiler import Errors
        Errors.LEVEL = 0

    cythonize_directives = {
        'binding': True,
    }
    if OPTION_WITH_COVERAGE:
        cythonize_directives['linetrace'] = True
    if OPTION_WITH_SIGNATURE:
        cythonize_directives['embedsignature'] = True

    result = []
    for module, src_file in zip(modules, module_files):
        is_py = module in COMPILED_MODULES
        main_module_source = src_file + (
            '.cpp' if not use_cython else '.py' if is_py else '.pyx')
        result.append(
            Extension(
                module,
                sources=[main_module_source] + EXT_MODULES_EXTRA_SRC.get(module, []),
                depends=find_dependencies(module),
                extra_compile_args=_cflags,
                extra_link_args=None if is_py else _ldflags,
                extra_objects=None if is_py else static_binaries,
                define_macros=_define_macros,
                include_dirs=_include_dirs,
                library_dirs=None if is_py else _library_dirs,
                runtime_library_dirs=None if is_py else runtime_library_dirs,
                libraries=None if is_py else _libraries,
            ))

    gdb = False
    if CYTHON_INSTALLED and OPTION_WITH_CYTHON_GDB:
        gdb = True

    if CYTHON_INSTALLED and use_cython:
        # build .cpp files right now and convert Extension() objects
        from Cython.Build import cythonize
        result = cythonize(result, compiler_directives=cythonize_directives, gdb_debug=gdb)

    return result


def find_dependencies(module):
    if not CYTHON_INSTALLED:
        return []
    base_dir = get_base_dir()
    package_dir = os.path.join(base_dir, SOURCE_PATH, 'pyxpdf')
    includes_dir = os.path.join(base_dir, INCLUDE_PACKAGE_PATH)

    pxd_files = [
        os.path.join(INCLUDE_PACKAGE_PATH, filename)
        for filename in os.listdir(includes_dir)
        if filename.endswith('.pxd')
    ]

    if module == 'pyxpdf.xpdf':
        pxi_files = [
            os.path.join(SOURCE_PATH, 'pyxpdf', filename)
            for filename in os.listdir(package_dir)
            if filename.endswith('.pxi')
        ]
    else:
        pxi_files = pxd_files = []

    return pxd_files + pxi_files


def libraries():
    libs = ["xpdf"]
    if sys.platform in ('win32',):
        xpdf_deps = ['shell32', 'advapi32']
        libs.extend(xpdf_deps)
    return libs


def library_dirs(static_library_dirs):
    return static_library_dirs


def include_dirs(static_include_dirs):
    return static_include_dirs


def cflags(static_cflags):
    result = []
    if not OPTION_SHOW_WARNINGS:
        result.append('-w')
    if OPTION_DEBUG_GCC:
        result.append('-g2')

    if sys.platform in ('win32',):
        # cython's warpper for std::move depends on __cplusplus macro
        # for MSVC to report that correctly in 19.xx minor series
        # we need this compiler flag.
        # https://devblogs.microsoft.com/cppblog/msvc-now-correctly-reports-__cplusplus/
        # https://github.com/cython/cython/blob/master/Cython/Includes/libcpp/utility.pxd
        result.append('/Zc:__cplusplus')

    if not static_cflags:
        static_cflags = env_var('CFLAGS')
    result.extend(static_cflags)
    return result


def define_macros():
    macros = []
    if OPTION_WITHOUT_ASSERT:
        macros.append(('PYREX_WITHOUT_ASSERTIONS', None))
    if OPTION_WITHOUT_THREADING:
        macros.append(('WITHOUT_THREADING', None))
    if OPTION_WITH_REFNANNY:
        macros.append(('CYTHON_REFNANNY', None))
    if OPTION_WITH_COVERAGE:
        macros.append(('CYTHON_TRACE_NOGIL', '1'))
    # Disable showing C lines in tracebacks, unless explicitly requested.
    macros.append(('CYTHON_CLINE_IN_TRACEBACK',
                   '1' if OPTION_WITH_CLINES else '0'))
    return macros


def run_command(cmd, *args):
    if not cmd:
        return ''
    if args:
        cmd = ' '.join((cmd,) + args)

    p = subprocess.Popen(cmd, shell=True,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout_data, errors = p.communicate()

    if errors:
        return ''
    return decode_input(stdout_data).strip()


def get_xcode_isysroot():
    return run_command('xcrun', '--show-sdk-path')


# Option handling:

def has_option(name):
    try:
        sys.argv.remove('--%s' % name)
        return True
    except ValueError:
        pass
    # allow passing all cmd line options also as environment variables
    env_val = os.getenv(name.upper().replace('-', '_'), 'false').lower()
    if env_val == "true":
        return True
    return False


def option_value(name):
    for index, option in enumerate(sys.argv):
        if option == '--' + name:
            if index+1 >= len(sys.argv):
                raise DistutilsOptionError(
                    'The option %s requires a value' % option)
            value = sys.argv[index+1]
            sys.argv[index:index+2] = []
            return value
        if option.startswith('--' + name + '='):
            value = option[len(name)+3:]
            sys.argv[index:index+1] = []
            return value
    env_val = os.getenv(name.upper().replace('-', '_'))
    return env_val


# pick up any commandline options and/or env variables
# OPTION_WITH_UNICODE_STRINGS = has_option('with-unicode-strings')
OPTION_WITHOUT_ASSERT = has_option('without-assert')
OPTION_WITHOUT_THREADING = has_option('without-threading')
OPTION_WITHOUT_CYTHON = has_option('without-cython')
OPTION_WITH_CYTHON = has_option('with-cython')
OPTION_WITH_CYTHON_GDB = has_option('cython-gdb')
OPTION_WITH_REFNANNY = has_option('with-refnanny')
OPTION_WITH_COVERAGE = has_option('with-coverage')
OPTION_WITH_CLINES = has_option('with-clines')
OPTION_WITH_SIGNATURE = has_option('with-signature')
if OPTION_WITHOUT_CYTHON:
    CYTHON_INSTALLED = False
OPTION_DEBUG_GCC = has_option('debug-gcc')
OPTION_SHOW_WARNINGS = has_option('warnings')
OPTION_AUTO_RPATH = has_option('auto-rpath')
OPTION_DOWNLOAD_DIR = option_value('download-dir')
if OPTION_DOWNLOAD_DIR is None:
    OPTION_DOWNLOAD_DIR = 'libs'
