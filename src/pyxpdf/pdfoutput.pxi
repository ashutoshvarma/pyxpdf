

cdef class PDFOutputDevice:
    """Generic PDF Output Device

    All PDF Output Device inherit from this.
    """
    def get(self, int page_no, **kwargs):
        """Get the output of `page_no` indexed page
        """
        raise NotImplementedError()
