NULL =

AM_CPPFLAGS = \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\" 		\
	-DGNOMELOCALEDIR=\""$(prefix)/$(DATADIRNAME)/locale"\" 	\
	$(NULL)

bin_PROGRAMS = fidod

fidod_VALAFLAGS = \
	--vapidir=$(top_builddir)/vapi	\
	--pkg gio-2.0		        \
	--pkg gee-1.0                   \
	--pkg libsoup-2.4               \
	--pkg libxml2-2.0               \
	--pkg sqlheavy-0.2              \
	--pkg libgrss-0.5               \
	--target-glib=2.36

VALA_SOURCES = \
        fido-database.vala              \
        fido-dbus-interface.vala        \
        fido-feed.vala                  \
        fido-item.vala                  \
        fido-logging.vala               \
        fido-updater.vala               \
        fido-utils.vala			\
	main.vala			\
	$(NULL)

fidod_SOURCES = \
	$(VALA_SOURCES)

AM_CFLAGS = \
	$(FIDOD_CFLAGS)		            \
	-Wall				            \
	-Wno-unused-but-set-variable	\
	-Wno-unused-variable		    \
	$(NULL)

fidod_LDFLAGS = -export-dynamic
fidod_LDADD =                           \
        $(FIDOD_LIBS)                   \
	$(NULL)

MAINTAINERCLEANFILES =	\
	*.stamp				\
	$(VALA_SOURCES:.vala=.c)

-include $(top_srcdir)/git.mk
