#!/bin/bash
set -o errexit -o nounset -o pipefail

cd "`dirname $0`"

source ./checkout.sh

if [ "${checkout:-true}" != "false" ]; then
  python2 tools/git-sync-deps
fi

build_type=${build_type:-Release}
echo "> Build type $build_type"

if [ "${build_type}" = "Debug" ]; then
  args="is_debug=true"
else
  args="is_debug=false is_official_build=true"
fi

gn gen out/${build_type}-arm64 --args="${args} \
  skia_use_system_expat=false \
  skia_use_system_libjpeg_turbo=false \
  skia_use_system_libpng=false \
  skia_use_system_libwebp=false \
  skia_use_system_zlib=false \
  skia_use_sfntly=false \
  skia_use_freetype=true \
  skia_use_system_freetype2=false \
  skia_use_harfbuzz=true \
  skia_use_system_harfbuzz=false \
  skia_pdf_subset_harfbuzz=true \
  skia_use_icu=true \
  skia_use_system_icu=false \
  skia_enable_skshaper=true \
  skia_enable_skparagraph=true \
  skia_enable_gpu=true \
  skia_use_gl=true \
  skia_use_metal=true \
  target_cpu=\"arm64\" \
  extra_cflags=[\"-stdlib=libc++\"] \
  extra_cflags_cc=[\"-frtti\"]"

ninja -C out/${build_type}-arm64 skia modules

if [ "${archive:-false}" = "true" ]; then
  zip --recurse-paths --quiet ../Skia-${release}-macos-${build_type}-arm64.zip \
    out/${build_type}-arm64/*.a \
    include \
    modules/particles/include/*.h \
    modules/skottie/include/*.h \
    modules/skparagraph/include/*.h \
    modules/skplaintexteditor/include/*.h \
    modules/skresources/include/*.h \
    modules/sksg/include/*.h \
    modules/skshaper/include/*.h \
    modules/skshaper/src/*.h \
    modules/skshaper/utils/*.h \
    modules/skunicode/include/*.h \
    src/core/*.h \
    src/gpu/gl/*.h \
    src/utils/*.h \
    third_party/externals/angle2/LICENSE \
    third_party/externals/angle2/include \
    third_party/externals/freetype/docs/FTL.TXT \
    third_party/externals/freetype/docs/GPLv2.TXT \
    third_party/externals/freetype/docs/LICENSE.TXT \
    third_party/externals/freetype/include \
    third_party/externals/libpng/LICENSE \
    third_party/externals/libpng/*.h \
    third_party/externals/libwebp/COPYING \
    third_party/externals/libwebp/PATENTS \
    third_party/externals/libwebp/src/dec/*.h \
    third_party/externals/libwebp/src/dsp/*.h \
    third_party/externals/libwebp/src/enc/*.h \
    third_party/externals/libwebp/src/mux/*.h \
    third_party/externals/libwebp/src/utils/*.h \
    third_party/externals/libwebp/src/webp/*.h \
    third_party/externals/harfbuzz/COPYING \
    third_party/externals/harfbuzz/src/*.h \
    third_party/externals/swiftshader/LICENSE.txt \
    third_party/externals/swiftshader/include \
    third_party/externals/zlib/LICENSE \
    third_party/externals/zlib/*.h
fi
