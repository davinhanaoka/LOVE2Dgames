--require('variables')

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

function love.load()
  love.window.setTitle('Pursuit')
  love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false
  })

  playerSound = love.audio.newSource('audio/player_boop.wav', 'static')
  playerDeath = love.audio.newSource('audio/player_die.wav', 'static')
  enemySound = love.audio.newSource('audio/enemy_boop.wav', 'static')
  followSound = love.audio.newSource('audio/collect.wav', 'static')
  bossSound = love.audio.newSource('audio/boss_boop.wav', 'static')
  titleSound = love.audio.newSource('audio/title_sound.mp3', 'static')
  inGameSound = love.audio.newSource('audio/in_game.mp3', 'static')
  select = love.audio.newSource('audio/select.wav', 'static')

  playerSound:setPitch(1.5)
  playerSound:setVolume(1.5)
  enemySound:setVolume(0.6)
  inGameSound:setVolume(0.5)
  inGameSound:setLooping(true)
  titleSound:setLooping(true)

  love.graphics.setBackgroundColor(1, 1, 1, 1)

  math.randomseed(os.time())
  moveFollower()
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if alive then
    if key == 'right' then
      playerSound:stop()
      playerSound:play()
      playerMoving = 'right'
    elseif key == 'left' then
      playerSound:stop()
      playerSound:play()
      playerMoving = 'left'
    elseif key == 'up' then
      playerSound:stop()
      playerSound:play()
      playerMoving = 'up'
    elseif key == 'down' then
      playerSound:stop()
      playerSound:play()
      playerMoving = 'down'
    end
  end

  if gameStart then
    if key == 'space' then
      select:play()
      gameStart = false
      gamePrompt = true
      resetFlag = false
    end
  elseif gamePrompt then
    if key == 'space' then
      select:play()
      gamePrompt = false
      play = true
    end
  elseif gameOverFlag then
    if key == 'space' then
      select:play()
      gameOverFlag = false
      resetFlag = true
    end
  end
end

function love.update(dt)

  if gameStart or gamePrompt then
    titleSound:play()
  else
    titleSound:stop()
  end

  if resetFlag then
    gameOverFlag = false
    resetFlag = false
    reset()
  end

  if not gameStart and not gamePrompt and play then
    alive = true
    gameOverFlag = false
  else
    alive = false
  end

  if gameStart then
    pTimer = pTimer + dt
    eTimer = eTimer + dt
    if location == 1 then
      pY, eY = 2, 2
      if pTimer >= pSpeed then
        pX = pX + 1
        pTimer = 0
      end
      if eTimer >= eSpeed then
        if eX >= MAX_TILES_X + 2 then
          location = love.math.random(1, 4)
          if location == 1 or location == 3 then
            pX = 0
            ex = pX - 2
          else
            pX = MAX_TILES_X + 1
            ex = pX + 2
          end
        else
          eX = eX + 1
          eTimer = 0
        end
      end
    elseif location == 2 then
      pY, eY = 2, 2
      if pTimer >= pSpeed then
        pX = pX - 1
        pTimer = 0
      end
      if eTimer >= eSpeed then
        if eX <= -2 then
          location = love.math.random(1, 4)
          if location == 1 or location == 3 then
            pX = 0
            ex = pX - 2
          else
            pX = MAX_TILES_X + 2
            ex = pX + 2
          end
        else
          eX = eX - 1
          eTimer = 0
        end
      end
    elseif location == 3 then
      pY, eY = MAX_TILES_Y - 2, MAX_TILES_Y - 2
      if pTimer >= pSpeed then
        pX = pX + 1
        pTimer = 0
      end
      if eTimer >= eSpeed then
        if eX >= MAX_TILES_X + 2 then
          location = love.math.random(1, 4)
          if location == 1 or location == 3 then
            pX = 0
            ex = pX - 2
          else
            pX = MAX_TILES_X + 1
            ex = pX + 2
          end
        else
          eX = eX + 1
          eTimer = 0
        end
      end
    elseif location == 4 then
      pY, eY = MAX_TILES_Y - 2, MAX_TILES_Y - 2
      if pTimer >= pSpeed then
        pX = pX - 1
        pTimer = 0
      end
      if eTimer >= eSpeed then
        if eX <= -2 then
          location = love.math.random(1, 4)
          if location == 1 or location == 3 then
            pX = 0
            ex = pX - 2
          else
            pX = MAX_TILES_X + 2
            ex = pX + 2
          end
        else
          eX = eX - 1
          eTimer = 0
        end
      end
    end
  end

  if score > 0 and score % 5 == 0 and not bossAlive then
    spawn = true
  end

  if spawn then
    bossAlive = true
    spawn = false
    bossLife = 15
  end

  if bossLife >= 0 and bossAlive then
    bossTimer = bossTimer + dt
    if bossTimer >= bossSpeed then
      bossDir = love.math.random(1, 4)
      if bossDir == 1 then
        bossSound:stop()
        bossSound:play()
        if bossY <= 1 then
          bossY = MAX_TILES_Y - 2
        else
          bossY = bossY - 2
        end
      elseif bossDir == 2 then
        bossSound:stop()
        bossSound:play()
        if bossY >= MAX_TILES_Y - 2 then
          bossY = 1
        else
          bossY = bossY + 2
        end
      elseif bossDir == 3 then
        bossSound:stop()
        bossSound:play()
        if bossX <= 1 then
          bossX = MAX_TILES_X - 2
        else
          bossX = bossX - 2
        end
      else
        bossSound:stop()
        bossSound:play()
        if bossX >= MAX_TILES_X - 2 then
          bossX = 1
        else
          bossX = bossX + 2
        end
      end
      bossTimer = 0
    end
  end

  bossLife = bossLife - dt
  if bossLife <= 0 then
    bossAlive = false
  end

  if followCollision() then
    score = score + 1
    followSound:stop()
    followSound:play()
    moveFollower()
  end

  for i = 1, #enemy do

    enemy[i].sizeIndex = enemy[i].sizeIndex + 1
    if enemy[i].sizeIndex > 36 then
      enemy[i].sizeIndex = 1
    else
      enemy[i].sizeIndex = enemy[i].sizeIndex + 1
      enemy[i].size = enemy[i].sizeIndex
    end
    if enemy[i].size < 24 then
      enemy[i].size = enemySize[1]
    end

    enemy[i].enemyTimer = enemy[i].enemyTimer + dt
    enemy[i].currentDistance = getDistance(playerX, playerY, enemy[i].enemyX, enemy[i].enemyY)

    if enemy[i].currentDistance <= 12 and alive then
      enemy[i].chase = true
      enemy[i].chaseTimer = enemy[i].chaseTimer - 1
      if enemy[i].chaseTimer == 0 and enemy[i].enemySpeed >= 0.15 then
        enemy[i].enemySpeed = enemy[i].enemySpeed - dt
        enemy[i].chaseTimer = 50
      end
    else
      enemy[i].chase = false
      enemy[i].enemySpeed = 0.5
      enemy[i].chaseTimer = 50
    end

    if enemy[i].chase ~= true then
      enemy[i].enemyMoving = love.math.random(1, 4)

      if enemy[i].enemyMoving == 1 then
        enemy[i].enemyDirection = 'up'
      elseif enemy[i].enemyMoving == 2 then
        enemy[i].enemyDirection = 'down'
      elseif enemy[i].enemyMoving == 3 then
        enemy[i].enemyDirection = 'left'
      else
        enemy[i].enemyDirection = 'right'
      end
    else
      enemy[i].enemyDirection = enemyPath(enemy[i].enemyX, enemy[i].enemyY)
    end

    if enemy[i].enemyTimer >= enemy[i].enemySpeed then
      if enemy[i].enemyDirection == 'up' then
        enemySound:stop()
        enemySound:play()
        if enemy[i].enemyY <= 1 then
          enemy[i].enemyY = MAX_TILES_Y
        else
          enemy[i].enemyY = enemy[i].enemyY - 1
        end
      elseif enemy[i].enemyDirection == 'down' then
        enemySound:stop()
        enemySound:play()
        if enemy[i].enemyY >= MAX_TILES_Y then
          enemy[i].enemyY = 1
        else
          enemy[i].enemyY = enemy[i].enemyY + 1
        end
      elseif enemy[i].enemyDirection == 'left' then
        enemySound:stop()
        enemySound:play()
        if enemy[i].enemyX <= 1 then
          enemy[i].enemyX = MAX_TILES_X
        else
          enemy[i].enemyX = enemy[i].enemyX - 1
        end
      else
        enemySound:stop()
        enemySound:play()
        if enemy[i].enemyX >= MAX_TILES_X then
          enemy[i].enemyX = 1
        else
          enemy[i].enemyX = enemy[i].enemyX + 1
        end
      end
      enemy[i].enemyTimer = 0
    end

    if (alive and collision(enemy[i].enemyX, enemy[i].enemyY, enemy[i].size)) or
       (alive and bossAlive and bossCollision(bossX, bossY)) then
      pcolor = grey
      playerSpeed = 100
      enemy[i].chase = false
      alive = false
      shake = true
      startShake(1, 5)
      playerDeath:play()
      play = false
    else
      pcolor = cyan
      playerSpeed = 0.2
      shake = false
    end
  end -- end of for i

  if alive then
    inGameSound:play()

    maxRow = maxRow - TILE_SIZE
    maxCol = maxCol - TILE_SIZE
    sizeRow = sizeRow + TILE_SIZE
    sizeCol = sizeCol + TILE_SIZE

    bgTimer = bgTimer - 1

    if bgTimer <= 0 then
      oldcolor = color
      maxRow = WINDOW_WIDTH
      maxCol = WINDOW_HEIGHT
      sizeRow = 0
      sizeCol = 0
      bg = love.math.random(1, 8)
      bgTimer = 600
      maxRow = WINDOW_WIDTH
      maxCol = WINDOW_HEIGHT
      sizeRow = 0
      sizeCol = 0

      repeat
        colorCode = love.math.random(1, 6)
        if colorCode == 1 then
          color = lightblue
        elseif colorCode == 2 then
          color = lightpink
        elseif colorCode == 3 then
          color = lightbrown
        elseif colorCode == 4 then
          color = lightgreen
        elseif colorCode == 5 then
          color = lightyellow
        elseif colorCode == 6 then
          color = lightpurple
        end
      until color ~= oldcolor
    end

    playerTimer = playerTimer + dt
    followtimer = followtimer - dt

    minMeterY = minMeterY - (4 * dt)

    if minMeterY <= (followY - 1) * TILE_SIZE then
      minMeterY = ((followY - 1) * TILE_SIZE) + TILE_SIZE
    end

    spawnDelay = spawnDelay - dt
    if spawnDelay <= 0 then
      if spawnFirst then
        enemy = {{enemyX = math.random(1, MAX_TILES_X), enemyY = math.random(1, MAX_TILES_Y),
                  enemyMoving = 1, enemyDirection = 'right', enemySpeed = 0.5, enemyTimer = 0,
                  chase = false, chaseTimer = 50, sizeIndex = love.math.random(1, 36), size = 32,
                  currentDistance = 0}}
                  spawnFirst = false
      end
      spawnDelay = 5
    end

    if followtimer <= 0 then
      table.insert(enemy, {enemyX = followX, enemyY = followY,
                   enemyMoving = 1, enemyDirection = 'right', enemySpeed = 0.5, enemyTimer = 0,
                   chase = false, chaseTimer = 50, sizeIndex = love.math.random(1, 36), size = 32,
                   currentDistance = 0})
      moveFollower()
    end

    if playerTimer >= playerSpeed then
      if playerMoving == 'up' then
        if playerY <= 1 then
          playerY = MAX_TILES_Y
        else
          playerY = playerY - 1
        end
      elseif playerMoving == 'down' then
        if playerY >= MAX_TILES_Y then
          playerY = 1
        else
          playerY = playerY + 1
        end
      elseif playerMoving == 'left' then
        if playerX <= 1 then
          playerX = MAX_TILES_X
        else
          playerX = playerX - 1
        end
      else
        if playerX >= MAX_TILES_X then
          playerX = 1
        else
          playerX = playerX + 1
        end
      end
      playerTimer = 0
    end
  else--else not alive
    inGameSound:stop()
    gameOverFlag = true
    shake = false
    gameOver()
  end --end else not alive
end --end update

function love.draw()
  --love.graphics.push()
  --love.graphics.scale(2.56, 2.4)
  if gameStart then
    love.graphics.setBackgroundColor(cyan)
    local font = love.graphics.newFont('Tutor.ttf', 128)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.printf('PURSUIT', 0, WINDOW_HEIGHT / 2 - 128, WINDOW_WIDTH, 'center')
    local fontPrompt = love.graphics.newFont('unlearn2.ttf', 32)
    love.graphics.setFont(fontPrompt)
    love.graphics.printf('Press Space to Start', 0, WINDOW_HEIGHT / 2 + 32, WINDOW_WIDTH, 'center')
    love.graphics.setColor(lightyellow)
    love.graphics.rectangle('fill', 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT / 5)
    love.graphics.rectangle('fill', 0, 4 * (WINDOW_HEIGHT / 5), WINDOW_WIDTH, WINDOW_HEIGHT / 5)
    drawCharacters()
  elseif gamePrompt then
    love.graphics.setBackgroundColor(lightbrown)
    local font = love.graphics.newFont('Tutor.ttf', 48)
    love.graphics.setColor(0, 0, 0, 1)
    local fontInstruct = love.graphics.newFont('good_timing.ttf', 32)
    love.graphics.setFont(fontInstruct)
    love.graphics.printf('To Play:', 0, WINDOW_HEIGHT / 2 - 288, WINDOW_WIDTH, 'center')
    love.graphics.printf('- Move by tapping in a direction.', 0, WINDOW_HEIGHT / 2 - 256, WINDOW_WIDTH, 'left')
    love.graphics.printf('- Avoid the Red Haters!', 0, WINDOW_HEIGHT / 2 - 224, WINDOW_WIDTH, 'left')
    love.graphics.printf('- Collect the Green Followers.', 0, WINDOW_HEIGHT / 2 - 192, WINDOW_WIDTH, 'left')
    love.graphics.printf('- Followers turn to Haters over time.', 0, WINDOW_HEIGHT / 2 - 160, WINDOW_WIDTH, 'left')
    love.graphics.printf('- Watch out for the black void!', 0, WINDOW_HEIGHT / 2 - 128, WINDOW_WIDTH, 'left')
    love.graphics.printf('- Press Space to start.', 0, WINDOW_HEIGHT / 2 - 96, WINDOW_WIDTH, 'left')
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle('fill', WINDOW_HEIGHT / 2 - 196 - 10, WINDOW_WIDTH / 2 - 32 + 10, 64, 64)
    love.graphics.setColor(pcolor)
    love.graphics.rectangle('fill', WINDOW_HEIGHT / 2 - 196, WINDOW_WIDTH / 2 - 32, 64, 64)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle('fill', WINDOW_HEIGHT / 2 + 36 - 10, WINDOW_WIDTH / 2 - 32 + 10, 64, 64)
    love.graphics.setColor(fcolor)
    love.graphics.rectangle('fill', WINDOW_HEIGHT / 2 + 36, WINDOW_WIDTH / 2 - 32, 64, 64)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle('fill', WINDOW_HEIGHT / 2 + 256 - 10, WINDOW_WIDTH / 2 - 32 + 10, 64, 64)
    love.graphics.setColor(ecolor)
    love.graphics.rectangle('fill', WINDOW_HEIGHT / 2 + 256, WINDOW_WIDTH / 2 - 32, 64, 64)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf('The Player', 0, WINDOW_HEIGHT / 2 + 128, WINDOW_WIDTH / 2 - 120, 'center')
    love.graphics.printf('The Followers', 0, WINDOW_HEIGHT / 2 + 128, WINDOW_WIDTH / 2 + 364, 'center')
    love.graphics.printf('The Haters', 0, WINDOW_HEIGHT / 2 + 128, WINDOW_WIDTH / 2 + 846, 'center')
  else

    if shakeTime < shakeDuration then
      local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
      local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
      love.graphics.translate(dx, dy)
      shakeTime = shakeTime + 0.025
    end

    if alive ~= true then
      drawEndgame()
      drawScore()
    else
      if bg == 1 then
        bgSwipeTopLR()
      elseif bg == 2 then
        bgSwipeBottomRL()
      elseif bg ==3 then
        bgSwipeTopRL()
      elseif bg == 4 then
        bgSwipeBottomLR()
      elseif bg == 5 then
        bgSwipeLR()
      elseif bg == 6 then
        bgSwipeRL()
      elseif bg == 7 then
        bgSwipeTop()
      elseif bg == 8 then
        bgSwipeBottom()
      end
      love.graphics.setBackgroundColor(oldcolor)
      drawShadows()
      drawPlayer()
      drawEnemy()
      if bossAlive then
        drawBoss()
      end
      drawFollower()
      drawScore()
    end
  end
  --love.graphics.pop()
end

function drawCharacters()
  love.graphics.setColor(0, 0, 0, 0.4)
  love.graphics.rectangle('fill', (pX - 1) * TILE_SIZE - 5, (pY - 1) * TILE_SIZE + 5, TILE_SIZE, TILE_SIZE)
  love.graphics.setColor(cyan)
  love.graphics.rectangle('fill', (pX - 1) * TILE_SIZE, (pY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
  love.graphics.setColor(0, 0, 0, 0.4)
  love.graphics.rectangle('fill', (eX - 1) * TILE_SIZE - 5, (eY - 1) * TILE_SIZE + 5, TILE_SIZE, TILE_SIZE)
  love.graphics.setColor(crimson)
  love.graphics.rectangle('fill', (eX - 1) * TILE_SIZE, (eY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
end

function drawScore()
  local font = love.graphics.newFont('Tutor.ttf', 36)
  love.graphics.setFont(font)
  if alive then
    love.graphics.setColor(0, 0, 0, 1)
  elseif alive ~= true then
    love.graphics.setColor(1, 1, 1, 1)
  end
    local font = love.graphics.newFont('Tutor.ttf', 32)
    love.graphics.setFont(font)
    love.graphics.printf('FOLLOWERS', 0, (WINDOW_HEIGHT / 2) - 330, WINDOW_WIDTH, 'center')
    local font = love.graphics.newFont('Tutor.ttf', 36)
    love.graphics.setFont(font)
    love.graphics.printf(score, 0, (WINDOW_HEIGHT / 2) - 302, WINDOW_WIDTH, 'center')
end

function drawEndgame()
  color = {0, 0, 0, 0}
  love.graphics.setBackgroundColor(color)
  local font = love.graphics.newFont('Tutor.ttf', 128)
  love.graphics.setFont(font)
  drawShadows()
  drawPlayer()
  if bossAlive then
    drawBoss()
  end
  love.graphics.setColor(ecolor)
  for v = table.getn(enemy), 1, -1 do
    love.graphics.rectangle('fill', (enemy[v].enemyX - 1) * TILE_SIZE, (enemy[v].enemyY - 1) * TILE_SIZE,
    enemy[v].size, enemy[v].size)
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf('GAME OVER', 0, WINDOW_HEIGHT / 2 - 128, WINDOW_WIDTH, 'center')
  local fontCont = love.graphics.newFont('unlearn2.ttf', 32)
  love.graphics.setFont(fontCont)
  love.graphics.printf('Press Space to try again.', 0, WINDOW_HEIGHT / 2 + 248, WINDOW_WIDTH, 'center')
end

function drawShadows()
  if alive then
    love.graphics.setColor(0, 0, 0, 0.4)
  else
    love.graphics.setColor(1, 1, 1, 0.4)
  end
  love.graphics.rectangle('fill', (playerX - 1) * TILE_SIZE - 5, (playerY - 1) * TILE_SIZE + 5, TILE_SIZE, TILE_SIZE)

  for g = table.getn(enemy), 1, -1 do
    love.graphics.rectangle('fill', (enemy[g].enemyX - 1) * TILE_SIZE - 5, (enemy[g].enemyY - 1) * TILE_SIZE + 5,
    enemy[g].size, enemy[g].size)
  end
  if alive then
    love.graphics.rectangle('fill', (followX - 1) * TILE_SIZE - 5, (followY - 1) * TILE_SIZE + 5, TILE_SIZE, TILE_SIZE)
  end
  if bossAlive then
    love.graphics.rectangle('fill', (bossX - 1) * TILE_SIZE - 10, (bossY - 1) * TILE_SIZE + 10, bossSize, bossSize)
  end
end

function drawPlayer()
  if alive ~= true then
    love.graphics.setColor(grey)
    love.graphics.rectangle(state, (playerX - 1) * TILE_SIZE, (playerY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
  else
    love.graphics.setColor(cyan)
    love.graphics.rectangle(state, (playerX - 1) * TILE_SIZE, (playerY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
  end
end

function drawEnemy()
  love.graphics.setColor(ecolor)
  for v = table.getn(enemy), 1, -1 do
    love.graphics.rectangle('fill', (enemy[v].enemyX - 1) * TILE_SIZE, (enemy[v].enemyY - 1) * TILE_SIZE,
    enemy[v].size, enemy[v].size)
  end
end

function drawBoss()
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle('fill', (bossX - 1) * TILE_SIZE, (bossY - 1) * TILE_SIZE, bossSize, bossSize)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', (bossX - 1) * TILE_SIZE, (bossY - 1) * TILE_SIZE, bossSize, bossSize)
end

function drawFollower()
  love.graphics.setColor(fcolor)
  love.graphics.rectangle('fill', (followX - 1) * TILE_SIZE, (followY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
  love.graphics.setColor(0.9, 0, 0, 0.8)
  for level = ((followY - 1) * TILE_SIZE) + TILE_SIZE, minMeterY, -1 do
    love.graphics.rectangle('fill', (followX - 1) * TILE_SIZE, level, TILE_SIZE, 1)
  end
end

function enemyPath(x, y)

  local pathUp = y - 1
  local pathDown = y + 1
  local pathLeft = x - 1
  local pathRight = x + 1

  local pathCurrent = getDistance(playerX, playerY, x, y)
  local upDistance = getDistance(playerX, playerY, x, pathUp)
  local downDistance = getDistance(playerX, playerY, x, pathDown)
  local leftDistance = getDistance(playerX, playerY, pathLeft, y)
  local rightDistance = getDistance(playerX, playerY, pathRight, y)

  local paths = {upDistance, downDistance, leftDistance, rightDistance}
  local pathDirections = {'up', 'down', 'left', 'right'}
  local pathChoice = 'right'

  for p = 1, #paths do
    if paths[p] < pathCurrent then
      pathCurrent = paths[p]
      pathChoice = pathDirections[p]
    end
  end

  return pathChoice
end

function getDistance(x1, y1, x2, y2)
  return ((x2 - x1)^2 + (y2 - y1)^2)^0.5
end

function collision(x, y, size)
  --do not forget to account for the tile based coordinates. hence the x, y
  --values are (x - 1) * tilesize
  for k = 1, #enemy do
    if (playerX - 1) * TILE_SIZE < (x - 1) * TILE_SIZE + size and
       (playerX - 1) * TILE_SIZE + TILE_SIZE > (x - 1) * TILE_SIZE and
       (playerY - 1) * TILE_SIZE < (y - 1) * TILE_SIZE + size and
       (playerY - 1) * TILE_SIZE + TILE_SIZE > (y - 1) * TILE_SIZE then
         pcolor = grey
         return true
    else
         return false
    end
  end
end

function followCollision()
  --do not forget to account for the tile based coordinates. hence the x, y
  --values are (x - 1) * tilesize
  return (playerX - 1) * TILE_SIZE < (followX - 1) * TILE_SIZE + TILE_SIZE and
         (playerX - 1) * TILE_SIZE + TILE_SIZE > (followX - 1) * TILE_SIZE and
         (playerY - 1) * TILE_SIZE < (followY - 1) * TILE_SIZE + TILE_SIZE and
         (playerY - 1) * TILE_SIZE + TILE_SIZE > (followY - 1) * TILE_SIZE
end

function bossCollision(x, y)
  --do not forget to account for the tile based coordinates. hence the x, y
  --values are (x - 1) * tilesize
  return (playerX - 1) * TILE_SIZE < (x - 1) * TILE_SIZE + bossSize and
         (playerX - 1) * TILE_SIZE + TILE_SIZE > (x - 1) * TILE_SIZE and
         (playerY - 1) * TILE_SIZE < (y - 1) * TILE_SIZE + bossSize and
         (playerY - 1) * TILE_SIZE + TILE_SIZE > (y - 1) * TILE_SIZE
end

function moveFollower()
  followX = love.math.random(1, MAX_TILES_X)
  followY = love.math.random(1, MAX_TILES_Y)
  followtimer = 8
  minMeterY = ((followY - 1) * TILE_SIZE) + TILE_SIZE
end

function startShake(duration, magnitude)
  shakeTime, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end

--background graphics functions
--top left corner to bottom right
--top left corner to bottom right
function bgSwipeTopLR()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', 0, 0, sizeRow, sizeCol)
end

--bottom right corner to upper left
function bgSwipeBottomRL()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', maxRow, maxCol, sizeRow, sizeCol)
end

--top right to bottom left
function bgSwipeTopRL()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', maxRow, 0, sizeRow, sizeCol)
end

--bottom left to top right
function bgSwipeBottomLR()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', 0, maxCol, sizeRow, sizeCol)
end

--left to right
function bgSwipeLR()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', 0, 0, sizeRow, WINDOW_HEIGHT)
end

--right to left
function bgSwipeRL()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', maxRow, 0, sizeRow, WINDOW_HEIGHT)
end

--top to bottom
function bgSwipeBottom()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', 0, 0, WINDOW_WIDTH, sizeCol)
end

--bottom to top
function bgSwipeTop()
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', 0, maxCol, WINDOW_WIDTH, sizeCol)
end

function gameOver()
  inGameSound:stop()
  playerX = playerX
  playerY = playerY
end

function reset()
  gameStart = true
  resetFlag = false

  playerMoving = 'right'
  playerSpeed = 0.2
  playerX, playerY = 1, 1
  playerTimer = 0
  pcolor = cyan
  alive = true

  followtimer = 8
  minMeterY = ((followY - 1) * TILE_SIZE) + TILE_SIZE
  score = 0
  gameOverFlag = false

  bossTimer = 0
  spawn = false
  bossAlive = false
  bossLife = 15

  shakeTime, shakeDuration, shakeMagnitude = 0, -1, 0

  color = lightgreen
  oldcolor = lightbrown
  colorCode = 1
  bgTimer = 600
  bg = 1
  maxRow = WINDOW_WIDTH
  maxCol = WINDOW_HEIGHT
  sizeRow = 0
  sizeCol = 0

  spawnFirst = true
  spawnDelay = 5
  firstStart = true

  pX, pY = 0, 0
  pTimer = 0
  pSpeed = 0.2
  eX, eY = 0, 0
  eTimer = 0
  eSpeed = 0.3
  location = love.math.random(1, 4)

  for d in pairs(enemy) do
    enemy[d] = nil
  end
end
