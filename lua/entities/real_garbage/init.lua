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
	if data.DeltaTime > 0.2 then
		if data.Speed > 250 then
			self:EmitSound( REAL_GARBAGE_CONFIG.PhysicSoundHeavy, 75, math.random( 50, 160 ) )	
		else
			self:EmitSound( REAL_GARBAGE_CONFIG.PhysicSoundLow, 75, math.random( 50, 160 ) )	
		end
	end
end

function ENT:OnTakeDamage( dmginfo )
	local DmgReceive = dmginfo:GetDamage()
	self.CurrentHealth = math.Clamp( self.CurrentHealth - DmgReceive, 0, 200 )
	if (DmgReceive >= 5) then
		self:EmitSound( REAL_GARBAGE_CONFIG.HitSoundGarbage, 75, math.random( 50, 150 ) )	
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
	self:EmitSound( REAL_GARBAGE_CONFIG.ThrowSoundGarbage, 75, math.random( 50, 160 ) )	
end

function ENT:Think()
    if ( SERVER ) then
        self:NextThink( CurTime() )
        return true 
    end
end