version=0.03
name=lua-redis-parser
dist=$(name)-$(version)

.PHONY: all clean dist test t

#CC = gcc
RM = rm -f

# Gives a nice speedup, but also spoils debugging on x86. Comment out this
# line when debugging.
OMIT_FRAME_POINTER = -fomit-frame-pointer

# Name of .pc file. "lua5.1" on Debian/Ubuntu
#LUAPKG = lua5.1
#CFLAGS = `pkg-config $(LUAPKG) --cflags` -fPIC -O3 -Wall
#LFLAGS = -shared $(OMIT_FRAME_POINTER)
#INSTALL_PATH = `pkg-config $(LUAPKG) --variable=INSTALL_CMOD`

## If your system doesn't have pkg-config, comment out the previous lines and
## uncomment and change the following ones according to your building
## enviroment.

#CFLAGS=-I/usr/include/lua5.1/ -O0 -g -fPIC -Wall -Werror

LUA_INC=/usr/include/lua5.1
CFLAGS=-I$(LUA_INC) -O2 -fPIC -Wall -Werror
LFLAGS=-shared $(OMIT_FRAME_POINTER)
INSTALL_PATH=/usr/lib/lua/5.1
CC=gcc
#INSTALL=install -D -s
INSTALL=cp -p

all: parser.so
	if [ ! -d redis ]; then mkdir redis; fi
	cp parser.so redis/

parser.lo: redis-parser.c ddebug.h
	$(CC) $(CFLAGS) -o parser.lo -c $<

parser.so: parser.lo
	$(CC) -o parser.so $(LFLAGS) $(LIBS) $<

install: parser.so
	if [ ! -d "$(DESTDIR)$(INSTALL_PATH)/redis" ]; then mkdir -p "$(DESTDIR)$(INSTALL_PATH)/redis"; fi
	$(INSTALL) parser.so $(DESTDIR)$(INSTALL_PATH)/redis/parser.so

clean:
	$(RM) *.so *.lo lz/*.so

test: parser.so
	LUA_CPATH="$$HOME/work/lua-cjson-1.0.2/?.so;;" prove -r t

valtest: parser.so
	if [ ! -d lz ]; then mkdir lz; fi
	cp parser.so lz/
	LUA_CPATH="$$HOME/work/lua-cjson-1.0.2/?.so;;" TEST_LUA_USE_VALGRIND=1 prove -r t

t: parser.so
	if [ ! -d lz ]; then mkdir lz; fi
	cp parser.so lz/
	LUA_CPATH="$$HOME/work/lua-cjson-1.0.2/?.so;;" TEST_LUA_USE_VALGRIND=1 prove t/sanity.t

dist:
	if [ -d $(dist) ]; then rm -r $(dist); fi
	mkdir $(dist)
	cp *.c *.h Makefile $(dist)/
	tar czvf $(dist).tar.gz $(dist)/

