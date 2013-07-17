VALAC=valac-0.20
# use --Xcc=-w to disable C warnings
VALAFLAGS=--Xcc=-w
VALAFLAGS := --target-glib=2.36 --save-temps $(VALAFLAGS)
LIBNAMES =                      \
	gobject-2.0                 \
	gio-2.0                     \
	gee-1.0                     \
	libsoup-2.4                 \
	libxml2-2.0                 \
	sqlheavy-0.2                \
	libgrss-0.5 
LIBS=$(LIBNAMES:%=--pkg %) --vapidir=../vapi

fido_server_SOURCES =           \
	fido-server.vala            \
	feed.vala                   \
	item.vala                   \
	dbus-interface.vala         \
	database.vala               \
	updater.vala                \
	logging.vala

all: fido-server 

fido-server: $(fido_server_SOURCES)
	$(VALAC) $(LIBS) $^ -o $@ $(VALAFLAGS)

clean:
	-rm fido-server *.c

