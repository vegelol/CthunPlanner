local dotPos = {
	[1] = {1, 98}, --melee        		-- 
	[2] = {-32, 131}, --healer    		-|
	[3] = {-20, 170}, --ranged    		-|Group 1 
	[4] = {22, 171}, --ranged     		-|
	[5] = {34, 132}, --healer/ranged    --
	[6] = {67, 71}, -- melee      		--
	[7] = {69, 118}, --healer     		-|
	[8] = {105, 137}, --ranged    		-|Group 2
	[9] = {134, 107}, --ranged    		-|
	[10] = {115, 70}, --healer/ranged   --
	[11] = {-66, 69}, -- melee    		--
	[12] = {-113, 69}, --healer   		-|
	[13] = {-132, 106}, --ranged  		-|Group 3
	[14] = {-66, 116}, --ranged   		-|
	[15] = {-103, 135}, --healer/ranged --
	[16] = {97, 4}, -- melee      		--
	[17] = {130, 37}, --healer    		-|
	[18] = {169, 24}, --ranged    		-|Group 4
	[19] = {170, -17}, --ranged   		-|
	[20] = {130, -30}, --healer/ranged  --
	[21] = {-93, 2}, -- melee     		--
	[22] = {-126, -31}, --healer  		-|
	[23] = {-166, -19}, --ranged  		-|Group 5
	[24] = {-166, 22}, --ranged   		-|
	[25] = {-127, 35}, --healer/ranged  --
	[26] = {69, -64}, -- melee    		--
	[27] = {117, -64}, --healer   		-|
	[28] = {135, -100}, --ranged  		-|Group 6
	[29] = {107, -129}, --ranged  		-|
	[30] = {70, -110}, --healer/ranged  --
	[31] = {-65, -65}, -- melee   		--
	[32] = {-65, -112}, --healer  		-|
	[33] = {-101, -131}, --ranged 		-|Group 7
	[34] = {-130, -102}, --ranged 		-|
	[35] = {-112, -66}, --healer/ranged --
	[36] = {3, -92}, -- melee     		--
	[37] = {36, -126}, --healer   		-|
	[38] = {24, -165}, --ranged   		-|Group 8
	[39] = {-18, -165}, --ranged  		-|
	[40] = {-30, -126} --healer/ranged  --
}

local checkRoster = {}
local CthunPlanner_PlayerName,_ = UnitName("player")
local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix("CthunPlanner")

if not successfulRequest then
	DEFAULT_CHAT_FRAME:AddMessage("|cff00d2d6CthunPlanner:|r Error creating addon channel.", 1.0, 1.0, 0);
end

local backdrop = {
	bgFile = "Interface\\AddOns\\CthunPlanner\\Images\\CThun_Positioning.tga",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false,
	edgeSize = 32,
	insets = {
		left = 12,
		right = 12,
		top = 12,
		bottom = 12
	}
}

local frame = CreateFrame("Frame", "Cthun_room", UIParent)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetFrameStrata("FULLSCREEN")
frame:SetHeight(534)
frame:SetWidth(534)
frame:SetPoint("CENTER", 0, 0)
frame:SetBackdrop(backdrop)
frame:SetAlpha(1.00)
frame:SetUserPlaced(true)
frame:Hide()

frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", 
		function(...)
			local _, _, prefix, msg, dist, sender = ...
			if prefix == "CthunPlanner" then

				if msg == "SHARE" then
					DEFAULT_CHAT_FRAME:AddMessage("|cff00d2d6CthunPlanner:|r Accepting share..", 1.0, 1.0, 0);
					frame:Show()
					fillGrid()
				end

				if msg == "CHECK" then
					C_ChatInfo.SendAddonMessage("CthunPlanner", "CHECKRES: "..CthunPlanner_PlayerName, "WHISPER", sender)
				end

				if string.find(msg, "CHECKRES: ") then
					local _, start = string.find(msg, "CHECKRES: ")
					local name = string.sub(msg, start+1, string.len(msg))
					
					for i, v in ipairs(checkRoster) do
						if v == name then
							table.remove(checkRoster, i)
						end
					end
				end

			end
		end
	)

local CthunPlanner_Slider = CreateFrame("Slider", "MySlider1", frame, "OptionsSliderTemplate")
CthunPlanner_Slider:SetPoint("BOTTOM", frame, "BOTTOMRIGHT", -80, 20)
CthunPlanner_Slider:SetMinMaxValues(0.05, 1.00)
CthunPlanner_Slider:SetValue(1.00)
CthunPlanner_Slider:SetValueStep(0.05)
getglobal(CthunPlanner_Slider:GetName() .. 'Low'):SetText('5%')
getglobal(CthunPlanner_Slider:GetName() .. 'High'):SetText('100%')
getglobal(CthunPlanner_Slider:GetName() .. 'Text'):SetText('Opacity')
CthunPlanner_Slider:SetScript("OnValueChanged", function(self)
	local value = CthunPlanner_Slider:GetValue()
	frame:SetAlpha(value)
end)

local CthunPlanner_Header = CreateFrame("Frame", "CthunPlanner_Header", frame)
CthunPlanner_Header:SetPoint("TOP", frame, "TOP", 0, 12)
CthunPlanner_Header:SetWidth(256)
CthunPlanner_Header:SetHeight(64)
CthunPlanner_Header:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header"
})

local CthunPlanner_Fontstring = CthunPlanner_Header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
CthunPlanner_Fontstring:SetPoint("CENTER", CthunPlanner_Header, "CENTER", 0, 12)
CthunPlanner_Fontstring:SetText("Cthun Planner")

local button = CreateFrame("Button", "Close_button", frame)
button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
button:SetHeight(32)
button:SetWidth(32)
button:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
button:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
button:SetScript("OnLoad", 
	function()
		button:RegisterForClicks("AnyUp")
	end 
)
button:SetScript("OnClick", 
	function()
		frame:Hide();
	end
)

local num_dots = 0

function newDot(x, y, name, class)
	num_dots = num_dots + 1

	local dot = CreateFrame("Button", "Dot_"..num_dots, frame)

	dot:SetPoint("CENTER", frame, "CENTER", x, y)
	dot:EnableMouse(true)
	if (CthunPlanner_PlayerName == name) then
		dot:SetWidth(32)
		dot:SetHeight(32)
	else
		dot:SetWidth(16)
		dot:SetHeight(16)
	end
	
	local texdot = dot:CreateTexture(nil, "OVERLAY")

	dot.texture = texdot
	texdot:SetAllPoints(dot)
	if (name == "Empty") then
		texdot:SetTexture(nil)
	else
		texdot:SetTexture("Interface\\AddOns\\CthunPlanner\\Images\\playerdot_".. class ..".tga")
	end

	dot:SetFrameLevel(dot:GetFrameLevel()+3)
	dot:RegisterEvent("GROUP_ROSTER_UPDATE")
	dot:SetScript("OnEvent", 
		function()
			dot:Hide();
			frame:Hide();
			wipeReserves()
		end
	)

	dot:SetScript("OnEnter",
		function()
			GameTooltip:SetOwner(dot, "ANCHOR_RIGHT")
			GameTooltip:SetText(name)
			GameTooltip:Show()
		end
	)
	dot:SetScript("OnLeave",
		function()
			GameTooltip:Hide()
		end
	)

	return dot
end

local dotRes = {{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}, -- group 1
		  		{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}, -- group 2
		  		{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}, --    |
	  	  		{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}, --    |
	  	  		{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}, --    |
		  		{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}, --    |
		  		{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}, --    |
		  		{{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"},{"Empty","Empty"}}} -- group 8

function getRaidInfo()
	for i=1,40 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);

		if (class == "Rogue" or class == "Warrior") then
			if dotRes[subgroup][1][1] == "Empty" or dotRes[subgroup][1][1] == name then
				dotRes[subgroup][1] = {name, class}
			elseif dotRes[subgroup][5][1] == "Empty" or dotRes[subgroup][5][1] == name then
				dotRes[subgroup][5] = {name, class}
			elseif dotRes[subgroup][2][1] == "Empty" or dotRes[subgroup][2][1] == name then
				dotRes[subgroup][2] = {name, class}
			elseif dotRes[subgroup][3][1] == "Empty" or dotRes[subgroup][3][1] == name then
				dotRes[subgroup][3] = {name, class}
			else
				dotRes[subgroup][4] = {name, class}
			end
		elseif (class == "Mage" or class == "Warlock" or class == "Hunter") then
			if dotRes[subgroup][3][1] == "Empty" or dotRes[subgroup][3][1] == name then
				dotRes[subgroup][3] = {name, class}
			elseif dotRes[subgroup][4][1] == "Empty" or dotRes[subgroup][4][1] == name then
				dotRes[subgroup][4] = {name, class}
			elseif dotRes[subgroup][5][1] == "Empty" or dotRes[subgroup][5][1] == name then
				dotRes[subgroup][5] = {name, class}
			elseif dotRes[subgroup][2][1] == "Empty" or dotRes[subgroup][2][1] == name then
				dotRes[subgroup][2] = {name, class}
			else 
				dotRes[subgroup][1] = {name, class}
			end
		elseif (class == "Priest" or class == "Paladin" or class == "Druid") then
			if dotRes[subgroup][2][1] == "Empty" or dotRes[subgroup][2][1] == name then
				dotRes[subgroup][2] = {name, class}
			elseif dotRes[subgroup][5][1] == "Empty" or dotRes[subgroup][5][1] == name then
				dotRes[subgroup][5] = {name, class}
			elseif dotRes[subgroup][3][1] == "Empty" or dotRes[subgroup][3][1] == name then
				dotRes[subgroup][3] = {name, class}
			elseif dotRes[subgroup][4][1] == "Empty" or dotRes[subgroup][4][1] == name then
				dotRes[subgroup][4] = {name, class}
			else
				dotRes[subgroup][1] = {name, class}
			end
		end
	end
end

function fillGrid()
	wipeReserves()
	getRaidInfo()
	local count = 0
	for i=1,8 do
		for j=1,5 do
			count = count + 1
			local x = ((i-1)*5)+j
			newDot(dotPos[x][1], dotPos[x][2], dotRes[i][j][1], dotRes[i][j][2])
		end
	end
end

function shareGrid()
	C_ChatInfo.SendAddonMessage("CthunPlanner", "SHARE", "RAID")
end

function checkAddons()
	checkRoster = {}

	for i=1,41 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
			if name then
				table.insert(checkRoster, name)
		end
	end

	C_ChatInfo.SendAddonMessage("CthunPlanner", "CHECK", "RAID")
	DEFAULT_CHAT_FRAME:AddMessage("|cff00d2d6CthunPlanner:|r checking if everyone has the addon installed..", 1.0, 1.0, 0);
	C_Timer.After(3, checkResults)

end

function checkResults()
	DEFAULT_CHAT_FRAME:AddMessage(table.concat(checkRoster,", "), 1.0, 1.0, 0);
	if table.getn(checkRoster) > 0 then
		DEFAULT_CHAT_FRAME:AddMessage("   |cFFFF0000Missing Addon:|r "..table.concat(checkRoster,", "), 1.0, 1.0, 0);
	else
		DEFAULT_CHAT_FRAME:AddMessage("   |cFF00FF00All players have CthunPlanner installed!|r", 1.0, 1.0, 0);
	end
end

function wipeReserves()
	for i=1,8 do
		for j=1,5 do
			for k=1,2 do
				dotRes[i][j][k] = "Empty"
			end
		end
	end
end

SLASH_CthunPlanner1 = "/cthun";

local function HandleSlashCommands(str)
	if (str == "help") then
		DEFAULT_CHAT_FRAME:AddMessage("Commands:", 1.0, 1.0, 0);
		DEFAULT_CHAT_FRAME:AddMessage("   /cthun |cff00d2d6help |r-- show this help menu", 1.0, 1.0, 0);
		DEFAULT_CHAT_FRAME:AddMessage("   /cthun |cff00d2d6fill |r-- show all players on map (/cthun)", 1.0, 1.0, 0);
		DEFAULT_CHAT_FRAME:AddMessage("   /cthun |cff00d2d6share |r-- displays the planner to your raid", 1.0, 1.0, 0);
		DEFAULT_CHAT_FRAME:AddMessage("   /cthun |cff00d2d6check |r-- check if all raiders have the addon installed", 1.0, 1.0, 0);		
	elseif (str == "fill" or str == "" or str == nil) then
		frame:Show()
		fillGrid()
	elseif (str == "share") then
		if IsInGroup() then
			if UnitIsGroupLeader("player") then
				frame:Show()
				fillGrid()
				shareGrid()
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cff00d2d6CthunPlanner:|r Only the group leader can share.", 1.0, 1.0, 0);
			end
		else 
			DEFAULT_CHAT_FRAME:AddMessage("|cff00d2d6CthunPlanner:|r You need to be in a raid to use this command.", 1.0, 1.0, 0);
		end
	elseif (str == "check") then
		if IsInGroup() and UnitIsGroupLeader("player") then
			checkAddons()
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cff00d2d6CthunPlanner:|r This is only available to group leaders.", 1.0, 1.0, 0);
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Command not found", 1.0, 1.0, 0);
	end
end

SlashCmdList.CthunPlanner = HandleSlashCommands;
