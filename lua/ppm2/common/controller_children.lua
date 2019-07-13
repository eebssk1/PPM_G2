do
  local _class_0
  local _parent_0 = PPM2.SequenceHolder
  local _base_0 = {
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.objID) .. "|" .. tostring(self:GetEntity()) .. "]"
    end,
    IsValid = function(self)
      return self.isValid and IsValid(self:GetEntity())
    end,
    GetData = function(self)
      return self.nwController
    end,
    GrabData = function(self, str, ...)
      return self.nwController['Get' .. str](self.nwController, ...)
    end,
    GetEntity = function(self)
      return self.controller:GetEntity()
    end,
    GetEntityID = function(self)
      return self.entID
    end,
    GetDataID = function(self)
      return self.entID
    end,
    GetObjectSlot = function(self)
      return self.nwController:GetObjectSlot()
    end,
    ObjectSlot = function(self)
      return self.nwController:ObjectSlot()
    end,
    RemoveFunc = function(self) end,
    Remove = function(self)
      if not self.isValid then
        return false
      end
      _class_0.__parent.__base.Remove(self)
      self:RemoveFunc()
      return true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, controller)
      _class_0.__parent.__init(self)
      assert(controller, 'You can not create a children without controller.')
      self.entID = controller.entID
      self.controller = controller
      self.nwController = controller
      self.objID = self.__class.NEXT_OBJ_ID
      self.__class.NEXT_OBJ_ID = self.__class.NEXT_OBJ_ID + 1
      self.lastPAC3BoneReset = 0
    end,
    __base = _base_0,
    __name = "ControllerChildren",
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
  self.MODELS = { }
  self.__inherited = function(self, child)
    _class_0.__parent.__inherited(self, child)
    do
      local _tbl_0 = { }
      for _, mod in ipairs(child.MODELS) do
        _tbl_0[mod] = true
      end
      child.MODELS_HASH = _tbl_0
    end
    child.NEXT_OBJ_ID = 0
    if not child.AVALIABLE_CONTROLLERS then
      return 
    end
    do
      local _tbl_0 = { }
      for _, mod in ipairs(child.MODELS) do
        _tbl_0[mod] = true
      end
      child.MODELS_HASH = _tbl_0
    end
    for _, mod in ipairs(child.MODELS) do
      child.AVALIABLE_CONTROLLERS[mod] = child
    end
  end
  self.SelectController = function(self, model)
    if model == nil then
      model = 'models/ppm/player_default_base.mdl'
    end
    return self.AVALIABLE_CONTROLLERS[model:lower()] or self
  end
  self.NEXT_OBJ_ID = 0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PPM2.ControllerChildren = _class_0
  return _class_0
end
