
--[[

Script by: Fungi

Discord: @WLncstr
ROBLOX: ThSingularFungi

Notes:
- There is no animation for an upward attack
- This script only controls stances, swings, and animations]]


local plr = game:GetService("Players").LocalPlayer -- Get the player character
local char = plr.Character or plr.CharacterAdded:Wait() -- Wait for the character to load
local usi = game:GetService("UserInputService")
local tween = game:GetService("TweenService")

-- UI Elements
local frame = plr.PlayerGui:WaitForChild("AttackDirection"):WaitForChild("Frame")
local top = frame.Top
local right = frame.Right
local left = frame.Left
local bottom = frame.Bottom

-- Preset Destinations
local TopOrigin, topPos = top.Size, top.Position
local RightOrigin, RightPos = right.Size, right.Position
local LeftOrigin, LeftPos = left.Size, left.Position
local BottomOrigin, BottomPos = bottom.Size, bottom.Position
local framePos, frameSize = frame.Position, frame.Size



-- THERE IS A GUI TO CONTROL STANCE AND SWING DIRECTION. This keeps track of the UI's size and position, since it is altered frequently when hovered over. 
local ListOfOrigins = {
	["Top"] = { Position = topPos, Size = TopOrigin },
	["Right"] = { Position = RightPos, Size = RightOrigin },
	["Left"] = { Position = LeftPos, Size = LeftOrigin },
	["Bottom"] = { Position = BottomPos, Size = BottomOrigin },
}


local c = {}
local anims = {}
local Direction = "Bottom" -- default attack direction is bottom
local holdTick = nil
local holdingAttack = false
local attacking = false
local switchDebouce = false
local attackDebounce = false

-- Functions

function DebounceSwitch(t)
	switchDebouce = true
	_G.Spawn(function()
		task.wait(t)
		switchDebouce = false
	end)
	-- This creates a coroutine. The function is below:
--[[
function _G.Spawn(func, ...)
	local thread = coroutine.create(func)
	coroutine.resume(thread, ...)
	return thread
end
]]
end

function DebounceAttack(t) -- this function is used to control attack cooldowns
	_G.Spawn(function()
		task.wait(t)
		attackDebounce = false
	end)
	
	

end

function Disconnect(index, wt) --This function is used to disconnect functions after a period of time. 
	task.wait(wt)
	if index then 
		index:Disconnect() 
	end
end

function Attack()
	if attackDebounce == true then return end -- Function stops if someone is already attacking. 
	attackDebounce = true
	attacking = true
	local timeHeld = tick() - holdTick -- Calculate how long the attack was held
	timeHeld = timeHeld > 1 and timeHeld or 1 -- This will be a damage multiplier. 
	print(timeHeld)

	local humanoid = char:FindFirstChild("Humanoid")
	for i, v in pairs(anims) do v:Stop() end -- Stop any previous animations
	local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing" .. Direction))
	anim:AdjustSpeed(3) -- Set animation speed
	anim:Play()
	task.wait(anim.Length)
	attacking = false
	holdTick = nil
	DebounceAttack(.7) -- Set a delay before the next attack can occur
	holdingAttack = false
	
	-- Attacks dont do damage yet, but when they do, timeHeld is used to calculate damage. 
end

function BlowUp(ui, x, y)
	if ui.Size ~= TopOrigin then return end -- Only proceed if the UI size is the original
	ui.Size = ui.Size + x -- Increase UI size
	ui.Position = ui.Position + y -- Change UI position
	for i, v in pairs(frame:GetChildren()) do
		if v:IsA("ImageButton") and v ~= ui then -- Reset other UI elements
			v.Position = ListOfOrigins[v.Name].Position
			v.Size = ListOfOrigins[v.Name].Size
		end
	end
end

-- If you dont wanna hold C, you can also click
top.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end 
	BlowUp(top, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, -0.05, 0)) -- Makes ui element bigger and moves it
	task.wait()
	Direction = "Top" 
	DebounceSwitch(.2) -- Cooldown for switching directions
end)

bottom.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end 
	BlowUp(bottom, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, 0.05, 0)) 
	task.wait()
	Direction = "Bottom" 
	DebounceSwitch(.2) 
end)

left.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end 
	BlowUp(left, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, -0.05, 0)) 
	task.wait()
	Direction = "Left" 
	DebounceSwitch(.2) 
end)

right.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end -- If already holding attack or switching, return
	BlowUp(right, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, 0.05, 0))  
	task.wait()
	Direction = "Right" -- Set attack direction
	DebounceSwitch(.2) -- Set a delay before switching again
end)

usi.InputBegan:Connect(function(key, proc)
	if proc == true then return end -- If input is processed by something else the function will not run
	if key.KeyCode == Enum.KeyCode.C then
		for i, v in pairs(c) do
			if string.find(i, "Tween") then -- Stop any ongoing tweens
				v:Stop()
			elseif string.find(i, "Con") then -- Disconnect any ongoing connections
				v:Disconnect()
			end
		end
		c["Tween1"] = tween:Create(frame, TweenInfo.new(.2), { Position = UDim2.new(.5, 0, .5, 0) }):Play() -- Tween frame to center
		c["Tween2"] = tween:Create(frame, TweenInfo.new(.2), { Size = UDim2.new(0, 300, 0, 300) }):Play() -- Tween frame size
		
		--[[
		
		The following allow the player to hover over the direction they wish to swing in.
		The UI will go to the centre of the screen and become big.
		The connections are added to a connection folder so they can be disabled easier
		
		It will check to make sure youre not attacking, and if youre not, it changes direction and makes the indicated direction bigger.
		]]
		
		c["Con1"] = top.MouseEnter:Connect(function()
			if holdingAttack == true then return end 
			Direction = "Top" -- Set attack direction
			BlowUp(top, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, -0.05, 0))  
		end)
		c["Con2"] = bottom.MouseEnter:Connect(function()
			if holdingAttack == true then return end  
			Direction = "Bottom" -- Set attack direction
			BlowUp(bottom, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, 0.05, 0))  
		end)
		c["Con3"] = left.MouseEnter:Connect(function()
			if holdingAttack == true then return end  
			Direction = "Left" -- Set attack direction
			BlowUp(left, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, -0.05, 0))  
		end)
		c["Con4"] = right.MouseEnter:Connect(function()
			if holdingAttack == true then return end  
			Direction = "Right" -- Set attack direction
			BlowUp(right, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, 0.05, 0))  
		end)
	elseif key.UserInputType == Enum.UserInputType.MouseButton1 then
		if attackDebounce == true then return end -- makes sure cooldown is up
		if char.SwordOut.Value == false or proc == true or holdingAttack == true then return end -- Makes sure sword is out
		holdingAttack = true
		local humanoid = char:FindFirstChild("Humanoid")
		holdTick = tick() -- gets the tiem the attack started
        --[[local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing"..Direction.."Prepare"))
        anim.Looped = false
        anim:Play()
        anim.Stopped:Wait()]]--
		if holdingAttack == false then return end -- ends if the attack is not being held
		local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing" .. Direction .. "Hold")) 
		--[[
		There is a folder in this script containing the animations. 
		IT IS IMPORTANT TO NOTE THAT THERE IS NO UP ANIMATION YET]]
		anim.Looped = false
		anim:Play()
		table.insert(anims, anim) 
		if attacking == true and holdTick ~= nil then return end -- if an attack is already being done, the function ends
		task.delay(anim.Length,function()
			if holdingAttack == true then
				Attack() -- if the attack is still being held when the animation finishes, the attack is released. 
			end
		end)
	end
end)


usi.InputEnded:Connect(function(key) 
	if key.KeyCode == Enum.KeyCode.C then -- this just puts UI back into the corner
		for i,v in pairs(c) do
			if string.find(i,"Tween") then
				v:Stop() -- stops all tweening incase it was in the middle of englarging
			elseif string.find(i,"Con") then
				v:Disconnect() -- disconnects all the mouse hovering connections
			end
		end
		c["Tween1"] =  tween:Create(frame,TweenInfo.new(.2),{Position = framePos}):Play() -- tweens it back into its corner
		c["Tween2"] = tween:Create(frame,TweenInfo.new(.2),{Size = frameSize}):Play()-- tweens it back into its corner (and gets smaller c:)
	
	elseif holdingAttack == true and key.UserInputType == Enum.UserInputType.MouseButton1 then
		Attack() -- attacks if you release MB1
	end
end)

