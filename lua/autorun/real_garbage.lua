-- Real Garbage, A representation of a Garbage object on the game Garry's Mod.
-- Copyright (C) 2023  MrMarrant aka BIBI.

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Functions
real_garbage = {}
-- Global Variable
REAL_GARBAGE_CONFIG = {}

REAL_GARBAGE_CONFIG.EnableThrowNPC = CreateConVar( "Enable_Throw_NPC_Trash", 1, FCVAR_PROTECTED, "Enable or not to throw NPC intop the garbage.", 0, 1 )
REAL_GARBAGE_CONFIG.RootFolder = "real_garbage/"

/*
* Allows you to load all the files in a folder.
* @string path of the folder to load.
* @bool isFile if the path is a file and not a folder.
*/
function real_garbage.LoadDirectory(pathFolder, isFile)
    if isFile then
        AddCSLuaFile(pathFolder)
        include(pathFolder)
    else
        local files, directories = file.Find(pathFolder.."*", "LUA")
        for key, value in pairs(files) do
            AddCSLuaFile(pathFolder..value)
            include(pathFolder..value)
        end
        for key, value in pairs(directories) do
            LoadDirectory(pathFolder..value)
        end
    end
end

print("Real Garbage Loading . . .")
real_garbage.LoadDirectory(REAL_GARBAGE_CONFIG.RootFolder.."config/sv_realgarbage_config.lua", true)
print("Real Garbage Loaded!")