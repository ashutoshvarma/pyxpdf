[![Build Status](https://travis-ci.com/ashutoshvarma/pyxpdf.svg?branch=master)](https://travis-ci.com/ashutoshvarma/pyxpdf)
[![Build status](https://ci.appveyor.com/api/projects/status/y4qys3oquc4bo8wd/branch/master?svg=true)](https://ci.appveyor.com/project/ashutoshvarma/pyxpdf/branch/master)
[![codecov](https://codecov.io/gh/ashutoshvarma/pyxpdf/branch/master/graph/badge.svg)](https://codecov.io/gh/ashutoshvarma/pyxpdf)

# pyxpdf
Fast Python PDF parser module based on [xpdf-reader](https://www.xpdfreader.com/) sources.

## Quickstart
```python
from pyxpdf import Document, Page, Config
from pyxpdf.xpdf import TextControl

doc = Document("samples/nonfree/mandarin.pdf")
# or
# load pdf from file like object
with open("samples/nonfree/mandarin.pdf", 'rb') as fp:
    doc = Document(fp)

# get pdf metadata dict
print(doc.info())
# >>> doc.info()
# {'CreationDate': "D:20080721141207-04'00'", 
#  'Subject': 'Chinese Version of Universal PCXR8 ...', 
#  'Author': 'SKC Inc.', 
#  'Creator': 'PScript5.dll
#   .....

# get all text
all_text = doc.text()

# iter first 10 pages
for page in doc[:10]:
    # get page label if any
    print(page.label)

# get page by page label
label_page = doc['1']

# get text in table layout without discarding clipped
# text.
text_control = TextControl("table", clip_text=True)
text = label_page.text(control=text_control)

# find case sensitive text within [x_min, y_min, x_max, y_max]
res_box = label_page.find_text('操作说明', search_box=[0, 0, 400, 400],
                                case_sensitive=True)
# >>> print(res_box)
# (281.88, 269.718, 354.05819999999994, 287.7)

# load xpdfrc
Config.load_file('my_xpdfrc')
# suppress stderr output for xpdf error log.
Config.error_quiet = False

```


## pdftotext
If you are familiar with *pdftotext* binary then this is it's python port with almost native binary speed.

```python
from pyxpdf import pdftotext

file = "sample.pdf"
# Get text from first two pages of pdf
pdf_text = pdftotext(file, start=1, end=2, layout="table",
                     userpass="1234", ownerpass="1234", 
                     cfg_file="~/.xpdfrc")
```

### Note:-
+ `pdftotext` returns Unicode encoded string, so if your PDF contain characters outside of utf-8 then they will be ignored [`decode('utf-8', errors='ignore')`].
+ If you are working with different encoding then you can use `pdftotext_raw` which has same function signature but returns `bytes` object. You can then decode it yourself but make sure to set `Config.text_encoding` to your encoding so that xpdf can properly extract text. Currently only 'UTF-8', 'Latin1', 'ASCII7', 'Symbol', 'ZapfDingbats' and 'UCS-2' encodings are predefined. To add additional encodings you can provide Unicode CMaps for your encoding through [`xpdfrc`](https://github.com/ashutoshvarma/libxpdf/blob/master/xpdf-4.02/doc/xpdfrc.cat).


## Install

```
pip install pyxpdf
``` 
### Note (Windows):-
To build this in windows you will need Visual C++ compiler which you can get by installing [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019)


## Build Instructions
### Requirements:-
* (CPython) Python 3.4+ 
* A recent enough C/C++ build environment 

First clone the pyxpdf git repository:

```
$ git clone https://github.com/ashutoshvarma/pyxpdf.git
$ cd pyxpdf
```
Optionally create a virtualenv (recommended):
```
$ python -m venv <directory>
$ source <directory>/bin/activate
```
Then install the dependencies:

```
$ pip install -r test_requirements.txt
```

Build wheel
```
$ pip install wheel
$ python setup.py bdist_wheel --with-cython
```

Install wheel package
```
$ pip install dist/*.whl
```

Now you can run the tests
```
$ python runtests.py -v
```


## License
`pyxpdf` is licensed under the GNU General Public License (GPL), version 3. See the [LICENSE](https://github.com/ashutoshvarma/pyxpdf/blob/master/LICENSE)

It uses following third party sources :-
- Xpdf Reader [https://www.xpdfreader.com/] by Derek Noonburg
 



