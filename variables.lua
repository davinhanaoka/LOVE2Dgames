TILE_SIZE = 32
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 640


--scale factor x 2.56, y 2.4
MAX_TILES_X = WINDOW_WIDTH / TILE_SIZE
MAX_TILES_Y = WINDOW_HEIGHT / TILE_SIZE

--game state variables
local gameOverFlag = false
local gameStart = true
local gamePrompt = true

--player variables
local playerMoving = 'right'
local playerSpeed = 0.2
local playerX, playerY = 1, 1
local playerTimer = 0
local state = 'fill'
local alive = false

--enemy variables
local enemySize = {24, 24, 24, 24, 24, 24, 28, 28, 28, 28,
                   28, 28, 32, 32, 32, 32, 32, 32, 36, 36,
                   36, 36, 36, 36, 32, 32, 32, 32, 32, 32,
                   28, 28, 28, 28, 28, 28}
local enemy = {}

local bossX = love.math.random(1, MAX_TILES_X)
local bossY = love.math.random(1, MAX_TILES_Y)
local bossSize = 96
local bossDir = 'right'
local bossSpeed = 0.8
local bossTimer = 0
local spawn = false
local bossAlive = false
local bossLife = 15

--follower variables
local followX = love.math.random(1, MAX_TILES_X)
local followY = love.math.random(1, MAX_TILES_Y)
local countDown = false
local followtimer = 8
local minMeterY = ((followY - 1) * TILE_SIZE) + TILE_SIZE
local score = 0

--entity colors
local green = {0, 0.75, 0, 1}
local grey = {0.5, 0.5, 0.5, 1}
local crimson = {0.54, 0, 0, 1}
local cyan = {0, 0.75, 0.75, 1}
local magenta = {0.75, 0, 0.75, 1}
local ecolor = crimson
local pcolor = cyan
local fcolor = green

--screen effect and color variables
local shakeTime, shakeDuration, shakeMagnitude = 0, -1, 0

local bgTimer = 600
local bg = 1
local maxRow = WINDOW_WIDTH
local maxCol = WINDOW_HEIGHT
local sizeRow = 0
local sizeCol = 0

local lightgreen = {0.75, 0.95, 0.77}
local lightpink = {0.98, 0.75, 0.75}
local lightyellow = {0.89, 0.85, 0.75}
local lightblue = {0.69, 0.95, 0.95}
local lightpurple = {0.90, 0.75, 0.95}
local lightbrown = {0.8, 0.7, 0.6}
local color = lightgreen
local oldcolor = lightbrown
local colorCode = 1

--control variables
local spawnFirst = true
local spawnDelay = 5
local firstStart = true
local resetFlag = false
local play = false

--title screen variables
local pX, pY = 0, 0
local pTimer = 0
local pSpeed = 0.2
local eX, eY = 0, 0
local eTimer = 0
local eSpeed = 0.3
local location = love.math.random(1, 4)
