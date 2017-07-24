# Defold Apple Game Center Native Extension
Defold Game Center native extension. Only support basic funtionalities for now. 

## API:
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
gamecenter.login()
```
- ###### Show a specified Leaderboard
```lua    
gamecenter.showLeaderboard("com.siligame.example.defoldgamecenter.leaderboard")     
```
- ###### Show achivements
```lua
gamecenter.showAchivements()     
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
-- Show Achivements
elseif message_id == hash("show_achivements") then
   if gamecenter~= nil then
     gamecenter.showAchivements()
   end 
end 
```
