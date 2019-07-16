local USE_NEW_HULL = CreateConVar('ppm2_sv_newhull', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Use proper collision box for ponies. Slightly affects jump mechanics. When disabled, unexpected behaviour could happen.')
local NO_VO_MOD = CreateConVar('ppm2_sv_no_viewoffset_mod', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED
}, 'Do not mod the view offset')
local ALLOW_TO_MODIFY_SCALE = PPM2.ALLOW_TO_MODIFY_SCALE
local PonySizeController
do
  local _class_0
  local _parent_0 = PPM2.ControllerChildren
  local _base_0 = {
    Remap = function(self)
      local mapping = {
        'NECK_BONE_1',
        'NECK_BONE_2',
        'NECK_BONE_3',
        'NECK_BONE_4',
        'LEGS_BONE_ROOT',
        'LEGS_FRONT_1',
        'LEGS_FRONT_2',
        'LEGS_FRONT_3',
        'LEGS_FRONT_4',
        'LEGS_FRONT_5',
        'LEGS_FRONT_6',
        'LEGS_BEHIND_1_1',
        'LEGS_BEHIND_2_1',
        'LEGS_BEHIND_3_1',
        'LEGS_BEHIND_1_2',
        'LEGS_BEHIND_2_2',
        'LEGS_BEHIND_3_2'
      }
      self.validSkeleton = true
      for _, name in ipairs(mapping) do
        self[name] = self:GetEntity():LookupBone(self.__class[name])
        if not self[name] then
          self.validSkeleton = false
        end
      end
    end,
    IsValid = function(self)
      return self.controller:IsValid()
    end,
    GetEntity = function(self)
      return self.controller:GetEntity()
    end,
    IsNetworked = function(self)
      return self.controller:IsNetworked()
    end,
    AllowResize = function(self)
      return not self.controller:IsNetworked() or ALLOW_TO_MODIFY_SCALE:GetBool()
    end,
    DisallowViewOffsetMod = function(self)
      return not self.controller:IsNetworked() or NO_VO_MOD:GetBool()
    end,
    DataChanges = function(self, state)
      if not IsValid(self:GetEntity()) then
        return 
      end
      if not self:GetEntity():IsPony() then
        return 
      end
      self:Remap()
      if not self:GetEntity():IsPlayer() and self:GetEntity():GetModelScale() ~= 1 then
        self:GetEntity():SetModelScale(1)
      end
      if state:GetKey() == 'PonySize' then
        self:ModifyScale()
      end
      if state:GetKey() == 'NeckSize' then
        self:ModifyNeck()
        self:ModifyViewOffset()
      end
      if state:GetKey() == 'LegsSize' then
        self:ModifyLegs()
        self:ModifyHull()
        return self:ModifyViewOffset()
      end
    end,
    ResetViewOffset = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if ent.SetViewOffset then
        ent:SetViewOffset(PPM2.PLAYER_VIEW_OFFSET_ORIGINAL)
      end
      if ent.SetViewOffsetDucked then
        return ent:SetViewOffsetDucked(PPM2.PLAYER_VIEW_OFFSET_DUCK_ORIGINAL)
      end
    end,
    ResetHulls = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if ent.ResetHull then
        ent:ResetHull()
      end
      if ent.SetStepSize then
        ent:SetStepSize(self.__class.STEP_SIZE)
      end
      ent.__ppm2_modified_hull = false
    end,
    ResetJumpHeight = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if CLIENT then
        return 
      end
      if not ent.SetJumpPower then
        return 
      end
      if not ent.__ppm2_modified_jump then
        return 
      end
      ent:SetJumpPower(ent:GetJumpPower() / PPM2.PONY_JUMP_MODIFIER)
      ent.__ppm2_modified_jump = false
    end,
    ResetModelScale = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if SERVER then
        return 
      end
      local mat = Matrix()
      mat:Scale(self.__class.DEF_SCALE)
      return ent:EnableMatrix('RenderMultiply', mat)
    end,
    ResetScale = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not IsValid(ent) then
        return 
      end
      if USE_NEW_HULL:GetBool() or ent.__ppm2_modified_hull then
        self:ResetHulls(ent)
        self:ResetJumpHeight(ent)
      end
      self:ResetViewOffset(ent)
      self:ResetModelScale(ent)
      if self.validSkeleton then
        self:ResetNeck(ent)
        return self:ResetLegs(ent)
      end
    end,
    ResetNeck = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not CLIENT then
        return 
      end
      if not IsValid(self:GetEntity()) then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      do
        local _with_0 = ent
        _with_0:ManipulateBoneScale2Safe(self.NECK_BONE_1, LVector(1, 1, 1))
        _with_0:ManipulateBoneScale2Safe(self.NECK_BONE_2, LVector(1, 1, 1))
        _with_0:ManipulateBoneScale2Safe(self.NECK_BONE_3, LVector(1, 1, 1))
        _with_0:ManipulateBoneScale2Safe(self.NECK_BONE_4, LVector(1, 1, 1))
        _with_0:ManipulateBoneAngles2Safe(self.NECK_BONE_1, Angle(0, 0, 0))
        _with_0:ManipulateBoneAngles2Safe(self.NECK_BONE_2, Angle(0, 0, 0))
        _with_0:ManipulateBoneAngles2Safe(self.NECK_BONE_3, Angle(0, 0, 0))
        _with_0:ManipulateBoneAngles2Safe(self.NECK_BONE_4, Angle(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_1, LVector(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_2, LVector(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_3, LVector(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_4, LVector(0, 0, 0))
        return _with_0
      end
    end,
    ResetLegs = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not CLIENT then
        return 
      end
      if not IsValid(ent) then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local vec1 = LVector(1, 1, 1)
      local vec2 = LVector(0, 0, 0)
      local ang = Angle(0, 0, 0)
      do
        local _with_0 = ent
        _with_0:ManipulateBoneScale2Safe(self.LEGS_BONE_ROOT, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_FRONT_1, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_FRONT_2, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_BEHIND_1_1, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_BEHIND_2_1, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_BEHIND_3_1, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_BEHIND_1_2, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_BEHIND_2_2, vec1)
        _with_0:ManipulateBoneScale2Safe(self.LEGS_BEHIND_3_2, vec1)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_BONE_ROOT, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_FRONT_1, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_FRONT_2, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_BEHIND_1_1, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_BEHIND_2_1, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_BEHIND_3_1, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_BEHIND_1_2, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_BEHIND_2_2, ang)
        _with_0:ManipulateBoneAngles2Safe(self.LEGS_BEHIND_3_2, ang)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BONE_ROOT, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_1, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_2, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_1_1, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_2_1, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_3_1, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_1_2, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_2_2, vec2)
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_3_2, vec2)
        return _with_0
      end
    end,
    Remove = function(self)
      return self:ResetScale()
    end,
    Reset = function(self)
      self:ResetScale()
      self:ResetNeck()
      self:ResetLegs()
      return self:ModifyScale()
    end,
    GetLegsSize = function(self)
      return self:GetData():GetLegsSize()
    end,
    GetLegsScale = function(self)
      return self:GetData():GetLegsSize()
    end,
    GetNeckSize = function(self)
      return self:GetData():GetNeckSize()
    end,
    GetNeckScale = function(self)
      return self:GetData():GetNeckSize()
    end,
    GetPonySize = function(self)
      return self:GetData():GetPonySize()
    end,
    GetPonyScale = function(self)
      return self:GetData():GetPonySize()
    end,
    PlayerDeath = function(self)
      self:ResetScale()
      self:ResetNeck()
      self:ResetLegs()
      return self:Remap()
    end,
    PlayerRespawn = function(self)
      self:Remap()
      self:ResetScale()
      return self:ModifyScale()
    end,
    SlowUpdate = function(self)
      self:Remap()
      return self:ModifyScale()
    end,
    ModifyHull = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      ent.__ppm2_modified_hull = true
      local size = self:GetPonySize()
      local legssize = self:GetLegsModifier()
      local HULL_MINS = Vector(self.__class.HULL_MINS)
      local HULL_MAXS = Vector(self.__class.HULL_MAXS)
      local HULL_MAXS_DUCK = Vector(self.__class.HULL_MAXS_DUCK)
      if self:AllowResize() then
        HULL_MINS = HULL_MINS * size
        HULL_MAXS = HULL_MAXS * size
        HULL_MAXS_DUCK = HULL_MAXS_DUCK * size
        HULL_MINS.z = HULL_MINS.z * legssize
        HULL_MAXS.z = HULL_MAXS.z * legssize
        HULL_MAXS_DUCK.z = HULL_MAXS_DUCK.z * legssize
      end
      do
        local _with_0 = ent
        if _with_0.SetHull then
          local cmins, cmaxs = _with_0:GetHull()
          if cmins ~= HULL_MINS or cmaxs ~= HULL_MAXS then
            _with_0:SetHull(HULL_MINS, HULL_MAXS)
          end
        end
        if _with_0.SetHullDuck then
          local cmins, cmaxs = _with_0:GetHullDuck()
          if cmins ~= HULL_MINS or cmaxs ~= HULL_MAXS_DUCK then
            _with_0:SetHullDuck(HULL_MINS, HULL_MAXS_DUCK)
          end
        end
        if _with_0.SetStepSize then
          local newsize = self.__class.STEP_SIZE * size * self:GetLegsModifier(1.2)
          if _with_0:GetStepSize() ~= newsize then
            _with_0:SetStepSize(newsize)
          end
        end
        return _with_0
      end
    end,
    ModifyJumpHeight = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if CLIENT then
        return 
      end
      if not self:GetEntity().SetJumpPower then
        return 
      end
      if ent.__ppm2_modified_jump then
        return 
      end
      ent:SetJumpPower(ent:GetJumpPower() * PPM2.PONY_JUMP_MODIFIER)
      ent.__ppm2_modified_jump = true
    end,
    GetLegsModifier = function(self, mult)
      if mult == nil then
        mult = 0.4
      end
      if self:AllowResize() then
        return 1 + (self:GetLegsSize() - 1) * mult
      else
        return 1
      end
    end,
    ModifyViewOffset = function(self, ent)
	if self:DisallowViewOffsetMod() then
	  return
	end
      if ent == nil then
        ent = self:GetEntity()
      end
      local size = self:GetPonySize()
      local necksize = 1 + (self:GetNeckSize() - 1) * .3
      local legssize = self:GetLegsModifier()
      local PLAYER_VIEW_OFFSET = Vector(PPM2.PLAYER_VIEW_OFFSET)
      local PLAYER_VIEW_OFFSET_DUCK = Vector(PPM2.PLAYER_VIEW_OFFSET_DUCK)
      if self:AllowResize() then
        PLAYER_VIEW_OFFSET = PLAYER_VIEW_OFFSET * (size * necksize)
        PLAYER_VIEW_OFFSET_DUCK = PLAYER_VIEW_OFFSET_DUCK * (size * necksize)
        PLAYER_VIEW_OFFSET.z = PLAYER_VIEW_OFFSET.z * legssize
        PLAYER_VIEW_OFFSET_DUCK.z = PLAYER_VIEW_OFFSET_DUCK.z * legssize
      end
      if ent.SetViewOffset then
        ent:SetViewOffset(PLAYER_VIEW_OFFSET)
      end
      if ent.SetViewOffsetDucked then
        return ent:SetViewOffsetDucked(PLAYER_VIEW_OFFSET_DUCK)
      end
	end,
    ModifyModelScale = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not self:AllowResize() then
        return 
      end
      if SERVER then
        if not ent:IsPlayer() then
          local newscale = (self:GetPonySize() * 100):floor() / 100
          local currscale = (ent:GetModelScale() * 100):floor() / 100
          if currscale ~= newscale then
            if type(ent) == 'NPC' or type(NPC) == 'NextBot' then
              for _, ply in ipairs(player.GetAll()) do
                ent:SetPreventTransmit(ply, true)
              end
              ent:SetModelScale(newscale)
              for _, ply in ipairs(player.GetAll()) do
                ent:SetPreventTransmit(ply, false)
              end
            else
              ent:SetModelScale(newscale)
            end
          end
        end
        return 
      end
      if ent.RenderOverride then
        return 
      end
      local mat = Matrix()
      mat:Scale(self.__class.DEF_SCALE * self:GetPonySize())
      return ent:EnableMatrix('RenderMultiply', mat)
    end,
    ModifyScale = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not IsValid(ent) then
        return 
      end
      if not ent:IsPony() then
        return 
      end
      if ent.Alive and not ent:Alive() then
        return 
      end
      if USE_NEW_HULL:GetBool() then
        self:ModifyHull(ent)
        self:ModifyJumpHeight(ent)
      end
      self:ModifyViewOffset(ent)
      self:ModifyModelScale(ent)
      if CLIENT and self.lastPAC3BoneReset < RealTimeL() then
        self:ModifyNeck(ent)
        return self:ModifyLegs(ent)
      end
    end,
    ModifyNeck = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not IsValid(ent) then
        return 
      end
      if not self:AllowResize() then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local size = (self:GetNeckSize() - 1) * 3
      local vec = LVector(size, -size, 0)
      local boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or { }
      local emptyLVector = LVector(0, 0, 0)
      do
        local _with_0 = ent
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_1, vec + (boneAnimTable[self.NECK_BONE_1] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_2, vec + (boneAnimTable[self.NECK_BONE_2] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_3, vec + (boneAnimTable[self.NECK_BONE_3] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.NECK_BONE_4, vec + (boneAnimTable[self.NECK_BONE_4] or emptyLVector))
        return _with_0
      end
    end,
    ModifyLegs = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not IsValid(ent) then
        return 
      end
      if not self:AllowResize() then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local realSizeModify = self:GetLegsSize() - 1
      local size = realSizeModify * 3
      local boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or { }
      local emptyLVector = LVector(0, 0, 0)
      do
        local _with_0 = ent
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BONE_ROOT, LVector(0, 0, size * 5) + _with_0:GetManipulateBonePosition2Safe(self.LEGS_BONE_ROOT))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_1, LVector(size * 1.5, 0, 0) + (boneAnimTable[self.LEGS_FRONT_1] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_2, LVector(size * 1.5, 0, 0) + (boneAnimTable[self.LEGS_FRONT_2] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_3, LVector(size, 0, 0) + (boneAnimTable[self.LEGS_FRONT_3] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_4, LVector(size, 0, 0) + (boneAnimTable[self.LEGS_FRONT_4] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_5, LVector(size, size, 0) + (boneAnimTable[self.LEGS_FRONT_5] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_FRONT_6, LVector(size, size, 0) + (boneAnimTable[self.LEGS_FRONT_6] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_1_1, LVector(size, -size * 0.5, 0) + (boneAnimTable[self.LEGS_BEHIND_1_1] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_1_2, LVector(size, -size * 0.5, 0) + (boneAnimTable[self.LEGS_BEHIND_1_2] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_2_1, LVector(size, 0, 0) + (boneAnimTable[self.LEGS_BEHIND_2_1] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_2_2, LVector(size, 0, 0) + (boneAnimTable[self.LEGS_BEHIND_2_2] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_3_1, LVector(size * 2, 0, 0) + (boneAnimTable[self.LEGS_BEHIND_3_1] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.LEGS_BEHIND_3_2, LVector(size * 2, 0, 0) + (boneAnimTable[self.LEGS_BEHIND_3_2] or emptyLVector))
        return _with_0
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller)
      _class_0.__parent.__init(self, controller)
      self.isValid = true
      self.objID = self.__class.NEXT_OBJ_ID
      self.__class.NEXT_OBJ_ID = self.__class.NEXT_OBJ_ID + 1
      self.lastPAC3BoneReset = 0
      self:Remap()
      PPM2.DebugPrint('Created new size controller for ', self:GetEntity(), ' as part of ', controller, '; internal ID is ', self.objID)
      if not self:GetEntity():IsPlayer() and self:GetEntity():GetModelScale() ~= 1 then
        return self:GetEntity():SetModelScale(1)
      end
    end,
    __base = _base_0,
    __name = "PonySizeController",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.AVALIABLE_CONTROLLERS = { }
  self.MODELS = {
    'models/ppm/player_default_base.mdl',
    'models/ppm/player_default_base_nj.mdl',
    'models/cppm/player_default_base.mdl',
    'models/cppm/player_default_base_nj.mdl'
  }
  self.NECK_BONE_1 = 'LrigNeck1'
  self.NECK_BONE_2 = 'LrigNeck2'
  self.NECK_BONE_3 = 'LrigNeck3'
  self.NECK_BONE_4 = 'LrigScull'
  self.LEGS_BONE_ROOT = 'LrigPelvis'
  self.LEGS_FRONT_1 = 'Lrig_LEG_FL_FrontHoof'
  self.LEGS_FRONT_2 = 'Lrig_LEG_FR_FrontHoof'
  self.LEGS_FRONT_3 = 'Lrig_LEG_FL_Metacarpus'
  self.LEGS_FRONT_4 = 'Lrig_LEG_FR_Metacarpus'
  self.LEGS_FRONT_5 = 'Lrig_LEG_FL_Radius'
  self.LEGS_FRONT_6 = 'Lrig_LEG_FR_Radius'
  self.LEGS_BEHIND_1_1 = 'Lrig_LEG_BR_Tibia'
  self.LEGS_BEHIND_2_1 = 'Lrig_LEG_BR_PhalanxPrima'
  self.LEGS_BEHIND_3_1 = 'Lrig_LEG_BR_LargeCannon'
  self.LEGS_BEHIND_1_2 = 'Lrig_LEG_BL_Tibia'
  self.LEGS_BEHIND_2_2 = 'Lrig_LEG_BL_PhalanxPrima'
  self.LEGS_BEHIND_3_2 = 'Lrig_LEG_BL_LargeCannon'
  self.NEXT_OBJ_ID = 0
  self.STEP_SIZE = 20
  self.PONY_HULL = 17
  self.HULL_MINS = Vector(-self.PONY_HULL, -self.PONY_HULL, 0)
  self.HULL_MAXS = Vector(self.PONY_HULL, self.PONY_HULL, 72 * PPM2.PONY_HEIGHT_MODIFIER)
  self.HULL_MAXS_DUCK = Vector(self.PONY_HULL, self.PONY_HULL, 36 * PPM2.PONY_HEIGHT_MODIFIER_DUCK_HULL)
  self.DEFAULT_HULL_MINS = Vector(-16, -16, 0)
  self.DEFAULT_HULL_MAXS = Vector(16, 16, 72)
  self.DEFAULT_HULL_MAXS_DUCK = Vector(16, 16, 36)
  self.DEF_SCALE = Vector(1, 1, 1)
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PonySizeController = _class_0
end
PPM2.PonySizeController = PonySizeController
local NewPonySizeContoller
do
  local _class_0
  local _parent_0 = PonySizeController
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "NewPonySizeContoller",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.MODELS = {
    'models/ppm/player_default_base_new.mdl',
    'models/ppm/player_default_base_new_nj.mdl'
  }
  self.NECK_BONE_1 = 'LrigNeck1'
  self.NECK_BONE_2 = 'LrigNeck2'
  self.NECK_BONE_3 = 'LrigNeck3'
  self.NECK_BONE_4 = 'LrigScull'
  self.LEGS_FRONT_1 = 'Lrig_LEG_FL_FrontHoof'
  self.LEGS_FRONT_2 = 'Lrig_LEG_FR_FrontHoof'
  self.LEGS_FRONT_3 = 'Lrig_LEG_FL_Metacarpus'
  self.LEGS_FRONT_4 = 'Lrig_LEG_FR_Metacarpus'
  self.LEGS_FRONT_5 = 'Lrig_LEG_FL_Radius'
  self.LEGS_FRONT_6 = 'Lrig_LEG_FR_Radius'
  self.LEGS_BEHIND_1_1 = 'Lrig_LEG_BL_Tibia'
  self.LEGS_BEHIND_1_2 = 'Lrig_LEG_BR_Tibia'
  self.LEGS_BEHIND_2_1 = 'Lrig_LEG_BL_PhalanxPrima'
  self.LEGS_BEHIND_2_2 = 'Lrig_LEG_BR_PhalanxPrima'
  self.LEGS_BEHIND_3_1 = 'Lrig_LEG_BL_LargeCannon'
  self.LEGS_BEHIND_3_2 = 'Lrig_LEG_BR_LargeCannon'
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  NewPonySizeContoller = _class_0
end
PPM2.NewPonySizeContoller = NewPonySizeContoller
hook.Add('PPM2.SetupBones', 'PPM2.Size', function(ent, data)
  do
    local sizes = data:GetSizeController()
    if sizes then
      sizes.ent = ent
      sizes:ModifyNeck()
      sizes:ModifyLegs()
      sizes.lastPAC3BoneReset = RealTimeL() + 1
    end
  end
end)
local ppm2_sv_allow_resize
ppm2_sv_allow_resize = function()
  for _, ply in ipairs(player.GetAll()) do
    do
      local data = ply:GetPonyData()
      if data then
        do
          local scale = data:GetSizeController()
          if scale then
            scale:Reset()
          end
        end
      end
    end
  end
end
local ppm2_sv_no_viewoffset_mod
ppm2_sv_no_viewoffset_mod = function()
  local AVOM = GetConVar( "ppm2_sv_no_viewoffset_mod" )
  if tobool(AVOM)  then
     for nop,PE in pairs(player.GetAll()) do
       PE:SetViewOffset(PPM2.PLAYER_VIEW_OFFSET_ORIGINAL)
       PE:SetViewOffsetDucked(PPM2.PLAYER_VIEW_OFFSET_DUCK_ORIGINAL)
     end
  end
end
local ppm2_sv_newhull
ppm2_sv_newhull = function()
  local NH = GetConVar( "ppm2_sv_newhull" )
  if not tobool(NH) then
    for nop,PE in pairs(player.GetAll()) do
	  PE:ResetHull()
	  PE:SetStepSize(20)
	  PE.__ppm2_modified_hull = false
	  PE:SetJumpPower(200)
	  PE.__ppm2_modified_jump = false
     end
  end
end
local des = "Do sth to make you more pony?\n0 - disable Hull and ViewOffset mod once\n1 - Enable Hull But disable ViewOffset mod once(default config)\n2 - Enable hull and ViewOffset mod once(OG PPM2)"
concommand.Add("isrealpony",
function(ply,cmd,args,argStr)
 local vo = GetConVar( "ppm2_sv_no_viewoffset_mod" )
 local hl = GetConVar( "ppm2_sv_newhull" )
 local num = tonumber(argStr) 
 if not num then
     print("Unregonized mode",num)
     return
 end
 if num > 2 or num < 0 then
    print("Unregonized mode",num)
	return
 end
  if num == 0 then
    vo:SetString("1")
	hl:SetString("0")
  end
  if num == 1 then
    vo:SetString("1")
	hl:SetString("1")
  end
  if num == 2 then
    vo:SetString("0")
	hl:SetString("1")
  end
  for nop,PE in pairs(player.GetAll()) do
  PE:ConCommand("ppm2_reload")
  end
end
,nil,des,{FCVAR_SERVER_CAN_EXECUTE})
cvars.AddChangeCallback('ppm2_sv_no_viewoffset_mod', ppm2_sv_no_viewoffset_mod, 'PPM.VO')
cvars.AddChangeCallback('ppm2_sv_allow_resize', ppm2_sv_allow_resize, 'PPM2.Scale')
cvars.AddChangeCallback('ppm2_sv_newhull', ppm2_sv_newhull, 'PPM.NH')
PPM2.GetSizeController = function(model)
  if model == nil then
    model = 'models/ppm/player_default_base.mdl'
  end
  return PonySizeController.AVALIABLE_CONTROLLERS[model:lower()] or PonySizeController
end
