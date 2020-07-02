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


#cdef bytearray splash_bitmap_to_pnm(SplashBitmap *bitmap):
#    cdef:
#        int x,y
#        int height = bitmap.getHeight()
#        int width = bitmap.getWidth()
#        SplashBitmapRowSize row_size = bitmap.getRowSize()
#        bytes ppm_header
#        bytearray img = bytearray()
#       SplashColorPtr row, p
#
#    ppm_header = b'P6\n%d %d\n255\n' % (width, height)
#    img.extend(ppm_header)
#
#    row = bitmap.getDataPtr()
#    for y in range(height):
#        p = row
#        for x in range(width):
#            img.append(splashBGR8R(p))
#            img.append(splashBGR8G(p))
#            img.append(splashBGR8B(p))
#            p += 3
#        row += row_size
#
#    return img

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

# adapted from poppler's pdftoppm
cdef class RawImageOutput(PDFOutputDevice):
    """Render PDF page as `Image`.

    Convert the PDF page to uncompressed raw image.

    `paper_color` depends on the color mode of image, if
    color mode is `RGB` or `RGBA` than `paper_color` should
    be a 3 int(0-255) tuple of RGB values, similarly for `CMYK`
    it should be 4 int(0-255) tuple of CMYK color values.

    If you are using image mode with alpha channel and want transparent
    background then set `no_composite` to `True`

    Parameters
    ----------
    doc : Document
        PDF Document for this output device
    mode : {"RGB", "RGBA", "L", "LA", "1", "CMYK"}, optional
        image modes for output rendered image,
        equivalent to Pillow's image modes.
        (default is 'RGB')
    paper_color : tuple of int, optional
        paper color for rendered pdf page
        (default is :obj:`None`, means 'white' paper color)
    resolution : float, optional
        X and Y resolution of output image in DPI
        (default is 150)
    resolution_x : float, optional
        X resolution in DPI
        (default is 150)
    resolution_y : float, optional
        X resolution in DPI
        (default is 150)
    anti_alias : bool, optional
        enable font anti-aliasing for rendering
        (default is `True`)
    no_composite : bool, optional
        disables the final composite (with the opaque paper color),
        resulting in transparent output.
        (default is `False`)
    use_cropbox : bool, optional
        use the crop box rather than media box
        (default is `False`)
    scale_before_rotation : bool, optional
        resize dimensions before rotation of rotated pdfs
        (default is `False`)

    Note
    ----
    Additionally you can enable :attr:`Config.vector_anti_alias` for better
    anti-alias effect.

    Warning
    -------
    Avoid '1' image mode, as of now its quite buggy and fonts are not rendered properly
    in it. Instead use 'L' for black and white.

    """
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
        """Get the rendered :class:`~PIL.Image.Image` for `page_no` indexed page

        Parameters
        ----------
        page_no : int
            index of page to render
        crop_box : tuple of float, optional
            tuple of cordinates of :term:`BBox` to set the rendering area.
            (default is (0,0,0,0), means the whole page area)
        scale_pixel_box : tuple of int, optional
            tuple of pair of int which scales the page to fix within x * y pixels

        Return
        ------
        :class:`~PIL.Image.Image`
            Rendered PDF Page

        Note
        ----
        Requires Optional dependency ``Pillow`` module
        """
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




from pyxpdf.includes.BitmapOutputDev cimport PDFBitmapImage, BitmapOutputDev, ImageType
from pyxpdf.includes.GfxState cimport GfxColorSpaceMode
from pyxpdf.includes.Stream cimport StreamKind

cdef dict GFX_COLOR_SPACE_NAMES = {
    GfxColorSpaceMode.csDeviceGray  :   u"gray",
    GfxColorSpaceMode.csCalGray     :   u"gray",
    GfxColorSpaceMode.csDeviceRGB   :   u"rgb",
    GfxColorSpaceMode.csCalRGB      :   u"rgb",
    GfxColorSpaceMode.csDeviceCMYK  :   u"cmyk",
    GfxColorSpaceMode.csLab         :   u"lab",
    GfxColorSpaceMode.csICCBased    :   u"icc",
    GfxColorSpaceMode.csIndexed     :   u"index",
    GfxColorSpaceMode.csSeparation  :   u"sep",
    GfxColorSpaceMode.csDeviceN     :   u"devn",
    # not including csPattern
    #GfxColorSpaceMode.csPattern     :   u""
}

cdef dict IMAGE_STREAM_TYPES = {
    StreamKind.strCCITTFax  :   u"ccitt",
    StreamKind.strDCT       :   u"jpeg",
    StreamKind.strJPX       :   u"jpx",
    StreamKind.strJBIG2     :   u"jbig2",
    StreamKind.strFlate     :   u"flate",
    StreamKind.strLZW       :   u"lzw",
    StreamKind.strRunLength :   u"rle",
}

cdef class PDFImage:
    """ Represents a PDF Image.

    Image Colorspace:
        - **gray** : DeviceGray, CalGray
        - **rgb** : DeviceRGB, CalRGB
        - **cmyk** : DeviceCMYK
        - **lab** : Lab
        - **icc** : ICCBased
        - **index** : Indexed
        - **sep** : Sepration
        - **devn** : DeviceN

    Image Compression:
        - **ccitt** : CCITTFax
        - **jpeg** : DCT
        - **jpx** : JPX
        - **jbig2** : JBIG2
        - **flate** : Flate
        - **lzw** : LZW
        - **rle** : RunLength

    Attributes
    ----------
    bbox : tuple of float
        Image's Boundary Box (:term:`BBox`)
    image: :class:`~PIL.Image.Image`
        Image data as Pillow Image
    page_index : int
        Index of Image's PDF page
    interpolate : bool
        Whether image is interpolated or not
    is_inline : bool
        Whether image is inline or not
    hDPI : float
        Image's horizontal DPI
    vDPI : float
        Image's vertical DPI
    colorspace : {'gray', 'rgb', 'cmyk', 'lab', 'icc', 'index', 'sep', 'devn', 'unknown'}
        Image's color space.
    components : int
        components in the image's colorspace.
    bpc : int
        bits per component.
    compression : {'ccitt', 'jpeg', 'jpx', 'jbig2', 'flate', 'lzw', 'rle', 'unknown'}
        Image's compression
    """

    cdef:
        readonly tuple bbox
        readonly int page_index
        readonly bint interpolate
        readonly bint is_inline
        readonly double hDPI
        readonly double vDPI
        readonly object colorspace
        readonly int components
        readonly int bpc
        readonly object image_type
        readonly object compression
        readonly object image

    @staticmethod
    cdef PDFImage from_ptr(PDFBitmapImage *c_img):
        cdef:
            PDFImage img = PDFImage.__new__(PDFImage)
            SplashBitmap *bmap
            object mode
        img.page_index = c_img.pageNum
        img.bbox = (c_img.x1, c_img.y1, c_img.x2, c_img.y2)
        img.hDPI = c_img.hDPI
        img.vDPI = c_img.vDPI

        img.interpolate = True if c_img.interpolate == gTrue else False
        img.is_inline = True if c_img.inlineImg == gTrue else False

        cs = GFX_COLOR_SPACE_NAMES.get(c_img.colorspace, None)
        img.colorspace = cs if cs != None else "unknown"

        img.bpc = c_img.bpc
        img.components = c_img.components

        comp = IMAGE_STREAM_TYPES.get(c_img.compression, None)
        img.compression = comp if comp != None else "unknown"

        # image_type
        if c_img.imgType == ImageType.imgImage:
            img.image_type = "image"
        elif c_img.imgType == ImageType.imgStencil:
            img.image_type = "stencil"
        elif c_img.imgType == ImageType.imgMask:
            img.image_type = "mask"
        elif c_img.imgType == ImageType.imgSmask:
            img.image_type = "smask"
        else:
            raise ValueError(f"unexpected value of imgType")

        bmap = c_img.bitmap.get()
        if c_img.bitmapColorMode == SplashColorMode.splashModeMono1:
            mode = "1"
        elif c_img.bitmapColorMode == SplashColorMode.splashModeMono8:
            mode = "L"
        elif c_img.bitmapColorMode == SplashColorMode.splashModeRGB8:
            mode = "RGB"
        buff = splash_bitmap_to_buffer(bmap, mode)
        img.image = pillow_image_from_buffer(mode, bmap.getHeight(), bmap.getWidth(), buff)

        return img

    def __repr__(self):
        return f"<pyxpdf.xpdf.PDFImage type={self.image_type} compression={self.compression} colorspace={self.colorspace} bbox={self.bbox}>"


cdef class PDFImageOutput:
    """Extract the images from PDF Document

    Extract and decode images inside a PDF and output them as
    :class:`~PIL.Image.Image` object.

    Parameters
    ----------
    doc : Document
        PDF Document for this output device

    Note
    ----
    Requires Optional dependency ``Pillow`` module
    """
    cdef:
        readonly Document doc


    def __cinit__(self, Document doc not None):
        self.doc = doc


    cdef int _get_PDFBitmapImages(self, page_no, vector[PDFBitmapImage] *img_vec) except -1:
        cdef:
            unique_ptr[BitmapOutputDev] out = make_unique[BitmapOutputDev](img_vec)
            Page page = self.doc.get_page(page_no)

        page.display(out.get())


    cdef list _get_images(self, page_no):
        cdef:
            vector[PDFBitmapImage] img_vec
            size_t i
            list images = []

        self._get_PDFBitmapImages(page_no, &img_vec)
        for i in range(img_vec.size()):
            img = PDFImage.from_ptr(&img_vec[i])
            images.append(img)

        return images


    cpdef list get(self, page_no):
        """Get all the images from `page_no` indexed page.

        Parameters
        ----------
        page_no : int
            index of page to render

        Return
        ------
        list of :class:`~pyxpdf.xpdf.PDFImage`
            All the images in PDF Page
        """
        return self._get_images(page_no)










