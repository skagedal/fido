PROGRAM = fido
PROGRAM_SERVER = fido-server
PROGRAM_SUBSCRIBE = fido-subscribe
PROGRAM_LIST = fido-list

VERSION = 0.1.0
GITVER := $(shell git log -n 1 2>/dev/null | head -n 1 | awk '{print $$2}')

GETTEXT_PACKAGE = $(PROGRAM)

ifndef VALAC
VALAC := $(shell which valac)
else
VALAC := $(shell which $VALAC)
endif

VALAC_VERSION := `$(VALAC) --version | awk '{print $$2}'`
MIN_VALAC_VERSION := 0.18.0
INSTALL_PROGRAM := install
INSTALL_DATA := install -m 644

# needed for testing
VALADATE_PKG_NAME := valadate-1.0
MIN_VALADATE_VERSION := 0.1.1

# defaults that may be overridden by configure.mk
PREFIX=/usr/local
BUILD_RELEASE=1
LIB=lib

-include configure.mk

CORE_SUPPORTED_LANGUAGES=

VALAFLAGS := -g --enable-checking --target-glib=2.32 --thread --fatal-warnings $(USER_VALAFLAGS)

DEFINES := _PREFIX='"$(PREFIX)"' _VERSION='"$(VERSION)"' GETTEXT_PACKAGE='"$(GETTEXT_PACKAGE)"' \
	_LANG_SUPPORT_DIR='"$(SYSTEM_LANG_DIR)"' _LIB='"${LIB}"'

ifdef GITVER
DEFINES := $(DEFINES) _GIT_VERSION='"$(GITVER)"'
VALAFLAGS := $(VALAFLAGS) --define=_GITVERSION
endif

SERVER_SRC_FILES = \
	main.vala

SUBSCRIBE_SRC_FILES = \
	main.vala

LIST_SRC_FILES = \
	main.vala

TEXT_FILES = \
	AUTHORS \
	COPYING \
	INSTALL \
	MAINTAINERS \
	NEWS \
	README

LOCAL_PKGS =

EXT_PKGS = \
	gee-0.8 \
	gio-unix-2.0 \
	glib-2.0 \
	gmodule-2.0 \
	gtk+-3.0 \
	libsoup-2.4 \
	libxml-2.0 \
	sqlite3 \
	webkitgtk-3.0

EXT_PKG_VERSIONS = \
	gee-0.8 >= 0.8.0 \
	gio-unix-2.0 >= 2.20 \
	glib-2.0 >= $(MIN_GLIB_VERSION) \
	gmodule-2.0 >= 2.24.0 \
	gtk+-3.0 >= 3.4.0 \
	libsoup-2.4 >= 2.26.0 \
	libxml-2.0 >= 2.6.32 \
	sqlite3 >= 3.5.9 \
	webkitgtk-3.0 >= 1.4.0 

ifdef ENABLE_TESTS
EXT_PKGS += valadate-1.0
EXT_PKG_VERSIONS += valadate-1.0 >= 0.1.1
endif

VALA_PKGS = $(EXT_PKGS) $(LOCAL_PKGS)

ifndef BUILD_DIR
BUILD_DIR=src
endif

EXPANDED_SERVER_SRC_FILES := $(foreach src,$(SERVER_SRC_FILES),src/server/$(src))
EXPANDED_SUBSCRIBE_SRC_FILES := $(foreach src,$(SUBSCRIBE_SRC_FILES),src/client/$(src))
EXPANDED_LIST_SRC_FILES := $(foreach src,$(LIST_SRC_FILES),src/client/$(src))

DIST_FILES = \
	Makefile configure chkver \
	$(EXPANDED_SERVER_SRC_FILES) \
	$(EXPANDED_SUBSCRIBE_SRC_FILES) \
	$(EXPANDED_LIST_SRC_FILES)
DIST_TAR = $(PROGRAM)-$(VERSION).tar
DIST_TAR_XZ = $(DIST_TAR).xz

