CC = gcc
CFLAGS = -fPIC
LUA_INCLUDE_DIR = /usr/include/lua5.4
SOURCES = llcontrol.c
OBJECTS = $(SOURCES:.c=.o)
TARGET = ../llcontrol.so
HEADER = llcontrol.h

$(TARGET): $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS)

%.o: %.c $(HEADER)
	$(CC) $(CFLAGS) -I$(LUA_INCLUDE_DIR) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET)

