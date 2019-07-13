local PPM2
PPM2 = _G.PPM2
local PonyWeightController
do
  local _class_0
  local extrabones
  local _parent_0 = PPM2.ControllerChildren
  local _base_0 = {
    Remap = function(self)
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, _des_0 in ipairs(self.__class.WEIGHT_BONES) do
          local id, scale
          id, scale = _des_0.id, _des_0.scale
          _accum_0[_len_0] = {
            id = self:GetEntity():LookupBone(id),
            scale = scale
          }
          _len_0 = _len_0 + 1
        end
        self.WEIGHT_BONES = _accum_0
      end
      self.validSkeleton = true
      for _, _des_0 in ipairs(self.WEIGHT_BONES) do
        local id
        id = _des_0.id
        if not id then
          self.validSkeleton = false
          break
        end
      end
    end,
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.objID) .. "|" .. tostring(self:GetData()) .. "]"
    end,
    IsValid = function(self)
      return IsValid(self:GetEntity()) and self.isValid
    end,
    GetEntity = function(self)
      return self.controller:GetEntity()
    end,
    GetData = function(self)
      return self.controller
    end,
    GetController = function(self)
      return self.controller
    end,
    GetModel = function(self)
      return self.controller:GetModel()
    end,
    PlayerDeath = function(self)
      self:ResetBones()
      return self:Remap()
    end,
    PlayerRespawn = function(self)
      self:Remap()
      return self:UpdateWeight()
    end,
    DataChanges = function(self, state)
      if not IsValid(self:GetEntity()) or not self.isValid then
        return 
      end
      self:Remap()
      if state:GetKey() == 'Weight' then
        self:SetWeight(state:GetValue())
      end
      if state:GetKey() == 'PonySize' then
        return self:SetSize(state:GetValue())
      end
    end,
    SetWeight = function(self, weight)
      if weight == nil then
        weight = 1
      end
      self.weight = math.Clamp(weight, self.__class.HARD_LIMIT_MINIMAL, self.__class.HARD_LIMIT_MAXIMAL)
    end,
    SetSize = function(self, scale)
      if scale == nil then
        scale = 1
      end
      self.scale = math.Clamp(math.sqrt(scale), self.__class.HARD_LIMIT_MINIMAL, self.__class.HARD_LIMIT_MAXIMAL)
    end,
    SlowUpdate = function(self) end,
    ResetBones = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not IsValid(ent) or not self.isValid then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      for _, _des_0 in ipairs(self.WEIGHT_BONES) do
        local id
        id = _des_0.id
        ent:ManipulateBoneScale2Safe(id, self.__class.DEFAULT_BONE_SIZE)
      end
    end,
    Reset = function(self)
      return self:ResetBones()
    end,
    UpdateWeight = function(self, ent)
      if ent == nil then
        ent = self:GetEntity()
      end
      if not IsValid(ent) or not self.isValid then
        return 
      end
      if not self:GetEntity():IsPony() then
        return 
      end
      if self:GetEntity().Alive and not self:GetEntity():Alive() then
        return 
      end
      if not self.validSkeleton then
        return 
      end
      for _, _des_0 in ipairs(self.WEIGHT_BONES) do
        local id, scale
        id, scale = _des_0.id, _des_0.scale
        local delta = 1 + (self.weight * self.scale - 1) * scale
        ent:ManipulateBoneScale2Safe(id, LVector(delta, delta, delta))
      end
    end,
    Remove = function(self)
      self.isValid = false
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller, applyWeight)
      if applyWeight == nil then
        applyWeight = true
      end
      self.isValid = true
      self.controller = controller
      self.objID = self.__class.NEXT_OBJ_ID
      self.__class.NEXT_OBJ_ID = self.__class.NEXT_OBJ_ID + 1
      self.lastPAC3BoneReset = 0
      self.scale = 1
      self:SetWeight(controller:GetWeight())
      self:Remap()
      if IsValid(self:GetEntity()) and applyWeight then
        self:UpdateWeight()
      end
      return PPM2.DebugPrint('Created new weight controller for ', self:GetEntity(), ' as part of ', data, '; internal ID is ', self.objID)
    end,
    __base = _base_0,
    __name = "PonyWeightController",
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
  self.HARD_LIMIT_MINIMAL = 0.1
  self.HARD_LIMIT_MAXIMAL = 3
  self.DEFAULT_BONE_SIZE = LVector(1, 1, 1)
  self.NEXT_OBJ_ID = 0
  self.WEIGHT_BONES = {
    {
      id = 'LrigPelvis',
      scale = 1.1
    },
    {
      id = 'LrigSpine1',
      scale = 0.7
    },
    {
      id = 'LrigSpine2',
      scale = 0.7
    },
    {
      id = 'LrigRibcage',
      scale = 0.7
    }
  }
  extrabones = {
    'Lrig_LEG_BL_Femur',
    'Lrig_LEG_BL_Tibia',
    'Lrig_LEG_BL_LargeCannon',
    'Lrig_LEG_BL_PhalanxPrima',
    'Lrig_LEG_BL_RearHoof',
    'Lrig_LEG_BR_Femur',
    'Lrig_LEG_BR_Tibia',
    'Lrig_LEG_BR_LargeCannon',
    'Lrig_LEG_BR_PhalanxPrima',
    'Lrig_LEG_BR_RearHoof',
    'Lrig_LEG_FL_Scapula',
    'Lrig_LEG_FL_Humerus',
    'Lrig_LEG_FL_Radius',
    'Lrig_LEG_FL_Metacarpus',
    'Lrig_LEG_FL_PhalangesManus',
    'Lrig_LEG_FL_FrontHoof',
    'Lrig_LEG_FR_Scapula',
    'Lrig_LEG_FR_Humerus',
    'Lrig_LEG_FR_Radius',
    'Lrig_LEG_FR_Metacarpus',
    'Lrig_LEG_FR_PhalangesManus',
    'Lrig_LEG_FR_FrontHoof'
  }
  for _, name in ipairs(extrabones) do
    table.insert(self.WEIGHT_BONES, {
      id = name,
      scale = 1
    })
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PonyWeightController = _class_0
end
do
  local reset
  reset = function(ent, data)
    do
      local weight = data:GetWeightController()
      if weight then
        weight.ent = ent
        return weight:UpdateWeight()
      end
    end
  end
  hook.Add('PPM2.SetupBones', 'PPM2.Weight', reset, -2)
end
local NewPonyWeightController
do
  local _class_0
  local _parent_0 = PonyWeightController
  local _base_0 = {
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.objID) .. "|" .. tostring(self:GetData()) .. "]"
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "NewPonyWeightController",
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
  self.WEIGHT_BONES = {
    {
      id = 'LrigPelvis',
      scale = 1.1
    },
    {
      id = 'Lrig_LEG_BL_Femur',
      scale = 0.7
    },
    {
      id = 'Lrig_LEG_BR_Femur',
      scale = 0.7
    },
    {
      id = 'LrigSpine1',
      scale = 0.7
    },
    {
      id = 'LrigSpine2',
      scale = 0.7
    },
    {
      id = 'LrigRibcage',
      scale = 0.7
    },
    {
      id = 'Lrig_LEG_FL_Scapula',
      scale = 0.7
    },
    {
      id = 'Lrig_LEG_FR_Scapula',
      scale = 0.7
    },
    {
      id = 'Lrig_LEG_BL_RearHoof',
      scale = 0.9
    },
    {
      id = 'Lrig_LEG_BR_RearHoof',
      scale = 0.9
    },
    {
      id = 'Lrig_LEG_FL_FrontHoof',
      scale = 0.9
    },
    {
      id = 'Lrig_LEG_FR_FrontHoof',
      scale = 0.9
    },
    {
      id = 'Lrig_LEG_BL_Tibia',
      scale = 1
    },
    {
      id = 'Lrig_LEG_BL_LargeCannon',
      scale = 1
    },
    {
      id = 'Lrig_LEG_BL_PhalanxPrima',
      scale = 1
    },
    {
      id = 'Lrig_LEG_BR_Femur',
      scale = 1
    },
    {
      id = 'Lrig_LEG_BR_Tibia',
      scale = 1
    },
    {
      id = 'Lrig_LEG_BR_LargeCannon',
      scale = 1
    },
    {
      id = 'Lrig_LEG_BR_PhalanxPrima',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FL_Humerus',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FL_Radius',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FL_Metacarpus',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FL_PhalangesManus',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FR_Humerus',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FR_Radius',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FR_Metacarpus',
      scale = 1
    },
    {
      id = 'Lrig_LEG_FR_PhalangesManus',
      scale = 1
    },
    {
      id = 'LrigNeck1',
      scale = 1
    },
    {
      id = 'LrigNeck2',
      scale = 1
    },
    {
      id = 'LrigNeck3',
      scale = 1
    }
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  NewPonyWeightController = _class_0
end
PPM2.PonyWeightController = PonyWeightController
PPM2.NewPonyWeightController = NewPonyWeightController
PPM2.GetPonyWeightController = function(model)
  if model == nil then
    model = ''
  end
  return PonyWeightController.AVALIABLE_CONTROLLERS[model] or PonyWeightController
end
