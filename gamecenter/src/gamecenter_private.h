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

#pragma once
#include <dmsdk/sdk.h>
#include "luautils.h"

enum LeaderboardTimeScope
{
    LEADERBOARD_TIME_SCOPE_TODAY,
    LEADERBOARD_TIME_SCOPE_WEEK,
    LEADERBOARD_TIME_SCOPE_ALLTIME,
};

enum LeaderboardPlayerScope
{
    LEADERBOARD_PLAYER_SCOPE_GLOBAL,
    LEADERBOARD_PLAYER_SCOPE_FRIENDS_ONLY
};

enum GKErrors
{
    GK_ERROR_UNKOWN,
    GK_ERROR_CACELLED,
    GK_ERROR_COMMUNICATIONS_FAILURE,
    GK_ERROR_USER_DENIED,
    GK_ERROR_INVALID_CREDENTIALS,
    GK_ERROR_NOT_AUTHENTICATED,
    GK_ERROR_AUTHENTICATION_IN_PROGRESS,
    GK_ERROR_INVALID_PLAYER,
    GK_ERROR_SCORE_NOT_SET,
    GK_ERROR_PARENTAL_CONTROLS_BLOCKED,
    GK_ERROR_PLAYER_STATUS_EXEEDS_MAXIMUM_LENGTH,
    GK_ERROR_PLAYER_STATUS_INVALID,
    GK_ERROR_MATCH_REQUEST_INVALID,
    GK_ERROR_UNDERAGE,
    GK_ERROR_GAME_UNRECOGNIZED,
    GK_ERROR_NOT_SUPPORTED,
    GK_ERROR_INVALID_PARAMETER,
    GK_ERROR_UNEXPECTED_CONNECTION,
    GK_ERROR_CHALLENGE_INVALID,
    GK_ERROR_TURN_BASED_MATCH_DATA_TOO_LARGE,
    GK_ERROR_TURN_BASED_TOO_MANY_SESSIONS,
    GK_ERROR_TURN_BASED_INVALID_PARTICIPANT,
    GK_ERROR_TURN_BASED_INVALID_TURN,
    GK_ERROR_TURN_BASED_INVALID_STATE,
    GK_ERROR_INVITATIONS_DISABLED,
    GK_ERROR_PLAYER_PHOTO_FAILURE,
    GK_ERROR_UBIQUITY_CONTAINER_UNAVAILABLE,
    GK_ERROR_MATCH_NOT_CONNECTED,
    GK_ERROR_GAME_SESSION_REQUEST_INVALID
};

extern void login(CallbackFn fn , CallbackInfo* cbk);
extern void reportScore(const char *leaderboardId, int score, CallbackFn fn, CallbackInfo* cbk);
extern void showLeaderboards(int timeScope);
extern void showLeaderboards(const char *leaderboardId, int timeScope);
extern void showAchievements();
extern void submitAchievement(const char *identifier, double percentComplete, CallbackFn fn , CallbackInfo* cbk);
extern void resetAchievements(CallbackFn fn , CallbackInfo* cbk);
