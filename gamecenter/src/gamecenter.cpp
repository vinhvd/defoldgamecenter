/*******************************************************************************
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *******************************************************************************/

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

/** Authenticate local player, show Game Center login modal if not logged yet.
 */
static int login(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    login();
    return 0;
}

/** Submit a score for a specified Leader Board
 * @param 1 The leaderboard identity to report
 * @param 2 The score to report
 */
static int reportScore(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    const char *leaderboardId = lua_tostring(L, 1);
    int score = luaL_checkint(L, 2);
    int status = reportScore(leaderboardId, score);
    return 0;
}

/** Load a specified Leader Board
 * @param 1 The leaderboard identity to load
 */
static int showLeaderboard(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    const char *leaderboardId = lua_tostring(L, 1);
    showLeaderboard(leaderboardId);
    return 0;
}

/** Load Leader Boards
 */
static int showLeaderboards(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    showLeaderboards();
    return 0;
}

/** Load Achievements
 */
static int showAchievements(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    showAchievements();
    return 0;
}

static const luaL_reg Module_methods[] =
{
    {"login", login},
    {"reportScore", reportScore},
    {"showLeaderboards", showLeaderboards},
    {"showLeaderboard", showLeaderboard},
    {"showAchievements", showAchievements},
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
