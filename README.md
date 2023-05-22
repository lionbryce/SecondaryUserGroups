# SecondaryUserGroups
Good for splitting up your user groups, in theory you could use multiple of this for more than just secondary but I wouldn't recommend it

Player methods:
GetSecondaryUserGroup() -- returns what group they're in
SetSecondaryUserGroup(group) -- sets the group they're in
IsSecondaryGroup(group) -- checks if they're at or above the provided group

Functions worth editing (because using files to save is not the greatest methd):
SecondaryUserGroups.Save(PLAYER) -- save player
SecondaryUserGroups.Load(PLAYER) -- load player
