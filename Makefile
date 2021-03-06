.POSIX:

INSTALL ?= install
ASCIIDOC ?= asciidoc
SOURCES := subprocess.c liolib-copy.c
VERSION := 0.02
DISTDIR := lua-subprocess-$(VERSION)
DISTFILES := Makefile $(SOURCES) liolib-copy.h subprocess.txt subprocess.html

lua_package := lua5.2
INSTALL_CMOD := $(shell pkg-config --variable=INSTALL_CMOD $(lua_package))

ifeq ($(INSTALL_CMOD),)
$(error Lua package not found)
endif

CFLAGS ?= -Wall -Wextra -pedantic -O2
LUA_CFLAGS := $(shell pkg-config --cflags --libs $(lua_package))

.PHONY: all
all: subprocess.so subprocess.html

subprocess.so: $(SOURCES)
	$(CC) $(CFLAGS) $(LUA_CFLAGS) -DOS_POSIX -shared -fPIC -o $@ $(SOURCES)

subprocess.html: subprocess.txt
	$(ASCIIDOC) $<

.PHONY: clean
clean:
	$(RM) subprocess.so

.PHONY: install
install: subprocess.so
	mkdir -p $(DESTDIR)$(INSTALL_CMOD)/
	$(INSTALL) -m755 subprocess.so $(DESTDIR)$(INSTALL_CMOD)/

.PHONY: uninstall
uninstall:
	$(RM) $(INSTALL_CMOD)/subprocess.so

.PHONY: dist
dist: $(DISTFILES)
	[ -d $(DISTDIR) ] || mkdir $(DISTDIR)
	$(INSTALL) -m644 $(DISTFILES) $(DISTDIR)/
	tar -czf $(DISTDIR).tar.gz $(DISTDIR)
