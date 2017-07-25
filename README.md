# Defold Apple Game Center Native Extension
Defold Game Center native extension. Only support basic funtionalities for now. 

## Usage:
```
Copy the whole gamecenter folder to your project root folder.
```
## APIs:
- ###### Login
```lua
gamecenter.login()
```
- ###### Report score to a specifed Leaderboard
```lua
gamecenter.reportScore("com.siligame.example.defoldgamecenter.leaderboard", message.score)
```
- ###### Show all Leaderboards
```lua
gamecenter.showLeaderboards()
```
- ###### Show a specified Leaderboard
```lua    
gamecenter.showLeaderboard("com.siligame.example.defoldgamecenter.leaderboard")     
```
- ###### Show achievements
```lua
gamecenter.showAchievements()     
```

## Limitation:
- No callbacks.
- No return values.
- No Exception handle.

## Examples:
```lua
-- Login 
if  gamecenter~= nil then
    gamecenter.login()
else
    print("could not connect native code")
end

-- Others --

-- Report score to a specified Leaderboard
if message_id == hash("report_scores") then
  if gamecenter~= nil then
    gamecenter.reportScore("com.siligame.example.defoldgamecenter.leaderboard", message.score)
  end
-- Show all Leaderboards
elseif message_id == hash("show_leaderboards") then
   if gamecenter~= nil then
      gamecenter.showLeaderboards()
   end  
-- Show a Leaderboard
elseif message_id == hash("show_highscore") then
   if gamecenter~= nil then
      gamecenter.showLeaderboard("com.siligame.example.defoldgamecenter.leaderboard")
   end     
-- Show Achievements
elseif message_id == hash("show_achievements") then
   if gamecenter~= nil then
     gamecenter.showAchievements()
   end 
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
