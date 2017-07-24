# defoldgamecenter
Defold Game Center native extension. Only support basic funtionalities for now. 

# API:
- Login
- Report score to a specifed Leaderboard
- Show all Leaderboards
- Show a specified Leaderboard
- Show achivements

# Limitation:
- No callbacks.
- No return values.

# Usage:
```
if message_id == hash("report_scores") then
    -- Report score to a specified Leaderboard
    if message_id == hash("report_scores") then
      if  gamecenter~= nil then
          gamecenter.reportScore("com.siligame.example.defoldgamecenter.leaderboard", message.score)
      end
    -- Show all Leaderboards
    elseif message_id == hash("show_leaderboards") then
    	if  gamecenter~= nil then
        	gamecenter.showLeaderboards()
      end  
    -- Show a Leaderboard
    elseif message_id == hash("show_highscore") then
    	if  gamecenter~= nil then
        	gamecenter.showLeaderboard("com.siligame.example.defoldgamecenter.leaderboard")
      end     
    -- Show Achivements
    elseif message_id == hash("show_achivements") then
    	if  gamecenter~= nil then
        	gamecenter.showAchivements()
      end          
end
```
