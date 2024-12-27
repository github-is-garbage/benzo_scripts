local Snowflakes = {}

do
	for _ = 1, 300 do
		local Size = math.random(2, 5)

		local X = math.random(-500, ScrW())
		local Y = math.random(-100, -Size)

		table.insert(Snowflakes, {
			X = X,
			Y = Y,
			VerticalSpeed = math.random(100, 300),
			HorizontalSpeed = math.random(50, 200),
			Size = Size
		})
	end
end

API.Callbacks.Add("ImGui::Draw", "BenzoScripts:Christmas", function()
	if not API.GUI.GetVisible() then return end

	local ScrW, ScrH = ScrW(), ScrH()
	local DeltaTime = FrameTime()

	for i = 1, #Snowflakes do
		local Snowflake = Snowflakes[i]

		Snowflake.X = Snowflake.X + (Snowflake.HorizontalSpeed * DeltaTime)
		Snowflake.Y = Snowflake.Y + (Snowflake.VerticalSpeed * DeltaTime)

		if (Snowflake.X > ScrW + Snowflake.Size) or (Snowflake.Y > ScrH + Snowflake.Size) then
			Snowflake.X = math.random(-500, ScrW)
			Snowflake.Y = -Snowflake.Size
		end

		surface.DrawCircle(Snowflake.X, Snowflake.Y, Snowflake.Size, 255, 255, 255, 255)
	end
end)
