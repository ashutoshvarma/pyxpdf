
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
#include <math.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory>
#include <utility>

#include "Error.h"
#include "GfxState.h"
#include "BitmapOutputDev.h"
#include "SplashTypes.h"
#include "SplashBitmap.h"
#include "Object.h"
#include "Stream.h"
#include "config.h"
#include "gmem.h"
#include "gmempp.h"

BitmapOutputDev::BitmapOutputDev(std::vector<PDFImage> *image_listA): image_list(*image_listA) {
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
    img.bitmap = std::make_unique<SplashBitmap>(width, height, 1, splashModeMono1,
                                           gFalse, upsideDown(), (SplashBitmap*)NULL);
    img.mode = splashModeMono1;
    data = img.bitmap->getDataPtr();

    // initialize stream
    str->reset();

    // copy the stream
    size = img.bitmap->getRowSize() * height;
    n = str->getBlock((char*)data, size);
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
            width, height, 1, splashModeMono1, gFalse, upsideDown(), (SplashBitmap *)NULL);
        img.mode = splashModeMono1;
        data = img.bitmap->getDataPtr();

        // initialize stream
        str->reset();

        // copy the stream
        size = img.bitmap->getRowSize() * height;
        n = str->getBlock((char*)data, size);
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
            width, height, 1, splashModeMono8, gFalse, gFalse, (SplashBitmap*)NULL);
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
        img.bitmap = std::make_unique<SplashBitmap>(width, height, 1, splashModeRGB8,
                                               gFalse, gFalse, (SplashBitmap*)NULL);
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


