# Defold Apple Game Center Native Extension
Defold Game Center native extension. Only support basic funtionalities for now. 

## Usage:
```
Copy the whole gamecenter folder to your project root folder.
```
## APIs:
- ###### Login
```lua
local function login_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)	
	end
end

gamecenter.login(login_cb)
```
- ###### Report score to a specifed Leaderboard
```lua
local function report_score_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)
	end
end

gamecenter.reportScore({leaderboardId="com.siligame.example.defoldgamecenter.leaderboard", score=message.score}, report_score_cb)

-- OR
gamecenter.reportScore("com.siligame.example.defoldgamecenter.leaderboard", message.score, report_score_cb)
```
- ###### Show all Leaderboards with default time scope
```lua
gamecenter.showLeaderboards()
```
- ###### Show all Leaderboards with time scope
```lua
gamecenter.showLeaderboards({timeScope=gamecenter.LEADERBOARD_TIME_SCOPE_WEEK})
-- OR
gamecenter.showLeaderboards(gamecenter.LEADERBOARD_TIME_SCOPE_WEEK)      
```
- ###### Show a specified Leaderboard
```lua    
gamecenter.showLeaderboards({leaderboardId="com.siligame.example.defoldgamecenter.leaderboard", timeScope=gamecenter.LEADERBOARD_TIME_SCOPE_WEEK})
-- OR
gamecenter.showLeaderboards("com.siligame.example.defoldgamecenter.leaderboard", gamecenter.LEADERBOARD_TIME_SCOPE_WEEK)       
```
- ###### Show achievements
```lua
gamecenter.showAchievements()     
```
- ###### Submit Achievement
```lua    
local function submit_achievement_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)
	end
end

gamecenter.submitAchievement({identifier="com.siligame.example.defoldgamecenter.achievementA", percentComplete=45.0}, submit_achievement_cb)  
-- OR
gamecenter.submitAchievement("com.siligame.example.defoldgamecenter.achievementA", percentComplete=45.0, submit_achievement_cb)         
```
- ###### Reset Achievements
```lua
local function reset_achievements_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)	
	end
end

gamecenter.resetAchievements(reset_achievements_cb) 
```
## Examples:
```lua
-- Login --

-- Login callback
local function login_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)
	end
end

-- Login
function init(self) 
    if  gamecenter~= nil then
        gamecenter.login(login_cb)
    else
        print("could not connect native code")
    end
end

-- Others --

-- submit achievement callback
local function submit_achievement_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)
	end
end

-- reset achievement callback
local function reset_achievements_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)
	end
end

-- report score callback
local function report_score_cb(self, data)
	if(data.error) then
		print("===>code :" .. data.error.code)
		print("===>message :" .. data.error.message)
	end
end

-- Report score to a specified Leaderboard
if message_id == hash("report_scores") then
  if gamecenter~= nil then
     gamecenter.reportScore({leaderboardId="com.siligame.example.defoldgamecenter.leaderboard", score=message.score}, report_score_cb)
  end
-- Show all Leaderboards
elseif message_id == hash("show_leaderboards") then
   if gamecenter~= nil then
      gamecenter.showLeaderboards(gamecenter.LEADERBOARD_TIME_SCOPE_WEEK)
   end  
-- Show a Leaderboard
elseif message_id == hash("show_highscore") then
   if gamecenter~= nil then
      gamecenter.showLeaderboards("com.siligame.example.defoldgamecenter.leaderboard", gamecenter.LEADERBOARD_TIME_SCOPE_WEEK)      
   end     
-- Show Achievements
elseif message_id == hash("show_achievements") then
   if gamecenter~= nil then
     gamecenter.showAchievements()
   end 
-- Submit Achievement
elseif message_id == hash("submit_achievement") then
        gamecenter.submitAchievement({identifier="com.siligame.example.defoldgamecenter.achievementA", percentComplete=45.0}, submit_achievement_cb)  
-- Reset Achievements
elseif message_id == hash("reset_achievements") then
        gamecenter.resetAchievements(reset_achievements_cb)                
end
```
## Screenshots:
- ###### Log in
![ScreenShot](https://s4.postimg.org/t7gzzsef1/image.png "Log in")
- ###### Log in progress
![ScreenShot](https://s4.postimg.org/xun21k1rx/image.png "Log in progress")
- ###### Logged in
![ScreenShot](https://s4.postimg.org/xx6xoe5fh/image.png "Logged in")
- ###### Show a leaderboard
![ScreenShot](https://s4.postimg.org/oo4re9wjh/image.png "Show a leaderboards")
- ###### Show leaderboards
![ScreenShot](https://s4.postimg.org/qihlw0jjx/image.png "Show leaderboards")
- ###### Show Achievements
![ScreenShot](https://s4.postimg.org/aya85h9fh/image.png "Show Achievements")
