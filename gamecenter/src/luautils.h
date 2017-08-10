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

struct LuaCallbackInfo
{
    LuaCallbackInfo() : m_L(0), m_Callback(LUA_NOREF), m_Self(LUA_NOREF) {}
    lua_State* m_L;
    int        m_Callback;
    int        m_Self;
};

struct GKError
{
    int			m_code;
    const char	*m_description;
    GKError(int code, const char *description) : m_code(code), m_description(description) {}
};

struct CallbackInfo
{
    LuaCallbackInfo *m_Cbk;
    GKError         *m_Error;
    CallbackInfo(): m_Error(0), m_Cbk(new LuaCallbackInfo()) {}
    void Delete(){
    	
    	if(m_Cbk) {
    		delete m_Cbk;
    	}
    	
    	if(m_Error) {
    		delete m_Error;
    	}
    }
};

typedef void (*CallbackFn)(CallbackInfo *cbkInfo);

void registerCallback(lua_State* L, int index, LuaCallbackInfo* cbk);
void invokeErrorCallback(CallbackInfo *cbkInfo);
void unregisterCallback(LuaCallbackInfo* cbk);
int checkTableNumber(lua_State* L, int index, const char* name, int default_value);
const char* toTableString(lua_State* L, int index, const char* name);