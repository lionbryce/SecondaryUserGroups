SecondaryUserGroups = SecondaryUserGroups or {} -- setup the "namespace" + live lua safety
SecondaryUserGroups.networkvar = "SecondaryUserGroup"
SecondaryUserGroups.folder = "SecondaryUserGroups"

SecondaryUserGroups.groups = {"Default", "Group2", "Group3", "Highest"} -- Higher index = higher precedence, group[1] is the default

-- very mild optimizations, would be better to put them in the do end blocks but that gets ugly fast
local groups = SecondaryUserGroups.groups
local nwvar = SecondaryUserGroups.networkvar
local folder = SecondaryUserGroups.folder

-- turns the above array into a dictionary
for k, v in ipairs(groups) do
    groups[v] = k
end

-- metamethod stuff
do
    local PLAYER = FindMetaTable("Player") -- grab that metatable

    -- convenience function
    local function verifyGroup(group)
        assert(group, "missing arg1 (group)") -- will trigger if you put "false" as well
        assert(isstring(group), "Group name should be a string") -- theoretically you could keep them numbered but we already nw it as a string so just use '1' instead of 1
        assert(groups[group], "Group not defined: " .. tostring(group)) -- I have trust issues, hence the tostring
    end

    function PLAYER:SetSecondaryUserGroup(group)
        verifyGroup(group)
        self:SetNWString(nwvar, group) -- theoretically, could save a couple bytes by networking as an int that refers to the index of the group
        SecondaryUserGroups.Save(self)
    end

    function PLAYER:GetSecondaryUserGroup()
        return self:GetNWString(nwvar, groups[1]) -- little bit of a magic number but that's not the end of the world here
    end

    function PLAYER:IsUserGroup(group)
        verifyGroup(group)
        local targetNum = groups[group]
        local playerNum = self:GetSecondaryUserGroup()

        return playerNum >= targetNum
    end

	--[[/* -- example code for generating PLAYER:IsGroupName(), I would not recommend this, will make refactoring harder
		for k,v in ipairs(groups) do

			local targetNum = groups[v]
			PLAYER["Is"..v] = function(self)
				local playerNum = self:GetSecondaryUserGroup()

				return playerNum >= targetNum
			end
		end
	*/]]
end

do
    local fileFormat = [[%s/%s.txt]]

    local function getPath(ply)
        return string.format(fileFormat, folder, ply:SteamID64())
    end

    -- example saving function
    function SecondaryUserGroups.Save(ply)
        file.CreateDir(folder)
        file.Write(getPath(ply), ply:GetSecondaryUserGroup())
    end

    -- example loading function, I'd recommend using a proper DB but this is just an example
    function SecondaryUserGroups.Load(ply)
        local group = file.Read(getPath(ply), "DATA")
        if not groups[group] then return end -- check if the group still exists, if it doesn't then don't bother loading it, don't overwrite though
        ply:SetSecondaryUserGroup(group)
    end
end

hook.Add("PlayerInitialSpawn", "SecondaryUserGroups", SecondaryUserGroups.Load)
