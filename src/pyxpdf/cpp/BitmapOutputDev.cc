
//========================================================================
//
// BitmapOutputDev.cc
//
// Copyright 1998-2003 Glyph & Cog, LLC
//
//========================================================================

#include <aconf.h>

#ifdef USE_GCC_PRAGMAS
#pragma implementation
#endif

#include <ctype.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include <cmath>
#include <memory>
#include <utility>

#include "Error.h"
#include "GfxState.h"
#include "Object.h"
#include "SplashBitmap.h"
#include "SplashTypes.h"
#include "Stream.h"
#include "config.h"
#include "gmem.h"
#include "gmempp.h"
#include "BitmapOutputDev.h"

BitmapOutputDev::BitmapOutputDev(std::vector<PDFImage> *image_listA)
    : image_list(*image_listA) {
    curPageNum = 0;
    ok = gTrue;
}

BitmapOutputDev::~BitmapOutputDev() {}

void BitmapOutputDev::startPage(int pageNum, GfxState *state) {
    curPageNum = pageNum;
}

void BitmapOutputDev::tilingPatternFill(GfxState *state, Gfx *gfx,
                                        Object *strRef, int paintType,
                                        int tilingType, Dict *resDict,
                                        double *mat, double *bbox, int x0,
                                        int y0, int x1, int y1, double xStep,
                                        double yStep) {
    // do nothing -- this avoids the potentially slow loop in Gfx.cc
}

void BitmapOutputDev::drawImageMask(GfxState *state, Object *ref, Stream *str,
                                    int width, int height, GBool invert,
                                    GBool inlineImg, GBool interpolate) {
    int size, n, i;
    PDFImage img;
    SplashColorPtr data;

    img.pageNum = curPageNum;
    img.bitmap = std::make_unique<SplashBitmap>(
        width, height, 1, splashModeMono1, gFalse, upsideDown(),
        (SplashBitmap *)NULL);
    img.mode = splashModeMono1;
    data = img.bitmap->getDataPtr();

    // initialize stream
    str->reset();

    // copy the stream
    size = img.bitmap->getRowSize() * height;
    n = str->getBlock((char *)data, size);
    if (n < size) {
        for (i = n; i < size; i++) {
            data[n] = 0;
        }
    }

    str->close();

    image_list.push_back(std::move(img));
}

void BitmapOutputDev::drawImage(GfxState *state, Object *ref, Stream *str,
                                int width, int height,
                                GfxImageColorMap *colorMap, int *maskColors,
                                GBool inlineImg, GBool interpolate) {
    GfxColorSpaceMode csMode;
    ImageStream *imgStr;
    Guchar *p;
    GfxRGB rgb;
    GfxGray gray;
    int x, y;
    int size, n, i;
    PDFImage img;
    SplashColorPtr data;
    SplashBitmapRowSize rowSize = 0;

    img.pageNum = curPageNum;

    csMode = colorMap->getColorSpace()->getMode();
    if (csMode == csIndexed) {
        csMode = ((GfxIndexedColorSpace *)colorMap->getColorSpace())
                     ->getBase()
                     ->getMode();
    }

    if (colorMap->getNumPixelComps() == 1 && colorMap->getBits() == 1) {
        // open the image file and write the PBM header
        img.bitmap = std::make_unique<SplashBitmap>(
            width, height, 1, splashModeMono1, gFalse, upsideDown(),
            (SplashBitmap *)NULL);
        img.mode = splashModeMono1;
        data = img.bitmap->getDataPtr();

        // initialize stream
        str->reset();

        // copy the stream
        size = img.bitmap->getRowSize() * height;
        n = str->getBlock((char *)data, size);
        if (n < size) {
            for (i = n; i < size; i++) {
                data[n] = 0;
            }
        }

        str->close();

        // dump PGM file
    } else if (colorMap->getNumPixelComps() == 1 &&
               (csMode == csDeviceGray || csMode == csCalGray)) {
        // open the image file and write the PGM header
        img.bitmap = std::make_unique<SplashBitmap>(
            width, height, 1, splashModeMono8, gFalse, gFalse,
            (SplashBitmap *)NULL);
        img.mode = splashModeMono8;
        data = img.bitmap->getDataPtr();
        rowSize = img.bitmap->getRowSize();

        // initialize stream
        imgStr = new ImageStream(str, width, colorMap->getNumPixelComps(),
                                 colorMap->getBits());
        imgStr->reset();

        // for each line...
        for (y = 0; y < height; ++y) {
            // write the line
            if ((p = imgStr->getLine())) {
                for (x = 0; x < width; ++x) {
                    colorMap->getGray(p, &gray, state->getRenderingIntent());
                    // fputc(colToByte(gray), f);
                    data[y * rowSize + x] = colToByte(gray);
                    ++p;
                }
            } else {
                for (x = 0; x < width; ++x) {
                    // fputc(0, f);
                    data[y * rowSize + x] = 0;
                }
            }
        }

        imgStr->close();
        delete imgStr;

        // dump PPM file
    } else {
        img.bitmap = std::make_unique<SplashBitmap>(
            width, height, 1, splashModeRGB8, gFalse, gFalse,
            (SplashBitmap *)NULL);
        img.mode = splashModeRGB8;
        data = img.bitmap->getDataPtr();
        rowSize = img.bitmap->getRowSize();

        // initialize stream
        imgStr = new ImageStream(str, width, colorMap->getNumPixelComps(),
                                 colorMap->getBits());
        imgStr->reset();

        // for each line...
        for (y = 0; y < height; ++y) {
            // write the line
            if ((p = imgStr->getLine())) {
                for (x = 0; x < width; ++x) {
                    colorMap->getRGB(p, &rgb, state->getRenderingIntent());
                    // fputc(colToByte(rgb.r), f);
                    // fputc(colToByte(rgb.g), f);
                    // fputc(colToByte(rgb.b), f);
                    data[y * rowSize + (3 * x + 0)] = colToByte(rgb.r);
                    data[y * rowSize + (3 * x + 1)] = colToByte(rgb.g);
                    data[y * rowSize + (3 * x + 2)] = colToByte(rgb.b);
                    p += colorMap->getNumPixelComps();
                }
            } else {
                for (x = 0; x < width; ++x) {
                    // fputc(0, f);
                    // fputc(0, f);
                    // fputc(0, f);
                    data[y * rowSize + (3 * x + 0)] = 0;
                    data[y * rowSize + (3 * x + 1)] = 0;
                    data[y * rowSize + (3 * x + 2)] = 0;
                }
            }
        }

        imgStr->close();
        delete imgStr;
    }

    image_list.push_back(std::move(img));
}

void BitmapOutputDev::drawMaskedImage(GfxState *state, Object *ref, Stream *str,
                                      int width, int height,
                                      GfxImageColorMap *colorMap,
                                      Stream *maskStr, int maskWidth,
                                      int maskHeight, GBool maskInvert,
                                      GBool interpolate) {
    drawImage(state, ref, str, width, height, colorMap, NULL, gFalse,

              interpolate);
    drawImageMask(state, ref, maskStr, maskWidth, maskHeight, maskInvert,
                  gFalse, interpolate);
}

void BitmapOutputDev::drawSoftMaskedImage(
    GfxState *state, Object *ref, Stream *str, int width, int height,
    GfxImageColorMap *colorMap, Stream *maskStr, int maskWidth, int maskHeight,
    GfxImageColorMap *maskColorMap, double *matte, GBool interpolate) {
    drawImage(state, ref, str, width, height, colorMap, NULL, gFalse,
              interpolate);
    drawImage(state, ref, maskStr, maskWidth, maskHeight, maskColorMap, NULL,
              gFalse, interpolate);
}

// taken from
// https://gitlab.freedesktop.org/poppler/poppler/-/blob/master/poppler/CairoOutputDev.cc
static void get_singular_values(const CTMatrix *matrix, double *minor,
                                double *major) {
    double xx = matrix->xx, xy = matrix->xy;
    double yx = matrix->yx, yy = matrix->yy;

    double a = xx * xx + yx * yx;
    double b = xy * xy + yy * yy;
    double k = xx * xy + yx * yy;

    double f = (a + b) * .5;
    double g = (a - b) * .5;
    double delta = sqrt(g * g + k * k);

    if (major) *major = sqrt(f + delta);
    if (minor) *minor = sqrt(f - delta);
}

// taken from
// https://gitlab.freedesktop.org/poppler/poppler/-/blob/master/poppler/CairoOutputDev.cc
void BitmapOutputDev::getScaledSize(const CTMatrix *matrix, int orig_width,
                                    int orig_height, int *scaledWidth,
                                    int *scaledHeight) {
    double xScale;
    double yScale;
    if (orig_width > orig_height)
        get_singular_values(matrix, &xScale, &yScale);
    else
        get_singular_values(matrix, &yScale, &xScale);

    int tx, tx2, ty, ty2; /* the integer co-ordinates of the resulting image */
    if (xScale >= 0) {
        tx = splashRound(matrix->x0 - 0.01);
        tx2 = splashRound(matrix->x0 + xScale + 0.01) - 1;
    } else {
        tx = splashRound(matrix->x0 + 0.01) - 1;
        tx2 = splashRound(matrix->x0 + xScale - 0.01);
    }
    *scaledWidth = abs(tx2 - tx) + 1;
    // scaledWidth = splashRound(fabs(xScale));
    // if (*scaledWidth == 0) {
    // technically, this should draw nothing, but it generally seems
    // better to draw a one-pixel-wide stripe rather than throwing it
    // away
    //    *scaledWidth = 1;
    //}
    if (yScale >= 0) {
        ty = splashFloor(matrix->y0 + 0.01);
        ty2 = splashCeil(matrix->y0 + yScale - 0.01);
    } else {
        ty = splashCeil(matrix->y0 - 0.01);
        ty2 = splashFloor(matrix->y0 + yScale + 0.01);
    }
    *scaledHeight = abs(ty2 - ty);
    // if (*scaledHeight == 0) {
    //    *scaledHeight = 1;
    //}
}

void BitmapOutputDev::getBBox(GfxState *state, int width, int height,
                              double *x1, double *y1, double *x2, double *y2) {
    const double *ctm = state->getCTM();
    CTMatrix matrix;

    matrix.xx = ctm[0];
    matrix.yx = ctm[1];
    matrix.xy = -ctm[2];
    matrix.yy = -ctm[3];
    matrix.x0 = ctm[2] + ctm[4];
    matrix.y0 = ctm[3] + ctm[5];

    int scaledWidth, scaledHeight;
    getScaledSize(&matrix, width, height, &scaledWidth, &scaledHeight);

    if (matrix.xx >= 0) {
        *x1 = matrix.x0;
    } else {
        *x1 = matrix.x0 - scaledWidth;
    }
    *x2 = *x1 + scaledWidth;

    if (matrix.yy >= 0) {
        *y1 = matrix.y0;
    } else {
        *y1 = matrix.y0 - scaledHeight;
    }
    *y2 = *y1 + scaledHeight;
}

