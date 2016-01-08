ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitARM")
endif

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

LIBCONFIG            := libconfig
LIBCONFIG_VERSION    := $(LIBCONFIG)-1.5
LIBCONFIG_SRC        := $(LIBCONFIG_VERSION).tar.gz
LIBCONFIG_DOWNLOAD   := "http://www.hyperrealm.com/libconfig/libconfig-1.5.tar.gz"

FREETYPE             := freetype
FREETYPE_VERSION     := $(FREETYPE)-2.6.1
FREETYPE_SRC         := $(FREETYPE_VERSION).tar.bz2
FREETYPE_DOWNLOAD    := "http://download.savannah.gnu.org/releases/freetype/freetype-2.6.1.tar.bz2"

LIBEXIF              := libexif
LIBEXIF_VERSION      := $(LIBEXIF)-0.6.21
LIBEXIF_SRC          := $(LIBEXIF_VERSION).tar.bz2
LIBEXIF_DOWNLOAD     := "http://sourceforge.net/projects/libexif/files/libexif/0.6.21/libexif-0.6.21.tar.bz2"

LIBJPEGTURBO         := libjpeg-turbo
LIBJPEGTURBO_VERSION := $(LIBJPEGTURBO)-1.4.2
LIBJPEGTURBO_SRC     := $(LIBJPEGTURBO_VERSION).tar.gz
LIBJPEGTURBO_DOWNLOAD := "http://sourceforge.net/projects/libjpeg-turbo/files/1.4.2/libjpeg-turbo-1.4.2.tar.gz"

LIBPNG               := libpng
LIBPNG_VERSION       := $(LIBPNG)-1.6.19
LIBPNG_SRC           := $(LIBPNG_VERSION).tar.xz
LIBPNG_DOWNLOAD      := "http://prdownloads.sourceforge.net/libpng/libpng-1.6.19.tar.xz"

SQLITE               := sqlite
SQLITE_VERSION       := $(SQLITE)-autoconf-3081002
SQLITE_SRC           := $(SQLITE_VERSION).tar.gz
SQLITE_DOWNLOAD      := "http://www.sqlite.org/2015/sqlite-autoconf-3081002.tar.gz"

ZLIB                 := zlib
ZLIB_VERSION         := $(ZLIB)-1.2.8
ZLIB_SRC             := $(ZLIB_VERSION).tar.gz
ZLIB_DOWNLOAD        := "http://prdownloads.sourceforge.net/libpng/zlib-1.2.8.tar.gz"

SDL                  := SDL
SDL_VERSION          := $(SDL)-mirror-SDL12_3DS
SDL_SRC              := $(SDL_VERSION).tar.gz
SDL_DOWNLOAD         := "https://github.com/LoveMHz/SDL-mirror/archive/SDL12_3DS.tar.gz"

SDLIMAGE             := SDL_image
SDLIMAGE_VERSION     := $(SDLIMAGE)-1.2.12
SDLIMAGE_SRC         := $(SDLIMAGE_VERSION).tar.gz
SDLIMAGE_DOWNLOAD    := "https://www.libsdl.org/projects/SDL_image/release/SDL_image-1.2.12.tar.gz"

export PORTLIBS        := $(DEVKITPRO)/portlibs/armv6k
export PATH            := $(DEVKITARM)/bin:$(PATH)
export PKG_CONFIG_PATH := $(PORTLIBS)/lib/pkgconfig
export CFLAGS          := -march=armv6k -mtune=mpcore -mfloat-abi=hard -O3 \
                          -mword-relocations -fomit-frame-pointer -ffast-math
export CPPFLAGS        := -I$(PORTLIBS)/include
export LDFLAGS         := -L$(PORTLIBS)/lib

.PHONY: all old_all install install-zlib clean \
	$(LIBCONFIG) \
        $(FREETYPE) \
        $(LIBEXIF) \
        $(LIBJPEGTURBO) \
        $(LIBPNG) \
        $(SQLITE) \
        $(ZLIB) \
        $(SDL) \
        $(SDLIMAGE)
all: zlib install-zlib libconfig install-libconfig freetype libexif libjpeg-turbo libpng sqlite sdl sdlimage install
	@echo "Finished!"

old_all:
	@echo "Please choose one of the following targets:"
	@echo "  $(LIBCONFIG)"
	@echo "  $(FREETYPE) (requires zlib to be installed)"
	@echo "  $(LIBEXIF)"
	@echo "  $(LIBJPEGTURBO)"
	@echo "  $(LIBPNG) (requires zlib to be installed)"
	@echo "  $(SQLITE)"
	@echo "  $(ZLIB)"
	@echo "  $(SDL)"
	@echo "  $(SDLIMAGE)"

$(LIBCONFIG): $(LIBCONFIG_SRC)
	@[ -d $(LIBCONFIG_VERSION) ] || tar -xf $<
	@cd $(LIBCONFIG_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-none-eabi --disable-cxx --disable-examples
	@$(MAKE) -C $(LIBCONFIG_VERSION)

$(FREETYPE): $(FREETYPE_SRC)
	@[ -d $(FREETYPE_VERSION) ] || tar -xf $<
	@cd $(FREETYPE_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-none-eabi --disable-shared --enable-static --without-harfbuzz
	@$(MAKE) -C $(FREETYPE_VERSION)

$(LIBEXIF): $(LIBEXIF_SRC)
	@[ -d $(LIBEXIF_VERSION) ] || tar -xf $<
	@cd $(LIBEXIF_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-none-eabi --disable-shared --enable-static
	@$(MAKE) -C $(LIBEXIF_VERSION)

$(LIBJPEGTURBO): $(LIBJPEGTURBO_SRC)
	@[ -d $(LIBJPEGTURBO_VERSION) ] || tar -xf $<
	@cd $(LIBJPEGTURBO_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-none-eabi --disable-shared --enable-static
	@$(MAKE) CFLAGS+="\"-Drandom()=rand()\"" -C $(LIBJPEGTURBO_VERSION)

$(LIBPNG): $(LIBPNG_SRC)
	@[ -d $(LIBPNG_VERSION) ] || tar -xf $<
	@cd $(LIBPNG_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-none-eabi --disable-shared --enable-static
	@$(MAKE) -C $(LIBPNG_VERSION)

# sqlite won't work with -ffast-math
$(SQLITE): $(SQLITE_SRC)
	@[ -d $(SQLITE_VERSION) ] || tar -xf $<
	@cd $(SQLITE_VERSION) && \
	 CFLAGS="$(filter-out -ffast-math,$(CFLAGS)) -DSQLITE_OS_OTHER=1" ./configure --disable-shared --disable-threadsafe --disable-dynamic-extensions --host=arm-none-eabi --prefix=$(PORTLIBS)
	# avoid building sqlite3 shell
	@$(MAKE) -C $(SQLITE_VERSION) libsqlite3.la

$(ZLIB): $(ZLIB_SRC)
	@[ -d $(ZLIB_VERSION) ] || tar -xf $<
	@cd $(ZLIB_VERSION) && \
	 CHOST=arm-none-eabi ./configure --static --prefix=$(PORTLIBS)
	@$(MAKE) -C $(ZLIB_VERSION)

$(SDL): $(SDL_SRC)
	@[ -d $(SDL_VERSION) ] || tar -xf $<
	@cd $(SDL_VERSION) && \
     ./autogen.sh && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-none-eabi --with-platform=3ds --disable-shared --enable-static
	@$(MAKE) -C $(SDL_VERSION)

$(SDLIMAGE): $(SDLIMAGE_SRC)
	@[ -d $(SDLIMAGE_VERSION) ] || tar -xf $<
	@cd $(SDLIMAGE_VERSION) && \
     sed -i '/noinst_PROGRAMS = showimage/c\#noinst_PROGRAMS = showimage' Makefile.am && \
     ./autogen.sh && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-none-eabi --disable-shared --enable-static --disable-sdltest --disable-webp \
     	SDL_CFLAGS="$(shell $(PORTLIBS)/bin/sdl-config --cflags)" \
     	SDL_LIBS="$(shell $(PORTLIBS)/bin/sdl-config --libs)" \
        PNG_LIBS="$(shell $(PORTLIBS)/bin/libpng-config --static --ldflags)" \
        PNG_CFLAGS="$(shell $(PORTLIBS)/bin/libpng-config --cflags)" \

# Downloads
$(LIBCONFIG_SRC):
	wget -O $@ $(LIBCONFIG_DOWNLOAD)

$(ZLIB_SRC):
	wget -O $@ $(ZLIB_DOWNLOAD)

$(FREETYPE_SRC):
	wget -O $@ $(FREETYPE_DOWNLOAD)

$(LIBEXIF_SRC):
	wget -O $@ $(LIBEXIF_DOWNLOAD)

$(LIBJPEGTURBO_SRC):
	wget -O $@ $(LIBJPEGTURBO_DOWNLOAD)

$(LIBPNG_SRC):
	wget -O $@ $(LIBPNG_DOWNLOAD)

$(SQLITE_SRC):
	wget -O $@ $(SQLITE_DOWNLOAD)

$(SDL_SRC):
	wget -O $@ $(SDL_DOWNLOAD)

$(SDLIMAGE_SRC):
	wget -O $@ $(SDLIMAGE_DOWNLOAD)

install-zlib:
	@$(MAKE) -C $(ZLIB_VERSION) install

install-libconfig:
	@$(MAKE) -C $(LIBCONFIG_VERSION) install

install:
	@[ ! -d $(LIBCONFIG_VERSION) ] || $(MAKE) -C $(LIBCONFIG_VERSION) install
	@[ ! -d $(FREETYPE_VERSION) ] || $(MAKE) -C $(FREETYPE_VERSION) install
	@[ ! -d $(LIBEXIF_VERSION) ] || $(MAKE) -C $(LIBEXIF_VERSION) install
	@[ ! -d $(LIBJPEGTURBO_VERSION) ] || $(MAKE) -C $(LIBJPEGTURBO_VERSION) install
	@[ ! -d $(LIBPNG_VERSION) ] || $(MAKE) -C $(LIBPNG_VERSION) install
	@[ ! -d $(SQLITE_VERSION) ] || $(MAKE) -C $(SQLITE_VERSION) install-libLTLIBRARIES install-data
	@[ ! -d $(SDL_VERSION) ] || $(MAKE) -C $(SDL_VERSION) install
	@[ ! -d $(SDLIMAGE_VERSION) ] || $(MAKE) -C $(SDLIMAGE_VERSION) install

clean:
	@$(RM) -r $(LIBCONFIG_VERSION)
	@$(RM) -r $(FREETYPE_VERSION)
	@$(RM) -r $(LIBEXIF_VERSION)
	@$(RM) -r $(LIBJPEGTURBO_VERSION)
	@$(RM) -r $(LIBPNG_VERSION)
	@$(RM) -r $(SQLITE_VERSION)
	@$(RM) -r $(ZLIB_VERSION)
