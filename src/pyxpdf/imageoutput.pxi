from pyxpdf.includes.SplashOutputDev cimport SplashOutputDev
from pyxpdf.includes.splash.SplashTypes cimport (
    SplashColorMode, SplashColorPtr, SplashColor,
    splashBGR8R, splashBGR8G, splashBGR8B
)
from pyxpdf.includes.splash.SplashBitmap cimport (
    SplashBitmap, SplashBitmapRowSize
)

DEF BITMAP_ROW_PAD = 4
DEF BITMAP_RESOLUTION = 150


cdef bytearray splash_bitmap_to_pnm(SplashBitmap *bitmap):
    cdef:
        int x,y
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        bytes ppm_header
        bytearray img = bytearray()
        SplashColorPtr row, p

    ppm_header = b'P6\n%d %d\n255\n' % (width, height)
    img.extend(ppm_header)

    row = bitmap.getDataPtr()
    for y in range(height):
        p = row
        for x in range(width):
            img.append(splashBGR8R(p))
            img.append(splashBGR8G(p))
            img.append(splashBGR8B(p))
            p += 3
        row += row_size

    return img


cdef bytearray splash_bitmap_to_rgb(SplashBitmap *bitmap, bint alpha = False):
    cdef:
        int idx, x, y
        int pixel_width = 4 if alpha else 3
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        Guchar *alpha_data = bitmap.getAlphaPtr()
        SplashColorPtr p
        Guchar ap
        #FIX: can overflow for large values
        bytearray img = bytearray(height * width * pixel_width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + 3 * x]
            ap = alpha_data[y * <size_t>width + x]
            idx = y * width + (pixel_width * x)
            img[idx + 0] = p[0]
            img[idx + 1] = p[1]
            img[idx + 2] = p[2]
            if alpha == True:
                img[idx + 3] = ap
    return img


cdef bytearray splash_bitmap_to_bgr(SplashBitmap *bitmap, bint alpha = False):
    cdef:
        int idx, x, y
        int pixel_width = 4 if alpha else 3
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        Guchar *alpha_data = bitmap.getAlphaPtr()
        SplashColorPtr p
        Guchar ap
        #FIX: can overflow for large values
        bytearray img = bytearray(height * width * pixel_width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + 3 * x]
            ap = alpha_data[y * <size_t>width + x]
            idx = y * width + (pixel_width * x)
            img[idx + 0] = p[2]
            img[idx + 1] = p[1]
            img[idx + 2] = p[0]
            if alpha == True:
                img[idx + 3] = ap
    return img


cdef bytearray splash_bitmap_to_mono(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        SplashColorPtr p
        bytearray img = bytearray(height * width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + (x >> 3)]
            idx = y * width + x
            if p[0] & (0x80 >> (x & 7)):
                img[idx] = 0xff
            else:
                img[idx] = 0x00
    return img



cdef bytearray splash_bitmap_to_mono8(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        SplashColorPtr p
        bytearray img = bytearray(height * width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + x ]
            idx = y * width + x
            img[idx] = p[0]
    return img


cdef bytearray splash_bitmap_to_cmyk(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        SplashColorPtr p
        #FIX: can overflow for large values
        bytearray img = bytearray(height * width * 4)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + 4 * x]
            idx = y * width + (4 * x)
            img[idx + 0] = p[0]
            img[idx + 1] = p[1]
            img[idx + 2] = p[2]
            img[idx + 3] = p[3]
    return img





cdef class RawImageControl:
    pass


cdef class RawImageOutput:
    cdef:
        unique_ptr[SplashOutputDev] _c_splash_dev
        bint doc_started
        public bint use_cropbox
        public bint scale_before_rotation
        public double resolution_y
        public double resolution_x
        readonly Document doc


    cdef SplashBitmap* _get_SplashBitmap(self, int page_no, int x, int y,
                                         int w, int h, double page_h,
                                         double page_w, double res_x,
                                         double res_y):
        cdef:
            Page page = self.doc.get_page(page_no)

        if self.doc_started == False:
            self._c_splash_dev.get().startDoc(self.doc.doc.getXRef())

        if w == 0:
            w = <int>cmath.ceil(page_w)
        if h == 0:
            h = <int>cmath.ceil(page_h)
        w = <int>cmath.ceil(page_w - x) if x + w > page_w else w
        h = <int>cmath.ceil(page_h - y) if y + h > page_h else h

        page.display_slice(self._c_splash_dev.get(), x, y,
                                           w, h, res_x, res_y, 0,
                                           to_GBool(not self.use_cropbox),
                                           gFalse)
        return self._c_splash_dev.get().getBitmap()


    def __cinit__(self, Document doc not None,
                  object paper_color = (0xff, 0xff, 0xff),
                  double resolution = BITMAP_RESOLUTION,
                  double resolution_x = BITMAP_RESOLUTION,
                  double resolution_y = BITMAP_RESOLUTION,
                  anti_alias=True, no_composite=False,
                  use_cropbox = False, scale_before_rotation = False):
        if len(paper_color) != 3:
            raise ValueError(f"'paper_color' must be 3 value (0-255) list/tuple.")

        cdef:
            SplashColor _c_paper_color

        _c_paper_color[0] = paper_color[0]
        _c_paper_color[1] = paper_color[1]
        _c_paper_color[2] = paper_color[2]

        if resolution != BITMAP_RESOLUTION:
            resolution_x = resolution
            resolution_y = resolution

        self.doc = doc
        self.doc_started = False
        self.resolution_x = resolution_x
        self.resolution_y = resolution_y
        self.use_cropbox = use_cropbox
        self.scale_before_rotation = scale_before_rotation
        self._c_splash_dev = make_unique[SplashOutputDev](SplashColorMode.splashModeBGR8,
                                                          4, gFalse, _c_paper_color, gTrue,
                                                          to_GBool(anti_alias))
        # set spashoutdev properties
        self._c_splash_dev.get().setNoComposite(to_GBool(no_composite))



    cpdef object get(self, int page_no, crop_box=(0,0,0,0), scale_pixel_box = None):
        cdef:
            int rotation = 0
            int total_pages = self.doc.doc.getNumPages()
            double page_h = 0
            double page_w = 0
            double tmp
            double res_x = self.resolution_x
            double res_y = self.resolution_y
            int scale_x = scale_pixel_box[0] if scale_pixel_box else 0
            int scale_y = scale_pixel_box[1] if scale_pixel_box else 0
            SplashBitmap* bitmap


        if page_no < 0:
            page_no = 0
        if page_no >= total_pages:
            page_no = total_pages - 1

        if self.use_cropbox:
            page_h = self.doc.doc.getPageCropHeight(page_no + 1)
            page_w = self.doc.doc.getPageCropWidth(page_no + 1)
        else:
            page_h = self.doc.doc.getPageMediaHeight(page_no + 1)
            page_w = self.doc.doc.getPageMediaWidth(page_no + 1)


        rotation = self.doc.doc.getPageRotate(page_no + 1)
        # swap height and width
        if self.scale_before_rotation and (rotation == 90 or rotation == 270):
            # cppalgo.swap(page_h, page_w)
            tmp = page_h
            page_h = page_w
            page_w = tmp


        if scale_x > 0:
            res_x = (72.0 * scale_x) / page_w
            if scale_y <= 0:
                res_y = res_x
        if scale_y > 0:
            res_y = (72.0 * scale_y) / page_h
            if scale_x <= 0:
                res_x = res_y

        page_w = page_w * (res_x / 72.0)
        page_h = page_h * (res_y / 72.0)

        # swap height and width
        if (not self.scale_before_rotation) and (rotation == 90 or rotation == 270):
            # cppalgo.swap(page_h, page_w)
            tmp = page_h
            page_h = page_w
            page_w = tmp

        bitmap = self._get_SplashBitmap(page_no, crop_box[0], crop_box[1],
                                        crop_box[2], crop_box[3], page_h,
                                        page_w, res_x, res_y)
        return splash_bitmap_to_pnm(bitmap)


