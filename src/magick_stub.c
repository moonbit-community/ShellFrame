#if __has_include(<MagickWand/MagickWand.h>)
#include <MagickWand/MagickWand.h>
#elif __has_include(<wand/MagickWand.h>)
#include <wand/MagickWand.h>
#else
#error "MagickWand headers not found"
#endif

#include "moonbit.h"

void destroy_wand_as_finalize(void *self) {
  if (self == NULL) {
    return;
  }

  MagickWand **wand = (MagickWand **)self;

  DestroyMagickWand(*wand);
}

MOONBIT_FFI_EXPORT MagickWand **SFStubNewMagickWand() {
  MagickWand *new_wand = NewMagickWand();
  MagickWand **obj = moonbit_make_external_object(destroy_wand_as_finalize,
                                                  sizeof(MagickWand *));
  *obj = new_wand;
  return obj;
}

MOONBIT_FFI_EXPORT MagickBooleanType
SFStubMagickReadImage(MagickWand **wand, const char *filename) {
  return MagickReadImage(*wand, filename);
}

MOONBIT_FFI_EXPORT MagickBooleanType
SFStubMagickWandWriteImage(MagickWand **wand, const char *filename) {
  return MagickWriteImage(*wand, filename);
}

MOONBIT_FFI_EXPORT size_t SFStubMagickGetImageWidth(MagickWand **wand) {
  return MagickGetImageWidth(*wand);
}

MOONBIT_FFI_EXPORT size_t SFStubMagickGetImageHeight(MagickWand **wand) {
  return MagickGetImageHeight(*wand);
}

MOONBIT_FFI_EXPORT MagickBooleanType SFStubMagickExportImagePixels(
    MagickWand **wand, const ssize_t x, const ssize_t y, const size_t columns,
    const size_t rows,
    // const char *map,
    // const StorageType storage,
    void *pixels) {
  return MagickExportImagePixels(*wand, x, y, columns, rows, "RGB", CharPixel,
                                 pixels);
}

MOONBIT_FFI_EXPORT MagickBooleanType SFStubMagickImportImagePixels(
    MagickWand **wand, const ssize_t x, const ssize_t y, const size_t columns,
    const size_t rows,
    // const char *map,
    // const StorageType storage,
    void *pixels) {
  return MagickImportImagePixels(*wand, x, y, columns, rows, "RGB", CharPixel,
                                 pixels);
}
