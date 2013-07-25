NULL =

AM_CPPFLAGS = \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\" 		\
	-DGNOMELOCALEDIR=\""$(prefix)/$(DATADIRNAME)/locale"\" 	\
	$(NULL)

bin_PROGRAMS = fido fido-cmd fido-subscribe

egg_list_box_sources = \
	$(top_builddir)/egg-list-box/egglistbox.vapi	\
	$(top_builddir)/egg-list-box/egg-list-box.c	\
	$(top_builddir)/egg-list-box/egg-list-box-accessible.c

# fido-cmd

fido_cmd_VALAFLAGS = 					\
	--vapidir=$(top_builddir)/vapi			\
	--pkg gio-2.0					\
	--pkg gee-1.0					\
	--pkg config					\
	--target-glib=2.36

FIDO_CMD_VALA_SOURCES = 				\
        $(top_srcdir)/server/fido-dbus-interface.vala   \
	fido-cmd-main.vala				

fido_cmd_SOURCES = 					\
	$(FIDO_CMD_VALA_SOURCES)

fido_cmd_LDFLAGS = -export-dynamic
fido_cmd_LDADD =					\
	$(FIDO_CMD_LIBS)				\
	$(NULL)

# fido-subscribe

fido_subscribe_VALAFLAGS = 				\
	--vapidir=$(top_builddir)/egg-list-box		\
	--vapidir=$(top_builddir)/vapi			\
	--pkg gtk+-3.0					\
	--pkg gio-2.0					\
	--pkg gee-1.0					\
	--pkg libgrss-0.5               		\
	--pkg libsoup-2.4               		\
	--pkg libxml2-2.0               		\
	--pkg config					\
	--target-glib=2.36

FIDO_SUBSCRIBE_VALA_SOURCES = 				\
        $(top_srcdir)/server/fido-dbus-interface.vala   \
        $(top_srcdir)/server/fido-feed.vala   		\
        $(top_srcdir)/server/fido-item.vala   		\
        $(top_srcdir)/server/fido-logging.vala   	\
	fido-feed-list.vala				\
	fido-feed-listwidget.vala			\
	fido-subscribe-main.vala			\
	$(NULL)
	
fido_subscribe_SOURCES =				\
	$(FIDO_SUBSCRIBE_VALA_SOURCES)			\
	$(egg_list_box_sources)

fido_subscribe_LDFLAGS = -export-dynamic
fido_subscribe_LDADD =                                 	\
	$(FIDO_LIBS)			        	\
	$(NULL)

# fido

fido_VALAFLAGS = \
	--vapidir=$(top_builddir)/libgd			\
	--vapidir=$(top_builddir)/egg-list-box		\
	--vapidir=$(top_builddir)/vapi			\
	--pkg gtk+-3.0					\
	--pkg gio-2.0					\
	--pkg gd-1.0					\
	--pkg webkitgtk-3.0				\
	--pkg gee-1.0					\
	--pkg config					\
	--target-glib=2.36


FIDO_VALA_SOURCES = \
        $(top_srcdir)/server/fido-dbus-interface.vala   \
	fido-application.vala		                \
	fido-window.vala                                \
	fido-main.vala			                \
	$(NULL)

fido_SOURCES = \
	$(FIDO_VALA_SOURCES)				\
	$(egg_list_box_sources)

fido_LDFLAGS = -export-dynamic
fido_LDADD =                                    \
	$(FIDO_LIBS)			        \
	$(top_builddir)/libgd/libgd.la          \
	$(NULL)

AM_CFLAGS = \
	$(FIDO_CFLAGS)		                \
	-I$(top_srcdir)/libgd		        \
	-I$(top_srcdir)/egg-list-box		\
	-Wall				        \
	-Wno-unused-but-set-variable	        \
	-Wno-unused-variable		        \
	$(NULL)

MAINTAINERCLEANFILES =	                        \
	*.stamp			                \
	$(VALA_SOURCES:.vala=.c)

EXTRA_DIST =                                    \
	fido.gresource.xml                      \
	fido-main-window.ui                     \
	fido-menu.ui

-include $(top_srcdir)/git.mk
