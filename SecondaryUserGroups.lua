SecondaryUserGroups = SecondaryUserGroups or {} -- setup the "namespace" and live lua safety
SecondaryUserGroups.networkvar = "SecondaryUserGroup"
SecondaryUserGroups.folder = "SecondaryUserGroups"
SecondaryUserGroups.groups = { -- Higher index = higher precedence, group[1] is the default
	"Default",
	"Group2",
	"Group3",
	"Highest",
}

-- very mild optimizations, would be better to put them in the do end blocks but that gets ugly fast
local groups = SecondaryUserGroups.groups
local nwvar = SecondaryUserGroups.networkvar
local folder = SecondaryUserGroups.folder

for k,v in ipairs(groups) do -- turns the above array into a dictionary
	groups[v] = k
end

do -- metamethod stuff
	local PLAYER = FindMetaTable("Player") -- grab that metatable

	local function verifyGroup(group) -- convenience function
		assert(group, "missing arg1 (group)") -- will trigger if you put "false" as well
		assert(isstring(group), "Group name should be a string") -- theoretically you could keep them numbered but we already nw it as a string so just use '1' instead of 1
		assert(groups[group], "Group not defined: " .. tostring(group)) -- I have trust issues, hence the tostring
	end

	function PLAYER:SetSecondaryUserGroup(group)
		verifyGroup(group)

		self:SetNWString( nwvar , group ) -- theoretically, could save a couple bytes by networking as an int that refers to the index of the group
		SecondaryUserGroups.Save(self)
	end

	function PLAYER:GetSecondaryUserGroup(default) -- incase you want to override the default
		return self:GetNWString( nwvar, default or groups[1])
	end

	function PLAYER:IsUserGroup(group)
		verifyGroup(group)
		
		local targetNum = groups[group]
		local playerNum = self:GetSecondaryUserGroup()

		return playerNum >= targetNum
	end
end

do
	local fileFormat = [[%s/%s.txt]]

	local function getPath(ply)
		return string.format(fileFormat,folder,ply:SteamID64())
	end

	function SecondaryUserGroups.Save(ply) -- example saving function
		file.CreateDir(folder)
		file.Write(getPath(ply),ply:GetSecondaryUserGroup())
	end

	function SecondaryUserGroups.Load(ply) -- example loading function, I'd recommend using a proper DB but this is just an example
		local group = file.Read(getPath(ply), "DATA")
		if !groups[group] then return end -- check if the group still exists, if it doesn't then don't bother loading it, don't overwrite though

		ply:SetSecondaryUserGroup(group)
	end
end

hook.Add("PlayerInitialSpawn","SecondaryUserGroups",SecondaryUserGroups.Load)
