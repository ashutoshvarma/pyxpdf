from pyxpdf.includes.SplashOutputDev cimport SplashOutputDev
from pyxpdf.includes.splash.SplashTypes cimport (
    SplashColorMode, SplashColorPtr, SplashColor,
    splashBGR8R, splashBGR8G, splashBGR8B
)
from pyxpdf.includes.splash.SplashBitmap cimport (
    SplashBitmap, SplashBitmapRowSize
)
from pyxpdf.includes.BitmapOutputDev cimport PDFImage, BitmapOutputDev

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

#FIXME: buggy as hell, text does not render properly.
cdef bytearray splash_bitmap_to_1bpc_1comp(SplashBitmap *bitmap):
    cdef:
        int idx, x, y, i
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        SplashColorPtr p
        bytearray img = bytearray(height * width)

    for y in range(height):
        i = 0
        for x in range(0, width, 8):
            p = &data[y * row_size + i]
            idx = y * row_size + i
            img[idx] = p[0]
            inc(i)
    return img


cdef bytearray splash_bitmap_to_8bpc_1comp(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int pixel_width = 1
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        SplashColorPtr p
        bytearray img = bytearray(height * width * pixel_width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + x]
            idx = (y * width * pixel_width) + (x * pixel_width)
            img[idx + 0] = p[0]
    return img


cdef bytearray splash_bitmap_to_8bpc_1comp_with_alpha(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int pixel_width = 2
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        Guchar *alpha_data = bitmap.getAlphaPtr()
        SplashColorPtr p
        Guchar ap
        bytearray img = bytearray(height * width * pixel_width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + x]
            ap = alpha_data[y * <size_t>width + x]
            idx = (y * width * pixel_width) + (x * pixel_width)
            img[idx + 0] = p[0]
            img[idx + 1] = ap
    return img


cdef bytearray splash_bitmap_to_8bpc_4comp(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        SplashColorPtr p
        #FIXME: can overflow for large values
        bytearray img = bytearray(height * width * 4)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + 4 * x]
            idx = (y * width * 4) + (x * 4)
            img[idx + 0] = p[0]
            img[idx + 1] = p[1]
            img[idx + 2] = p[2]
            img[idx + 3] = p[3]
    return img


cdef bytearray splash_bitmap_to_8bpc_3comp(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int pixel_width = 3
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        SplashColorPtr p
        #FIXME: can overflow for large values
        bytearray img = bytearray(height * width * pixel_width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + 3 * x]
            idx = (y * width * pixel_width) + (x * pixel_width)
            img[idx + 0] = p[0]
            img[idx + 1] = p[1]
            img[idx + 2] = p[2]
    return img


cdef bytearray splash_bitmap_to_8bpc_3comp_with_alpha(SplashBitmap *bitmap):
    cdef:
        int idx, x, y
        int pixel_width = 4
        int height = bitmap.getHeight()
        int width = bitmap.getWidth()
        SplashBitmapRowSize row_size = bitmap.getRowSize()
        SplashColorPtr data = bitmap.getDataPtr()
        Guchar *alpha_data = bitmap.getAlphaPtr()
        SplashColorPtr p
        Guchar ap
        #FIXME: can overflow for large values
        bytearray img = bytearray(height * width * pixel_width)

    for y in range(height):
        for x in range(width):
            p = &data[y * row_size + 3 * x]
            ap = alpha_data[y * <size_t>width + x]
            idx = (y * width * pixel_width) + (x * pixel_width)
            img[idx + 0] = p[0]
            img[idx + 1] = p[1]
            img[idx + 2] = p[2]
            img[idx + 3] = ap
    return img



cdef dict IMAGE_MODES = {
    #raw mode     mode       SplashColorMode
    'RGB'   :   ('RGB',      SplashColorMode.splashModeRGB8),
    'RGBA'  :   ('RGBA',     SplashColorMode.splashModeRGB8),
    'BGR'   :   ('RGB',      SplashColorMode.splashModeBGR8),
    'BGRA'  :   ('RGBA',     SplashColorMode.splashModeBGR8),
    'L'     :   ('L',        SplashColorMode.splashModeMono8),
    'LA'    :   ('LA',       SplashColorMode.splashModeMono8),
    '1'     :   ('1',        SplashColorMode.splashModeMono1),
    'CMYK'  :   ('CMYK',     SplashColorMode.splashModeCMYK8),
}

cdef bytearray splash_bitmap_to_buffer(SplashBitmap *bitmap, mode):
    if mode == "CMYK":
        return splash_bitmap_to_8bpc_4comp(bitmap)
    elif mode == "RGB":
        return splash_bitmap_to_8bpc_3comp(bitmap)
    elif mode == "RGBA":
        return splash_bitmap_to_8bpc_3comp_with_alpha(bitmap)
    elif mode == "BGR":
        return splash_bitmap_to_8bpc_3comp(bitmap)
    elif mode == "BGRA":
        return splash_bitmap_to_8bpc_3comp_with_alpha(bitmap)
    elif mode == "L":
        return splash_bitmap_to_8bpc_1comp(bitmap)
    elif mode == "LA":
        return splash_bitmap_to_8bpc_1comp_with_alpha(bitmap)
    elif mode == "1":
        return splash_bitmap_to_1bpc_1comp(bitmap)
    else:
        raise Exception(f"'{mode}' color mode is not supported.")


cdef object pillow_image_from_buffer(object mode, int height, int width, object buffer):
    if not ("PIL.Image" in available_deps):
        raise PDFError("'Pillow' is not installed. Please install it.")

    cdef object Image = available_deps['PIL.Image']
    cdef bytes bbuff = bytes(buffer)
    return Image.frombuffer(IMAGE_MODES[mode][0], (width, height), bbuff, 'raw', mode, 0, 1)




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
        readonly object mode
        readonly Document doc


    def __cinit__(self, Document doc not None,
                  object mode = "RGB",
                  object paper_color = None,
                  double resolution = BITMAP_RESOLUTION,
                  double resolution_x = BITMAP_RESOLUTION,
                  double resolution_y = BITMAP_RESOLUTION,
                  anti_alias=True, no_composite=False,
                  use_cropbox = False, scale_before_rotation = False):
        if paper_color != None and len(paper_color) not in (3, 4):
            raise ValueError(f"'paper_color' must be 3 (RGB) or 4 (CMYK) value (0-255) list/tuple.")

        cdef:
            SplashColor _c_paper_color

        if paper_color == None:
            # default paper color is white
            if mode == 'CMYK':
                paper_color = (0,0,0,0)
            else:
                paper_color = (255,255,255)
        _c_paper_color[0] = paper_color[0]
        _c_paper_color[1] = paper_color[1]
        _c_paper_color[2] = paper_color[2]
        if mode == 'CMYK':
            _c_paper_color[3] = paper_color[3]

        if resolution != BITMAP_RESOLUTION:
            resolution_x = resolution
            resolution_y = resolution

        self.doc = doc
        self.doc_started = False
        self.mode = mode.upper()
        self.resolution_x = resolution_x
        self.resolution_y = resolution_y
        self.use_cropbox = use_cropbox
        self.scale_before_rotation = scale_before_rotation
        #self._c_splash_dev = make_unique[SplashOutputDev](SplashColorMode.splashModeBGR8,
        #                                                  4, gFalse, _c_paper_color, gTrue,
        #                                                  to_GBool(anti_alias))
        self._init_SplashOutputDev(mode, row_pad=BITMAP_ROW_PAD, paper_color=_c_paper_color,
                                   bitmap_topdown = gTrue,
                                   anti_alias = to_GBool(anti_alias))
        # set spashoutdev properties
        self._c_splash_dev.get().setNoComposite(to_GBool(no_composite))


    cdef int _init_SplashOutputDev(self, object mode, int row_pad,
                                   SplashColorPtr paper_color,
                                   GBool bitmap_topdown, GBool anti_alias) except -1:
        if mode not in IMAGE_MODES:
            raise ValueError(f"{mode} is not supported.")

        cdef SplashColorMode _c_mode = IMAGE_MODES[mode][1]

        self._c_splash_dev = make_unique[SplashOutputDev](_c_mode, row_pad, gFalse,
                                                         paper_color, bitmap_topdown,
                                                         anti_alias)
        return 0


    cdef SplashBitmap* _get_SplashBitmap(self, int page_no, int x, int y,
                                         int w, int h, double page_h,
                                         double page_w, double res_x,
                                         double res_y) except NULL:
        cdef Page page = self.doc.get_page(page_no)

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


    cdef SplashBitmap* _get_normalize_SplashBitmap(self, int page_no, int crop_x, int crop_y,
                                                   int crop_h, int crop_w, double scale_x,
                                                   double scale_y) except NULL:
        cdef:
            int rotation = 0
            int total_pages = self.doc.doc.getNumPages()
            double page_h = 0
            double page_w = 0
            double tmp
            double res_x = self.resolution_x
            double res_y = self.resolution_y
            SplashBitmap* bitmap

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

        return self._get_SplashBitmap(page_no, crop_x, crop_y,
                                      crop_h, crop_w, page_h,
                                      page_w, res_x, res_y)




    cpdef object get(self, int page_no, crop_box=(0,0,0,0), scale_pixel_box = None):
        cdef:
            int scale_x = scale_pixel_box[0] if scale_pixel_box else 0
            int scale_y = scale_pixel_box[1] if scale_pixel_box else 0
            int total_pages = self.doc.doc.getNumPages()
            SplashBitmap* bitmap
            bytearray buff

        if page_no < 0:
            page_no = 0
        if page_no >= total_pages:
            page_no = total_pages - 1

        bitmap = self._get_normalize_SplashBitmap(page_no, crop_box[0], crop_box[1],
                                                  crop_box[2], crop_box[3], scale_x,
                                                  scale_y)
        buff = splash_bitmap_to_buffer(bitmap, self.mode)

        return pillow_image_from_buffer(self.mode, bitmap.getHeight(), bitmap.getWidth(),
                                        buff)




cdef class PDFImageOutput:
    cdef:
        readonly Document doc


    def __cinit__(self, Document doc not None):
        self.doc = doc


    cdef int _get_PDFImages(self, page_no, vector[PDFImage] *img_vec) except -1:
        cdef:
            unique_ptr[BitmapOutputDev] out = make_unique[BitmapOutputDev](img_vec)
            Page page = self.doc.get_page(page_no)

        page.display(out.get())


    cdef list _get_pillow_images(self, page_no):
        cdef:
            vector[PDFImage] img_vec
            SplashBitmap *bmap
            size_t i
            list images = []
            object mode

        self._get_PDFImages(page_no, &img_vec)
        for i in range(img_vec.size()):
            bmap = img_vec[i].bitmap.get()
            if img_vec[i].mode == SplashColorMode.splashModeMono1:
                mode = "1"
            elif img_vec[i].mode == SplashColorMode.splashModeMono8:
                mode = "L"
            elif img_vec[i].mode == SplashColorMode.splashModeRGB8:
                mode = "RGB"
            buff = splash_bitmap_to_buffer(bmap, mode)
            pillow_image = pillow_image_from_buffer(mode, bmap.getHeight(), bmap.getWidth(), buff)
            images.append(pillow_image)

        return images


    cpdef list get(self, page_no):
        return self._get_pillow_images(page_no)










