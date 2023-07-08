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

function ENT:GenerateTrash(ent)
	self.HasTrash = true
	ent:Remove()

	self:ManageRecepticle()

	timer.Simple(self:SequenceDuration(), function()
		if(!self:IsValid()) then return end

		self:EmitSound( REAL_GARBAGE_CONFIG.GeneratorRunning, 75, math.random( 100, 110 ) )
		timer.Simple(5, function()
			if(!self:IsValid()) then return end
			self:ManageRecepticle(true)

			timer.Simple(self:SequenceDuration(), function()
				if(!self:IsValid()) then return end
				local TrashEnt = ents.Create( "real_trash" )
				local PosTrash = self:GetPos() + Vector(0, 40, 50)

				TrashEnt:SetPos( self:GetPos() + Vector(0, 40, 50) )
				TrashEnt:Spawn()
				TrashEnt:Activate()

				self.HasTrash = false
			end)
		end)
	end)
end

function ENT:ManageRecepticle(fullSequence)
	self.InAction = true
	self:ResetSequence( self.IsOpen and "close" or "open" )
	self:EmitSound( self.IsOpen and REAL_GARBAGE_CONFIG.CloseRecepticle or REAL_GARBAGE_CONFIG.OpenRecepticle, 75)
		
	timer.Simple(self:SequenceDuration(), function()
		if(!self:IsValid()) then return end

		self.InAction = false
		self.IsOpen = !self.IsOpen
		if (fullSequence) then self:ManageRecepticle() end
	end)
end

function ENT:Initialize()
	self:SetModel( "models/generator_trash/generator_trash.mdl" )
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
			self:EmitSound( "physics/metal/metal_computer_impact_hard".. math.random(1, 3) ..".wav", 75, math.random( 50, 160 ) )	
		else
			self:EmitSound( "physics/metal/metal_computer_impact_soft".. math.random(1, 3) ..".wav", 75, math.random( 50, 160 ) )	
		end
	end
end

function ENT:Use(ply)
	if(!IsValid(ply) or self.HasTrash or self.InAction) then return end

	self:ManageRecepticle()
end

function ENT:Touch(ent)
	local CurrentTime = CurTime()

	if (self.NextTrash > CurrentTime or !self.IsOpen or !IsValid(ent) or ent:IsPlayer()) then return end
	if(real_garbage.IsADoor(ent) or ent:GetClass() == "real_trash") then return end
	if (!REAL_GARBAGE_CONFIG.EnableThrowNPC:GetBool() and ent:IsNPC()) then return end

	self.NextTrash = CurrentTime + self.Delay
	self:GenerateTrash(ent)
end

function ENT:Think()
    if ( SERVER ) then
        self:NextThink( CurTime() )
        return true 
    end
end