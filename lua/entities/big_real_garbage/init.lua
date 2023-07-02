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

AddCSLuaFile("shared.lua")
include("shared.lua")

-- TODO : Trouver les sons.
local PhysicSoundLow = Sound( "physics/glass/glass_bottle_impact_hard"..math.random(1, 3)..".wav" )
local PhysicSoundHeavy = Sound( "physics/glass/glass_bottle_break"..math.random(1, 2)..".wav" )
local TrowSoundGarbage = Sound( "" )
local OpenSoundGarbage = Sound( "" )

local DoorClass = {
    prop_door_rotating = true,
    func_door = true,
    func_door_rotating = true
}

local function IsADoor(ent)
	local EntClass = ent:GetClass()
	if (DoorClass[EntClass]) then return true end
	return false
end

function ENT:AddTrash(ent)
	if (ent:IsPlayer() or ent:IsWorld() or IsADoor(ent)) then return end

	table.insert( self.Trash, { -- TODO : Save BodyGroup ?
		class = ent:GetClass(),
		model = ent:GetModel(),
		health = ent:Health()
	})

	self.ActualCapacity = self.ActualCapacity + 1
	ent:Remove()
end

function ENT:RemoveTrash()
	if (table.IsEmpty( self.Trash )) then return end

	local TrashToRemove = self.Trash[#self.Trash]
		
	local TrashEnt = ents.Create( TrashToRemove.class )
	local PosTrash = self:GetPos() + Vector(math.random(1,2), 0, math.random(1,2))

	TrashEnt:SetPos( PosTrash )
	TrashEnt:SetModel(TrashToRemove.model)
	TrashEnt:SetModelName( TrashToRemove.model )
	TrashEnt:Health(TrashToRemove.health)
	TrashEnt:Spawn()
	TrashEnt:Activate()
	TrashEnt.DelayTrash = true
	timer.Simple(3, function()
		if (IsValid(TrashEnt)) then TrashEnt.DelayTrash = nil end
	end)

	self.ActualCapacity = self.ActualCapacity - 1
	table.remove( self.Trash ) -- Remove the last element.
end


function ENT:Initialize()
	self:SetModel( "models/props_junk/TrashBin01a.mdl" )
	self:RebuildPhysics()
end

function ENT:RebuildPhysics( )
	self:PhysicsInit( SOLID_VPHYSICS ) 
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS ) 
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
end

function ENT:PhysicsCollide( data, physobj )
	if ( data.Speed > 250 and data.DeltaTime > 0.01) then
		sound.Play( PhysicSoundHeavy, self:GetPos(), 75, math.random( 50, 160 ) )	
	elseif (data.Speed > 50 and data.DeltaTime > 0.01) then
		sound.Play( PhysicSoundLow, self:GetPos(), 75, math.random( 50, 160 ) )	
	end
end

function ENT:OnTakeDamage( dmginfo ) -- TODO : Exploser la poubelle si elle prend trop de dégats ?
	local DmgReceive = dmginfo:GetDamage()
	if (DmgReceive >= 30) then
		sound.Play( PhysicSoundHeavy, self:GetPos(), 75, math.random( 50, 160 ) )	
	else
		sound.Play( PhysicSoundLow, self:GetPos(), 75, math.random( 50, 160 ) )	
	end
end

function ENT:Use(ply)
	if(!IsValid(ply) or self.ActualCapacity == 0) then return end

	self:RemoveTrash()
	sound.Play( OpenSoundGarbage, self:GetPos(), 75, math.random( 50, 160 ) )	
end

-- TODO : Faire les sons de jeter en fonction du type de ce qui a été jeté ?
function ENT:Touch(ent)
	local CurrentTime = CurTime()
	if (ent.DelayTrash or self.NextTrash > CurrentTime) then return end
	if (!IsValid(ent) or self.ActualCapacity == self.MaxCapacity) then return end
	self.NextTrash = CurrentTime + self.Delay

	self:AddTrash(ent)
	sound.Play( TrowSoundGarbage, self:GetPos(), 75, math.random( 50, 160 ) )	
end