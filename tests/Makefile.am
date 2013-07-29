NULL =

noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS = tests test-webserver

SERVER = $(top_srcdir)/server

tests_SOURCES = 				\
	testcase.vala				\
	test-main.vala				\
	test-utils.vala				\
	test-updater.vala			\
	$(SERVER)/fido-utils.vala		\
	$(SERVER)/fido-updater.vala		\
	$(SERVER)/fido-database.vala		\
        $(SERVER)/fido-feed.vala                \
        $(SERVER)/fido-item.vala                \
        $(SERVER)/fido-dbus-interface.vala      \
        $(SERVER)/fido-logging.vala             \
        $(NULL)
	

tests_VALAFLAGS = 				\
	$(VALAFLAGS)				\
	--vapidir=$(top_builddir)/vapi		\
	--pkg gio-2.0		        	\
	--pkg gee-1.0                   	\
	--pkg libsoup-2.4               	\
	--pkg libxml2-2.0               	\
	--pkg sqlheavy-0.2              	\
	--pkg libgrss-0.5               	\
	--pkg posix				\
	--target-glib=2.36			\
	$(NULL)

tests_LDFLAGS = -export-dynamic
tests_LDADD =                                   \
	$(FIDOD_LIBS)			        \
	$(NULL)
	
test_webserver_SOURCES =			\
	test-webserver.vala			\
	$(NULL)

test_webserver_VALAFLAGS =			\
	$(VALAFLAGS)				\
	--pkg libsoup-2.4               	\	
	$(NULL)
	
test_webserver_LDADD = 				\
	$(FIDOD_LIBS)				\
	$(NULL)

AM_CFLAGS = 					\
	$(FIDOD_CFLAGS)				\
	-Wall					\
	-Wno-unused-but-set-variable		\
	-Wno-unused-variable		    	\
	$(NULL)
	
VALA_FILES = 					\
	$(tests_SOURCES)			\
	$(test_webserver_SOURCES)		\
	$(NULL)

VALA_FILES_NOTDIR = $(notdir $(VALA_FILES))

MAINTAINERCLEANFILES =	                        \
	*.stamp			                \
	$(VALA_FILES_NOTDIR:.vala=.c)


-include $(top_srcdir)/git.mk

