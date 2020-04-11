# pyxpdf
Fast Python PDF module based on [xpdf-reader](https://www.xpdfreader.com/) sources.

It is written in [cython](https://cython.org/) as Python C Extension for speed and better memory usage, just so you know.

## TODO:

Done | Name
:---:| ---
:heavy_check_mark:| pdftotext
⬜️| pdftohtml, pdftopng, pdftimages, etc
⬜️| Make all xpdf classes usable in Python 
⬜️| Python API based on xpdf (similar to poppler C++ API) 
⬜️| Documentation
⬜️| Full Test Coverage


## pdftotext
If you are familiar with pdftotext binary then this is it's python port with almost native binary speed.

```python
from pyxpdf import pdftotext

file = "sample.pdf"
# Get text from first two pages of pdf
pdf_text = pdftotext(file, start=1, end=2, layout="table",
                     userpass="1234", ownerpass="1234", 
                     cfg_file="~/.xpdfrc")
```

### Note:-
1. **Text Encoding**
    + `pdftotext` returns Unicode encoded string, so if your PDF contain characters outside of utf-8 then they will be ignored [`decode('utf-8', errors='ignore')`].
    + If you are working with different encoding then you can use `pdftotext_raw` which has same function signature but returns `bytes` object. You can then decode it yourself but make sure to set `textEncoding` in [`xpdfrc`](https://github.com/ashutoshvarma/libxpdf/blob/master/xpdf-4.02/doc/xpdfrc.cat) to your encoding so that xpdf can properly extract text.

2. Line endings in extracted text is os dependent i.e `\n` in Unix and `\r\n` in DOS/Windows (can be change with [`xpdfrc`](https://github.com/ashutoshvarma/libxpdf/blob/master/xpdf-4.02/doc/xpdfrc.cat)).


## Install
```
pip install git+https://github.com/ashutoshvarma/pyxpdf@master
``` 
### Note (Windows):-
To build this in windows you will need Visual C++ compiler which you can get by installing [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019)


## License
`pyxpdf` is licensed under the GNU General Public License (GPL), version 3. See the [LICENSE](https://github.com/ashutoshvarma/pyxpdf/blob/master/LICENSE)

It uses following third party sources :-
- Xpdf Reader [https://www.xpdfreader.com/] by Derek Noonburg
 



