REAL_GARBAGE_CONFIG.PhysicSoundLow = Sound( "real_garbage/physic_low_garbage.mp3" )
REAL_GARBAGE_CONFIG.PhysicSoundHeavy = Sound( "real_garbage/physic_heavy_garbage.mp3" )
REAL_GARBAGE_CONFIG.ThrowSoundGarbage = Sound( "real_garbage/throw_garbage.mp3" )
REAL_GARBAGE_CONFIG.OpenSoundGarbage = Sound( "real_garbage/open_garbage.mp3" )
REAL_GARBAGE_CONFIG.HitSoundGarbage = Sound( "real_garbage/hit_garbage.mp3" )
REAL_GARBAGE_CONFIG.GeneratorRunning = Sound( "real_garbage/generator_running.mp3" )
REAL_GARBAGE_CONFIG.OpenRecepticle = Sound( "real_garbage/open_recepticle.mp3" )
REAL_GARBAGE_CONFIG.CloseRecepticle = Sound( "real_garbage/close_recepticle.mp3" )
REAL_GARBAGE_CONFIG.HardImpactTrash = Sound( "real_garbage/hard_impact_trash.mp3" )
REAL_GARBAGE_CONFIG.SoftImpactTrash = Sound( "real_garbage/soft_impact_trash.mp3" )

REAL_GARBAGE_CONFIG.GarbageClassAvailable = {
    big_real_garbage = true,
    real_garbage = true,
    generator_trash = true
}

REAL_GARBAGE_CONFIG.DoorClass = {
    prop_door_rotating = true,
    func_door = true,
    func_door_rotating = true
}

real_garbage.LoadDirectory(REAL_GARBAGE_CONFIG.RootFolder.."server/")