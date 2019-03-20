--input lag AB test
INSTRUCTIONS = [[
Notes:
Use a 500 Hz or higher mouse.
Please use FRAPS or something to ensure vsync is off.

Instructions:
0. Press Escape to exit at any time.
1. Use W and S to increase or decrease the lag.
2. Click anywhere to start/restart this test.
3. Click the side you feel is more laggy.
4. Repeat 25 trials and you will return to this screen.
5. If you get more than 18 trials correct, you probably are able to detect the difference :D
    (If you try this entire test 100 times, you will probably pass the above condition several times.
    that isn't evidence that you can detect the difference. read a bit on hypothesis testing to understand)

have fun :D
]]

NUM_TRIALS = 25
MAX_LAG = 100

current_trial = 0 --current trial number
num_correct = 0 --correct responses in current test
lag = 50 --milliseconds of lag on laggier side
side = 0 --current laggy side. 0:left side, 1:right side
width = 0
height = 0

history_x = {} --mouse position history
history_y = {}

prev_time = 0

for i = 0, MAX_LAG do
	history_x[i] = 0
	history_y[i] = 0
end

function love.load()
	love.window.setMode(0, 0, {fullscreen = true})
	love.mouse.setVisible(false)
	width, height = love.window.getDimensions()
	love.keyboard.setKeyRepeat(true)
	math.randomseed(os.time())
	side = math.random(0, 1)
end

function love.update()
	local cur_time = math.floor(1000 * love.timer.getTime())
	local delta = cur_time - prev_time
	if delta > MAX_LAG then delta = MAX_LAG end

	for i = 100, delta, -1 do
		history_x[i] = history_x[i - delta]
		history_y[i] = history_y[i - delta]
	end

	for i = 0, delta - 1 do
		history_x[i] = love.mouse.getX()
		history_y[i] = love.mouse.getY()
	end

	prev_time = cur_time
end

function love.draw()
	if current_trial == 0 then --start and results screen
		love.graphics.print("current lag: "..lag.."ms", 100, 80)
		love.graphics.print("Previous test: "..num_correct.." out of "..NUM_TRIALS.." correct.\n\n"..INSTRUCTIONS, 100, 100)		
		return
	end

	love.graphics.setColor(64, 64, 64)
	love.graphics.rectangle("fill", width / 2 - 50, 0, 100, height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("trial "..current_trial, width / 2 - 20, 100)

	local x, y
	
	if side == 1 then
		if history_x[lag] > width / 2 + 50 then
			x = history_x[lag]
			y = history_y[lag]
		elseif history_x[0] < width / 2 - 50 then
			x = history_x[0]
			y = history_y[0]
		else
			return
		end
	elseif side == 0 then
		if history_x[lag] < width / 2 - 50 then
			x = history_x[lag]
			y = history_y[lag]
		elseif history_x[0] > width / 2 + 50 then
			x = history_x[0]
			y = history_y[0]
		else
			return
		end
	else --wtf???
		return
	end

	love.graphics.polygon("fill", {x, y, x, y + 16, x + 16, y})
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
	if current_trial == 0 then
		if key == 'w' then
			lag = lag + 1
		elseif key == 's' then
			lag = lag - 1
		end
		if lag > MAX_LAG then
			lag = MAX_LAG
		elseif lag < 0 then
			lag = 0
		end
	end
end

function love.mousepressed(x, y)
	
	if current_trial == 0 then
		current_trial = 1
		num_correct = 0
		return
	end
	
	local i --ya there are more efficient ways to code this but idc :D
	if x < width / 2 - 50 then
		i = 0
	elseif x > width / 2 + 50 then
		i = 1
	else
		return
	end
	
	if i == side then
		num_correct = num_correct + 1
	end
	
	current_trial = current_trial + 1
	side = math.random(0, 1)
	
	if current_trial > NUM_TRIALS then
		current_trial = 0
	end
end
