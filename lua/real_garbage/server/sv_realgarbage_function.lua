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

local function MakeVehicle( Pos, model, Class, VName, VTable )

	local Ent = ents.Create( Class )
	if ( !IsValid( Ent ) ) then return NULL end

	Ent:SetModel( model )

	-- Fallback vehiclescripts for HL2 maps ( dupe support )
	if ( model == "models/buggy.mdl" ) then Ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jeep_test.txt" ) end
	if ( model == "models/vehicle.mdl" ) then Ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jalopy.txt" ) end

	-- Fill in the keyvalues if we have them
	if ( VTable && VTable.KeyValues ) then
		for k, v in pairs( VTable.KeyValues ) do

			local kLower = string.lower( k )

			if ( kLower == "vehiclescript" or
				kLower == "limitview"     or
				kLower == "vehiclelocked" or
				kLower == "cargovisible"  or
				kLower == "enablegun" )
			then
				Ent:SetKeyValue( k, v )
			end

		end
	end
	
	Ent:SetPos( Pos )
	Ent:Spawn()
	Ent:Activate()

	if ( Ent.SetVehicleClass && VName ) then Ent:SetVehicleClass( VName ) end
	Ent.VehicleName = VName
	Ent.VehicleTable = VTable

	-- We need to override the class in the case of the Jeep, because it
	-- actually uses a different class than is reported by GetClass
	Ent.ClassOverride = Class

	return Ent
end

local function CreateTrash(garbage, trash)
	local TrashToRemove = trash or garbage.Trash[#garbage.Trash]
	local PosTrash = garbage:GetPos() + Vector(0, 40, 50)
	local TrashEnt = nil

	if (TrashToRemove.is_vehicle) then
		TrashEnt = MakeVehicle( PosTrash, TrashToRemove.model, TrashToRemove.class,  TrashToRemove.vehicle_name, TrashToRemove.key_values )
	else
		TrashEnt = ents.Create( TrashToRemove.class )

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
	end

	if (IsValid(TrashEnt:GetPhysicsObject())) then
		TrashEnt:GetPhysicsObject():SetMass(TrashToRemove.mass)
		TrashEnt.Mass = TrashToRemove.mass
		TrashEnt:GetPhysicsObject():SetVelocity( garbage:GetUp() * 0.05 )
	end
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
	util.Effect( "GlassImpact", effectdata )
	util.Effect( "WheelDust", effectdata )

	garbage:Remove()
end

function real_garbage.AddTrash(garbage, ent)
	if (ent:IsPlayer() or ent:IsWorld() or real_garbage.IsADoor(ent) or REAL_GARBAGE_CONFIG.GarbageClassAvailable[ent:GetClass()]) then return end
	if (!REAL_GARBAGE_CONFIG.EnableThrowNPC:GetBool() and ent:IsNPC()) then return end
	if (REAL_GARBAGE_CONFIG.AllowOnlyTrashBag:GetBool() and ent:GetClass() != "real_trash") then return end

	table.insert( garbage.Trash, { -- TODO : Save BodyGroup ?
		class = ent:GetClass(),
		model = ent:GetModel(),
		health = ent:Health()
	})
	if (IsValid(ent:GetPhysicsObject())) then
		garbage.Trash[#garbage.Trash].mass = ent:GetPhysicsObject():GetMass()
	end
	if (ent:IsNPC()) then
		if(IsValid(ent:GetActiveWeapon())) then
			garbage.Trash[#garbage.Trash].weapon = ent:GetActiveWeapon():GetClass() 
		end
	end
	if (ent:IsVehicle()) then
		garbage.Trash[#garbage.Trash].is_vehicle = true
		garbage.Trash[#garbage.Trash].key_values = ent:GetKeyValues()
		garbage.Trash[#garbage.Trash].vehicle_name = ent:GetVehicleClass()
	end

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