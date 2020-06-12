from functools import wraps
from time import time

from pdfminer.high_level import extract_text

from pyxpdf import Document
from pyxpdf.xpdf import TextOutput

PDF = 'samples/nonfree/mandarin.pdf'

# https://cartographicperspectives.org/index.php/journal/article/view/cp43-complete-issue/pdf
PDF_100MB = '100mb.pdf'

#https://ia800304.us.archive.org/19/items/nasa_techdoc_19880069935/19880069935.pdf
PDF_500MB = '500mb.pdf'

COUNT = 10

def timing(f):
    @wraps(f)
    def wrap(*args, **kw):
        ts = time()
        result = f(*args, **kw)
        te = time()
        print('%r took: %2.4f sec' % (f.__name__,  (te-ts)/COUNT))
        return result
    return wrap

def repeat(count):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            rets = []
            for _ in range(count):
                rets.append(f(*args, **kwargs))
            return rets
        return wrapper
    return decorator


@timing
@repeat(count=COUNT)
def pdfminer_text():
    text = extract_text(PDF)

@timing
@repeat(count=COUNT)
def pdfminer_text_100mb():
    text = extract_text(PDF_100MB)

@timing
@repeat(count=COUNT)
def pdfminer_text_500mb():
    text = extract_text(PDF_500MB)


@timing
@repeat(count=COUNT)
def pyxpdf_text():
    text = TextOutput(Document(PDF)).get_all()


@timing
@repeat(count=COUNT)
def pyxpdf_text_100mb():
    text = TextOutput(Document(PDF_100MB)).get_all()


@timing
@repeat(count=COUNT)
def pyxpdf_text_500mb():
    text = TextOutput(Document(PDF_500MB)).get_all()

pdfminer_text()
pyxpdf_text()

pdfminer_text_100mb()
pyxpdf_text_100mb()

pdfminer_text_500mb()
pyxpdf_text_500mb()
