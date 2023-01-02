import 'helpers'

local pd = playdate
local gfx <const> = pd.graphics
local font = gfx.font.new('font/cour-small') -- DEMO
local SFC_INERTIA = 3    -- higher for more inertia, lower for less inertia, 0 for no inertia
local SFC_MIN_WIDTH = 4    -- minimum width of cave
local SFC_MAX_WIDTH = 25    -- maximum width of cave (total screen width is only 48)
local SFC_LEVEL_RATE = 75    -- every N points the cave gets narrower, every 5N points the screen speeds up

local sfcScore = 0
local sfcHighScore = 0
local sfcWalls = newAutotable(2) --sfcWalls[48][2]
local sfcRibbon = table.create( 20, 0 ) --sfcRibbon[16]
local sfcTrend = 0
local sfcVelocity = 0
local sfcWidth = 0
local sfcMode = 0
local sfcWinner = false

function sfcDrawPixel(x, y, isRibbon) 
	if ((sfcMode < 2) and ((y < 4) or (y > 35))) then 
		return 
	end
	x = x * 4
	y = y * 2

	gfx.setColor(playdate.graphics.kColorWhite)

	gfx.drawPixel(x, y)
	gfx.drawPixel(x + 1, y + 1)
	gfx.drawPixel(x + 2, y)
	gfx.drawPixel(x + 3, y + 1)
	if (isRibbon) then
		gfx.drawPixel(x, y + 1)
		gfx.drawPixel(x + 1, y)
		gfx.drawPixel(x + 2, y + 1)
		gfx.drawPixel(x + 3, y)
	else 
		if (y <= 0) then
			gfx.drawPixel(x, 0)
			gfx.drawPixel(x + 2, 0)
		elseif (y >= 64) then
			--middle stray line
			gfx.drawPixel(x, 164)
			gfx.drawPixel(x + 2, 164)
		end
	end

end

function sfcPaintScreen()
	local x, y, z, q

	if (sfcScore > (SFC_LEVEL_RATE * 20)) then
	  q = 1
	  print("q1")
	  --pd.wait(20)
	elseif (sfcScore > (SFC_LEVEL_RATE * 15)) then
	  q = 2
	  print("q2")
	  --pd.wait(30)
	elseif (sfcScore > (SFC_LEVEL_RATE * 10)) then
	  q = 3
	  print("q3")
	  --pd.wait(40)
	elseif (sfcScore > (SFC_LEVEL_RATE * 5)) then
	  q = 4
	  print("q4")
	  --pd.wait(50)
	else
	  q = 5
	  --pd.wait(60)
	end

	gfx.clear()
	--for i=20,1,-1 do print(i) end

	for x = 1, 48, 1 do
	  -- draw the top half of the screen
	  z = 30 - sfcWalls[x][1]
	  for y = (z - q), z, 1 do
		sfcDrawPixel(x, y, false)
	  end
	  -- draw the bottom half of the screen
	  z = 30 - sfcWalls[x][2]
	  for y = z, (z + q), 1 do
		sfcDrawPixel(x, y, false)
	  end
	  -- draw the ribbon
	  if (x < 20) then
		y = 30 - sfcRibbon[x]
		sfcDrawPixel(x, y, true)
	  end
	end
	--gfx.setTextColor(WHITE) --, BLACK
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	if (sfcMode ~= 2) then
		gfx.drawText('Score:' .. sfcScore, 0, 0)
		if (sfcWinner) then
			gfx.drawText("High Score:", 50, 70)
		end
		gfx.drawText('High Score:' .. sfcHighScore, 50, 70)
	else 
		gfx.drawText('Score:' .. sfcScore,0,0)
	end

	if (sfcMode == 0) then
		gfx.drawText('Game Over', 60, 50)
	elseif (sfcMode == 1) then
		
		print('Start')
	  	gfx.drawText("Press A Btn to Start", 30, 50)
	end
end

function sfcStepWalls(lastValue)
	if (math.random(200) < 30) then sfcTrend = sfcTrend * -1 end
	local newValue = lastValue + sfcTrend
	if (newValue <  (-14 + sfcWidth)) then
	  newValue = (-14 + sfcWidth)
	  sfcTrend = 1
	end
	if (newValue > 14) then
	  newValue = 14
	  sfcTrend = -1
	end
	return newValue
end

function sfcWallsInit() 
	local x
	-- initialize the ribbon
	for x = 1, 20, 1 do
	  sfcRibbon[x] = 0
	end
	--initialize the screen at max width
	sfcWidth = SFC_MAX_WIDTH
	sfcTrend = 1
	for x = 1, 48, 1 do
	  if (x == 1) then
		sfcWalls[x][1] = SFC_MAX_WIDTH / 2
		sfcWalls[x][2] = sfcWalls[x][1] - SFC_MAX_WIDTH
	  else 
		sfcWalls[x][1] = sfcStepWalls(sfcWalls[x - 1][1])
		sfcWalls[x][2] = sfcWalls[x][1] - sfcWidth -- 20
	  end
	end
	sfcWinner = false
	sfcMode = 1

	sfcVelocity = 2 -- start off with a bit of velocity
	sfcPaintScreen()
end

function sfcGamePlay() 
	if (sfcScore > (SFC_LEVEL_RATE * 25)) then
		--pd.wait(10)
	elseif (sfcScore > (SFC_LEVEL_RATE * 20)) then
		pd.wait(10)
	elseif (sfcScore > (SFC_LEVEL_RATE * 15)) then
		pd.wait(15)
	elseif (sfcScore > (SFC_LEVEL_RATE * 10)) then
		pd.wait(20)
	elseif (sfcScore > (SFC_LEVEL_RATE * 5)) then
		pd.wait(25)
	else
	pd.wait(30)
	end

  	local x, y
  	local newRibbon = sfcRibbon[20]

	if (pd.buttonIsPressed('A')) then
		print('pressed A')
		sfcVelocity+=1
  	else 
    	sfcVelocity-=1
	end

  if (sfcVelocity > SFC_INERTIA) then
    sfcVelocity = SFC_INERTIA
    newRibbon+=1      -- increases difficulty!
  end
  if (sfcVelocity < -SFC_INERTIA) then
    sfcVelocity = -SFC_INERTIA
    newRibbon-=1      -- increases difficulty!
  end

  -- get next ribbon position
  if (sfcVelocity > 0) then newRibbon+=1 end
  if (sfcVelocity < 0) then newRibbon-=1 end
  if (newRibbon > 20) then newRibbon = 20 end
  if (newRibbon < -20) then newRibbon = -20 end
  -- get next screen column
  local newRoof = sfcStepWalls(sfcWalls[48][1])
  local newFloor = newRoof - sfcWidth
  -- advance the screen one column
  for x = 1, 48, 1 do
    sfcWalls[x][1] = sfcWalls[x + 1][1]
    sfcWalls[x][2] = sfcWalls[x + 1][2]
    if (x<20) then sfcRibbon[x] = sfcRibbon[x + 1] end
  end
  sfcWalls[48][1] = newRoof
  sfcWalls[48][2] = newFloor
  sfcRibbon[20] = newRibbon
  -- test for game over
  if (newRibbon >= sfcWalls[20][1]) then sfcMode = 0 end -- crashed!
  if (newRibbon <= sfcWalls[20][2]) then sfcMode = 0 end -- crashed!
  if (sfcMode == 0) then
	  if (sfcScore > sfcHighScore) then
      sfcHighScore = sfcScore
      sfcWinner = true
    --   Save High Score here
		playdate.datastore.write(sfcHighScore, "highScore")
	  end
    sfcPaintScreen()
    pd.wait(500) -- little pause to relax and stop button mashing
  else
    sfcPaintScreen()
    sfcScore+=1
    if ((sfcWidth > SFC_MIN_WIDTH) and ((sfcScore % SFC_LEVEL_RATE) == 0)) then sfcWidth-=1 end
  end
end

local function loadGame()
	pd.display.setRefreshRate(30) -- Sets framerate to 50 fps
	pd.display.setScale(3)
	
	gfx.setFont(font)
	gfx.setBackgroundColor(playdate.graphics.kColorBlack)
	gfx.clear()
	
	sfcWallsInit()
	if playdate.datastore.read("highScore") ~= nil then
		sfcHighScore = playdate.datastore.read("highScore")
	end
end

loadGame()

function playdate.update()
	if (sfcMode == 2) then
	  sfcGamePlay()
	else 
		if (pd.buttonJustPressed('A')) then
		  if (sfcMode == 0) then
			sfcWallsInit()
		  elseif (sfcMode == 1) then
			sfcMode = 2
			sfcScore = 0
		  end
		end
	end
	--pd.drawFPS(0,20)
end