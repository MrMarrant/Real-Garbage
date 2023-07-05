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