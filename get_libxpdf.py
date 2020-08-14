"""
Adapted from lxml buildlibxml.py
"""
import os
import platform
import re
import sys
import tarfile
import zipfile
from contextlib import closing

try:
    from urllib import urlcleanup, urlopen, urlretrieve

    from urlparse import unquote, urljoin
except ImportError:
    from urllib.parse import unquote, urljoin
    from urllib.request import urlcleanup, urlopen, urlretrieve

try:
    from io import BytesIO as StringIO
except ImportError:
    from StringIO import StringIO

multi_make_options = []
try:
    import multiprocessing

    cpus = multiprocessing.cpu_count()
    if cpus > 1:
        if cpus > 5:
            cpus = 5
        multi_make_options = ["--parallel %d" % (cpus + 1)]
except:
    pass


def is64():
    return sys.maxsize > 2 ** 32


def download_and_extract_libxpdf(destdir):
    url = "https://github.com/ashutoshvarma/libxpdf/releases"
    filenames = list(_list_dir_urllib(url))

    lib_version = find_max_version(
        "libxpdf", filenames, re.compile(r"/releases/tag/v([0-9.]+[0-9])$")
    )
    release_path = "/download/v%s/" % lib_version
    url += release_path
    filenames = [
        filename.rsplit("/", 1)[1] for filename in filenames if release_path in filename
    ]

    if platform.system() == "Windows":
        arch = "win64" if is64() else "win32"
        libname = [name for name in filenames if arch in name][0]
    elif platform.system() == "Linux":
        arch = "x64" if is64() else "x86"
        libname = [name for name in filenames if "linux" in name and arch in name][0]
    elif platform.system() == "Darwin":
        arch = "x64" if is64() else "x86"
        libname = [name for name in filenames if "macos" in name and arch in name][0]
    else:
        raise Exception("No Prebuit binary available for %s" % (platform.system()))

    if not os.path.exists(destdir):
        os.makedirs(destdir)

    lib_url = urljoin(url, libname)
    lib_dest_path = os.path.join(destdir, "libxpdf")

    if os.path.exists(os.path.join(destdir, libname + lib_version + ".keep")):
        print(
            "Version %s of %s already downloaded. Skipping download."
            % (lib_version, libname)
        )
    else:
        for keep_file in os.listdir(destdir):
            if libname in keep_file and keep_file.endswith(".keep"):
                os.remove(keep_file)
        print("Downloading %s" % (libname))
        dwd_req = urlopen(lib_url)
        unpack_zipfile(StringIO(dwd_req.read()), lib_dest_path)
        open(os.path.join(destdir, libname + lib_version + ".keep"), "w").close()

    return lib_dest_path


def get_prebuilt_libxpdf(download_dir, static_include_dirs, static_library_dirs):
    lib_dest_path = download_and_extract_libxpdf(download_dir)
    inc_path = os.path.join(lib_dest_path, "include")
    lib_path = os.path.join(lib_dest_path, "lib")
    assert os.path.exists(inc_path), "does not exist: %s" % inc_path
    assert os.path.exists(lib_path), "does not exist: %s" % lib_path
    static_include_dirs.append(inc_path)
    static_library_dirs.append(lib_path)


LIBXPDF_RELEASE = "https://github.com/ashutoshvarma/libxpdf/releases"
match_libfile_version = re.compile("^[^-]*-([.0-9-]+)[.].*").match


def unpack_zipfile(zipfn, destdir):
    zipf = zipfile.ZipFile(zipfn)
    zipf.extractall(destdir)
    print("Extracted zip to %s" % (destdir))


def unpack_tarball(tar_filename, dest):
    print("Unpacking %s into %s" % (os.path.basename(tar_filename), dest))
    tar = tarfile.open(tar_filename)
    tar.extractall(dest)
    tar.close()
    return os.path.join(dest)


def _find_content_encoding(response, default="iso8859-1"):
    from email.message import Message

    content_type = response.headers.get("Content-Type")
    if content_type:
        msg = Message()
        msg.add_header("Content-Type", content_type)
        charset = msg.get_content_charset(default)
    else:
        charset = default
    return charset


def _list_dir_urllib(url):
    with closing(urlopen(url)) as res:
        charset = _find_content_encoding(res)
        content_type = res.headers.get("Content-Type")
        data = res.read()

    data = data.decode(charset)
    assert content_type.startswith("text/html")
    files = parse_html_filelist(data)
    return files


def parse_html_filelist(s):
    re_href = re.compile(
        r'<a\s+(?:[^>]*\s+)?href=["\']([^;?"\']+?)[;?"\']', re.I | re.M
    )
    links = set(re_href.findall(s))
    for link in links:
        if not link.endswith("/"):
            yield unquote(link)


def tryint(s):
    try:
        return int(s)
    except ValueError:
        return s


def find_max_version(libname, filenames, version_re=None):
    if version_re is None:
        version_re = re.compile(r"%s-([0-9.]+[0-9](?:-[abrc0-9]+)?)" % libname)
    versions = []
    for fn in filenames:
        match = version_re.search(fn)
        if match:
            version_string = match.group(1)
            versions.append(
                (tuple(map(tryint, version_string.split("."))), version_string)
            )
    if not versions:
        raise Exception(
            "Could not find the most current version of %s from the files: %s"
            % (libname, filenames)
        )
    versions.sort()
    version_string = versions[-1][-1]
    print("Latest version of %s is %s" % (libname, version_string))
    return version_string


def download_libxpdf_source(dest_dir, version=None):
    name = "libxpdf"
    filename = "libxpdf-%s.tar.gz"
    url_filename = "libxpdf-4.02.tar.gz"
    if version is None:
        try:
            filenames = list(_list_dir_urllib(LIBXPDF_RELEASE))
            version = find_max_version(
                "libxpdf", filenames, re.compile(r"/releases/tag/v([0-9.]+[0-9])$")
            )
        except IOError:
            # Network Failure
            latest = (0, 0, 0)
            fns = os.listdir(dest_dir)
            for fn in fns:
                if fn.startswith(name + "-"):
                    match = match_libfile_version(fn)
                    if match:
                        version_tuple = tuple(map(tryint, match.group(1).split(".")))
                        if version_tuple > latest:
                            latest = version_tuple
                            filename = fn
                            version = None
            if latest == (0, 0, 0):
                raise

    if version:
        filename = filename % version
    full_url = "%s/download/v%s/%s" % (LIBXPDF_RELEASE, version, url_filename)
    dest_filename = os.path.join(dest_dir, filename)
    if os.path.exists(dest_filename):
        print(
            (
                "Using existing %s downloaded into %s "
                "(delete this file if you want to re-download the package)"
            )
            % (name, dest_filename)
        )
    else:
        print("Downloading %s into %s from %s" % (name, dest_filename, full_url))
        urlretrieve(full_url, dest_filename)
    return dest_filename


def call_subprocess(cmd, **kw):
    import subprocess

    cwd = kw.get("cwd", ".")
    cmd_desc = " ".join(cmd)
    print('Running "%s" in %s' % (cmd_desc, cwd))
    returncode = subprocess.call(cmd, **kw)
    if returncode:
        raise Exception('Command "%s" returned code %s' % (cmd_desc, returncode))


def safe_mkdir(dir):
    if not os.path.exists(dir):
        os.makedirs(dir)


def check_cmake():
    import shutil
    import subprocess

    if shutil.which("cmake"):
        ret = subprocess.call(["cmake", "--version"])
        if ret != 0:
            return False
        else:
            return True
    return False


def cmake_run_install(
    configure_cmd,
    cmake_build_dir,
    install_prefix,
    build_type="Release",
    multicore=None,
    **call_setup
):
    print("Starting build in %s" % cmake_build_dir)
    call_subprocess(configure_cmd, cwd=cmake_build_dir, **call_setup)
    if not multicore:
        jobs = multi_make_options
    elif int(multicore) > 1:
        jobs = ["--parallel %s" % multicore]
    else:
        jobs = []
    call_subprocess(
        ["cmake", "--build", cmake_build_dir, "--config", build_type] + jobs,
        cwd=cmake_build_dir,
        **call_setup
    )
    call_subprocess(
        ["cmake", "--install", cmake_build_dir, "--prefix", install_prefix],
        cwd=cmake_build_dir,
        **call_setup
    )


def configure_darwin_env(env_setup):
    import platform

    # configure target architectures on MacOS-X (x86_64 only, by default)
    major_version, minor_version = tuple(map(int, platform.mac_ver()[0].split(".")[:2]))
    if major_version > 7:
        env_default = {
            "CFLAGS": "-arch x86_64 -std=c++14",
            "LDFLAGS": "-arch x86_64",
            "MACOSX_DEPLOYMENT_TARGET": "10.6",
        }
        env_default.update(os.environ)
        env_setup["env"] = env_default


def build_libxpdf(
    download_dir,
    extract_dir,
    static_include_dirs,
    static_library_dirs,
    static_cflags,
    static_binaries,
    libxpdf_version=None,
    build_type="Release",
    multicore=None,
):
    if not check_cmake():
        print("CMake is required. Please make sure cmake is installed and is in PATH.")
        return

    cmake_build_dir = os.path.join(extract_dir, "build")
    safe_mkdir(download_dir)
    safe_mkdir(extract_dir)
    safe_mkdir(cmake_build_dir)

    download_dir = os.path.abspath(download_dir)
    extract_dir = os.path.abspath(extract_dir)
    cmake_build_dir = os.path.abspath(cmake_build_dir)

    libxpdf_dir = unpack_tarball(
        download_libxpdf_source(download_dir, libxpdf_version),
        os.path.join(extract_dir, "libxpdf"),
    )
    prefix = os.path.abspath(extract_dir)
    safe_mkdir(prefix)

    call_setup = {}
    if sys.platform == "darwin":
        configure_darwin_env(call_setup)

    configure_cmd = [
        "cmake",
        "-DCMAKE_BUILD_TYPE=%s" % build_type,
        "-S%s" % os.path.abspath(libxpdf_dir),
        "-B%s" % os.path.abspath(cmake_build_dir),
    ]

    # build libxpdf
    cmake_run_install(
        configure_cmd, cmake_build_dir, prefix, build_type, multicore, **call_setup
    )

    lib_dir = os.path.join(prefix, "libxpdf", "lib")
    static_include_dirs.append(os.path.join(prefix, "libxpdf", "include"))
    static_library_dirs.append(lib_dir)

    listdir = os.listdir(lib_dir)
    static_binaries += [
        os.path.join(lib_dir, filename)
        for lib in ["xpdf"]
        for filename in listdir
        if lib in filename and filename.endswith(".a")
    ]

    return os.path.join(prefix, "libxpdf")
