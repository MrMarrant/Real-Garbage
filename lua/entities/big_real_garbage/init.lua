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

-- TODO : Modifier les sons pour la grosse poubelle.

AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/big_garbage/big_garbage.mdl" )
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
		sound.Play( REAL_GARBAGE_CONFIG.PhysicSoundHeavy, self:GetPos(), 75, math.random( 50, 160 ) )	
	elseif (data.Speed > 50 and data.DeltaTime > 0.01) then
		sound.Play( REAL_GARBAGE_CONFIG.PhysicSoundLow, self:GetPos(), 75, math.random( 50, 160 ) )	
	end
end

function ENT:OnTakeDamage( dmginfo )
	local DmgReceive = dmginfo:GetDamage()
	self.CurrentHealth = math.Clamp( self.CurrentHealth - DmgReceive, 0, 300 )
	if (DmgReceive >= 5) then
		sound.Play( REAL_GARBAGE_CONFIG.HitSoundGarbage, self:GetPos(), 75, math.random( 50, 160 ) )	
	end
	if (self.CurrentHealth <= 0) then real_garbage.DestroyGarbage(self) end
end

function ENT:Use(ply)
	if(!IsValid(ply) or self.ActualCapacity == 0) then return end

	real_garbage.RemoveTrash(self)
end

function ENT:Touch(ent)
	local CurrentTime = CurTime()
	if (ent.DelayTrash or self.NextTrash > CurrentTime) then return end
	if (!IsValid(ent) or self.ActualCapacity == self.MaxCapacity) then return end
	self.NextTrash = CurrentTime + self.Delay

	real_garbage.AddTrash(self, ent)
	sound.Play( REAL_GARBAGE_CONFIG.ThrowSoundGarbage, self:GetPos(), 75, math.random( 50, 160 ) )	
end

function ENT:Think()
    if ( SERVER ) then
        self:NextThink( CurTime() )
        return true 
    end
end