#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <lauxlib.h>
#include <lualib.h>
#include <lua.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include "llcontrol.h"

static int disableRawMode(lua_State *L) {
  struct termios* origin = (struct termios *) lua_touserdata(L, lua_upvalueindex(1));
  tcsetattr(STDIN_FILENO, TCSAFLUSH, origin);
  return 0;
}

static int enableRawMode(lua_State *L) {
  struct termios* raw = (struct termios *) malloc(sizeof(struct termios));
  tcgetattr(STDIN_FILENO, raw);

  (raw->c_lflag) &= ~(ECHO | ICANON);
  tcsetattr(STDIN_FILENO, TCSAFLUSH, raw);

  write(STDOUT_FILENO, "\x1b[2J\x1b[H", 4);
  return 0;

}

static int createFIFO(lua_State *L) {
  const char* file_location = (char *) lua_tostring(L, -1);
  mkfifo(file_location, 0666);
  return 0;
}

static int deletefile(lua_State *L) {
  const char* file_location = (char *) lua_tostring(L, -1);
  if (remove(file_location) != 0) {
    return luaL_error(L, "Unable to remove %s", file_location);
  }
  return 0;
}

static int getWindowSize(lua_State *L) {
  struct winsize w;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
  lua_pushinteger(L, w.ws_row);
  lua_pushinteger(L, w.ws_col);

  return 2;
}


static int packFunctions(lua_State *L) {
  lua_newtable(L);

  lua_pushstring(L, "disableRawMode");
  struct termios* origin = (struct termios *) lua_newuserdata(L, sizeof(struct termios));
  tcgetattr(STDIN_FILENO, origin);
  lua_pushcclosure(L, disableRawMode, 1);
  lua_settable(L, -3);

  lua_pushstring(L, "enableRawMode");
  lua_pushcclosure(L, enableRawMode, 0);
  lua_settable(L, -3);

  lua_pushstring(L, "mkfifo");
  lua_pushcclosure(L, createFIFO, 0);
  lua_settable(L, -3);

  lua_pushstring(L, "remove");
  lua_pushcclosure(L, deletefile, 0);
  lua_settable(L, -3);

  lua_pushstring(L, "winsize");
  lua_pushcclosure(L, getWindowSize, 0);
  lua_settable(L, -3);
  return 1;
}



int luaopen_llcontrol(lua_State *L) {
  static const luaL_Reg r[] = {
    {"unpack", packFunctions},
    {NULL, NULL}
  };

  luaL_newlib(L, r);
  return 1;
}
