# adapted from https://github.com/lxml/lxml/blob/master/setup.py

import os
import re
import sys
import fnmatch
import os.path

# for command line options and supported environment variables, please
# see the end of 'setupinfo.py'

if (2, 7) != sys.version_info[:2] < (3, 5):
    print("This pyxpdf version requires Python 2.7, 3.5 or later.")
    sys.exit(1)

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

# make sure Cython finds include files in the project directory and not outside
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import setupinfo
import versioninfo

# override these and pass --static for a static build. See
# doc/build.txt for more information. If you do not pass --static
# changing this will have no effect.
STATIC_INCLUDE_DIRS = []
STATIC_LIBRARY_DIRS = []
STATIC_CFLAGS = []
STATIC_BINARIES = []

pyxpdf_version = versioninfo.version()
print("Building pyxpdf version %s." % pyxpdf_version)

OPTION_RUN_TESTS = setupinfo.has_option('run-tests')

extra_options = {}
if 'setuptools' in sys.modules:
    extra_options['zip_safe'] = False
    extra_options['python_requires'] = (
        # NOTE: keep in sync with Trove classifier list below.
        '>=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, != 3.4.*')

    try:
        import pkg_resources
    except ImportError:
        pass
    else:
        f = open("requirements.txt", "r")
        try:
            deps = [str(req) for req in pkg_resources.parse_requirements(f)]
        finally:
            f.close()
        extra_options['extras_require'] = {
            'source': deps,
            "dev": ["cython",],
        }

extra_options['package_data'] = {
    'pyxpdf.includes': [
        '*.pxd', '*.h'
    ],
}

extra_options['package_dir'] = {
    '': 'src'
}

extra_options['packages'] = [
    'pyxpdf', 'pyxpdf.includes'
]


def setup_extra_options():
    is_interesting_package = re.compile('.*/libxpdf.*').match

    def extract_files(directories, pattern='*'):
        def get_files(root, dir_path, files):
            return [(root, dir_path, filename)
                    for filename in fnmatch.filter(files, pattern)]

        file_list = []
        for dir_path in directories:
            for root, dirs, files in os.walk(dir_path):
                if is_interesting_package(dir_path):
                    file_list.extend(get_files(root, dir_path, files))
        return file_list

    def build_packages(files):
        packages = {}
        seen = set()
        for root_path, rel_path, filename in files:
            if filename in seen:
                # libxml2/libxslt header filenames are unique
                continue
            seen.add(filename)
            package_path = '.'.join(rel_path.split(os.sep)[:-1])
            if package_path in packages:
                root, package_files = packages[package_path]
                if root != root_path:
                    print("conflicting directories found for include package '%s': %s and %s"
                          % (package_path, root_path, root))
                    continue
            else:
                package_files = []
                packages[package_path] = (root_path, package_files)
            package_files.append(filename)

        return packages
        
    # Copy Global Extra Options
    extra_opts = dict(extra_options)

    # Build ext modules
    ext_modules = setupinfo.ext_modules(
        STATIC_INCLUDE_DIRS, STATIC_LIBRARY_DIRS,
        STATIC_CFLAGS, STATIC_BINARIES)
    extra_opts['ext_modules'] = ext_modules

    packages = extra_opts.get('packages', list())
    package_dir = extra_opts.get('package_dir', dict())
    package_data = extra_opts.get('package_data', dict())

    include_dirs = []  # keep them in order
    for extension in ext_modules:
        for inc_dir in extension.include_dirs:
            if inc_dir not in include_dirs:
                include_dirs.append(inc_dir)

    header_packages = build_packages(extract_files(include_dirs))

    for package_path, (root_path, filenames) in header_packages.items():
        if package_path:
            package = 'pyxpdf.includes.' + package_path
            packages.append(package)
        else:
            package = 'pyxpdf.includes'
        package_data[package] = filenames
        package_dir[package] = root_path

    return extra_opts


with open(os.path.join(os.path.abspath(os.path.dirname(__file__)), 'README.md',),  encoding='utf8') as f:
    readme = f.read()


setup(
    name="pyxpdf",
    version=pyxpdf_version,
    author="Ashutosh Varma",
    author_email="ashutoshvarma11@live.com",
    maintainer="Ashutosh Varma",
    maintainer_email="ashutoshvarma11@live.com",
    license="GPL",
    url="https://github.com/ashutoshvarma/pyxpdf",
    # bugtrack_url="https://github.com/ashutoshvarma/pyxpdf",
    description=(
        "Powerful and Pythonic PDF processing library based on xpdf-4.02"
    ),
    long_description=readme,
    long_description_content_type='text/markdown',
    keywords=[
        'pdf parser',
        'pdf converter',
        'text mining',
        'xpdf bindings',
    ],
    classifiers=[
         versioninfo.dev_status(),
        'Intended Audience :: Developers',
        'Intended Audience :: Information Technology',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: BSD License',
        'Programming Language :: Cython',
        # NOTE: keep in sync with 'python_requires' list above.
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: C',
        'Operating System :: OS Independent',
        'Topic :: Software Development :: Libraries :: Python Modules'
        'Topic :: Text Processing',
    ],

    **setup_extra_options()
)