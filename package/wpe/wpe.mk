################################################################################
#
# WPE
#
################################################################################

WPE_VERSION = 553282e6683f23e80f17b1458d02d1aa3b17b7b7
WPE_SITE = $(call github,Metrological,WebKitForWayland,$(WPE_VERSION))

WPE_INSTALL_STAGING = YES
WPE_DEPENDENCIES = host-flex host-bison host-gperf host-ruby host-ninja \
	host-pkgconf zlib pcre libgles libegl cairo freetype fontconfig \
	harfbuzz icu libxml2 libxslt sqlite libsoup jpeg webp \
	wayland weston

ifeq ($(BR2_WPE_GSTREAMER),y)
WPE_DEPENDENCIES += \
	gstreamer1 gst1-plugins-base gst1-plugins-good gst1-plugins-bad
else
FLAGS+= \
	-DENABLE_VIDEO="OFF" -DENABLE_VIDEO_TRACK="OFF"
endif

WPE_TARGETS = Weston

ifeq ($(WPE_ATHOL),y)
WPE_DEPENDENCIES += \
	athol
WPE_TARGETS += {$(WPE_TARGETS),Athol}
endif
 
ifeq ($(BR2_ENABLE_DEBUG),y)
BUILDTYPE=Debug
WPE_BUILDDIR = $(@D)/debug
FLAGS+= -DCMAKE_C_FLAGS_DEBUG="-O0 -g -Wno-cast-align" \
 -DCMAKE_CXX_FLAGS_DEBUG="-O0 -g -Wno-cast-align"
else
BUILDTYPE=Release
WPE_BUILDDIR = $(@D)/release
FLAGS+= -DCMAKE_C_FLAGS_RELEASE="-O2 -DNDEBUG -Wno-cast-align" \
 -DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG -Wno-cast-align"
endif

ifeq ($(BR2_PACKAGE_WPE_USE_DXDRM_EME),y)
FLAGS += -DENABLE_DXDRM=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_ENCRYPTED_MEDIA),y)
FLAGS += -DENABLE_ENCRYPTED_MEDIA_V2=ON -DENABLE_ENCRYPTED_MEDIA=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_MEDIA_SOURCE),y)
FLAGS += -DENABLE_MEDIA_SOURCE=ON
endif

WPE_CONF_OPT = -DPORT=WPE -G Ninja \
 -DCMAKE_BUILD_TYPE=$(BUILDTYPE) \
 $(FLAGS)

RSYNC_VCS_EXCLUSIONS += --exclude LayoutTests

define WPE_BUILD_CMDS
	$(WPE_MAKE_ENV) $(HOST_DIR)/usr/bin/ninja -C $(WPE_BUILDDIR) jsc libWebKit2.so WPE{Web,Network}Process WPE$(WPE_TARGETS)Shell
endef

define WPE_INSTALL_STAGING_CMDS
	(cd $(WPE_BUILDDIR) && \
	cp bin/WPE{Network,Web}Process $(STAGING_DIR)/usr/bin/ && \
	cp -d lib/libWebKit* $(STAGING_DIR)/usr/lib/ && \
	cp lib/libWPE* $(STAGING_DIR)/usr/lib/ )
endef

define WPE_INSTALL_TARGET_CMDS
	(cd $(WPE_BUILDDIR) && \
	cp bin/WPE{Network,Web}Process $(TARGET_DIR)/usr/bin/ && \
	cp -d lib/libWebKit* $(TARGET_DIR)/usr/lib/ && \
	cp lib/libWPE* $(TARGET_DIR)/usr/lib/ && \
	$(STRIPCMD) $(TARGET_DIR)/usr/lib/libWebKit2.so.0.0.1 )
endef

$(eval $(cmake-package))
