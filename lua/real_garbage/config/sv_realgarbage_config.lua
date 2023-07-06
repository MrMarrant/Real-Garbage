REAL_GARBAGE_CONFIG.PhysicSoundLow = Sound( "real_garbage/physic_low_garbage.mp3" )
REAL_GARBAGE_CONFIG.PhysicSoundHeavy = Sound( "real_garbage/physic_heavy_garbage.mp3" )
REAL_GARBAGE_CONFIG.ThrowSoundGarbage = Sound( "real_garbage/throw_garbage.mp3" )
REAL_GARBAGE_CONFIG.OpenSoundGarbage = Sound( "real_garbage/open_garbage.mp3" )
REAL_GARBAGE_CONFIG.HitSoundGarbage = Sound( "real_garbage/hit_garbage.mp3" )

REAL_GARBAGE_CONFIG.GarbageClassAvailable = {
    big_real_garbage = true,
    real_garbage = true
}

REAL_GARBAGE_CONFIG.DoorClass = {
    prop_door_rotating = true,
    func_door = true,
    func_door_rotating = true
}

real_garbage.LoadDirectory(REAL_GARBAGE_CONFIG.RootFolder.."server/")