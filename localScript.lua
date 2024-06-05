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

local ListOfOrigins = {
    ["Top"] = { Position = topPos, Size = TopOrigin },
    ["Right"] = { Position = RightPos, Size = RightOrigin },
    ["Left"] = { Position = LeftPos, Size = LeftOrigin },
    ["Bottom"] = { Position = BottomPos, Size = BottomOrigin },
}

-- Misc variables to control state
local c = {}
local anims = {}
local Direction = "Bottom"
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
end

function DebounceAttack(t)
    _G.Spawn(function()
        task.wait(t)
        attackDebounce = false
    end)
end

function Disconnect(index, wt)
    task.wait(wt)
    if index then -- If the index exists, disconnect it
        index:Disconnect()
    end
end

function Attack()
    if attackDebounce == true then return end -- If attack is already in progress, return
    attackDebounce = true
    attacking = true
    local timeHeld = tick() - holdTick -- Calculate how long the attack was held
    timeHeld = timeHeld > 1 and timeHeld or 1 -- Ensure timeHeld is at least 1
    print(timeHeld)
    
    local humanoid = char:FindFirstChild("Humanoid")
    for i, v in pairs(anims) do v:Stop() end -- Stop any previous animations
    local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing" .. Direction))
    anim:AdjustSpeed(3) -- Set animation speed
    anim:Play()
    task.wait(anim.Length)
    attacking = false
    holdTick = nil
    DebounceAttack(.3) -- Set a delay before the next attack can occur
    holdingAttack = false
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

-- Mouse click handlers for direction buttons
top.MouseButton1Click:Connect(function()
    if holdingAttack == true or switchDebouce == true then return end -- If already holding attack or switching, return
    BlowUp(top, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, -0.05, 0)) -- Enlarge and move the UI element
    task.wait()
    Direction = "Top" -- Set attack direction
    DebounceSwitch(.2) -- Set a delay before switching again
end)

bottom.MouseButton1Click:Connect(function()
    if holdingAttack == true or switchDebouce == true then return end -- If already holding attack or switching, return
    BlowUp(bottom, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, 0.05, 0)) -- Enlarge and move the UI element
    task.wait()
    Direction = "Bottom" -- Set attack direction
    DebounceSwitch(.2) -- Set a delay before switching again
end)

left.MouseButton1Click:Connect(function()
    if holdingAttack == true or switchDebouce == true then return end -- If already holding attack or switching, return
    BlowUp(left, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, -0.05, 0)) -- Enlarge and move the UI element
    task.wait()
    Direction = "Left" -- Set attack direction
    DebounceSwitch(.2) -- Set a delay before switching again
end)

right.MouseButton1Click:Connect(function()
    if holdingAttack == true or switchDebouce == true then return end -- If already holding attack or switching, return
    BlowUp(right, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, 0.05, 0)) -- Enlarge and move the UI element
    task.wait()
    Direction = "Right" -- Set attack direction
    DebounceSwitch(.2) -- Set a delay before switching again
end)

usi.InputBegan:Connect(function(key, proc)
    if proc == true then return end -- If input is processed by something else, return
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
        c["Con1"] = top.MouseEnter:Connect(function()
            if holdingAttack == true then return end -- If already holding attack, return
            Direction = "Top" -- Set attack direction
            BlowUp(top, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, -0.05, 0)) -- Enlarge and move the UI element
        end)
        c["Con2"] = bottom.MouseEnter:Connect(function()
            if holdingAttack == true then return end -- If already holding attack, return
            Direction = "Bottom" -- Set attack direction
            BlowUp(bottom, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, 0.05, 0)) -- Enlarge and move the UI element
        end)
        c["Con3"] = left.MouseEnter:Connect(function()
            if holdingAttack == true then return end -- If already holding attack, return
            Direction = "Left" -- Set attack direction
            BlowUp(left, UDim2.new(.05, 0, .05, 0), UDim2.new(-0.05, 0, -0.05, 0)) -- Enlarge and move the UI element
        end)
        c["Con4"] = right.MouseEnter:Connect(function()
            if holdingAttack == true then return end -- If already holding attack, return
            Direction = "Right" -- Set attack direction
            BlowUp(right, UDim2.new(.05, 0, .05, 0), UDim2.new(0.05, 0, 0.05, 0)) -- Enlarge and move the UI element
        end)
    elseif key.UserInputType == Enum.UserInputType.MouseButton1 then
        if char.SwordOut.Value == false or proc == true or holdingAttack == true then return end -- If sword is not out or input is processed, return
        holdingAttack = true
        local humanoid = char:FindFirstChild("Humanoid")
        holdTick = tick() -- Record the time the attack started
        --[[local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing"..Direction.."Prepare"))
        anim.Looped = false
        anim:Play()
        anim.Stopped:Wait()]]--
        if holdingAttack == false then return end -- If not holding attack anymore, return
        local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing" .. Direction .. "Hold"))
        anim.Looped = false
        anim:Play()
        table.insert(anims, anim) -- Add animation to list
        task.wait(anim.Length)
        if attacking == true and holdTick ~= nil then return end -- If already attacking, return
        Attack() -- Perform attack
    end
end)


usi.InputBegan:Connect(function(key,proc)
	if proc == true then return end
	if key.KeyCode == Enum.KeyCode.C then
		for i,v in pairs(c) do
			if string.find(i,"Tween") then
				v:Stop()
			elseif string.find(i,"Con") then
				v:Disconnect()
			end
		end
		c["Tween1"] =  tween:Create(frame,TweenInfo.new(.2),{Position = UDim2.new(.5,0,.5,0)}):Play()
		c["Tween2"] = tween:Create(frame,TweenInfo.new(.2),{Size = UDim2.new(0,300,0,300)}):Play()
		c["Con1"] = top.MouseEnter:Connect(function()
			if holdingAttack == true then return end
			Direction = "Top"
			BlowUp(top,UDim2.new(.05,0,.05,0),UDim2.new(0.05,0,-0.05,0))
		end)
		c["Con2"] = bottom.MouseEnter:Connect(function()
			if holdingAttack == true then return end
			Direction = "Bottom"
			BlowUp(bottom,UDim2.new(.05,0,.05,0),UDim2.new(-0.05,0,0.05,0))
		end)
		c["Con3"] = left.MouseEnter:Connect(function()
			if holdingAttack == true then return end
			Direction = "Left"
			BlowUp(left,UDim2.new(.05,0,.05,0),UDim2.new(-0.05,0,-0.05,0))
		end)
		c["Con4"] = right.MouseEnter:Connect(function()
			if holdingAttack == true then return end
			Direction = "Right"
			BlowUp(right,UDim2.new(.05,0,.05,0),UDim2.new(0.05,0,0.05,0))
		end)
	elseif key.UserInputType == Enum.UserInputType.MouseButton1 then
		if char.SwordOut.Value == false or proc == true or holdingAttack == true then return end
		holdingAttack = true
		local humanoid = char:FindFirstChild("Humanoid")
		holdTick = tick()
		--[[local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing"..Direction.."Prepare"))
		anim.Looped = false
		anim:Play()
		anim.Stopped:Wait()]]--
		if holdingAttack ==  false then return end
		local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing"..Direction.."Hold"))
		anim.Looped = false
		anim:Play()
		table.insert(anims,anim)
		task.wait(anim.Length)
		if attacking == true and holdTick ~= nil then return end
		Attack()
	end
end)

usi.InputEnded:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.C then
		for i,v in pairs(c) do
			if string.find(i,"Tween") then
				v:Stop()
			elseif string.find(i,"Con") then
				v:Disconnect()
			end
		end
		c["Tween1"] =  tween:Create(frame,TweenInfo.new(.2),{Position = framePos}):Play()
		c["Tween2"] = tween:Create(frame,TweenInfo.new(.2),{Size = frameSize}):Play()
	
	elseif holdingAttack == true and key.UserInputType == Enum.UserInputType.MouseButton1 then
		Attack()
	end
end)

