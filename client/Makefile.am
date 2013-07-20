NULL =

AM_CPPFLAGS = \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\" 		\
	-DGNOMELOCALEDIR=\""$(prefix)/$(DATADIRNAME)/locale"\" 	\
	$(NULL)

bin_PROGRAMS = fido fido-cmd

fido_cmd_VALAFLAGS = 					\
	--vapidir=$(top_builddir)/vapi			\
	--pkg gio-2.0					\
	--pkg gee-1.0					\
	--pkg config					\
	--target-glib=2.36

fido_VALAFLAGS = \
	--vapidir=$(top_builddir)/libgd			\
	--vapidir=$(top_builddir)/vapi			\
	--pkg gtk+-3.0					\
	--pkg gio-2.0					\
	--pkg gd-1.0					\
	--pkg webkitgtk-3.0				\
	--pkg gee-1.0					\
	--pkg config
	--target-glib=2.36

FIDO_CMD_VALA_SOURCES = 				\
        $(top_srcdir)/server/fido-dbus-interface.vala   \
	fido-cmd-main.vala				
	
FIDO_VALA_SOURCES = \
        $(top_srcdir)/server/fido-dbus-interface.vala   \
	fido-application.vala		                \
	fido-window.vala                                \
	fido-main.vala			                \
	$(NULL)

fido_SOURCES = \
	$(FIDO_VALA_SOURCES)	

fido_cmd_SOURCES = \
	$(FIDO_CMD_VALA_SOURCES)

fido_cmd_LDFLAGS = -export-dynamic
fido_cmd_LDADD =				\
	$(FIDO_CMD_LIBS)			\
	$(NULL)

fido_LDFLAGS = -export-dynamic
fido_LDADD =                                    \
	$(FIDO_LIBS)			        \
	$(top_builddir)/libgd/libgd.la          \
	$(NULL)

AM_CFLAGS = \
	$(FIDO_CFLAGS)		                \
	-I$(top_srcdir)/libgd		        \
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
