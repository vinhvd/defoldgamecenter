#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define EXTENSION_NAME GameCenter
#define LIB_NAME "GameCenter"
#define MODULE_NAME "gamecenter"

// Defold SDK
#define DLIB_LOG_DOMAIN LIB_NAME
#include <dmsdk/sdk.h>

#if defined(DM_PLATFORM_IOS) || defined(DM_PLATFORM_OSX)

#include "gamecenter_private.h"


static int authenticate(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    authenticate();
	return 0;
}

static const luaL_reg Module_methods[] =
{
    {"authenticate", authenticate},
    {0, 0}
};


static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);
    luaL_register(L, MODULE_NAME, Module_methods);

    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

dmExtension::Result AppInitializeGameCenter(dmExtension::AppParams* params)
{
    return dmExtension::RESULT_OK;
}

dmExtension::Result InitializeGameCenter(dmExtension::Params* params)
{
    LuaInit(params->m_L);
    return dmExtension::RESULT_OK;
}

dmExtension::Result AppFinalizeGameCenter(dmExtension::AppParams* params)
{
    return dmExtension::RESULT_OK;
}

dmExtension::Result FinalizeGameCenter(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

#else // unsupported platforms


static dmExtension::Result AppInitializeGameCenter(dmExtension::AppParams* params)
{
    dmLogInfo("Registered %s (null) Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result InitializeGameCenter(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeGameCenter(dmExtension::AppParams* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeGameCenter(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

#endif // platforms


DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, AppInitializeGameCenter, AppFinalizeGameCenter, InitializeGameCenter, 0, 0, FinalizeGameCenter)
