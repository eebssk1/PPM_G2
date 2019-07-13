local Lerp
Lerp = function(byVal, fromValue, intoValue)
  local delta = intoValue - fromValue
  if delta < 0 and delta > -0.025 then
    return intoValue
  elseif delta > 0 and delta < 0.025 then
    return intoValue
  end
  return fromValue + delta * byVal
end
do
  local _class_0
  local _base_0 = {
    RegisterModifier = function(self, modifName, def, calculateStart)
      if modifName == nil then
        modifName = 'MyModifier'
      end
      if def == nil then
        def = 0
      end
      if calculateStart == nil then
        calculateStart = 0
      end
      local iName = modifName .. 'Modifiers'
      for _, data in ipairs(self.CUSTOM_MODIFIERS) do
        if data.name == modifName then
          data.def = def
          return 
        end
      end
      local targetTable = {
        name = modifName,
        def = def,
        iName = iName,
        clamp = function(val)
          return val
        end,
        clampFinal = function(val)
          return val
        end,
        lerpFunc = Lerp,
        calculateStart = calculateStart
      }
      if type(def) ~= 'function' then
        targetTable.def = (function()
          return def
        end)
      end
      if type(calculateStart) ~= 'function' then
        targetTable.calculateStart = (function()
          return calculateStart
        end)
      end
      table.insert(self.CUSTOM_MODIFIERS, targetTable)
      self[iName] = { }
      self['SetModifier' .. modifName] = function(self, modifID, val)
        if val == nil then
          val = 0
        end
        if not modifID then
          return 
        end
        if not self[iName][modifID] then
          return 
        end
        self[iName][modifID] = targetTable.clamp(val)
      end
      self['GetModifier' .. modifName] = function(self, modifID, val)
        if val == nil then
          val = 0
        end
        if not modifID then
          return 
        end
        if targetTable.isLerped then
          return self[targetTable.iNameLerp][modifID]
        else
          return self[iName][modifID]
        end
      end
      self['GetRawModifier' .. modifName] = function(self, modifID, val)
        if val == nil then
          val = 0
        end
        if not modifID then
          return 
        end
        return self[iName][modifID]
      end
      self['Calculate' .. modifName] = function(self, inputAdd)
        local calc = targetTable.calculateStart()
        if inputAdd then
          calc = calc + inputAdd
        end
        if targetTable.isLerped and self[targetTable.iNameLerp] then
          for i, modif in ipairs(self[targetTable.iNameLerp]) do
            calc = calc + modif
          end
        elseif self[iName] then
          for i, modif in ipairs(self[iName]) do
            calc = calc + modif
          end
        end
        return targetTable.clampFinal(calc)
      end
    end,
    SetModifierMinMax = function(self, modifName, mins, maxs)
      if modifName == nil then
        modifName = 'MyModifier'
      end
      for _, data in ipairs(self.CUSTOM_MODIFIERS) do
        if data.name == modifName then
          data.mins = mins
          data.maxs = maxs
          if not mins and not maxs then
            data.clamp = function(val)
              return val
            end
          elseif not mins then
            data.clamp = function(val)
              return math.min(val, maxs)
            end
          elseif not maxs then
            data.clamp = function(val)
              return math.max(val, mins)
            end
          else
            data.clamp = function(val)
              return math.Clamp(val, mins, maxs)
            end
          end
          return true
        end
      end
      return false
    end,
    SetModifierMinMaxFinal = function(self, modifName, mins, maxs)
      if modifName == nil then
        modifName = 'MyModifier'
      end
      for _, data in ipairs(self.CUSTOM_MODIFIERS) do
        if data.name == modifName then
          data.minsFinal = mins
          data.maxsFinal = maxs
          if not mins and not maxs then
            data.clampFinal = function(val)
              return val
            end
          elseif not mins then
            data.clampFinal = function(val)
              return math.min(val, maxs)
            end
          elseif not maxs then
            data.clampFinal = function(val)
              return math.max(val, mins)
            end
          else
            data.clamp = function(val)
              return math.Clamp(val, mins, maxs)
            end
          end
          return true
        end
      end
      return false
    end,
    SetupLerpTables = function(self, modifName)
      if modifName == nil then
        modifName = 'MyModifier'
      end
      for _, data in ipairs(self.CUSTOM_MODIFIERS) do
        if data.name == modifName then
          data.isLerped = true
          do
            local _tbl_0 = { }
            for k, v in pairs(self[data.iName]) do
              _tbl_0[k] = v
            end
            data.lerpTable = _tbl_0
          end
          data.iNameLerp = data.iName .. 'Lerp'
          self[data.iNameLerp] = data.lerpTable
          return true, data.lerpTable
        end
      end
      return false
    end,
    SetLerpFunc = function(self, modifName, func)
      if modifName == nil then
        modifName = 'MyModifier'
      end
      if func == nil then
        func = Lerp
      end
      for _, data in ipairs(self.CUSTOM_MODIFIERS) do
        if data.name == modifName then
          data.lerpFunc = func
          return true
        end
      end
      return false
    end,
    TriggerLerp = function(self, modifName, lerpBy)
      if modifName == nil then
        modifName = 'MyModifier'
      end
      if lerpBy == nil then
        lerpBy = 0.5
      end
      for _, modif in ipairs(self.CUSTOM_MODIFIERS) do
        if modif.name == modifName then
          for id = 1, #self[modif.iNameLerp] do
            if self[modif.iNameLerp][id] ~= self[modif.iName][id] then
              self[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, self[modif.iNameLerp][id], self[modif.iName][id])
            end
          end
          return true
        end
      end
      for _, modif in ipairs(self.__class.MODIFIERS) do
        if modif.name == modifName then
          for id = 1, #self[modif.iNameLerp] do
            if self[modif.iNameLerp][id] ~= self[modif.iName][id] then
              self[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, self[modif.iNameLerp][id], self[modif.iName][id])
            end
          end
          return true
        end
      end
      return false
    end,
    TriggerLerpAll = function(self, lerpBy)
      if lerpBy == nil then
        lerpBy = 0.5
      end
      local outputTriggered = { }
      for _, modif in ipairs(self.CUSTOM_MODIFIERS) do
        if modif.iNameLerp then
          for id = 1, #self[modif.iNameLerp] do
            if self[modif.iNameLerp][id] ~= self[modif.iName][id] then
              self[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, self[modif.iNameLerp][id], self[modif.iName][id])
              table.insert(outputTriggered, {
                modif.name,
                self[modif.iNameLerp][id]
              })
            end
          end
        end
      end
      for _, modif in ipairs(self.__class.MODIFIERS) do
        if modif.iNameLerp then
          for id = 1, #self[modif.iNameLerp] do
            if self[modif.iNameLerp][id] ~= self[modif.iName][id] then
              self[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, self[modif.iNameLerp][id], self[modif.iName][id])
              table.insert(outputTriggered, {
                modif.name,
                self[modif.iNameLerp][id]
              })
            end
          end
        end
      end
      return outputTriggered
    end,
    ClearModifiers = function(self)
      for _, modif in ipairs(self.CUSTOM_MODIFIERS) do
        self[modif.iName] = nil
        self['SetModifier' .. modif.name] = nil
        self['Calculate' .. modif.name] = nil
      end
      self.CUSTOM_MODIFIERS = { }
    end,
    GetModifierID = function(self, name)
      if name == nil then
        name = ''
      end
      if self.modifiersNames[name] then
        return self.modifiersNames[name]
      end
      self.nextModifierID = self.nextModifierID + 1
      local id = self.nextModifierID
      self.modifiersNames[name] = id
      for _, modif in ipairs(self.__class.MODIFIERS) do
        self[modif.iName][id] = modif.def()
      end
      for _, modif in ipairs(self.__class.MODIFIERS) do
        if modif.iNameLerp then
          self[modif.iNameLerp][id] = modif.def()
        end
      end
      for _, modif in ipairs(self.CUSTOM_MODIFIERS) do
        self[modif.iName][id] = modif.def()
      end
      for _, modif in ipairs(self.CUSTOM_MODIFIERS) do
        if modif.iNameLerp then
          self[modif.iNameLerp][id] = modif.def()
        end
      end
      return id
    end,
    ResetModifiers = function(self, name, hard)
      if name == nil then
        name = ''
      end
      if hard == nil then
        hard = false
      end
      if not self.modifiersNames[name] then
        return false
      end
      local id = self.modifiersNames[name]
      for _, modif in ipairs(self.__class.MODIFIERS) do
        self[modif.iName][id] = modif.def()
      end
      for _, modif in ipairs(self.CUSTOM_MODIFIERS) do
        self[modif.iName][id] = modif.def()
      end
      if hard then
        for _, modif in ipairs(self.__class.MODIFIERS) do
          if modif.iNameLerp then
            self[modif.iNameLerp][id] = modif.def()
          end
        end
        for _, modif in ipairs(self.CUSTOM_MODIFIERS) do
          if modif.iNameLerp then
            self[modif.iNameLerp][id] = modif.def()
          end
        end
      end
      return true
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.CUSTOM_MODIFIERS = { }
      for _, modif in ipairs(self.__class.MODIFIERS) do
        self[modif.iName] = { }
        if modif.iNameLerp then
          self[modif.iNameLerp] = { }
        end
      end
      self.modifiersNames = { }
      self.nextModifierID = 0
    end,
    __base = _base_0,
    __name = "ModifierBase"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.MODIFIERS = { }
  self.SetupModifiers = function(self) end
  self.__inherited = function(self, child)
    child.MODIFIERS = { }
    return child:SetupModifiers()
  end
  self.RegisterModifier = function(self, modifName, def, calculateStart)
    if modifName == nil then
      modifName = 'MyModifier'
    end
    if def == nil then
      def = 0
    end
    if calculateStart == nil then
      calculateStart = 0
    end
    local iName = modifName .. 'Modifiers'
    for _, data in ipairs(self.MODIFIERS) do
      if data.name == modifName then
        data.def = def
        return 
      end
    end
    local targetTable = {
      name = modifName,
      def = def,
      iName = iName,
      clamp = function(val)
        return val
      end,
      clampFinal = function(val)
        return val
      end,
      lerpFunc = Lerp,
      calculateStart = calculateStart
    }
    if type(def) ~= 'function' then
      targetTable.def = (function()
        return def
      end)
    end
    if type(calculateStart) ~= 'function' then
      targetTable.calculateStart = (function()
        return calculateStart
      end)
    end
    table.insert(self.MODIFIERS, targetTable)
    self.__base['SetModifier' .. modifName] = function(self, modifID, val)
      if val == nil then
        val = 0
      end
      if not modifID then
        return 
      end
      if not self[iName][modifID] then
        return 
      end
      self[iName][modifID] = targetTable.clamp(val)
    end
    self.__base['GetModifier' .. modifName] = function(self, modifID, val)
      if val == nil then
        val = 0
      end
      if not modifID then
        return 
      end
      if targetTable.isLerped then
        return self[targetTable.iNameLerp][modifID]
      else
        return self[iName][modifID]
      end
    end
    self.__base['Calculate' .. modifName] = function(self, inputAdd)
      local calc = targetTable.calculateStart()
      if inputAdd then
        calc = calc + inputAdd
      end
      if targetTable.isLerped and self[targetTable.iNameLerp] then
        for _, modif in ipairs(self[targetTable.iNameLerp]) do
          calc = calc + modif
        end
      elseif self[iName] then
        for _, modif in ipairs(self[iName]) do
          calc = calc + modif
        end
      end
      return targetTable.clampFinal(calc)
    end
  end
  self.SetModifierMinMax = function(self, modifName, mins, maxs)
    if modifName == nil then
      modifName = 'MyModifier'
    end
    for _, data in ipairs(self.MODIFIERS) do
      if data.name == modifName then
        data.mins = mins
        data.maxs = maxs
        if not mins and not maxs then
          data.clamp = function(val)
            return val
          end
        elseif not mins then
          data.clamp = function(val)
            return math.min(val, maxs)
          end
        elseif not maxs then
          data.clamp = function(val)
            return math.max(val, mins)
          end
        else
          data.clamp = function(val)
            return math.Clamp(val, mins, maxs)
          end
        end
        return true
      end
    end
    return false
  end
  self.SetModifierMinMaxFinal = function(self, modifName, mins, maxs)
    if modifName == nil then
      modifName = 'MyModifier'
    end
    for _, data in ipairs(self.MODIFIERS) do
      if data.name == modifName then
        data.minsFinal = mins
        data.maxsFinal = maxs
        if not mins and not maxs then
          data.clampFinal = function(val)
            return val
          end
        elseif not mins then
          data.clampFinal = function(val)
            return math.min(val, maxs)
          end
        elseif not maxs then
          data.clampFinal = function(val)
            return math.max(val, mins)
          end
        else
          data.clampFinal = function(val)
            return math.Clamp(val, mins, maxs)
          end
        end
        return true
      end
    end
    return false
  end
  self.SetupLerpTables = function(self, modifName)
    if modifName == nil then
      modifName = 'MyModifier'
    end
    for _, data in ipairs(self.MODIFIERS) do
      if data.name == modifName then
        data.isLerped = true
        data.iNameLerp = data.iName .. 'Lerp'
        return true
      end
    end
    return false
  end
  self.SetLerpFunc = function(self, modifName, func)
    if modifName == nil then
      modifName = 'MyModifier'
    end
    if func == nil then
      func = Lerp
    end
    for _, data in ipairs(self.MODIFIERS) do
      if data.name == modifName then
        data.lerpFunc = func
        return true
      end
    end
    return false
  end
  self.ClearModifiers = function(self)
    for _, modif in ipairs(self.MODIFIERS) do
      self.__base['SetModifier' .. modif.name] = nil
      self.__base['Calculate' .. modif.name] = nil
    end
    self.MODIFIERS = { }
  end
  PPM2.ModifierBase = _class_0
  return _class_0
end
