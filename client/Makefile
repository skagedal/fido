VALAC=valac-0.20
# use --Xcc=-w to disable C warnings
VALAFLAGS=--Xcc=-w --Xcc=-g
VALAFLAGS:=--target-glib=2.36 --save-temps --thread $(VALAFLAGS)
LIBNAMES =                          \
	gobject-2.0                     \
	gio-2.0                         \
	gee-1.0                         \
	gtk+-3.0                        \
	webkitgtk-3.0
LIBS=$(LIBNAMES:%=--pkg %) --vapidir=../vapi

fido_client_SOURCES =               \
    fido.vala                       \
    fido-application.vala           \
    fido-window.vala                \
    ../server/dbus-interface.vala

all: fido 

fido: $(fido_client_SOURCES)
	$(VALAC) $(LIBS) $^ -o $@ $(VALAFLAGS)
	
clean:
	-rm fido *.c

