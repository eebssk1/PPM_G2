local PPM2, ents, LocalPlayer, SERVER, NULL, CLIENT, EF_BONEMERGE
do
  local _obj_0 = _G
  PPM2, ents, LocalPlayer, SERVER, NULL, CLIENT, EF_BONEMERGE = _obj_0.PPM2, _obj_0.ents, _obj_0.LocalPlayer, _obj_0.SERVER, _obj_0.NULL, _obj_0.CLIENT, _obj_0.EF_BONEMERGE
end
local ALLOW_TO_MODIFY_SCALE = PPM2.ALLOW_TO_MODIFY_SCALE
local TRACKED_ENTS = { }
local TRACKED_ENTS_FRAME = 0
local ents_GetAll
ents_GetAll = function()
  if TRACKED_ENTS_FRAME ~= FrameNumberL() then
    TRACKED_ENTS = ents.GetAll()
    TRACKED_ENTS_FRAME = FrameNumberL()
  end
  return TRACKED_ENTS
end
if CLIENT then
  for _, ent in ipairs(ents.GetAll()) do
    if ent.isPonyLegsModel or ent.isPonyPropModel then
      ent:Remove()
    end
  end
end
PPM2.BODYGROUP_SKELETON = 0
PPM2.BODYGROUP_GENDER = 1
PPM2.BODYGROUP_HORN = 2
PPM2.BODYGROUP_WINGS = 3
PPM2.BODYGROUP_MANE_UPPER = 4
PPM2.BODYGROUP_MANE_LOWER = 5
PPM2.BODYGROUP_TAIL = 6
PPM2.BODYGROUP_CMARK = 7
PPM2.BODYGROUP_EYELASH = 8
local DefaultBodygroupController
do
  local _class_0
  local _parent_0 = PPM2.ControllerChildren
  local _base_0 = {
    Remap = function(self)
      local mapping = {
        'BONE_SPINE_ROOT',
        'BONE_TAIL_1',
        'BONE_TAIL_2',
        'BONE_TAIL_3',
        'BONE_SPINE',
        'BONE_MANE_1',
        'BONE_MANE_2',
        'BONE_MANE_3',
        'BONE_MANE_4',
        'BONE_MANE_5',
        'BONE_MANE_6',
        'BONE_MANE_7',
        'BONE_MANE_8'
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
      return self.isValid
    end,
    CreateSocksModel = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      if IsValid(self.socksModel) then
        return self.socksModel
      end
      for _, ent in ipairs(ents_GetAll()) do
        if ent.isPonyPropModel and ent.isSocks and ent.manePlayer == self:GetEntity() then
          self.socksModel = ent
          self:GetData():SetSocksModel(self.socksModel)
          PPM2.DebugPrint('Resuing ', self.socksModel, ' as socks model for ', self:GetEntity())
          return ent
        end
      end
      do
        local _with_0 = ClientsideModel('models/props_pony/ppm/cosmetics/ppm_socks.mdl')
        self.socksModel = _with_0
        _with_0.isPonyPropModel = true
        _with_0.isSocks = true
        _with_0.manePlayer = self:GetEntity()
        _with_0:DrawShadow(true)
        _with_0:SetPos(self:GetEntity():EyePos())
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:SetNoDraw(true)
        _with_0:SetParent(self:GetEntity())
        _with_0:AddEffects(EF_BONEMERGE)
      end
      PPM2.DebugPrint('Creating new socks model for ', self:GetEntity(), ' as ', self.socksModel)
      self:GetData():SetSocksModel(self.socksModel)
      return self.socksModel
    end,
    CreateNewSocksModel = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      if IsValid(self.newSocksModel) then
        return self.newSocksModel
      end
      for _, ent in ipairs(ents_GetAll()) do
        if ent.isPonyPropModel and ent.isNewSocks and ent.manePlayer == self:GetEntity() then
          self.newSocksModel = ent
          self:GetData():SetNewSocksModel(self.newSocksModel)
          PPM2.DebugPrint('Resuing ', self.newSocksModel, ' as socks model for ', self:GetEntity())
          return ent
        end
      end
      do
        local _with_0 = ClientsideModel('models/props_pony/ppm/cosmetics/ppm2_socks.mdl')
        self.newSocksModel = _with_0
        _with_0.isPonyPropModel = true
        _with_0.isNewSocks = true
        _with_0.manePlayer = self:GetEntity()
        _with_0:DrawShadow(true)
        _with_0:SetPos(self:GetEntity():EyePos())
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:SetNoDraw(true)
        _with_0:SetParent(self:GetEntity())
        _with_0:AddEffects(EF_BONEMERGE)
      end
      PPM2.DebugPrint('Creating new socks model for ', self:GetEntity(), ' as ', self.newSocksModel)
      self:GetData():SetNewSocksModel(self.newSocksModel)
      return self.newSocksModel
    end,
    CreateNewSocksModelIfNotExists = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      if not IsValid(self.newSocksModel) then
        self:CreateNewSocksModel(force)
      end
      if not IsValid(self.newSocksModel) then
        return NULL
      end
      if IsValid(self:GetEntity()) then
        self.newSocksModel:SetParent(self:GetEntity())
      end
      self:GetData():SetNewSocksModel(self.newSocksModel)
      return self.newSocksModel
    end,
    CreateSocksModelIfNotExists = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      if not IsValid(self.socksModel) then
        self:CreateSocksModel(force)
      end
      if not IsValid(self.socksModel) then
        return NULL
      end
      if IsValid(self:GetEntity()) then
        self.socksModel:SetParent(self:GetEntity())
      end
      self:GetData():SetSocksModel(self.socksModel)
      return self.socksModel
    end,
    MergeModels = function(self, targetEnt)
      if targetEnt == nil then
        targetEnt = NULL
      end
      if SERVER or not self.isValid or not IsValid(targetEnt) then
        return 
      end
      local socks
      if self:GetData():GetSocksAsModel() then
        socks = self:CreateSocksModelIfNotExists(true)
      end
      local socks2
      if self:GetData():GetSocksAsNewModel() then
        socks2 = self:CreateNewSocksModelIfNotExists(true)
      end
      if IsValid(socks) then
        socks:SetParent(targetEnt)
      end
      if IsValid(socks2) then
        return socks2:SetParent(targetEnt)
      end
    end,
    GetSocks = function(self)
      return self.socksModel or NULL
    end,
    ApplyRace = function(self)
      if not (self.isValid) then
        return 
      end
      if not IsValid(self:GetEntity()) then
        return NULL
      end
      do
        local _with_0 = self:GetEntity()
        local _exp_0 = self:GetData():GetRace()
        if PPM2.RACE_EARTH == _exp_0 then
          _with_0:SetBodygroup(self.__class.BODYGROUP_HORN, 1)
          _with_0:SetBodygroup(self.__class.BODYGROUP_WINGS, 1)
        elseif PPM2.RACE_PEGASUS == _exp_0 then
          _with_0:SetBodygroup(self.__class.BODYGROUP_HORN, 1)
          _with_0:SetBodygroup(self.__class.BODYGROUP_WINGS, 0)
        elseif PPM2.RACE_UNICORN == _exp_0 then
          _with_0:SetBodygroup(self.__class.BODYGROUP_HORN, 0)
          _with_0:SetBodygroup(self.__class.BODYGROUP_WINGS, 1)
        elseif PPM2.RACE_ALICORN == _exp_0 then
          _with_0:SetBodygroup(self.__class.BODYGROUP_HORN, 0)
          _with_0:SetBodygroup(self.__class.BODYGROUP_WINGS, 0)
        end
        return _with_0
      end
    end,
    ResetTail = function(self)
      if not CLIENT then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      do
        local _with_0 = self:GetEntity()
        _with_0:ManipulateBoneScale2Safe(self.BONE_TAIL_1, LVector(1, 1, 1))
        _with_0:ManipulateBoneScale2Safe(self.BONE_TAIL_2, LVector(1, 1, 1))
        _with_0:ManipulateBoneScale2Safe(self.BONE_TAIL_3, LVector(1, 1, 1))
        _with_0:ManipulateBoneAngles2Safe(self.BONE_TAIL_1, Angle(0, 0, 0))
        _with_0:ManipulateBoneAngles2Safe(self.BONE_TAIL_2, Angle(0, 0, 0))
        _with_0:ManipulateBoneAngles2Safe(self.BONE_TAIL_3, Angle(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.BONE_TAIL_1, LVector(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.BONE_TAIL_2, LVector(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.BONE_TAIL_3, LVector(0, 0, 0))
        return _with_0
      end
    end,
    ResetBack = function(self)
      if not CLIENT then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      do
        local _with_0 = self:GetEntity()
        _with_0:ManipulateBoneScale2Safe(self.BONE_SPINE_ROOT, LVector(1, 1, 1))
        _with_0:ManipulateBoneScale2Safe(self.BONE_SPINE, LVector(1, 1, 1))
        _with_0:ManipulateBoneAngles2Safe(self.BONE_SPINE_ROOT, Angle(0, 0, 0))
        _with_0:ManipulateBoneAngles2Safe(self.BONE_SPINE, Angle(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.BONE_SPINE_ROOT, LVector(0, 0, 0))
        _with_0:ManipulateBonePosition2Safe(self.BONE_SPINE, LVector(0, 0, 0))
        return _with_0
      end
    end,
    ResetMane = function(self)
      if not CLIENT then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local vec1, ang, vec2 = LVector(1, 1, 1), Angle(0, 0, 0), LVector(0, 0, 0)
      do
        local _with_0 = self:GetEntity()
        for i = 1, 7 do
          _with_0:ManipulateBoneScale2Safe(self['BONE_MANE_' .. i], vec1)
          _with_0:ManipulateBoneAngles2Safe(self['BONE_MANE_' .. i], ang)
          _with_0:ManipulateBonePosition2Safe(self['BONE_MANE_' .. i], vec2)
        end
        return _with_0
      end
    end,
    ResetBodygroups = function(self)
      if not (self.isValid) then
        return 
      end
      if not (IsValid(self:GetEntity())) then
        return 
      end
      if not (self:GetEntity():GetBodyGroups()) then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      for _, grp in ipairs(self:GetEntity():GetBodyGroups()) do
        self:GetEntity():SetBodygroup(grp.id, 0)
      end
      if self.lastPAC3BoneReset < RealTimeL() then
        self:ResetTail()
        self:ResetMane()
        return self:ResetBack()
      end
    end,
    Reset = function(self)
      return self:ResetBodygroups()
    end,
    RemoveModels = function(self)
      if IsValid(self.socksModel) then
        self.socksModel:Remove()
      end
      if IsValid(self.newSocksModel) then
        return self.newSocksModel:Remove()
      end
    end,
    UpdateTailSize = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not CLIENT then
        return 
      end
      if self:GetEntity().Alive and not self:GetEntity():Alive() then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local size = self:GetData():GetTailSize()
      if not ent:IsRagdoll() and not ent:IsNJPony() then
        size = size * self:GetData():GetPonySize()
      end
      local vec = LVector(1, 1, 1)
      local vecTail = vec * size
      local vecTailPos = LVector((size - 1) * 8, 0, 0)
      local boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or { }
      local emptyLVector = LVector(0, 0, 0)
      do
        local _with_0 = ent
        _with_0:ManipulateBoneScale2Safe(self.BONE_TAIL_1, vecTail)
        _with_0:ManipulateBoneScale2Safe(self.BONE_TAIL_2, vecTail)
        _with_0:ManipulateBoneScale2Safe(self.BONE_TAIL_3, vecTail)
        _with_0:ManipulateBonePosition2Safe(self.BONE_TAIL_2, vecTailPos + (boneAnimTable[self.BONE_TAIL_2] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_TAIL_3, vecTailPos + (boneAnimTable[self.BONE_TAIL_3] or emptyLVector))
        return _with_0
      end
    end,
    UpdateManeSize = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not CLIENT then
        return 
      end
      if ent:IsRagdoll() then
        return 
      end
      if ent:IsNJPony() then
        return 
      end
      if self:GetEntity().Alive and not self:GetEntity():Alive() then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local size = self:GetData():GetPonySize()
      local vecMane = LVector(1, 1, 1) * size
      local boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or { }
      local emptyLVector = LVector(0, 0, 0)
      do
        local _with_0 = ent
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_1, vecMane)
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_2, vecMane)
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_3, vecMane)
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_4, vecMane)
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_5, vecMane)
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_6, vecMane)
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_7, vecMane)
        _with_0:ManipulateBoneScale2Safe(self.BONE_MANE_8, vecMane)
        _with_0:ManipulateBonePosition2Safe(self.BONE_MANE_1, LVector(-(size - 1) * 4, (1 - size) * 3, 0) + (boneAnimTable[self.BONE_MANE_1] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_MANE_2, LVector(-(size - 1) * 4, (size - 1) * 2, 1) + (boneAnimTable[self.BONE_MANE_2] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_MANE_3, LVector((size - 1) * 2, 0, 0) + (boneAnimTable[self.BONE_MANE_3] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_MANE_4, LVector(1 - size, (1 - size) * 4, 1 - size) + (boneAnimTable[self.BONE_MANE_4] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_MANE_5, LVector((size - 1) * 4, (1 - size) * 2, (size - 1) * 3) + (boneAnimTable[self.BONE_MANE_5] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_MANE_6, LVector(0, 0, -(size - 1) * 2) + (boneAnimTable[self.BONE_MANE_6] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_MANE_7, LVector(0, 0, -(size - 1) * 2) + (boneAnimTable[self.BONE_MANE_7] or emptyLVector))
        return _with_0
      end
    end,
    UpdateBack = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not CLIENT then
        return 
      end
      if ent:IsRagdoll() then
        return 
      end
      if ent:IsNJPony() then
        return 
      end
      if self:GetEntity().Alive and not self:GetEntity():Alive() then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local vecModify = LVector(-(self:GetData():GetBackSize() - 1) * 2, 0, 0)
      local vecModify2 = LVector((self:GetData():GetBackSize() - 1) * 5, 0, 0)
      local boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or { }
      local emptyLVector = LVector(0, 0, 0)
      do
        local _with_0 = ent
        _with_0:ManipulateBonePosition2Safe(self.BONE_SPINE_ROOT, vecModify + (boneAnimTable[self.BONE_SPINE_ROOT] or emptyLVector))
        _with_0:ManipulateBonePosition2Safe(self.BONE_SPINE, vecModify2 + (boneAnimTable[self.BONE_SPINE] or emptyLVector))
        return _with_0
      end
    end,
    SlowUpdate = function(self, createModels, ent, force)
      if createModels == nil then
        createModels = CLIENT
      end
      if ent == nil then
        ent = self:GetEntity()
      end
      if force == nil then
        force = false
      end
      if not IsValid(ent) then
        return 
      end
      if not ent:IsPony() then
        return 
      end
      do
        ent:SetBodygroup(self.__class.BODYGROUP_MANE_UPPER, self:GetData():GetManeType())
        ent:SetBodygroup(self.__class.BODYGROUP_MANE_LOWER, self:GetData():GetManeTypeLower())
        ent:SetBodygroup(self.__class.BODYGROUP_TAIL, self:GetData():GetTailType())
        ent:SetBodygroup(self.__class.BODYGROUP_EYELASH, self:GetData():GetEyelashType())
        ent:SetBodygroup(self.__class.BODYGROUP_GENDER, self:GetData():GetGender())
      end
      self:ApplyRace()
      if createModels then
        if self:GetData():GetSocksAsModel() then
          self:CreateSocksModelIfNotExists(force)
        end
        if self:GetData():GetSocksAsNewModel() then
          return self:CreateNewSocksModelIfNotExists(force)
        end
      end
    end,
    ApplyBodygroups = function(self, createModels, force)
      if createModels == nil then
        createModels = CLIENT
      end
      if force == nil then
        force = false
      end
      if not (self.isValid) then
        return 
      end
      if not IsValid(self:GetEntity()) then
        return 
      end
      self:ResetBodygroups()
      if not self:GetEntity():IsPony() then
        return 
      end
      return self:SlowUpdate(createModels, force)
    end,
    Remove = function(self)
      self:RemoveModels()
      self:ResetBodygroups()
      self.isValid = false
    end,
    DataChanges = function(self, state)
      if not (self.isValid) then
        return 
      end
      if not IsValid(self:GetEntity()) then
        return 
      end
      self:Remap()
      local _exp_0 = state:GetKey()
      if 'ManeType' == _exp_0 then
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_MANE_UPPER, self:GetData():GetManeType())
      elseif 'ManeTypeLower' == _exp_0 then
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_MANE_LOWER, self:GetData():GetManeTypeLower())
      elseif 'TailType' == _exp_0 then
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_TAIL, self:GetData():GetTailType())
      elseif 'TailSize' == _exp_0 or 'PonySize' == _exp_0 then
        return self:UpdateTailSize()
      elseif 'EyelashType' == _exp_0 then
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_EYELASH, self:GetData():GetEyelashType())
      elseif 'Gender' == _exp_0 then
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_GENDER, self:GetData():GetGender())
      elseif 'SocksAsModel' == _exp_0 then
        if state:GetValue() then
          return self:CreateSocksModelIfNotExists()
        else
          if IsValid(self.socksModel) then
            return self.socksModel:Remove()
          end
        end
      elseif 'SocksAsNewModel' == _exp_0 then
        if state:GetValue() then
          return self:CreateNewSocksModelIfNotExists()
        else
          if IsValid(self.newSocksModel) then
            return self.newSocksModel:Remove()
          end
        end
      elseif 'Race' == _exp_0 then
        return self:ApplyRace()
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
      return PPM2.DebugPrint('Created new bodygroups controller for ', self:GetEntity(), ' as part of ', controller, '; internal ID is ', self.objID)
    end,
    __base = _base_0,
    __name = "DefaultBodygroupController",
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
    'models/ppm/player_default_base_nj.mdl'
  }
  self.BODYGROUP_SKELETON = 0
  self.BODYGROUP_GENDER = 1
  self.BODYGROUP_HORN = 2
  self.BODYGROUP_WINGS = 3
  self.BODYGROUP_MANE_UPPER = 4
  self.BODYGROUP_MANE_LOWER = 5
  self.BODYGROUP_TAIL = 6
  self.BODYGROUP_CMARK = 7
  self.BODYGROUP_EYELASH = 8
  self.NEXT_OBJ_ID = 0
  self.COOLDOWN_TIME = 5
  self.COOLDOWN_MAX_COUNT = 4
  self.BONE_MANE_1 = 'Mane01'
  self.BONE_MANE_2 = 'Mane02'
  self.BONE_MANE_3 = 'Mane03'
  self.BONE_MANE_4 = 'Mane04'
  self.BONE_MANE_5 = 'Mane05'
  self.BONE_MANE_6 = 'Mane06'
  self.BONE_MANE_7 = 'Mane07'
  self.BONE_MANE_8 = 'Mane03_tip'
  self.BONE_TAIL_1 = 'Tail01'
  self.BONE_TAIL_2 = 'Tail02'
  self.BONE_TAIL_3 = 'Tail03'
  self.BONE_SPINE_ROOT = 'LrigPelvis'
  self.BONE_SPINE = 'LrigSpine2'
  self.ATTACHMENT_EYES = 4
  self.ATTACHMENT_EYES_NAME = 'eyes'
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  DefaultBodygroupController = _class_0
end
local CPPMBodygroupController
do
  local _class_0
  local _parent_0 = DefaultBodygroupController
  local _base_0 = {
    ApplyRace = function(self)
      if not (self.isValid) then
        return 
      end
      local _exp_0 = self:GetData():GetRace()
      if PPM2.RACE_EARTH == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 1)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, 1)
      elseif PPM2.RACE_PEGASUS == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 1)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, 0)
      elseif PPM2.RACE_UNICORN == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 0)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, 1)
      elseif PPM2.RACE_ALICORN == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 2)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, 3)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "CPPMBodygroupController",
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
    'models/cppm/player_default_base.mdl',
    'models/cppm/player_default_base_nj.mdl'
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CPPMBodygroupController = _class_0
end
local NewBodygroupController
do
  local _class_0
  local _parent_0 = DefaultBodygroupController
  local _base_0 = {
    Remap = function(self)
      _class_0.__parent.__base.Remap(self)
      local mapping = {
        'EAR_L',
        'EAR_R',
        'WING_LEFT_1',
        'WING_LEFT_2',
        'WING_RIGHT_1',
        'WING_RIGHT_2',
        'WING_OPEN_LEFT',
        'WING_OPEN_RIGHT'
      }
      for _, name in ipairs(mapping) do
        self[name] = self:GetEntity():LookupBone(self.__class[name])
        if not self[name] then
          self.validSkeleton = false
        end
      end
    end,
    CreateUpperManeModel = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      if IsValid(self.maneModelUP) then
        return self.maneModelUP
      end
      for _, ent in ipairs(ents_GetAll()) do
        if ent.isPonyPropModel and ent.upperMane and ent.manePlayer == self:GetEntity() then
          self.maneModelUP = ent
          self:GetData():SetUpperManeModel(self.maneModelUP)
          PPM2.DebugPrint('Resuing ', self.maneModelUP, ' as upper mane model for ', self:GetEntity())
          return ent
        end
      end
      local modelID, bodygroupID = PPM2.TransformNewModelID(self:GetData():GetManeTypeNew())
      if modelID < 10 then
        modelID = "0" .. modelID
      end
      do
        local _with_0 = ClientsideModel("models/ppm/hair/ppm_manesetupper" .. tostring(modelID) .. ".mdl")
        self.maneModelUP = _with_0
        _with_0.isPonyPropModel = true
        _with_0.upperMane = true
        _with_0.manePlayer = self:GetEntity()
        if CLIENT then
          _with_0:DrawShadow(true)
        end
        _with_0:SetPos(self:GetEntity():EyePos())
        _with_0:Spawn()
        _with_0:Activate()
        if CLIENT then
          _with_0:SetNoDraw(true)
        end
        _with_0:SetBodygroup(1, bodygroupID)
        _with_0:SetParent(self:GetEntity())
        if SERVER then
          _with_0:Fire('SetParentAttachment', self.__class.ATTACHMENT_EYES_NAME)
        end
        _with_0:AddEffects(EF_BONEMERGE)
      end
      PPM2.DebugPrint('Creating new upper mane model for ', self:GetEntity(), ' as ', self.maneModelUP)
      if SERVER then
        timer.Simple(.5, function()
          if not (self.isValid) then
            return 
          end
          if not (IsValid(self.maneModelUP)) then
            return 
          end
          return self:GetData():SetUpperManeModel(self.maneModelUP)
        end)
      else
        self:GetData():SetUpperManeModel(self.maneModelUP)
      end
      return self.maneModelUP
    end,
    CreateLowerManeModel = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      if IsValid(self.maneModelLower) then
        return self.maneModelLower
      end
      for _, ent in ipairs(ents_GetAll()) do
        if ent.isPonyPropModel and ent.lowerMane and ent.manePlayer == self:GetEntity() then
          self.maneModelLower = ent
          self:GetData():SetLowerManeModel(self.maneModelLower)
          PPM2.DebugPrint('Resuing ', self.maneModelLower, ' as lower mane model for ', self:GetEntity())
          return ent
        end
      end
      local modelID, bodygroupID = PPM2.TransformNewModelID(self:GetData():GetManeTypeLowerNew())
      if modelID < 10 then
        modelID = "0" .. modelID
      end
      do
        local _with_0 = ClientsideModel("models/ppm/hair/ppm_manesetlower" .. tostring(modelID) .. ".mdl")
        self.maneModelLower = _with_0
        _with_0.isPonyPropModel = true
        _with_0.lowerMane = true
        _with_0.manePlayer = self:GetEntity()
        _with_0:DrawShadow(true)
        _with_0:SetPos(self:GetEntity():EyePos())
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:SetBodygroup(1, bodygroupID)
        _with_0:SetNoDraw(true)
        _with_0:SetParent(self:GetEntity())
        _with_0:AddEffects(EF_BONEMERGE)
      end
      PPM2.DebugPrint('Creating new lower mane model for ', self:GetEntity(), ' as ', self.maneModelLower)
      self:GetData():SetLowerManeModel(self.maneModelLower)
      return self.maneModelLower
    end,
    CreateTailModel = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      if IsValid(self.tailModel) then
        return self.tailModel
      end
      for _, ent in ipairs(ents_GetAll()) do
        if ent.isPonyPropModel and ent.isTail and ent.manePlayer == self:GetEntity() then
          self.tailModel = ent
          self:GetData():SetTailModel(self.tailModel)
          PPM2.DebugPrint('Resuing ', self.tailModel, ' as tail model for ', self:GetEntity())
          return ent
        end
      end
      local modelID, bodygroupID = PPM2.TransformNewModelID(self:GetData():GetTailTypeNew())
      if modelID < 10 then
        modelID = "0" .. modelID
      end
      do
        local _with_0 = ClientsideModel("models/ppm/hair/ppm_tailset" .. tostring(modelID) .. ".mdl")
        self.tailModel = _with_0
        _with_0.isPonyPropModel = true
        _with_0.isTail = true
        _with_0.manePlayer = self:GetEntity()
        _with_0:DrawShadow(true)
        _with_0:SetPos(self:GetEntity():EyePos())
        _with_0:Spawn()
        _with_0:Activate()
        _with_0:SetNoDraw(true)
        _with_0:SetBodygroup(1, bodygroupID)
        _with_0:SetParent(self:GetEntity())
        _with_0:AddEffects(EF_BONEMERGE)
      end
      PPM2.DebugPrint('Creating new tail model for ', self:GetEntity(), ' as ', self.tailModel)
      self:GetData():SetTailModel(self.tailModel)
      return self.tailModel
    end,
    CreateUpperManeModelIfNotExists = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not self:GetEntity():IsPony() then
        return NULL
      end
      if not IsValid(self.maneModelUP) then
        self:CreateUpperManeModel(force)
      end
      if IsValid(self.maneModelUP) then
        self:GetData():SetUpperManeModel(self.maneModelUP)
      end
      return self.maneModelUP
    end,
    CreateLowerManeModelIfNotExists = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not self:GetEntity():IsPony() then
        return NULL
      end
      if not IsValid(self.maneModelLower) then
        self:CreateLowerManeModel(force)
      end
      if IsValid(self.maneModelLower) then
        self:GetData():SetLowerManeModel(self.maneModelLower)
      end
      return self.maneModelLower
    end,
    CreateTailModelIfNotExists = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not self:GetEntity():IsPony() then
        return NULL
      end
      if not IsValid(self.tailModel) then
        self:CreateTailModel(force)
      end
      if IsValid(self.tailModel) then
        self:GetData():SetTailModel(self.tailModel)
      end
      return self.tailModel
    end,
    GetUpperMane = function(self)
      return self.maneModelUP or NULL
    end,
    GetLowerMane = function(self)
      return self.maneModelLower or NULL
    end,
    GetTail = function(self)
      return self.tailModel or NULL
    end,
    MergeModels = function(self, targetEnt)
      if targetEnt == nil then
        targetEnt = NULL
      end
      if not (self.isValid) then
        return 
      end
      _class_0.__parent.__base.MergeModels(self, targetEnt)
      if not (IsValid(targetEnt)) then
        return 
      end
      for _, e in ipairs({
        self:CreateUpperManeModelIfNotExists(true),
        self:CreateLowerManeModelIfNotExists(true),
        self:CreateTailModelIfNotExists(true)
      }) do
        if IsValid(e) then
          e:SetParent(targetEnt)
        end
      end
    end,
    UpdateUpperMane = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      self:CreateUpperManeModelIfNotExists(force)
      if not IsValid(self.maneModelUP) then
        return NULL
      end
      local modelID, bodygroupID = PPM2.TransformNewModelID(self:GetData():GetManeTypeNew())
      if modelID < 10 then
        modelID = "0" .. modelID
      end
      local model = "models/ppm/hair/ppm_manesetupper" .. tostring(modelID) .. ".mdl"
      do
        local _with_0 = self.maneModelUP
        if model ~= _with_0:GetModel() then
          _with_0:SetModel(model)
        end
        if _with_0:GetBodygroup(1) ~= bodygroupID then
          _with_0:SetBodygroup(1, bodygroupID)
        end
        if _with_0:GetParent() ~= self:GetEntity() and IsValid(self:GetEntity()) then
          _with_0:SetParent(self:GetEntity())
        end
      end
      self:GetData():SetUpperManeModel(self.maneModelUP)
      return self.maneModelUP
    end,
    UpdateLowerMane = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      self:CreateLowerManeModelIfNotExists(force)
      if not IsValid(self.maneModelLower) then
        return NULL
      end
      local modelID, bodygroupID = PPM2.TransformNewModelID(self:GetData():GetManeTypeLowerNew())
      if modelID < 10 then
        modelID = "0" .. modelID
      end
      local model = "models/ppm/hair/ppm_manesetlower" .. tostring(modelID) .. ".mdl"
      do
        local _with_0 = self.maneModelLower
        if model ~= _with_0:GetModel() then
          _with_0:SetModel(model)
        end
        if _with_0:GetBodygroup(1) ~= bodygroupID then
          _with_0:SetBodygroup(1, bodygroupID)
        end
        if IsValid(self:GetEntity()) then
          _with_0:SetParent(self:GetEntity())
        end
      end
      self:GetData():SetLowerManeModel(self.maneModelLower)
      return self.maneModelLower
    end,
    UpdateTailModel = function(self, force)
      if force == nil then
        force = false
      end
      if SERVER or not self.isValid or not IsValid(self:GetEntity()) or not force and self:GetEntity():IsDormant() or not self:GetEntity():IsPony() then
        return NULL
      end
      self:CreateTailModelIfNotExists(force)
      if not IsValid(self.tailModel) then
        return NULL
      end
      local modelID, bodygroupID = PPM2.TransformNewModelID(self:GetData():GetTailTypeNew())
      if modelID < 10 then
        modelID = "0" .. modelID
      end
      local model = "models/ppm/hair/ppm_tailset" .. tostring(modelID) .. ".mdl"
      do
        local _with_0 = self.tailModel
        if model ~= _with_0:GetModel() then
          _with_0:SetModel(model)
        end
        if _with_0:GetBodygroup(1) ~= bodygroupID then
          _with_0:SetBodygroup(1, bodygroupID)
        end
        if IsValid(self:GetEntity()) then
          _with_0:SetParent(self:GetEntity())
        end
      end
      self:GetData():SetTailModel(self.tailModel)
      return self.tailModel
    end,
    ResetWings = function(self)
      if SERVER then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      local ang, vec1, vec2 = Angle(0, 0, 0), LVector(1, 1, 1), LVector(0, 0, 0)
      for _, wing in ipairs({
        self.WING_LEFT_1,
        self.WING_LEFT_2,
        self.WING_RIGHT_1,
        self.WING_RIGHT_2,
        self.WING_OPEN_LEFT,
        self.WING_OPEN_RIGHT
      }) do
        do
          local _with_0 = self:GetEntity()
          _with_0:ManipulateBoneAngles2Safe(wing, ang)
          _with_0:ManipulateBoneScale2Safe(wing, vec1)
          _with_0:ManipulateBonePosition2Safe(wing, vec2)
        end
      end
    end,
    UpdateWings = function(self)
      if SERVER then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      if self:GetEntity().Alive and not self:GetEntity():Alive() then
        return 
      end
      local left = self:GetData():GetLWingSize() * LVector(1, 1, 1)
      local leftX = self:GetData():GetLWingX()
      local leftY = self:GetData():GetLWingY()
      local leftZ = self:GetData():GetLWingZ()
      local right = self:GetData():GetRWingSize() * LVector(1, 1, 1)
      local rightX = self:GetData():GetRWingX()
      local rightY = self:GetData():GetRWingY()
      local rightZ = self:GetData():GetRWingZ()
      local leftPos = LVector(leftX, leftY, leftZ)
      local rightPos = LVector(rightX, rightY, rightZ)
      do
        local _with_0 = self:GetEntity()
        _with_0:ManipulateBoneScale2Safe(self.WING_LEFT_1, left)
        _with_0:ManipulateBoneScale2Safe(self.WING_LEFT_2, left)
        _with_0:ManipulateBoneScale2Safe(self.WING_OPEN_LEFT, left)
        _with_0:ManipulateBoneScale2Safe(self.WING_RIGHT_1, right)
        _with_0:ManipulateBoneScale2Safe(self.WING_RIGHT_2, right)
        _with_0:ManipulateBoneScale2Safe(self.WING_OPEN_RIGHT, right)
        _with_0:ManipulateBonePosition2Safe(self.WING_LEFT_1, leftPos)
        _with_0:ManipulateBonePosition2Safe(self.WING_LEFT_2, leftPos)
        _with_0:ManipulateBonePosition2Safe(self.WING_OPEN_LEFT, leftPos)
        _with_0:ManipulateBonePosition2Safe(self.WING_RIGHT_1, rightPos)
        _with_0:ManipulateBonePosition2Safe(self.WING_RIGHT_2, rightPos)
        _with_0:ManipulateBonePosition2Safe(self.WING_OPEN_RIGHT, rightPos)
        return _with_0
      end
    end,
    UpdateEars = function(self)
      local vec = LVector(1, 1, 1) * self:GrabData('EarsSize')
      self:GetEntity():ManipulateBoneScale2Safe(self.EAR_L, vec)
      return self:GetEntity():ManipulateBoneScale2Safe(self.EAR_R, vec)
    end,
    ResetEars = function(self)
      local ang, vec1, vec2 = Angle(0, 0, 0), LVector(1, 1, 1), LVector(0, 0, 0)
      for _, part in ipairs({
        self.EAR_L,
        self.EAR_R
      }) do
        do
          local _with_0 = self:GetEntity()
          _with_0:ManipulateBoneAngles2Safe(part, ang)
          _with_0:ManipulateBoneScale2Safe(part, vec1)
          _with_0:ManipulateBonePosition2Safe(part, vec2)
        end
      end
    end,
    ResetBodygroups = function(self)
      if not (self.isValid) then
        return 
      end
      if not (IsValid(self:GetEntity())) then
        return 
      end
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_EYELASHES, 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE, 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_2, 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_BODY, 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_BAT_PONY_EARS, 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS, 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_CLAW_TEETH, 0)
      self:ResetWings()
      self:ResetEars()
      return _class_0.__parent.__base.ResetBodygroups(self)
    end,
    SlowUpdate = function(self, createModels, force)
      if createModels == nil then
        createModels = CLIENT
      end
      if force == nil then
        force = false
      end
      if not IsValid(self:GetEntity()) then
        return 
      end
      if not self:GetEntity():IsPony() then
        return 
      end
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_EYELASHES, self:GetData():GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
      local maleModifier = self:GetData():GetGender() == PPM2.GENDER_MALE and 1 or 0
      if self:GetData():GetNewMuzzle() then
        self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_2, maleModifier)
        self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE, 0)
      else
        self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_2, 0)
        self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE, maleModifier)
      end
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_BODY, maleModifier * self:GetData():GetMaleBuff())
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_BAT_PONY_EARS, self:GrabData('BatPonyEars') and self:GrabData('BatPonyEarsStrength') or 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_CLAW_TEETH, self:GrabData('ClawTeeth') and self:GrabData('ClawTeethStrength') or 0)
      self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_HOOF_FLUFF, self:GrabData('HoofFluffers') and self:GrabData('HoofFluffersStrength') or 0)
      if self:GrabData('Fangs') then
        if self:GrabData('AlternativeFangs') then
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS, 0)
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS2, self:GrabData('FangsStrength'))
        else
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS, self:GrabData('FangsStrength'))
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS2, 0)
        end
      else
        self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS, 0)
        self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS2, 0)
      end
      self:ApplyRace()
      if createModels then
        self:UpdateUpperMane(force)
        self:UpdateLowerMane(force)
        self:UpdateTailModel(force)
        if createModels and self:GetData():GetSocksAsModel() then
          self:CreateSocksModelIfNotExists(force)
        end
        if createModels and self:GetData():GetSocksAsNewModel() then
          return self:CreateNewSocksModelIfNotExists(force)
        end
      end
    end,
    RemoveModels = function(self)
      if IsValid(self.maneModelUP) then
        self.maneModelUP:Remove()
      end
      if IsValid(self.maneModelLower) then
        self.maneModelLower:Remove()
      end
      if IsValid(self.tailModel) then
        self.tailModel:Remove()
      end
      return _class_0.__parent.__base.RemoveModels(self)
    end,
    ApplyBodygroups = function(self, createModels, force)
      if createModels == nil then
        createModels = CLIENT
      end
      if force == nil then
        force = false
      end
      if not (self.isValid) then
        return 
      end
      if not IsValid(self:GetEntity()) then
        return 
      end
      self:ResetBodygroups()
      if not self:GetEntity():IsPony() then
        return self:RemoveModels()
      end
      return self:SlowUpdate(createModels, force)
    end,
    SelectWingsType = function(self)
      local wtype = self:GetData():GetWingsType()
      if (self:GetData():GetFly() or self:GetEntity().GetMoveType and self:GetEntity():GetMoveType() == MOVETYPE_NOCLIP) and (not self:GetEntity().InVehicle or not self:GetEntity():InVehicle()) then
        wtype = wtype + (PPM2.MAX_WINGS + 1)
      end
      return wtype
    end,
    ApplyRace = function(self)
      if not (self.isValid) then
        return 
      end
      if not IsValid(self:GetEntity()) then
        return 
      end
      local _exp_0 = self:GetData():GetRace()
      if PPM2.RACE_EARTH == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 1)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
      elseif PPM2.RACE_PEGASUS == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 1)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, self:SelectWingsType())
      elseif PPM2.RACE_UNICORN == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 0)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
      elseif PPM2.RACE_ALICORN == _exp_0 then
        self:GetEntity():SetBodygroup(self.__class.BODYGROUP_HORN, 0)
        return self:GetEntity():SetBodygroup(self.__class.BODYGROUP_WINGS, self:SelectWingsType())
      end
    end,
    DataChanges = function(self, state)
      if not (self.isValid) then
        return 
      end
      if not IsValid(self:GetEntity()) then
        return 
      end
      self:Remap()
      local _exp_0 = state:GetKey()
      if 'EyelashType' == _exp_0 then
        return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_EYELASHES, self:GetData():GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
      elseif 'Gender' == _exp_0 then
        local maleModifier = self:GetData():GetGender() == PPM2.GENDER_MALE and 1 or 0
        if self:GetData():GetNewMuzzle() then
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_2, maleModifier)
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE, 0)
        else
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_2, 0)
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE, maleModifier)
        end
        return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_BODY, maleModifier * self:GetData():GetMaleBuff())
      elseif 'Fly' == _exp_0 then
        return self:ApplyRace()
      elseif 'NewMuzzle' == _exp_0 then
        local maleModifier = self:GetData():GetGender() == PPM2.GENDER_MALE and 1 or 0
        if self:GetData():GetNewMuzzle() then
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_2, maleModifier)
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE, 0)
        else
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_2, 0)
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE, maleModifier)
        end
        return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_BODY, maleModifier * self:GetData():GetMaleBuff())
      elseif 'BatPonyEars' == _exp_0 or 'BatPonyEarsStrength' == _exp_0 then
        return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_BAT_PONY_EARS, self:GrabData('BatPonyEars') and self:GrabData('BatPonyEarsStrength') or 0)
      elseif 'Fangs' == _exp_0 or 'AlternativeFangs' == _exp_0 or 'FangsStrength' == _exp_0 then
        if self:GrabData('Fangs') then
          if self:GrabData('AlternativeFangs') then
            self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS, 0)
            return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS2, self:GrabData('FangsStrength'))
          else
            self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS, self:GrabData('FangsStrength'))
            return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS2, 0)
          end
        else
          self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS, 0)
          return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_FANGS2, 0)
        end
      elseif 'EarFluffers' == _exp_0 or 'EarFluffersStrength' == _exp_0 then
        return self:UpdateEars()
      elseif 'HoofFluffers' == _exp_0 or 'HoofFluffersStrength' == _exp_0 then
        return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_HOOF_FLUFF, self:GrabData('HoofFluffers') and self:GrabData('HoofFluffersStrength') or 0)
      elseif 'ClawTeeth' == _exp_0 or 'ClawTeethStrength' == _exp_0 then
        return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_CLAW_TEETH, self:GrabData('ClawTeeth') and self:GrabData('ClawTeethStrength') or 0)
      elseif 'ManeTypeNew' == _exp_0 then
        if CLIENT then
          return self:UpdateUpperMane()
        end
      elseif 'ManeTypeLowerNew' == _exp_0 then
        if CLIENT then
          return self:UpdateLowerMane()
        end
      elseif 'TailSize' == _exp_0 or 'TailTypeNew' == _exp_0 then
        self:UpdateTailModel()
        return self:UpdateTailSize()
      elseif 'PonySize' == _exp_0 then
        return self:UpdateTailSize()
      elseif 'Race' == _exp_0 then
        return self:ApplyRace()
      elseif 'WingsType' == _exp_0 then
        return self:ApplyRace()
      elseif 'LWingSize' == _exp_0 or 'RWingSize' == _exp_0 or 'LWingX' == _exp_0 or 'RWingX' == _exp_0 or 'LWingY' == _exp_0 or 'RWingY' == _exp_0 or 'LWingZ' == _exp_0 or 'RWingZ' == _exp_0 then
        return self:UpdateWings()
      elseif 'MaleBuff' == _exp_0 then
        local maleModifier = self:GetData():GetGender() == PPM2.GENDER_MALE and 1 or 0
        return self:GetEntity():SetFlexWeight(self.__class.FLEX_ID_MALE_BODY, maleModifier * self:GetData():GetMaleBuff())
      elseif 'SocksAsModel' == _exp_0 then
        if SERVER then
          return 
        end
        if state:GetValue() then
          return self:CreateSocksModelIfNotExists()
        else
          if IsValid(self.socksModel) then
            return self.socksModel:Remove()
          end
        end
      elseif 'SocksAsNewModel' == _exp_0 then
        if state:GetValue() then
          return self:CreateNewSocksModelIfNotExists()
        else
          if IsValid(self.newSocksModel) then
            return self.newSocksModel:Remove()
          end
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "NewBodygroupController",
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
  self.BODYGROUP_SKELETON = 0
  self.BODYGROUP_GENDER = -1
  self.BODYGROUP_HORN = 1
  self.BODYGROUP_WINGS = 2
  self.EAR_L = 'Ear_L'
  self.EAR_R = 'Ear_R'
  self.WING_LEFT_1 = 'wing_l'
  self.WING_LEFT_2 = 'wing_l_bat'
  self.WING_RIGHT_1 = 'wing_r'
  self.WING_RIGHT_2 = 'wing_r_bat'
  self.WING_OPEN_LEFT = 'wing_open_l'
  self.WING_OPEN_RIGHT = 'wing_open_r'
  self.BONE_SPINE = 'LrigSpine1'
  self.FLEX_ID_EYELASHES = 16
  self.FLEX_ID_MALE = 25
  self.FLEX_ID_MALE_2 = 35
  self.FLEX_ID_MALE_BODY = 36
  self.FLEX_ID_BAT_PONY_EARS = 28
  self.FLEX_ID_FANGS = 31
  self.FLEX_ID_FANGS2 = 29
  self.FLEX_ID_CLAW_TEETH = 30
  self.FLEX_ID_HOOF_FLUFF = 26
  self.NOCLIP_ANIMATIONS = {
    9,
    10,
    11
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  NewBodygroupController = _class_0
end
if CLIENT then
  hook.Add('PPM2.SetupBones', 'PPM2.Bodygroups', function(ent, data)
    do
      local bodygroup = data:GetBodygroupController()
      if bodygroup then
        bodygroup.ent = ent
        bodygroup:UpdateBack()
        bodygroup:UpdateTailSize()
        bodygroup:UpdateManeSize()
        if bodygroup.UpdateWings then
          bodygroup:UpdateWings()
        end
        if bodygroup.UpdateEars then
          bodygroup:UpdateEars()
        end
        bodygroup.lastPAC3BoneReset = RealTimeL() + 1
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
            local bodygroup = data:GetBodygroupController()
            if bodygroup then
              bodygroup:ResetTail()
              bodygroup:ResetMane()
              bodygroup:ResetBack()
            end
          end
        end
      end
    end
  end
  cvars.AddChangeCallback('ppm2_sv_allow_resize', ppm2_sv_allow_resize, 'PPM2.Bodygroups')
else
  hook.Add('PlayerNoClip', 'PPM2.WingsCheck', function(self)
    return timer.Simple(0, function()
      if not IsValid(self) then
        return 
      end
      do
        local data = self:GetPonyData()
        if data then
          do
            local bg = data:GetBodygroupController()
            if bg then
              return bg:SlowUpdate()
            end
          end
        end
      end
    end)
  end)
end
PPM2.CPPMBodygroupController = CPPMBodygroupController
PPM2.DefaultBodygroupController = DefaultBodygroupController
PPM2.GetBodygroupController = function(model)
  if model == nil then
    model = 'models/ppm/player_default_base.mdl'
  end
  return DefaultBodygroupController.AVALIABLE_CONTROLLERS[model:lower()] or DefaultBodygroupController
end
