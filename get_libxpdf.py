"""
Heavily inspired from lxml buildlibxml.py
"""
import os
import re
import platform
import sys
import zipfile
from contextlib import closing

try:
    from urlparse import unquote, urljoin
    from urllib import urlopen
except ImportError:
    from urllib.parse import unquote, urljoin
    from urllib.request import urlopen

try:
    from io import BytesIO as StringIO
except ImportError:
    from StringIO import StringIO


def is64():
    return sys.maxsize > 2**32


def download_and_extract_libxpdf(destdir):
    url = "https://github.com/ashutoshvarma/libxpdf/releases"
    filenames = list(_list_dir_urllib(url))

    lib_version = find_max_version(
        'libxpdf', filenames, re.compile(r'/releases/tag/v([0-9.]+[0-9])$'))
    release_path = "/download/v%s/" % lib_version
    url += release_path
    filenames = [
        filename.rsplit('/', 1)[1]
        for filename in filenames
        if release_path in filename
    ]

    if platform.system() == 'Windows':
        arch = 'win64' if is64() else 'win32'
        libname = [name for name in filenames if arch in name][0]
    elif platform.system() == 'Linux':
        arch = 'x64' if is64() else 'x86'
        libname = [
            name for name in filenames if 'linux' in name and arch in name][0]
    elif platform.system() == 'Darwin':
        arch = 'x64' if is64() else 'x86'
        libname = [
            name for name in filenames if 'macos' in name and arch in name][0]
    else:
        raise Exception("No Prebuit binary available for %s" %
                        (platform.system()))

    if not os.path.exists(destdir):
        os.makedirs(destdir)

    lib_url = urljoin(url, libname)
    lib_dest_path = os.path.join(destdir, 'libxpdf')

    if os.path.exists(os.path.join(destdir, libname + lib_version + ".keep")):
        print("Version %s of %s already downloaded. Skipping download." % (lib_version, libname))
    else:
        for keep_file in os.listdir(destdir):
            if libname in keep_file and keep_file.endswith(".keep"):
                os.remove(keep_file)
        print("Downloading %s" % (libname))
        dwd_req = urlopen(lib_url)
        unpack_zipfile(StringIO(dwd_req.read()), lib_dest_path)
        open(os.path.join(destdir, libname + lib_version + ".keep"), 'w').close()

    return lib_dest_path


def get_prebuilt_libxpdf(download_dir, static_include_dirs, static_library_dirs):
    lib_dest_path = download_and_extract_libxpdf(download_dir)
    inc_path = os.path.join(lib_dest_path, 'include')
    lib_path = os.path.join(lib_dest_path, 'lib')
    assert os.path.exists(inc_path), 'does not exist: %s' % inc_path
    assert os.path.exists(lib_path), 'does not exist: %s' % lib_path
    static_include_dirs.append(inc_path)
    static_library_dirs.append(lib_path)


def unpack_zipfile(zipfn, destdir):
    zipf = zipfile.ZipFile(zipfn)
    zipf.extractall(destdir)
    print("Extracted zip to %s" % (destdir))


def _find_content_encoding(response, default='iso8859-1'):
    from email.message import Message
    content_type = response.headers.get('Content-Type')
    if content_type:
        msg = Message()
        msg.add_header('Content-Type', content_type)
        charset = msg.get_content_charset(default)
    else:
        charset = default
    return charset


def _list_dir_urllib(url):
    with closing(urlopen(url)) as res:
        charset = _find_content_encoding(res)
        content_type = res.headers.get('Content-Type')
        data = res.read()

    data = data.decode(charset)
    assert content_type.startswith('text/html')
    files = parse_html_filelist(data)
    return files
   

def parse_html_filelist(s):
    re_href = re.compile(
        r'<a\s+(?:[^>]*\s+)?href=["\']([^;?"\']+?)[;?"\']',
        re.I | re.M)
    links = set(re_href.findall(s))
    for link in links:
        if not link.endswith('/'):
            yield unquote(link)


def tryint(s):
    try:
        return int(s)
    except ValueError:
        return s


def find_max_version(libname, filenames, version_re=None):
    if version_re is None:
        version_re = re.compile(r'%s-([0-9.]+[0-9](?:-[abrc0-9]+)?)' % libname)
    versions = []
    for fn in filenames:
        match = version_re.search(fn)
        if match:
            version_string = match.group(1)
            versions.append((tuple(map(tryint, version_string.split('.'))),
                             version_string))
    if not versions:
        raise Exception(
            "Could not find the most current version of %s from the files: %s" % (libname, filenames))
    versions.sort()
    version_string = versions[-1][-1]
    print("Latest version of %s is %s" % (libname, version_string))
    return version_string
