from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.PDFDoc cimport PDFDoc


cdef extern from "Annot.h" nogil:
    ctypedef enum AnnotBorderType:
        annotBorderSolid
        annotBorderDashed
        annotBorderBevele
        annotBorderInset
        annotBorderUnderlined


    cdef cppclass AnnotBorderStyle:
        AnnotBorderStyle(AnnotBorderType typeA, double widthA,
                double *dashA, int dashLengthA,
                double *colorA, int nColorCompsA)

        AnnotBorderType getType() 
        double getWidth() 
        void getDash(double **dashA, int *dashLengthA)
            
        int getNumColorComps() 
        double *getColor() 


    cdef cppclass Annot:
        # Build a list of Annot objects.
        Annots(PDFDoc *docA, Object *annotsObj)

        # Iterate through list of annotations.
        int getNumAnnots() 
        Annot *getAnnot(int i) 

        # If point <x>,<y> is in an annotation, return the associated
        # annotation else return NULL.
        Annot *find(double x, double y)
        int findIdx(double x, double y)

        # Generate an appearance stream for any non-form-field annotation
        # that is missing it.
        void generateAnnotAppearances()

