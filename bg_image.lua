local API = API

local bg_image = {}

bg_image.ShowMenu = true
bg_image.ImageURL = ""
bg_image.FileName = API.Config.Get("BenzoScripts->BackgroundImage->LastFileName") or ""
bg_image.Material = nil
bg_image.X = API.Config.Get("BenzoScripts->BackgroundImage->X") or 0
bg_image.Y = API.Config.Get("BenzoScripts->BackgroundImage->Y") or 0

function bg_image.LoadMaterial()
	bg_image.Material = Material("../data/" .. bg_image.FileName)

	API.Config.Set("BenzoScripts->BackgroundImage->LastFileName", bg_image.FileName)
end

function bg_image.OnFetchSuccess(Body, Size, Headers, Code)
	if Size < 1 then
		return bg_image.OnFetchFail("Received no data in response")
	end

	local ContentType = Headers["Content-Type"]

	if not ContentType or not string.find(ContentType, "image") then
		return bg_image.OnFetchFail("Received non-image response")
	end

	bg_image.FileName = string.GetFileFromFilename(bg_image.ImageURL) -- TODO: Could be bad with certain URLs

	file.Write(bg_image.FileName, Body)

	bg_image.LoadMaterial()
end

function bg_image.OnFetchFail(Error)
	Error = string.format("BG Image: Failed to fetch image!\n\n%s", Error)

	API.GUI.Notifications.Add(Error, 5, Color(255, 0, 0, 255))
end

function bg_image.Fetch()
	http.Fetch(bg_image.ImageURL, bg_image.OnFetchSuccess, bg_image.OnFetchFail)
end

API.Callbacks.Add("ImGui::BuildWindowsCombo", "BenzoScripts:BackgroundImage", function()
	if API.ImGui.MenuItem("Background Image", nil, bg_image.ShowMenu) then
		bg_image.ShowMenu = not bg_image.ShowMenu
	end
end)

API.Callbacks.Add("ImGui::Draw", "BenzoScripts:BackgroundImage", function()
	if bg_image.ShowMenu and API.ImGui.Begin("Background Image") then
		API.ImGui.Text("Image URL")
		local Changed, NewValue = API.ImGui.InputText("", bg_image.ImageURL)

		if Changed then
			bg_image.ImageURL = NewValue
		end

		API.ImGui.SameLine(0, 8)
		if API.ImGui.Button("Update") then
			bg_image.Fetch()
		end

		Changed, NewValue = API.ImGui.SliderInt("X Offset", bg_image.X, 0, ScrW())
		if Changed then
			bg_image.X = NewValue
			API.Config.Set("BenzoScripts->BackgroundImage->X", bg_image.X)
		end

		Changed, NewValue = API.ImGui.SliderInt("Y Offset", bg_image.Y, 0, ScrH())
		if Changed then
			bg_image.Y = NewValue
			API.Config.Set("BenzoScripts->BackgroundImage->Y", bg_image.Y)
		end

		API.ImGui.End()
	end
end)

API.Callbacks.Add("ImGui::Draw", "BenzoScripts:BackgroundImage_Render", function() -- Hook::PostRender doesn't run in main menu
	local Alpha = API.GUI.GetAlpha()
	if Alpha < 0.01 then return end

	if not bg_image.Material then return end
	if bg_image.Material:IsError() then return end

	surface.SetMaterial(bg_image.Material)
	surface.SetDrawColor(255, 255, 255, 255 * Alpha)
	surface.DrawTexturedRect(bg_image.X, bg_image.Y, bg_image.Material:Width(), bg_image.Material:Height())
end)

do
	bg_image.LoadMaterial()
end
