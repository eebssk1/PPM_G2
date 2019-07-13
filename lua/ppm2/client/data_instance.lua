file.CreateDir('ppm2')
file.CreateDir('ppm2/backups')
file.CreateDir('ppm2/thumbnails')
for _, ffind in ipairs(file.Find('ppm2/*.txt', 'DATA')) do
  local fTarget = ffind:sub(1, -5)
  if not file.Exists('ppm2/' .. fTarget .. '.dat', 'DATA') then
    local fRead = file.Read('ppm2/' .. ffind, 'DATA')
    local json = util.JSONToTable(fRead)
    if json then
      local TagCompound = DLib.NBT.TagCompound()
      for key, value in pairs(json) do
        local _exp_0 = luatype(value)
        if 'string' == _exp_0 then
          TagCompound:AddString(key, value)
        elseif 'number' == _exp_0 then
          TagCompound:AddFloat(key, value)
        elseif 'boolean' == _exp_0 then
          TagCompound:AddByte(key, value and 1 or 0)
        elseif 'table' == _exp_0 then
          if value.r and value.g and value.b and value.a then
            TagCompound:AddByteArray(key, {
              value.r - 128,
              value.g - 128,
              value.b - 128,
              value.a - 128
            })
          end
        else
          error(luatype(value))
        end
      end
      local buf = DLib.BytesBuffer()
      TagCompound:WriteFile(buf)
      local stream = file.Open('ppm2/' .. fTarget .. '.dat', 'wb', 'DATA')
      buf:ToFileStream(stream)
      stream:Flush()
      stream:Close()
    end
  end
  file.Delete('ppm2/' .. ffind)
end
local PonyDataInstance
do
  local _class_0
  local _base_0 = {
    WriteNetworkData = function(self)
      for _, _des_0 in ipairs(PPM2.NetworkedPonyData.NW_Vars) do
        local strName, writeFunc, getName, defValue
        strName, writeFunc, getName, defValue = _des_0.strName, _des_0.writeFunc, _des_0.getName, _des_0.defValue
        if self["Get" .. tostring(getName)] then
          writeFunc(self["Get" .. tostring(getName)](self))
        else
          writeFunc(defValue)
        end
      end
    end,
    Copy = function(self, fileName)
      if fileName == nil then
        fileName = self.filename
      end
      local copyOfData = { }
      for key, val in pairs(self.dataTable) do
        local _exp_0 = luatype(val)
        if 'number' == _exp_0 or 'string' == _exp_0 or 'boolean' == _exp_0 then
          copyOfData[key] = val
        elseif 'table' == _exp_0 or 'Color' == _exp_0 then
          if IsColor(val) then
            copyOfData[key] = Color(val)
          else
            copyOfData[key] = Color(255, 255, 255)
          end
        end
      end
      local newData = self.__class(fileName, copyOfData, false)
      return newData
    end,
    CreateCustomNetworkObject = function(self, goingToNetwork, ply, ...)
      if goingToNetwork == nil then
        goingToNetwork = false
      end
      if ply == nil then
        ply = LocalPlayer()
      end
      local newData = PPM2.NetworkedPonyData(nil, ply)
      newData:SetIsGoingToNetwork(goingToNetwork)
      self:ApplyDataToObject(newData, ...)
      return newData
    end,
    CreateNetworkObject = function(self, goingToNetwork, ...)
      if goingToNetwork == nil then
        goingToNetwork = true
      end
      local newData = PPM2.NetworkedPonyData(nil, LocalPlayer())
      newData:SetIsGoingToNetwork(goingToNetwork)
      self:ApplyDataToObject(newData, ...)
      return newData
    end,
    ApplyDataToObject = function(self, target, ...)
      for key, value in pairs(self:GetAsNetworked()) do
        if not target["Set" .. tostring(key)] then
          error("Attempt to apply data to object " .. tostring(target) .. " at unknown index " .. tostring(key) .. "!")
        end
        target["Set" .. tostring(key)](target, value, ...)
      end
    end,
    UpdateController = function(self, ...)
      return self:ApplyDataToObject(self.nwObj, ...)
    end,
    CreateController = function(self, ...)
      return self:CreateNetworkObject(false, ...)
    end,
    CreateCustomController = function(self, ...)
      return self:CreateCustomNetworkObject(false, ...)
    end,
    Reset = function(self)
      for k, _des_0 in pairs(self.__class.PONY_DATA) do
        local getFunc
        getFunc = _des_0.getFunc
        self['Reset' .. getFunc](self)
      end
    end,
    GetSaveOnChange = function(self)
      return self.saveOnChange
    end,
    SaveOnChange = function(self)
      return self.saveOnChange
    end,
    SetSaveOnChange = function(self, val)
      if val == nil then
        val = true
      end
      self.saveOnChange = val
    end,
    GetValueFromNBT = function(self, mapData, value)
      if mapData.enum and type(value) == 'string' then
        return mapData.fix(mapData.enumMappingBackward[value:upper()])
      elseif mapData.type == 'COLOR' then
        if IsColor(value) then
          return mapData.fix(Color(value))
        else
          return mapData.fix(Color(value[1] + 128, value[2] + 128, value[3] + 128, value[4] + 128))
        end
      elseif mapData.type == 'BOOLEAN' then
        if type(value) == 'boolean' then
          return mapData.fix(value)
        else
          return mapData.fix(value == 1)
        end
      else
        return mapData.fix(value)
      end
    end,
    GetExtraBackupPath = function(self)
      return tostring(self.__class.DATA_DIR_BACKUP) .. tostring(self.filename) .. "_bak_" .. tostring(os.date('%S_%M_%H-%d_%m_%Y', os.time())) .. ".dat"
    end,
    SetupData = function(self, data, force, doBackup)
      if data == nil then
        data = self.NBTTagCompound
      end
      if force == nil then
        force = false
      end
      if doBackup == nil then
        doBackup = false
      end
      if luatype(data) == 'NBTCompound' then
        data = data:GetValue()
      end
      if doBackup or not force then
        local makeBackup = false
        for key, value2 in pairs(data) do
          key = key:lower()
          local map = self.__class.PONY_DATA_MAPPING[key]
          if map then
            local mapData = self.__class.PONY_DATA[map]
            local value = self:GetValueFromNBT(mapData, value2)
            if mapData.enum then
              if luatype(value) == 'string' and not mapData.enumMappingBackward[value:upper()] or luatype(value) == 'number' and not mapData.enumMapping[value] then
                if not force then
                  return self.__class.ERR_MISSING_CONTENT
                end
                makeBackup = true
                break
              end
            end
          end
        end
        if doBackup and makeBackup and self.exists then
          local fRead = file.Read(self.fpath, 'DATA')
          file.Write(self:GetExtraBackupPath(), fRead)
        end
      end
      for key, value2 in pairs(data) do
        local _continue_0 = false
        repeat
          key = key:lower()
          local map = self.__class.PONY_DATA_MAPPING[key]
          if not (map) then
            _continue_0 = true
            break
          end
          local mapData = self.__class.PONY_DATA[map]
          self.dataTable[key] = self:GetValueFromNBT(mapData, value2)
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
    end,
    ValueChanges = function(self, key, oldVal, newVal, saveNow)
      if saveNow == nil then
        saveNow = self.exists and self.saveOnChange
      end
      if self.nwObj and self.updateNWObject then
        local getFunc
        getFunc = self.__class.PONY_DATA[key].getFunc
        self.nwObj["Set" .. tostring(getFunc)](self.nwObj, newVal, self.networkNWObject)
      end
      if saveNow then
        return self:Save()
      end
    end,
    SetFilename = function(self, filename)
      self.filename = filename
      self.filenameFull = tostring(filename) .. ".dat"
      self.fpath = tostring(self.__class.DATA_DIR) .. tostring(filename) .. ".dat"
      self.preview = tostring(self.__class.DATA_DIR) .. "thumbnails/" .. tostring(filename) .. ".png"
      self.fpathFull = "data/" .. tostring(self.__class.DATA_DIR) .. tostring(filename) .. ".dat"
      self.isOpen = self.filename ~= nil
      self.exists = file.Exists(self.fpath, 'DATA')
      return self.exists
    end,
    SetNetworkData = function(self, nwObj)
      self.nwObj = nwObj
    end,
    SetPonyData = function(self, nwObj)
      self.nwObj = nwObj
    end,
    SetPonyDataController = function(self, nwObj)
      self.nwObj = nwObj
    end,
    SetPonyController = function(self, nwObj)
      self.nwObj = nwObj
    end,
    SetController = function(self, nwObj)
      self.nwObj = nwObj
    end,
    SetDataController = function(self, nwObj)
      self.nwObj = nwObj
    end,
    SetNetworkOnChange = function(self, newVal)
      if newVal == nil then
        newVal = true
      end
      self.networkNWObject = newVal
    end,
    SetUpdateOnChange = function(self, newVal)
      if newVal == nil then
        newVal = true
      end
      self.updateNWObject = newVal
    end,
    GetNetworkOnChange = function(self)
      return self.networkNWObject
    end,
    GetUpdateOnChange = function(self)
      return self.updateNWObject
    end,
    GetNetworkData = function(self)
      return self.nwObj
    end,
    GetPonyData = function(self)
      return self.nwObj
    end,
    GetPonyDataController = function(self)
      return self.nwObj
    end,
    GetPonyController = function(self)
      return self.nwObj
    end,
    GetController = function(self)
      return self.nwObj
    end,
    GetDataController = function(self)
      return self.nwObj
    end,
    IsValid = function(self)
      return self.valid
    end,
    Exists = function(self)
      return self.exists
    end,
    FileExists = function(self)
      return self.exists
    end,
    IsExists = function(self)
      return self.exists
    end,
    GetFileName = function(self)
      return self.filename
    end,
    GetFilename = function(self)
      return self.filename
    end,
    GetFileNameFull = function(self)
      return self.filenameFull
    end,
    GetFilenameFull = function(self)
      return self.filenameFull
    end,
    GetFilePath = function(self)
      return self.fpath
    end,
    GetFullFilePath = function(self)
      return self.fpathFull
    end,
    SerealizeValue = function(self, valID)
      if valID == nil then
        valID = ''
      end
      local map = self.__class.PONY_DATA[valID]
      if not (map) then
        return 
      end
      local val = self.dataTable[valID]
      if map.enum then
        return DLib.NBT.TagString(map.enumMapping[val] or map.enumMapping[map.default()])
      elseif map.serealize then
        return map.serealize(val)
      else
        local _exp_0 = map.type
        if 'INT' == _exp_0 then
          return DLib.NBT.TagInt(val)
        elseif 'FLOAT' == _exp_0 then
          return DLib.NBT.TagFloat(val)
        elseif 'URL' == _exp_0 then
          return DLib.NBT.TagString(val)
        elseif 'BOOLEAN' == _exp_0 then
          return DLib.NBT.TagByte(val and 1 or 0)
        elseif 'COLOR' == _exp_0 then
          return DLib.NBT.TagByteArray({
            val.r - 128,
            val.g - 128,
            val.b - 128,
            val.a - 128
          })
        end
      end
    end,
    GetAsNetworked = function(self)
      local _tbl_0 = { }
      for k, _des_0 in pairs(self.__class.PONY_DATA) do
        local getFunc
        getFunc = _des_0.getFunc
        _tbl_0[getFunc] = self.dataTable[k]
      end
      return _tbl_0
    end,
    ReadFromDisk = function(self, force, doBackup)
      if force == nil then
        force = false
      end
      if doBackup == nil then
        doBackup = true
      end
      if not (self.exists) then
        return self.__class.ERR_FILE_NOT_EXISTS
      end
      local fRead = file.Read(self.fpath, 'DATA')
      if not fRead or fRead == '' then
        return self.__class.ERR_FILE_EMPTY
      end
      self.NBTTagCompound:ReadFile(DLib.BytesBuffer(fRead))
      return self:SetupData(self.NBTTagCompound, force, doBackup) or self.__class.READ_SUCCESS
    end,
    SaveAs = function(self, path)
      if path == nil then
        path = self.fpath
      end
      for key, val in pairs(self.dataTable) do
        self.NBTTagCompound:AddTag(key, self:SerealizeValue(key))
      end
      local buf = DLib.BytesBuffer()
      self.NBTTagCompound:WriteFile(buf)
      local stream = file.Open(path, 'wb', 'DATA')
      buf:ToFileStream(stream)
      stream:Flush()
      stream:Close()
      return buf
    end,
    SavePreview = function(self, path)
      if path == nil then
        path = self.preview
      end
      local buildingModel = ClientsideModel('models/ppm/ppm2_stage.mdl', RENDERGROUP_OTHER)
      buildingModel:SetNoDraw(true)
      buildingModel:SetModelScale(0.9)
      local model = ClientsideModel('models/ppm/player_default_base_new_nj.mdl')
      do
        model:SetNoDraw(true)
        local data = self:CreateCustomController(model)
        model.__PPM2_PonyData = data
        local ctrl = data:GetRenderController()
        do
          local bg = data:GetBodygroupController()
          if bg then
            bg:ApplyBodygroups()
          end
        end
        do
          local _with_0 = model:PPMBonesModifier()
          _with_0:ResetBones()
          hook.Call('PPM2.SetupBones', nil, model, data)
          _with_0:Think(true)
        end
        model:SetSequence(22)
        model:FrameAdvance(0)
      end
      return timer.Simple(0.5, function()
        local renderTarget = GetRenderTarget('ppm2_save_preview_generate2', 1024, 1024, false)
        renderTarget:Download()
        render.PushRenderTarget(renderTarget)
        render.Clear(0, 0, 0, 255, true, true)
        cam.Start3D(Vector(49.373046875, -35.021484375, 58.332901000977), Angle(0, 141, 0), 90, 0, 0, 1024, 1024)
        buildingModel:DrawModel()
        do
          local data = model.__PPM2_PonyData
          local ctrl = data:GetRenderController()
          do
            local bg = data:GetBodygroupController()
            if bg then
              bg:ApplyBodygroups()
            end
          end
          do
            local _with_0 = model:PPMBonesModifier()
            _with_0:ResetBones()
            hook.Call('PPM2.SetupBones', nil, model, data)
            _with_0:Think(true)
          end
          do
            ctrl:DrawModels()
            ctrl:HideModels(true)
            ctrl:PreDraw(model, true)
          end
          model:DrawModel()
          ctrl:PostDraw(model, true)
        end
        cam.End3D()
        local data = render.Capture({
          format = 'png',
          x = 0,
          y = 0,
          w = 1024,
          h = 1024,
          alpha = false
        })
        model:Remove()
        buildingModel:Remove()
        file.Write(path, data)
        return render.PopRenderTarget()
      end)
    end,
    Save = function(self, doBackup, preview)
      if doBackup == nil then
        doBackup = true
      end
      if preview == nil then
        preview = true
      end
      if doBackup and self.exists then
        file.Write(self:GetExtraBackupPath(), file.Read(self.fpath, 'DATA'))
      end
      local buf = self:SaveAs(self.fpath)
      if preview then
        self:SavePreview(self.preview)
      end
      self.exists = true
      return buf
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, filename, data, readIfExists, force, doBackup)
      if readIfExists == nil then
        readIfExists = true
      end
      if force == nil then
        force = false
      end
      if doBackup == nil then
        doBackup = true
      end
      self:SetFilename(filename)
      self.NBTTagCompound = DLib.NBT.TagCompound()
      self.updateNWObject = true
      self.networkNWObject = true
      self.valid = self.isOpen
      self.rawData = data
      do
        local _tbl_0 = { }
        for k, _des_0 in pairs(self.__class.PONY_DATA) do
          local default
          default = _des_0.default
          _tbl_0[k] = default()
        end
        self.dataTable = _tbl_0
      end
      self.saveOnChange = true
      if data then
        return self:SetupData(data, true)
      elseif self.exists and readIfExists then
        return self:ReadFromDisk(force, doBackup)
      end
    end,
    __base = _base_0,
    __name = "PonyDataInstance"
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
  self.DATA_DIR = "ppm2/"
  self.DATA_DIR_BACKUP = "ppm2/backups/"
  self.FindFiles = function(self)
    local output
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _, str in ipairs(file.Find(self.DATA_DIR .. '*', 'DATA')) do
        if not str:find('.bak.dat') then
          _accum_0[_len_0] = str:sub(1, #str - 4)
          _len_0 = _len_0 + 1
        end
      end
      output = _accum_0
    end
    return output
  end
  self.FindInstances = function(self)
    local output
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _, str in ipairs(file.Find(self.DATA_DIR .. '*', 'DATA')) do
        if not str:find('.bak.dat') then
          _accum_0[_len_0] = self(str:sub(1, #str - 4))
          _len_0 = _len_0 + 1
        end
      end
      output = _accum_0
    end
    return output
  end
  self.PONY_DATA = PPM2.PonyDataRegistry
  do
    local _tbl_0 = { }
    for key, _des_0 in pairs(self.PONY_DATA) do
      local getFunc
      getFunc = _des_0.getFunc
      _tbl_0[getFunc:lower()] = key
    end
    self.PONY_DATA_MAPPING = _tbl_0
  end
  for key, value in pairs(self.PONY_DATA) do
    self.PONY_DATA_MAPPING[key] = key
  end
  for key, data in pairs(self.PONY_DATA) do
    local _continue_0 = false
    repeat
      if not (data.enum) then
        _continue_0 = true
        break
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, arg in ipairs(data.enum) do
          _accum_0[_len_0] = arg:upper()
          _len_0 = _len_0 + 1
        end
        data.enum = _accum_0
      end
      data.enumMapping = { }
      data.enumMappingBackward = { }
      local i = -1
      for _, enumVal in ipairs(data.enum) do
        i = i + 1
        data.enumMapping[i] = enumVal
        data.enumMappingBackward[enumVal] = i
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  for key, _des_0 in pairs(self.PONY_DATA) do
    local getFunc, fix, enumMappingBackward, enumMapping, enum, min, max, default
    getFunc, fix, enumMappingBackward, enumMapping, enum, min, max, default = _des_0.getFunc, _des_0.fix, _des_0.enumMappingBackward, _des_0.enumMapping, _des_0.enum, _des_0.min, _des_0.max, _des_0.default
    self.__base["Get" .. tostring(getFunc)] = function(self)
      return self.dataTable[key]
    end
    self.__base["GetMin" .. tostring(getFunc)] = function(self)
      if min then
        return min
      end
    end
    self.__base["GetMax" .. tostring(getFunc)] = function(self)
      if max then
        return max
      end
    end
    self.__base["Enum" .. tostring(getFunc)] = function(self)
      if enum then
        return enum
      end
    end
    self.__base["Get" .. tostring(getFunc) .. "Types"] = function(self)
      if enum then
        return enum
      end
    end
    self["GetMin" .. tostring(getFunc)] = function(self)
      if min then
        return min
      end
    end
    self["GetMax" .. tostring(getFunc)] = function(self)
      if max then
        return max
      end
    end
    self["GetDefault" .. tostring(getFunc)] = default
    self["GetEnum" .. tostring(getFunc)] = function(self)
      if enum then
        return enum
      end
    end
    self["Enum" .. tostring(getFunc)] = function(self)
      if enum then
        return enum
      end
    end
    if enumMapping then
      self.__base["Get" .. tostring(getFunc) .. "Enum"] = function(self)
        return enumMapping[self.dataTable[key]] or enumMapping[0] or self.dataTable[key]
      end
      self.__base["GetEnum" .. tostring(getFunc)] = self.__base["Get" .. tostring(getFunc) .. "Enum"]
    end
    self.__base["Reset" .. tostring(getFunc)] = function(self)
      return self["Set" .. tostring(getFunc)](self, default())
    end
    self.__base["Set" .. tostring(getFunc)] = function(self, val, ...)
      if val == nil then
        val = defValue
      end
      if luatype(val) == 'string' and enumMappingBackward then
        local newVal = enumMappingBackward[val:upper()]
        if newVal then
          val = newVal
        end
      end
      local newVal = fix(val)
      local oldVal = self.dataTable[key]
      self.dataTable[key] = newVal
      return self:ValueChanges(key, oldVal, newVal, ...)
    end
  end
  self.ERR_MISSING_PARAMETER = 4
  self.ERR_MISSING_CONTENT = 5
  self.READ_SUCCESS = 0
  self.ERR_FILE_NOT_EXISTS = 1
  self.ERR_FILE_EMPTY = 2
  self.ERR_FILE_CORRUPT = 3
  PonyDataInstance = _class_0
end
PPM2.PonyDataInstance = PonyDataInstance
PPM2.MainDataInstance = nil
PPM2.GetMainData = function()
  if not PPM2.MainDataInstance then
    PPM2.MainDataInstance = PonyDataInstance('_current', nil, true, true)
    if not PPM2.MainDataInstance:FileExists() then
      PPM2.MainDataInstance:Save()
    end
  end
  return PPM2.MainDataInstance
end
