from pyxpdf.includes.xpdf_types cimport GBool, GString
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.Gfx cimport Gfx
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.Catalog cimport Catalog


cdef extern from "Form.h" nogil:
    cdef cppclass Form:
        @staticmethod
        Form *load(PDFDoc *docA, Catalog *catalog, Object *acroFormObj)

        const char *getType()

        void draw(int pageNum, Gfx *gfx, GBool printing)

        int getNumFields()
        FormField *getField(int idx)

        FormField *findField(int pg, double x, double y)
        int findFieldIdx(int pg, double x, double y)


    cdef cppclass FormField:
        FormField()

        int getPageNum()
        const char *getType()

        # Return the field name.  This never returns NULL.
        Unicode *getName(int *length)

        # Return the field value.  This returns NULL if the field does not
        # have a value.
        Unicode *getValue(int *length)

        void getBBox(double *llx, double *lly, double *urx, double *ury)
        void getFont(Ref *fontID, double *fontSize)
        void getColor(double *red, double *green, double *blue)

        # Return the resource dictionaries used to draw this field.  The
        # returned object must be either a dictionary or an array of
        # dictonaries.
        Object *getResources(Object *res)