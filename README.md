# pyxpdf
Fast Python PDF module based on [xpdf-reader](https://www.xpdfreader.com/) sources.

It is written in [cython](https://cython.org/) as Python C Extension for speed and memory friendly, just so you know.

## TODO:

Done | Name
:---:| ---
✅| pdftotext
⬜️| pdftohtml, pdftopng, pdftimages, etc
⬜️| Make all xpdf classeds usable in Python 
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
                     userpass="1234", ownerpss="1234", 
                     cfg_file="~/.xpdfrc")
```

## Install
```
pip -e git+https://github.com/ashutoshvarma/pyxpdf@master
``` 

## License
`pyxpdf` is licensed under the GNU General Public License (GPL), version 2.

It uses following third party sources :-
- Xpdf Reader [https://www.xpdfreader.com/] by Derek Noonburg
 



