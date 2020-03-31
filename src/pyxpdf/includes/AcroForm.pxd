from pyxpdf.includes.xpdf_types cimport GString, GBool
from pyxpdf.includes.Gfx cimport Gfx
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.Catalog cimport Catalog
from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.Form cimport Form, FormField



cdef extern from "AcroForm.h" nogil:
    cdef cppclass AcroForm(Form):
        AcroForm *load(PDFDoc *docA, Catalog *catalog, Object *acroFormObjA)

        const char *getType() 

        void draw(int pageNum, Gfx *gfx, GBool printing)

        int getNumFields()
        FormField *getField(int idx)


    ctypedef enum AcroFormFieldType:
        acroFormFieldPushbutton,
        acroFormFieldRadioButton,
        acroFormFieldCheckbox,
        acroFormFieldFileSelect,
        acroFormFieldMultilineText,
        acroFormFieldText,
        acroFormFieldComboBox,
        acroFormFieldListBox,
        acroFormFieldSignature


    cdef cppclass AcroFormField(FormField):
        AcroFormField *load(AcroForm *acroFormA, Object *fieldRefA)

        int getPageNum()
        const char *getType()
        Unicode *getName(int *length)
        Unicode *getValue(int *length)
        void getBBox(double *llx, double *lly, double *urx, double *ury)
        void getFont(Ref *fontID, double *fontSize)
        void getColor(double *red, double *green, double *blue)
        int getMaxLen()

        Object *getResources(Object *res)

        AcroFormFieldType getAcroFormFieldType() 
        Object *getFieldRef(Object *ref)
        Object *getValueObj(Object *val)
        Object *getParentRef(Object *parent)
        GBool getTypeFromParent() 
