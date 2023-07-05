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
local PhysicSoundLow = Sound( "real_garbage/physic_low_garbage.mp3" )
local PhysicSoundHeavy = Sound( "real_garbage/physic_heavy_garbage.mp3" )
local ThrowSoundGarbage = Sound( "real_garbage/throw_garbage.mp3" )
local OpenSoundGarbage = Sound( "real_garbage/open_garbage.mp3" )
local HitSoundGarbage = Sound( "real_garbage/hit_garbage.mp3" )

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

function ENT:DestroyGarbage()
	local PosTrash = self:GetPos()

	for key, TrashToRemove in ipairs(self.Trash ) do
		local TrashEnt = ents.Create( TrashToRemove.class )
		PosTrash = PosTrash + Vector(math.random(-2,2), math.random(-2,2), math.random(40,50))

		TrashEnt:SetPos( PosTrash )
		TrashEnt:SetModel(TrashToRemove.model)
		TrashEnt:SetModelName( TrashToRemove.model )
		TrashEnt:Health(TrashToRemove.health)
		TrashEnt:Spawn()
		TrashEnt:Activate()
		TrashEnt:GetPhysicsObject():SetVelocity( (self:GetUp()) * 50 )
		PosTrash = PosTrash + Vector(1, 1, 0)
	end

	local effectdata = EffectData()

	effectdata:SetOrigin( self:GetPos() )
	sound.Play( OpenSoundGarbage, self:GetPos(), 75, 255 )
	util.Effect( "ThumperDust", effectdata )

	self:Remove()
end

function ENT:AddTrash(ent)
	if (ent:IsPlayer() or ent:IsWorld() or IsADoor(ent) or ent:GetClass() == self:GetClass()) then return end

	table.insert( self.Trash, { -- TODO : Save BodyGroup ?
		class = ent:GetClass(),
		model = ent:GetModel(),
		health = ent:Health()
	})

	self.ActualCapacity = self.ActualCapacity + 1
	ent:Remove()

	self:ResetSequence( "throw" )
	timer.Simple(self:SequenceDuration(), function()
		if (IsValid(self)) then self:ResetSequence( "idle" )  end
	end)
end

function ENT:RemoveTrash()
	if (table.IsEmpty( self.Trash )) then return end

	local TrashToRemove = self.Trash[#self.Trash]
		
	local TrashEnt = ents.Create( TrashToRemove.class )
	local PosTrash = self:GetPos() + Vector(0, 40, 50)

	TrashEnt:SetPos( PosTrash )
	TrashEnt:SetModel(TrashToRemove.model)
	TrashEnt:SetModelName( TrashToRemove.model )
	TrashEnt:Health(TrashToRemove.health)
	TrashEnt:Spawn()
	TrashEnt:Activate()
	TrashEnt:GetPhysicsObject():SetVelocity( self:GetUp() * 0.05 )
	TrashEnt.DelayTrash = true
	timer.Simple(3, function()
		if (IsValid(TrashEnt)) then TrashEnt.DelayTrash = nil end
	end)

	self.ActualCapacity = self.ActualCapacity - 1
	table.remove( self.Trash ) -- Remove the last element.
	self:ResetSequence( "throw" )
	timer.Simple(self:SequenceDuration(), function()
		if (IsValid(self)) then self:ResetSequence( "idle" )  end
	end)
	sound.Play( OpenSoundGarbage, self:GetPos(), 75, math.random( 50, 160 ) )	
end


function ENT:Initialize()
	self:SetModel( "models/small_garbage/small_garbage.mdl" )
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

function ENT:OnTakeDamage( dmginfo )
	local DmgReceive = dmginfo:GetDamage()
	self.CurrentHealth = math.Clamp( self.CurrentHealth - DmgReceive, 0, 200 )
	if (DmgReceive >= 5) then
		sound.Play( HitSoundGarbage, self:GetPos(), 75, math.random( 50, 160 ) )	
	end
	if (self.CurrentHealth <= 0) then self:DestroyGarbage() end
end

function ENT:Use(ply)
	if(!IsValid(ply) or self.ActualCapacity == 0) then return end

	self:RemoveTrash()
end

function ENT:Touch(ent)
	local CurrentTime = CurTime()
	if (ent.DelayTrash or self.NextTrash > CurrentTime) then return end
	if (!IsValid(ent) or self.ActualCapacity == self.MaxCapacity) then return end
	self.NextTrash = CurrentTime + self.Delay

	self:AddTrash(ent)
	sound.Play( ThrowSoundGarbage, self:GetPos(), 75, math.random( 50, 160 ) )	
end

function ENT:Think()
    if ( SERVER ) then
        self:NextThink( CurTime() )
        return true 
    end
end