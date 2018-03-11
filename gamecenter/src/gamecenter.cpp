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
#if defined(DM_PLATFORM_IOS) || defined(DM_PLATFORM_OSX)
#include <unistd.h>
#endif

#define EXTENSION_NAME GameCenter
#define LIB_NAME "GameCenter"
#define MODULE_NAME "gamecenter"

// Defold SDK
#define DLIB_LOG_DOMAIN LIB_NAME
#include <dmsdk/sdk.h>

#if defined(DM_PLATFORM_IOS) || defined(DM_PLATFORM_OSX)

#include "gamecenter_private.h"

CallbackInfo *g_cbkInfo = 0;

static void _error(CallbackInfo *cbkInfo) {
    invokeErrorCallback(cbkInfo);
    unregisterCallback(cbkInfo->m_Cbk);
}

/** Authenticate local player, show Game Center login modal if not logged yet.
 */
static int login(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    registerCallback(L, 1, g_cbkInfo->m_Cbk);
    login(_error, g_cbkInfo);
    return 0;
}

/** Submit a score for a specified Leader Board
 */
static int reportScore(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    int n = lua_gettop(L);
    const char *leaderboardId = 0;
    int score = 0;
    
    if(n > 2) {
    	leaderboardId = lua_tostring(L, 1);
    	score = lua_tonumber(L, 2);
    } else {
    	leaderboardId = toTableString(L, 1, "leaderboardId");
    	score = checkTableNumber(L, 1, "score", 0);
    }
    
    dmLogInfo("leaderboardId : %s\n", leaderboardId);
    dmLogInfo("score : %g\n", score);
    
    registerCallback(L, n, g_cbkInfo->m_Cbk);
    reportScore(leaderboardId, score, _error, g_cbkInfo);
    return 0;
}

/** Load Leader Boards
 */
static int showLeaderboards(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    int n = lua_gettop(L);
    
    const char *leaderboardId = 0;
    int timeScope = LEADERBOARD_TIME_SCOPE_ALLTIME;
    
    if(n == 0) {
    	showLeaderboards(timeScope);
    }else if(lua_isnumber(L, 1)) {
    	timeScope = lua_tointeger(L, 1);
    	showLeaderboards(timeScope);
    }else if(lua_istable(L, 1)) {
    	leaderboardId = toTableString(L, 1, "leaderboardId");
    	timeScope = checkTableNumber(L, 2, "timeScope", LEADERBOARD_TIME_SCOPE_ALLTIME);
    	showLeaderboards(leaderboardId, timeScope);
    }else {
    	leaderboardId = lua_tostring(L, 1);
    	timeScope = lua_tointeger(L, 2);
    	showLeaderboards(leaderboardId, timeScope);
    }
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

/** Submit Achievement
 */
static int submitAchievement(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    
    const char *identifier = 0;
    double percentComplete = 0.0;
    int n = lua_gettop(L);
    
    if(n > 2) {
    	identifier = lua_tostring(L, 1);
    	percentComplete = lua_tonumber(L, 2);
    }else {
    	identifier = toTableString(L, 1, "identifier");
    	percentComplete = checkTableNumber(L, 1, "percentComplete", 0.0);
    }
    
    registerCallback(L, n, g_cbkInfo->m_Cbk);
    submitAchievement(identifier, percentComplete, _error, g_cbkInfo);
    return 0;
}

static void _loadAchievements(CallbackInfo *cbkInfo) {
	if(cbkInfo->m_Error) {
    	invokeErrorCallback(cbkInfo);
    }else {
    	invokeAchievementCallback(cbkInfo);
    }
    unregisterCallback(cbkInfo->m_Cbk);
}

/** Load Achievements
 */
static int loadAchievements(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    registerCallback(L, 1, g_cbkInfo->m_Cbk);
    loadAchievements(_loadAchievements, g_cbkInfo);
    return 0;
}

/** Reset Achievement
 */
static int resetAchievements(lua_State* L)
{
    DM_LUA_STACK_CHECK(L, 0);
    registerCallback(L, 1, g_cbkInfo->m_Cbk);
    resetAchievements(_error, g_cbkInfo);
    return 0;
}

static const luaL_reg Module_methods[] =
{
    {"login", login},
    {"reportScore", reportScore},
    {"showLeaderboards", showLeaderboards},
    {"showAchievements", showAchievements},
    {"submitAchievement", submitAchievement},
    {"loadAchievements", loadAchievements},
    {"resetAchievements", resetAchievements},
    {0, 0}
};

static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);
    luaL_register(L, MODULE_NAME, Module_methods);
    
#define SETCONSTANT(name) \
lua_pushnumber(L, (lua_Number) name); \
lua_setfield(L, -2, #name);\

    SETCONSTANT(LEADERBOARD_PLAYER_SCOPE_GLOBAL)
    SETCONSTANT(LEADERBOARD_PLAYER_SCOPE_FRIENDS_ONLY)
    
    SETCONSTANT(LEADERBOARD_TIME_SCOPE_TODAY)
    SETCONSTANT(LEADERBOARD_TIME_SCOPE_WEEK)
    SETCONSTANT(LEADERBOARD_TIME_SCOPE_ALLTIME)
    
    SETCONSTANT(GK_ERROR_UNKOWN)
    SETCONSTANT(GK_ERROR_CACELLED)
    SETCONSTANT(GK_ERROR_COMMUNICATIONS_FAILURE)
    SETCONSTANT(GK_ERROR_USER_DENIED)
    SETCONSTANT(GK_ERROR_INVALID_CREDENTIALS)
    SETCONSTANT(GK_ERROR_NOT_AUTHENTICATED)
    SETCONSTANT(GK_ERROR_AUTHENTICATION_IN_PROGRESS)
    SETCONSTANT(GK_ERROR_INVALID_PLAYER)
    SETCONSTANT(GK_ERROR_SCORE_NOT_SET)
    SETCONSTANT(GK_ERROR_PARENTAL_CONTROLS_BLOCKED)
    SETCONSTANT(GK_ERROR_PLAYER_STATUS_EXEEDS_MAXIMUM_LENGTH)
    SETCONSTANT(GK_ERROR_PLAYER_STATUS_INVALID)
    SETCONSTANT(GK_ERROR_MATCH_REQUEST_INVALID)
    SETCONSTANT(GK_ERROR_UNDERAGE)
    SETCONSTANT(GK_ERROR_GAME_UNRECOGNIZED)
    SETCONSTANT(GK_ERROR_NOT_SUPPORTED)
    SETCONSTANT(GK_ERROR_INVALID_PARAMETER)
    SETCONSTANT(GK_ERROR_UNEXPECTED_CONNECTION)
    SETCONSTANT(GK_ERROR_CHALLENGE_INVALID)
    SETCONSTANT(GK_ERROR_TURN_BASED_MATCH_DATA_TOO_LARGE)
    SETCONSTANT(GK_ERROR_TURN_BASED_TOO_MANY_SESSIONS)
    SETCONSTANT(GK_ERROR_TURN_BASED_INVALID_PARTICIPANT)
    SETCONSTANT(GK_ERROR_TURN_BASED_INVALID_TURN)
    SETCONSTANT(GK_ERROR_TURN_BASED_INVALID_STATE)
    SETCONSTANT(GK_ERROR_INVITATIONS_DISABLED)
    SETCONSTANT(GK_ERROR_PLAYER_PHOTO_FAILURE)
    SETCONSTANT(GK_ERROR_UBIQUITY_CONTAINER_UNAVAILABLE)
    SETCONSTANT(GK_ERROR_MATCH_NOT_CONNECTED)
    SETCONSTANT(GK_ERROR_GAME_SESSION_REQUEST_INVALID)
    
#undef SETCONSTANT
    
    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

dmExtension::Result AppInitializeGameCenter(dmExtension::AppParams* params)
{
    if (g_cbkInfo) {
        dmLogError("Game Center already initialized.");
        return dmExtension::RESULT_OK;
    }
    
    g_cbkInfo = new CallbackInfo();
    return dmExtension::RESULT_OK;
}

dmExtension::Result InitializeGameCenter(dmExtension::Params* params)
{
    LuaInit(params->m_L);
    dmLogInfo("Registered %s Lua extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

dmExtension::Result AppFinalizeGameCenter(dmExtension::AppParams* params)
{
    if( !g_cbkInfo) {
        return dmExtension::RESULT_OK;
    }
    
    g_cbkInfo->Delete();
    delete g_cbkInfo;
    g_cbkInfo = 0;  
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
