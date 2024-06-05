local plr = game:GetService("Players").LocalPlayer -- gets the player character
local char = plr.Character or plr.CharacterAdded:Wait()
local usi = game:GetService("UserInputService")
local tween = game:GetService("TweenService")
--UI Elements
local frame = plr.PlayerGui:WaitForChild("AttackDirection"):WaitForChild("Frame")
local top = frame.Top
local right = frame.Right
local left = frame.Left
local bottom = frame.Bottom
--Preset Destinations
local TopOrigin, topPos = top.Size,top.Position
local RightOrigin, RightPos = right.Size,right.Position
local LeftOrigin, LeftPos = left.Size,left.Position
local BottomOrigin, BottomPos = bottom.Size,bottom.Position
local framePos,frameSize = frame.Position,frame.Size
local ListOfOrigins = {
	["Top"] = {
		Position = topPos,
		Size = TopOrigin
	},
	["Right"] = {
		Position = RightPos,
		Size = RightOrigin
	},
	["Left"] = {
		Position = LeftPos,
		Size = LeftOrigin
	},
	["Bottom"] = {
		Position = BottomPos,
		Size = BottomOrigin
	},
	
}
--Misc
local c = {}
local anims = {}
local Direction = "Bottom"
local holdTick = nil
local holdingAttack = false
local attacking = false
local switchDebouce = false
local attackDebounce = false

--Functions

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
function Disconnect(index,wt)
	task.wait(wt)
	if index then
		index:Disconnect()
	end
end


function Attack()
	if --[[holdTick == nil or]] attackDebounce == true then return end
	attackDebounce = true
	attacking = true
	local timeHeld = tick() - holdTick
	timeHeld = timeHeld > 1 and timeHeld or 1
	print(timeHeld)
	
	local humanoid = char:FindFirstChild("Humanoid")
	for i,v in pairs(anims) do v:Stop() end	
	local anim = humanoid:LoadAnimation(script.Anims:FindFirstChild("Swing"..Direction))
	anim:AdjustSpeed(3)
	anim:Play()
	task.wait(anim.Length)
	attacking = false
	holdTick = nil
	DebounceAttack(.3)
	holdingAttack = false
end

function BlowUp(ui,x,y)
	if ui.Size ~= TopOrigin then return end
	ui.Size = ui.Size + x
	ui.Position = ui.Position + y
	for i,v in pairs(frame:GetChildren()) do
		if v:IsA("ImageButton") and v ~= ui then
			v.Position = ListOfOrigins[v.Name].Position
			v.Size = ListOfOrigins[v.Name].Size
		end
	end
end
--CLICKS
top.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end
	BlowUp(top,UDim2.new(.05,0,.05,0),UDim2.new(0.05,0,-0.05,0))
	task.wait()
	Direction = "Top"
	DebounceSwitch(.2)
end)

bottom.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end
	BlowUp(bottom,UDim2.new(.05,0,.05,0),UDim2.new(-0.05,0,0.05,0))
	task.wait()
	Direction = "Bottom"
	DebounceSwitch(.2)
end)		
left.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end
	BlowUp(left,UDim2.new(.05,0,.05,0),UDim2.new(-0.05,0,-0.05,0))
	task.wait()
	Direction = "Left"
	DebounceSwitch(.2)
end)
right.MouseButton1Click:Connect(function()
	if holdingAttack == true or switchDebouce == true then return end
	BlowUp(right,UDim2.new(.05,0,.05,0),UDim2.new(0.05,0,0.05,0))
	task.wait()
	Direction = "Right"
	DebounceSwitch(.2)
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

