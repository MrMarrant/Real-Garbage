local function CreateTrash(garbage, trash)
	local TrashToRemove = trash or garbage.Trash[#garbage.Trash]
		
	local TrashEnt = ents.Create( TrashToRemove.class )
	local PosTrash = garbage:GetPos() + Vector(0, 40, 50)

	TrashEnt:SetPos( PosTrash )
	TrashEnt:SetModel(TrashToRemove.model)
	TrashEnt:SetModelName( TrashToRemove.model )
	TrashEnt:Health(TrashToRemove.health)
	TrashEnt:Spawn()
	TrashEnt:Activate()
	if(TrashToRemove.weapon) then 
		TrashEnt:Give( TrashToRemove.weapon )
		TrashEnt:SelectWeapon( TrashToRemove.weapon )
	end
	TrashEnt:GetPhysicsObject():SetVelocity( garbage:GetUp() * 0.05 )
	TrashEnt.DelayTrash = true
	timer.Simple(3, function()
		if (IsValid(TrashEnt)) then TrashEnt.DelayTrash = nil end
	end)
end

function real_garbage.IsADoor(ent)
	local EntClass = ent:GetClass()
	if (REAL_GARBAGE_CONFIG.DoorClass[EntClass]) then return true end
	return false
end

function real_garbage.DestroyGarbage(garbage)
	local PosTrash = garbage:GetPos()

	for key, TrashToRemove in ipairs(garbage.Trash ) do
		local TrashEnt = ents.Create( TrashToRemove.class )
		PosTrash = PosTrash + Vector(math.random(-2,2), math.random(-2,2), math.random(40,50))

		CreateTrash(garbage, TrashToRemove)
		PosTrash = PosTrash + Vector(1, 1, 0)
	end

	local effectdata = EffectData()

	effectdata:SetOrigin( garbage:GetPos() )
	garbage:EmitSound( REAL_GARBAGE_CONFIG.OpenSoundGarbage, 75, 255 )
	util.Effect( "ThumperDust", effectdata )

	garbage:Remove()
end

function real_garbage.AddTrash(garbage, ent)
	if (ent:IsPlayer() or ent:IsWorld() or real_garbage.IsADoor(ent) or REAL_GARBAGE_CONFIG.GarbageClassAvailable[ent:GetClass()]) then return end
	if (!REAL_GARBAGE_CONFIG.EnableThrowNPC:GetBool() and ent:IsNPC()) then return end

	table.insert( garbage.Trash, { -- TODO : Save BodyGroup ?
		class = ent:GetClass(),
		model = ent:GetModel(),
		health = ent:Health()
	})
	if (ent:IsNPC()) then garbage.Trash[#garbage.Trash].weapon = ent:GetActiveWeapon():GetClass() end

	garbage.ActualCapacity = garbage.ActualCapacity + 1
	ent:Remove()

	garbage:ResetSequence( "throw" )
	timer.Simple(garbage:SequenceDuration(), function()
		if (IsValid(garbage)) then garbage:ResetSequence( "idle" )  end
	end)
end

function real_garbage.RemoveTrash(garbage)
	if (table.IsEmpty( garbage.Trash )) then return end

	CreateTrash(garbage)
	garbage.ActualCapacity = garbage.ActualCapacity - 1
	table.remove( garbage.Trash ) -- Remove the last element.
	garbage:ResetSequence( "throw" )
	timer.Simple(garbage:SequenceDuration(), function()
		if (IsValid(garbage)) then garbage:ResetSequence( "idle" )  end
	end)
	garbage:EmitSound( REAL_GARBAGE_CONFIG.OpenSoundGarbage, 75, math.random( 50, 160 ) )	
end