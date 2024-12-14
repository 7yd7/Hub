local TweenService = game:GetService("TweenService")


local local_image_path = "http://www.roblox.com/asset/?id=112563150624040" 


local function addTermsToScrollingFrame(frame, terms)
	local yOffset = 0
	for _, term in ipairs(terms) do
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -20, 0, 20)
		title.Position = UDim2.new(0, 10, 0, yOffset)
		title.BackgroundTransparency = 1
		title.Text = term.title
		title.TextColor3 = Color3.fromRGB(0, 0, 0)
		title.Font = Enum.Font.SourceSansBold
		title.TextSize = 16
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = frame

		yOffset = yOffset + 25

		local description = Instance.new("TextLabel")
		description.Size = UDim2.new(1, -20, 0, 40)
		description.Position = UDim2.new(0, 10, 0, yOffset)
		description.BackgroundTransparency = 1
		description.Text = term.description
		description.TextColor3 = Color3.fromRGB(50, 50, 50)
		description.Font = Enum.Font.SourceSans
		description.TextSize = 14
		description.TextWrapped = true
		description.TextXAlignment = Enum.TextXAlignment.Left
		description.TextYAlignment = Enum.TextYAlignment.Top
		description.Parent = frame

		yOffset = yOffset + 45

		if term.link then
			local linkLabel = Instance.new("TextButton")
			linkLabel.Size = UDim2.new(1, -20, 0, 20)
			linkLabel.Position = UDim2.new(0, 10, 0, yOffset)
			linkLabel.BackgroundTransparency = 1
			linkLabel.Text = term.link
			linkLabel.TextColor3 = Color3.fromRGB(0, 100, 255)
			linkLabel.Font = Enum.Font.SourceSans
			linkLabel.TextSize = 14
			linkLabel.TextXAlignment = Enum.TextXAlignment.Left
			linkLabel.Parent = frame

			linkLabel.MouseButton1Click:Connect(function()
				local TweenService = game:GetService("TweenService")

				local notif = Instance.new("ScreenGui")
				local container = Instance.new("Frame")
				local mainFrame = Instance.new("Frame")
				local glow = Instance.new("ImageLabel")
				local contentFrame = Instance.new("Frame")
				local iconContainer = Instance.new("Frame")
				local icon = Instance.new("ImageLabel")
				local textContainer = Instance.new("Frame")
				local titleText = Instance.new("TextLabel")
				local descriptionText = Instance.new("TextLabel")
				local progressBarBg = Instance.new("Frame")
				local progressBar = Instance.new("Frame")

				notif.Name = "ModernNotification"
				notif.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
				notif.IgnoreGuiInset = true

				container.Size = UDim2.new(0, 380, 0, 120)
				container.Position = UDim2.new(1, 400, 1, -140)
				container.BackgroundTransparency = 1
				container.Parent = notif

				glow.Size = UDim2.new(1.2, 0, 1.2, 0)
				glow.Position = UDim2.new(0.5, 0, 0.5, 0)
				glow.AnchorPoint = Vector2.new(0.5, 0.5)
				glow.BackgroundTransparency = 1
				glow.Image = "rbxassetid://7131316274"
				glow.ImageColor3 = Color3.fromRGB(52, 152, 219)
				glow.ImageTransparency = 0.8
				glow.Parent = container

				mainFrame.Size = UDim2.new(1, 0, 1, 0)
				mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				mainFrame.Parent = container

				local shadow = Instance.new("ImageLabel")
				shadow.Name = "Shadow"
				shadow.AnchorPoint = Vector2.new(0.5, 0.5)
				shadow.BackgroundTransparency = 1
				shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
				shadow.Size = UDim2.new(1, 40, 1, 40)
				shadow.ZIndex = -1
				shadow.Image = "rbxassetid://5554236805"
				shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
				shadow.ImageTransparency = 0.6
				shadow.Parent = mainFrame

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 15)
				corner.Parent = mainFrame

				contentFrame.Size = UDim2.new(1, -20, 1, -20)
				contentFrame.Position = UDim2.new(0, 10, 0, 10)
				contentFrame.BackgroundTransparency = 1
				contentFrame.Parent = mainFrame

				iconContainer.Size = UDim2.new(0, 80, 0, 80)
				iconContainer.Position = UDim2.new(0, 0, 0.5, -40)
				iconContainer.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
				iconContainer.Parent = contentFrame

				local iconCorner = Instance.new("UICorner")
				iconCorner.CornerRadius = UDim.new(0, 12)
				iconCorner.Parent = iconContainer

				icon.Size = UDim2.new(0.7, 0, 0.7, 0)
				icon.Position = UDim2.new(0.5, 0, 0.5, 0)
				icon.AnchorPoint = Vector2.new(0.5, 0.5)
				icon.BackgroundTransparency = 1
				icon.Image = "rbxassetid://7743866529"
				icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
				icon.Parent = iconContainer

				textContainer.Size = UDim2.new(1, -100, 1, 0)
				textContainer.Position = UDim2.new(0, 100, 0, 0)
				textContainer.BackgroundTransparency = 1
				textContainer.Parent = contentFrame

				titleText.Size = UDim2.new(1, 0, 0, 30)
				titleText.Position = UDim2.new(0, 0, 0, 5)
				titleText.BackgroundTransparency = 1
				titleText.Text = "Copied the link"
				titleText.TextColor3 = Color3.fromRGB(40, 40, 40)
				titleText.Font = Enum.Font.GothamBold
				titleText.TextSize = 20
				titleText.TextXAlignment = Enum.TextXAlignment.Left
				titleText.Parent = textContainer

				descriptionText.Size = UDim2.new(1, 0, 0, 30)
				descriptionText.Position = UDim2.new(0, 0, 0, 35)
				descriptionText.BackgroundTransparency = 1
				descriptionText.Text = linkLabel.Text
				descriptionText.TextColor3 = Color3.fromRGB(100, 100, 100)
				descriptionText.Font = Enum.Font.Gotham
				descriptionText.TextSize = 16
				descriptionText.TextXAlignment = Enum.TextXAlignment.Left
				descriptionText.TextWrapped = true
				descriptionText.Parent = textContainer

				progressBarBg.Size = UDim2.new(1, 0, 0, 4)
				progressBarBg.Position = UDim2.new(0, 0, 1, -4)
				progressBarBg.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
				progressBarBg.BorderSizePixel = 0
				progressBarBg.Parent = mainFrame

				progressBar.Size = UDim2.new(1, 0, 1, 0)
				progressBar.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
				progressBar.BorderSizePixel = 0
				progressBar.Parent = progressBarBg
				

				local function animateNotification()
					container.Position = UDim2.new(1, 400, 1, -140)
					local enterTween = TweenService:Create(container, 
						TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Position = UDim2.new(1, -400, 1, -140)
						})
					enterTween:Play()

					spawn(function()
						while container.Parent do
							local pulseTween = TweenService:Create(glow,
								TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
									ImageTransparency = 0.9
								})
							pulseTween:Play()
							wait(1)
							local pulseTween2 = TweenService:Create(glow,
								TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
									ImageTransparency = 0.8
								})
							pulseTween2:Play()
							wait(1)
						end
					end)

					local progressTween = TweenService:Create(progressBar, 
						TweenInfo.new(3, Enum.EasingStyle.Linear), {
							Size = UDim2.new(0, 0, 1, 0)
						})
					progressTween:Play()

					wait(3)
					local exitTween = TweenService:Create(container, 
						TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
							Position = UDim2.new(1, 400, 1, -140)
						})
					exitTween:Play()

					exitTween.Completed:Connect(function()
						notif:Destroy()
					end)
				end
				
				animateNotification()
				
				setclipboard(linkLabel.Text)
			end)

			yOffset = yOffset + 25
		end
	end

	frame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

local screenGui = Instance.new("ScreenGui")
local blur = Instance.new("BlurEffect")
local mainFrame = Instance.new("Frame")

local alertImage = Instance.new("ImageLabel")
alertImage.Size = UDim2.new(0, 80, 0, 80)  
alertImage.Position = UDim2.new(1, -100, 0, 45) 
alertImage.BackgroundTransparency = 1
alertImage.Image = local_image_path 
alertImage.Parent = mainFrame


blur.Size = 0
blur.Parent = game.Lighting

screenGui.Name = "Setup-7yd7"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.ZIndex = -1
shadow.Image = "6673968185"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.Parent = mainFrame

local function openWindow()
	local finalPosition = mainFrame.Position

	mainFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
	mainFrame.BackgroundTransparency = 1
	shadow.ImageTransparency = 1
	blur.Size = 0

	local openTweenSize = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Position = finalPosition,
		BackgroundTransparency = 0
	})
	local openTweenShadow = TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		ImageTransparency = 0.6
	})
	local openTweenBlur = TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Size = 10
	})

	openTweenSize:Play()
	openTweenShadow:Play()
	openTweenBlur:Play()
end

openWindow()


local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(243, 243, 243)
titleBar.Parent = mainFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 90, 1, 0)
buttonContainer.Position = UDim2.new(1, -100, 0, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = titleBar

local function createTitleBarButton(text, position)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 30, 0, 30)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(243, 243, 243)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 16
	button.Parent = buttonContainer

	local hoverEffect = TweenService:Create(button, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	})

	button.MouseEnter:Connect(function()
		hoverEffect:Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(243, 243, 243)
		}):Play()
	end)

	return button
end

local function closeWindow()
	local currentPosition = mainFrame.Position

	local moveTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
		Position = UDim2.new(currentPosition.X.Scale, currentPosition.X.Offset, currentPosition.Y.Scale + 0.1, currentPosition.Y.Offset),
		BackgroundTransparency = 1
	})
	local shadowTween = TweenService:Create(shadow, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
		ImageTransparency = 1
	})

	local blurTween = TweenService:Create(blur, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
		Size = 0 
	})

	moveTween:Play()
	shadowTween:Play()
	blurTween:Play()

	moveTween.Completed:Connect(function()
		screenGui:Destroy()
		blur:Destroy()
	end)
end


local timerButton = createTitleBarButton("", UDim2.new(0, -35, 0, 0))
timerButton.Text = ""
timerButton.BackgroundTransparency = 1
timerButton.AutoButtonColor = false

local outerCircle = Instance.new("Frame")
outerCircle.Size = UDim2.new(0.85, 0, 0.85, 0)
outerCircle.Position = UDim2.new(0.075, 0, 0.075, 0)
outerCircle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
outerCircle.Parent = timerButton

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(1, 0)
outerCorner.Parent = outerCircle

local innerCircle = Instance.new("Frame")
innerCircle.Size = UDim2.new(0.85, 0, 0.85, 0)
innerCircle.Position = UDim2.new(0.075, 0, 0.075, 0)
innerCircle.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
innerCircle.Parent = outerCircle

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(1, 0)
innerCorner.Parent = innerCircle

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1.2, 0, 1.2, 0)
shadow.Position = UDim2.new(-0.1, 0, -0.1, 0)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ZIndex = -1
shadow.Parent = innerCircle

local countdownText = Instance.new("TextLabel")
countdownText.Size = UDim2.new(1, 0, 1, 0)
countdownText.Position = UDim2.new(0, 0, 0, 0)
countdownText.BackgroundTransparency = 1
countdownText.Text = "30"
countdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
countdownText.Font = Enum.Font.GothamBold
countdownText.TextSize = 14
countdownText.Parent = innerCircle

local isTimerRunning = true

local function startTimer()
	local timeLeft = 30
	local startColor = Color3.fromRGB(52, 152, 219) 
	local middleColor = Color3.fromRGB(230, 126, 34)
	local endColor = Color3.fromRGB(231, 76, 60) 

	for i = timeLeft, 0, -1 do
		if not isTimerRunning then
			return 
		end

		countdownText.Text = tostring(i)

		local progress = 1 - (i / timeLeft)
		local currentColor
		if progress < 0.5 then
			currentColor = startColor:Lerp(middleColor, progress * 2)
		else
			currentColor = middleColor:Lerp(endColor, (progress - 0.5) * 2)
		end

		TweenService:Create(innerCircle, TweenInfo.new(0.2), {
			BackgroundColor3 = currentColor,
			Size = UDim2.new(0.9, 0, 0.9, 0)
		}):Play()

		wait(0.2)

		TweenService:Create(innerCircle, TweenInfo.new(0.3), {
			Size = UDim2.new(0.85, 0, 0.85, 0)
		}):Play()

		wait(0.8)
	end

	closeWindow()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/Game"))()
end

local function stopTimerOnGUIRemoval()
	if not screenGui or not screenGui.Parent then
		isTimerRunning = false
	end
end

screenGui.AncestryChanged:Connect(function()
	stopTimerOnGUIRemoval()
end)

spawn(function()
	wait(1)
	startTimer()
end)

local closeButton = createTitleBarButton("✖", UDim2.new(0, 60, 0, 0))
local maximizeButton = createTitleBarButton("☐", UDim2.new(0, 30, 0, 0))
local minimizeButton = createTitleBarButton("━", UDim2.new(0, 0, 0, 0))
minimizeButton.TextTransparency = 0.5
minimizeButton.Active = false 

local isMaximized = false
local savedSize = nil
local savedPosition = nil

maximizeButton.MouseButton1Click:Connect(function()
	local screenSize = workspace.CurrentCamera.ViewportSize

	if not isMaximized then
		savedSize = mainFrame.Size
		savedPosition = mainFrame.Position

		local newWidth = math.min(screenSize.X * 0.8, screenSize.X - 50)
		local newHeight = math.min(screenSize.Y * 0.8, screenSize.Y - 50)

		local centerX = mainFrame.Position.X.Offset + (mainFrame.Size.X.Offset / 2)
		local centerY = mainFrame.Position.Y.Offset + (mainFrame.Size.Y.Offset / 2)

		TweenService:Create(mainFrame, TweenInfo.new(0.3), {
			Size = UDim2.new(0, newWidth, 0, newHeight),
			Position = UDim2.new(0.5, centerX - (newWidth / 2), 0.5, centerY - (newHeight / 2))
		}):Play()
	else
		if savedSize and savedPosition then
			TweenService:Create(mainFrame, TweenInfo.new(0.3), {
				Size = savedSize,
				Position = savedPosition
			}):Play()
		end
	end

	isMaximized = not isMaximized
end)




closeButton.MouseButton1Click:Connect(closeWindow)

local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 250, 250)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
})
gradient.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -90, 1, 0)
titleText.Position = UDim2.new(0, 35, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Setup - 7yd7・Script"
titleText.TextColor3 = Color3.fromRGB(0, 0, 0)
titleText.Font = Enum.Font.SourceSansSemibold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local alertImage = Instance.new("ImageLabel")
alertImage.Size = UDim2.new(0, 25, 0, 25)  
alertImage.Position = UDim2.new(0, 4, 0, 2)
alertImage.BackgroundTransparency = 1
alertImage.Image = local_image_path
alertImage.Name = "Image7YD7"
alertImage.Parent = mainFrame

local alertTitle = Instance.new("TextLabel")
alertTitle.Size = UDim2.new(1, -40, 0, 20)
alertTitle.Position = UDim2.new(0, 20, 0, 50)
alertTitle.BackgroundTransparency = 1
alertTitle.Text = "Warning"
alertTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
alertTitle.Font = Enum.Font.SourceSansBold
alertTitle.TextSize = 18
alertTitle.TextXAlignment = Enum.TextXAlignment.Left
alertTitle.Parent = mainFrame

local alertDescription = Instance.new("TextLabel")
alertDescription.Size = UDim2.new(1, -40, 0, 40)
alertDescription.Position = UDim2.new(0, 20, 0, 70)
alertDescription.BackgroundTransparency = 1
alertDescription.Text = "Please read the terms before clicking Accept."
alertDescription.TextColor3 = Color3.fromRGB(0, 0, 0)
alertDescription.Font = Enum.Font.SourceSans
alertDescription.TextSize = 14
alertDescription.TextWrapped = true
alertDescription.TextXAlignment = Enum.TextXAlignment.Left
alertDescription.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -40, 0, 180)
scrollFrame.Position = UDim2.new(0, 20, 0, 140)
scrollFrame.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
scrollFrame.BorderColor3 = Color3.fromRGB(171, 171, 171)
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
scrollFrame.Parent = mainFrame

local terms = {
	{
		title = "Warning",
		description = "We are not responsible if you are banned in the games that was used in the script"
	},

	{
		title = "Legal Notice",
		description = "Use of this script is at your own risk. The developer is not liable for any consequences arising from its usage"
	},
	{
		title = "Open source",
		description = "This is a completely open source script: ",
		link = "https://github.com/7yd7/Hub"
	},
	{
		title = "تحذير هام",
		description = "نحن غير مسؤولين عن أي حظر قد يحدث نتيجة استخدام هذا السكربت في أي ماب"
	},
	{
		title = "إخلاء مسؤولية",
		description = "استخدام هذا السكربت يكون على مسؤوليتك الشخصية. المطور غير مسؤول عن أي عواقب"
	},
	{
		title = "مفتوح المصدر",
		description = "هذا سكربت مفتوح المصدر بالكامل: ",
		link = "https://github.com/7yd7/Hub"
	}
}


addTermsToScrollingFrame(scrollFrame, terms)

local function createRadioButton(position, text, selected)
	local button = Instance.new("Frame")
	button.Size = UDim2.new(0, 18, 0, 18)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	button.BorderColor3 = Color3.fromRGB(171, 171, 171)
	button.Parent = mainFrame

	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(0, 10, 0, 10)
	inner.Position = UDim2.new(0.5, -5, 0.5, -5)
	inner.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	inner.BorderSizePixel = 0
	inner.BackgroundTransparency = selected and 0 or 1
	inner.Parent = button

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 200, 0, 18)
	label.Position = UDim2.new(1, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	return button, inner
end

local acceptButton, acceptInner = createRadioButton(UDim2.new(0, 20, 0, 330), "I accept the agreement", false)
local declineButton, declineInner = createRadioButton(UDim2.new(0, 20, 0, 355), "I do not accept the agreement", true)

local function createStyledButton(text, position)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 80, 0, 25)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	button.BorderColor3 = Color3.fromRGB(171, 171, 171)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(0, 0, 0)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 14
	button.AutoButtonColor = false
	button.Parent = mainFrame

	button.MouseEnter:Connect(function()
		if button.Active then
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(230, 230, 230)
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if button.Active then
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(240, 240, 240)
			}):Play()
		end
	end)

	button.MouseButton1Down:Connect(function()
		if button.Active then
			TweenService:Create(button, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			}):Play()
		end
	end)

	button.MouseButton1Up:Connect(function()
		if button.Active then
			TweenService:Create(button, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(230, 230, 230)
			}):Play()
		end
	end)


	return button
end

local nextButton = createStyledButton("Run", UDim2.new(1, -100, 1, -35))
local cancelButton = createStyledButton("Cancel", UDim2.new(1, -190, 1, -35))

mainFrame.Position = UDim2.new(0.5, -250, 0.45, -200)
mainFrame.BackgroundTransparency = 1
shadow.ImageTransparency = 1

TweenService:Create(blur, TweenInfo.new(0.3), {Size = 10}):Play()

TweenService:Create(shadow, TweenInfo.new(0.3), {
	ImageTransparency = 0.6
}):Play()


local selected = "decline"

local function updateNextButtonState()
	if selected == "accept" then
		TweenService:Create(nextButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(240, 240, 240),
			TextColor3 = Color3.fromRGB(0, 0, 0)
		}):Play()
		nextButton.AutoButtonColor = true
		nextButton.Active = true
	else
		TweenService:Create(nextButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(196, 196, 197),
			TextColor3 = Color3.fromRGB(120, 120, 120)
		}):Play()
		nextButton.AutoButtonColor = false
		nextButton.Active = false
	end
end

local function updateSelection(newSelection)
	local tweenInfo = TweenInfo.new(0.2)
	if newSelection == "accept" then
		TweenService:Create(acceptInner, tweenInfo, {BackgroundTransparency = 0}):Play()
		TweenService:Create(declineInner, tweenInfo, {BackgroundTransparency = 1}):Play()
	else
		TweenService:Create(acceptInner, tweenInfo, {BackgroundTransparency = 1}):Play()
		TweenService:Create(declineInner, tweenInfo, {BackgroundTransparency = 0}):Play()
	end
	selected = newSelection
	updateNextButtonState()
end

updateNextButtonState()

acceptButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		updateSelection("accept")
	end
end)

nextButton.MouseButton1Click:Connect(function()
	if selected == "accept" then
        closeWindow()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/Game"))()
	end
end)


declineButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		updateSelection("decline")
	end
end)

cancelButton.MouseButton1Click:Connect(closeWindow)
