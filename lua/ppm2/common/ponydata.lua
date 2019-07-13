do
  local _class_0
  local _base_0 = {
    GetPlayer = function(self)
      return self.ply
    end,
    ChangedByClient = function(self)
      return not self.networkChange or IsValid(self.ply)
    end,
    ChangedByPlayer = function(self)
      return not self.networkChange or IsValid(self.ply)
    end,
    ChangedByServer = function(self)
      return not self.networkChange or not IsValid(self.ply)
    end,
    GetKey = function(self)
      return self.keyValid
    end,
    GetVariable = function(self)
      return self.keyValid
    end,
    GetVar = function(self)
      return self.keyValid
    end,
    GetKeyInternal = function(self)
      return self.key
    end,
    GetVariableInternal = function(self)
      return self.key
    end,
    GetVarInternal = function(self)
      return self.key
    end,
    GetNewValue = function(self)
      return self.newValue
    end,
    GetValue = function(self)
      return self.newValue
    end,
    GetCantApply = function(self)
      return self.cantApply
    end,
    SetCantApply = function(self, val)
      self.cantApply = val
    end,
    NewValue = function(self)
      return self.newValue
    end,
    GetOldValue = function(self)
      return self.oldValue
    end,
    OldValue = function(self)
      return self.oldValue
    end,
    CurTime = function(self)
      return self.time
    end,
    GetCurTime = function(self)
      return self.time
    end,
    GetReceiveTime = function(self)
      return self.time
    end,
    GetReceiveStamp = function(self)
      return self.time
    end,
    RealTimeL = function(self)
      return self.rtime
    end,
    GetRealTimeL = function(self)
      return self.rtime
    end,
    SysTime = function(self)
      return self.stime
    end,
    GetSysTime = function(self)
      return self.stime
    end,
    GetObject = function(self)
      return self.obj
    end,
    GetNWObject = function(self)
      return self.obj
    end,
    GetNetworkedObject = function(self)
      return self.obj
    end,
    GetLength = function(self)
      return self.rlen
    end,
    GetRealLength = function(self)
      return self.len
    end,
    ChangedByNetwork = function(self)
      return self.networkChange
    end,
    Revert = function(self)
      if not self.cantApply then
        self.obj[self.key] = self.oldValue
      end
    end,
    Apply = function(self)
      if not self.cantApply then
        self.obj[self.key] = self.newValue
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, key, keyValid, newValue, obj, len, ply)
      if key == nil then
        key = ''
      end
      if keyValid == nil then
        keyValid = ''
      end
      if len == nil then
        len = 24
      end
      if ply == nil then
        ply = NULL
      end
      self.key = key
      self.keyValid = keyValid
      self.oldValue = obj[key]
      self.newValue = newValue
      self.ply = ply
      self.time = CurTimeL()
      self.rtime = RealTimeL()
      self.stime = SysTime()
      self.obj = obj
      self.objID = obj.netID
      self.len = len
      self.rlen = len - 24
      self.cantApply = false
      self.networkChange = true
    end,
    __base = _base_0,
    __name = "NetworkChangeState"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  PPM2.NetworkChangeState = _class_0
end
for _, ent in ipairs(ents.GetAll()) do
  if ent.__PPM2_PonyData then
    ent.__PPM2_PonyData:Remove()
  end
end
local wUInt
wUInt = function(def, size)
  if def == nil then
    def = 0
  end
  if size == nil then
    size = 8
  end
  return function(arg)
    if arg == nil then
      arg = def
    end
    return net.WriteUInt(arg, size)
  end
end
local wInt
wInt = function(def, size)
  if def == nil then
    def = 0
  end
  if size == nil then
    size = 8
  end
  return function(arg)
    if arg == nil then
      arg = def
    end
    return net.WriteInt(arg, size)
  end
end
local rUInt
rUInt = function(size, min, max)
  if size == nil then
    size = 8
  end
  if min == nil then
    min = 0
  end
  if max == nil then
    max = 255
  end
  return function()
    return math.Clamp(net.ReadUInt(size), min, max)
  end
end
local rInt
rInt = function(size, min, max)
  if size == nil then
    size = 8
  end
  if min == nil then
    min = -128
  end
  if max == nil then
    max = 127
  end
  return function()
    return math.Clamp(net.ReadInt(size), min, max)
  end
end
local rFloat
rFloat = function(min, max)
  if min == nil then
    min = 0
  end
  if max == nil then
    max = 255
  end
  return function()
    return math.Clamp(net.ReadFloat(), min, max)
  end
end
local wFloat = net.WriteFloat
local rBool = net.ReadBool
local wBool = net.WriteBool
local rColor = net.ReadColor
local wColor = net.WriteColor
local rString = net.ReadString
local wString = net.WriteString
local NetworkedPonyData
do
  local _class_0
  local _parent_0 = PPM2.ModifierBase
  local _base_0 = {
    GetEntity = function(self)
      return self.ent
    end,
    IsValid = function(self)
      return self.isValid
    end,
    GetModel = function(self)
      return self.modelCached
    end,
    EntIndex = function(self)
      return self.entID
    end,
    ObjectSlot = function(self)
      return self.slotID
    end,
    GetObjectSlot = function(self)
      return self.slotID
    end,
    Clone = function(self, target)
      if target == nil then
        target = self.ent
      end
      local copy = self.__class(nil, target)
      self:ApplyDataToObject(copy)
      return copy
    end,
    SetupEntity = function(self, ent)
      if ent.__PPM2_PonyData then
        if ent.__PPM2_PonyData:GetOwner() and IsValid(ent.__PPM2_PonyData:GetOwner()) and ent.__PPM2_PonyData:GetOwner() ~= self:GetOwner() then
          return 
        end
        if ent.__PPM2_PonyData.Remove and ent.__PPM2_PonyData ~= self then
          ent.__PPM2_PonyData:Remove()
        end
      end
      ent.__PPM2_PonyData = self
      self.entTable = self.ent:GetTable()
      if not (IsValid(ent)) then
        return 
      end
      self.modelCached = ent:GetModel()
      ent:PPMBonesModifier()
      self.flightController = PPM2.PonyflyController(self)
      self.entID = ent:EntIndex()
      self.lastLerpThink = RealTimeL()
      self:ModelChanges(self.modelCached, self.modelCached)
      self:Reset()
      if CLIENT then
        timer.Simple(0, function()
          if self:GetRenderController() then
            return self:GetRenderController():CompileTextures()
          end
        end)
      end
      PPM2.DebugPrint('Ponydata ', self, ' was updated to use for ', self.ent)
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, task in pairs(self.__class.NW_Objects) do
          if task:IsValid() and IsValid(task.ent) and not task.ent:IsPlayer() and not task:GetDisableTask() then
            _accum_0[_len_0] = task
            _len_0 = _len_0 + 1
          end
        end
        self.__class.RenderTasks = _accum_0
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, task in pairs(self.__class.NW_Objects) do
          if task:IsValid() and IsValid(task.ent) and not task:GetDisableTask() then
            _accum_0[_len_0] = task
            _len_0 = _len_0 + 1
          end
        end
        self.__class.CheckTasks = _accum_0
      end
    end,
    ModelChanges = function(self, old, new)
      if old == nil then
        old = self.ent:GetModel()
      end
      if new == nil then
        new = old
      end
      self.modelCached = new
      if SERVER then
        self:SetFly(false)
      end
      return timer.Simple(0.5, function()
        if not (IsValid(self.ent)) then
          return 
        end
        return self:Reset()
      end)
    end,
    GenericDataChange = function(self, state)
      hook.Run('PPM2_PonyDataChanges', self.ent, self, state)
      if state:GetKey() == 'Fly' and self.flightController then
        self.flightController:Switch(state:GetValue())
      end
      if state:GetKey() == 'DisableTask' then
        do
          local _accum_0 = { }
          local _len_0 = 1
          for i, task in pairs(self.__class.NW_Objects) do
            if task:IsValid() and IsValid(task.ent) and not task.ent:IsPlayer() and not task:GetDisableTask() then
              _accum_0[_len_0] = task
              _len_0 = _len_0 + 1
            end
          end
          self.__class.RenderTasks = _accum_0
        end
        do
          local _accum_0 = { }
          local _len_0 = 1
          for i, task in pairs(self.__class.NW_Objects) do
            if task:IsValid() and IsValid(task.ent) and not task:GetDisableTask() then
              _accum_0[_len_0] = task
              _len_0 = _len_0 + 1
            end
          end
          self.__class.CheckTasks = _accum_0
        end
      end
      if self.ent and self:GetBodygroupController() then
        self:GetSizeController():DataChanges(state)
      end
      if self.ent and self:GetBodygroupController() then
        self:GetBodygroupController():DataChanges(state)
      end
      if self.ent and self:GetWeightController() then
        self:GetWeightController():DataChanges(state)
      end
      if CLIENT and self.ent then
        if self:GetRenderController() then
          return self:GetRenderController():DataChanges(state)
        end
      end
    end,
    ResetScale = function(self)
      do
        local scale = self:GetSizeController()
        if scale then
          return scale:ResetScale()
        end
      end
    end,
    ModifyScale = function(self)
      do
        local scale = self:GetSizeController()
        if scale then
          return scale:ModifyScale()
        end
      end
    end,
    Reset = function(self)
      do
        local scale = self:GetSizeController()
        if scale then
          scale:Reset()
        end
      end
      if CLIENT then
        if self:GetWeightController() and self:GetWeightController().Reset then
          self:GetWeightController():Reset()
        end
        if self:GetRenderController() and self:GetRenderController().Reset then
          self:GetRenderController():Reset()
        end
        if self:GetBodygroupController() and self:GetBodygroupController().Reset then
          return self:GetBodygroupController():Reset()
        end
      end
    end,
    GetHoofstepVolume = function(self)
      if self:ShouldMuffleHoosteps() then
        return 0.8
      end
      return 1
    end,
    ShouldMuffleHoosteps = function(self)
      return self:GetSocksAsModel() or self:GetSocksAsNewModel()
    end,
    PlayerRespawn = function(self)
      if not IsValid(self.ent) then
        return 
      end
      self.entTable.__cachedIsPony = self.ent:IsPony()
      if not self.entTable.__cachedIsPony then
        if self.alreadyCalledRespawn then
          return 
        end
        self.alreadyCalledRespawn = true
        self.alreadyCalledDeath = true
      else
        self.alreadyCalledRespawn = false
        self.alreadyCalledDeath = false
      end
      self:ApplyBodygroups(CLIENT, true)
      if SERVER then
        self:SetFly(false)
      end
      self.ent:PPMBonesModifier()
      do
        local scale = self:GetSizeController()
        if scale then
          scale:PlayerRespawn()
        end
      end
      do
        local weight = self:GetWeightController()
        if weight then
          weight:PlayerRespawn()
        end
      end
      if CLIENT then
        self.deathRagdollMerged = false
        if self:GetRenderController() then
          self:GetRenderController():PlayerRespawn()
        end
        if IsValid(self.ent) and self:GetBodygroupController().MergeModels then
          return self:GetBodygroupController():MergeModels(self.ent)
        end
      end
    end,
    PlayerDeath = function(self)
      if not IsValid(self.ent) then
        return 
      end
      if self.ent.__ppmBonesModifiers then
        self.ent.__ppmBonesModifiers:Remove()
      end
      self.entTable.__cachedIsPony = self.ent:IsPony()
      if not self.entTable.__cachedIsPony then
        if self.alreadyCalledDeath then
          return 
        end
        self.alreadyCalledDeath = true
      else
        self.alreadyCalledDeath = false
      end
      if SERVER then
        self:SetFly(false)
      end
      do
        local scale = self:GetSizeController()
        if scale then
          scale:PlayerDeath()
        end
      end
      do
        local weight = self:GetWeightController()
        if weight then
          weight:PlayerDeath()
        end
      end
      if CLIENT then
        self:DoRagdollMerge()
        if self:GetRenderController() then
          return self:GetRenderController():PlayerDeath()
        end
      end
    end,
    DoRagdollMerge = function(self)
      if self.deathRagdollMerged then
        return 
      end
      local bgController = self:GetBodygroupController()
      local rag = self.ent:GetRagdollEntity()
      if not bgController.MergeModels then
        self.deathRagdollMerged = true
      elseif IsValid(rag) then
        self.deathRagdollMerged = true
        return bgController:MergeModels(rag)
      end
    end,
    ApplyBodygroups = function(self, updateModels)
      if updateModels == nil then
        updateModels = CLIENT
      end
      if self.ent then
        return self:GetBodygroupController():ApplyBodygroups(updateModels)
      end
    end,
    SetLocalChange = function(self, state)
      return self:GenericDataChange(state)
    end,
    NetworkDataChanges = function(self, state)
      return self:GenericDataChange(state)
    end,
    SlowUpdate = function(self)
      if self:GetBodygroupController() then
        self:GetBodygroupController():SlowUpdate()
      end
      if self:GetWeightController() then
        self:GetWeightController():SlowUpdate()
      end
      do
        local scale = self:GetSizeController()
        if scale then
          return scale:SlowUpdate()
        end
      end
    end,
    Think = function(self) end,
    RenderScreenspaceEffects = function(self)
      local time = RealTimeL()
      local delta = time - self.lastLerpThink
      self.lastLerpThink = time
      if self.isValid and IsValid(self.ent) then
        for _, change in ipairs(self:TriggerLerpAll(delta * 5)) do
          local state = PPM2.NetworkChangeState('_NW_' .. change[1], change[1], change[2] + self['_NW_' .. change[1]], self)
          state:SetCantApply(true)
          self:GenericDataChange(state)
        end
      end
    end,
    GetFlightController = function(self)
      return self.flightController
    end,
    GetRenderController = function(self)
      if SERVER then
        return 
      end
      if not self.isValid then
        return self.renderController
      end
      if not self.renderController or self.modelCached ~= self.modelRender then
        self.modelRender = self.modelCached
        local cls = PPM2.GetRenderController(self.modelCached)
        if self.renderController and cls == self.renderController.__class then
          self.renderController.ent = self.ent
          PPM2.DebugPrint('Skipping render controller recreation for ', self.ent, ' as part of ', self)
          return self.renderController
        end
        if self.renderController then
          self.renderController:Remove()
        end
        self.renderController = cls(self)
      end
      self.renderController.ent = self.ent
      return self.renderController
    end,
    GetWeightController = function(self)
      if not self.isValid then
        return self.weightController
      end
      if not self.weightController or self.modelCached ~= self.modelWeight then
        self.modelCached = self.modelCached or self.ent:GetModel()
        self.modelWeight = self.modelCached
        local cls = PPM2.GetPonyWeightController(self.modelCached)
        if self.weightController and cls == self.weightController.__class then
          self.weightController.ent = self.ent
          PPM2.DebugPrint('Skipping weight controller recreation for ', self.ent, ' as part of ', self)
          return self.weightController
        end
        if self.weightController then
          self.weightController:Remove()
        end
        self.weightController = cls(self)
      end
      self.weightController.ent = self.ent
      return self.weightController
    end,
    GetSizeController = function(self)
      if not self.isValid then
        return self.scaleController
      end
      if not self.scaleController or self.modelCached ~= self.modelScale then
        self.modelCached = self.modelCached or self.ent:GetModel()
        self.modelScale = self.modelCached
        local cls = PPM2.GetSizeController(self.modelCached)
        if self.scaleController and cls == self.scaleController.__class then
          self.scaleController.ent = self.ent
          PPM2.DebugPrint('Skipping size controller recreation for ', self.ent, ' as part of ', self)
          return self.scaleController
        end
        if self.scaleController then
          self.scaleController:Remove()
        end
        self.scaleController = cls(self)
      end
      self.scaleController.ent = self.ent
      return self.scaleController
    end,
    GetScaleController = function(self)
      return self:GetSizeController()
    end,
    GetBodygroupController = function(self)
      if not self.isValid then
        return self.bodygroups
      end
      if not self.bodygroups or self.modelBodygroups ~= self.modelCached then
        self.modelCached = self.modelCached or self.ent:GetModel()
        self.modelBodygroups = self.modelCached
        local cls = PPM2.GetBodygroupController(self.modelCached)
        if self.bodygroups and cls == self.bodygroups.__class then
          self.bodygroups.ent = self.ent
          PPM2.DebugPrint('Skipping bodygroup controller recreation for ', self.ent, ' as part of ', self)
          return self.bodygroups
        end
        if self.bodygroups then
          self.bodygroups:Remove()
        end
        self.bodygroups = cls(self)
      end
      self.bodygroups.ent = self.ent
      return self.bodygroups
    end,
    Remove = function(self, byClient)
      if byClient == nil then
        byClient = false
      end
      self.removed = true
      if SERVER or self.NETWORKED then
        self.__class.NW_Objects[self.netID] = nil
      end
      if self.slotID then
        self.__class.O_Slots[self.slotID] = nil
      end
      self.isValid = false
      if not IsValid(self.ent) then
        self.ent = self:GetEntity()
      end
      if IsValid(self.ent) and self.ent.__PPM2_PonyData == self then
        self.entTable.__PPM2_PonyData = nil
      end
      if self:GetWeightController() then
        self:GetWeightController():Remove()
      end
      if CLIENT then
        if self:GetRenderController() then
          self:GetRenderController():Remove()
        end
        if IsValid(self.ent) and self.ent.__ppm2_task_hit then
          self.entTable.__ppm2_task_hit = false
          self.ent:SetNoDraw(false)
        end
      end
      if self:GetBodygroupController() then
        self:GetBodygroupController():Remove()
      end
      if self:GetSizeController() then
        self:GetSizeController():Remove()
      end
      if self.flightController then
        self.flightController:Switch(false)
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, task in pairs(self.__class.NW_Objects) do
          if task:IsValid() and IsValid(task.ent) and not task.ent:IsPlayer() and not task:GetDisableTask() then
            _accum_0[_len_0] = task
            _len_0 = _len_0 + 1
          end
        end
        self.__class.RenderTasks = _accum_0
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, task in pairs(self.__class.NW_Objects) do
          if task:IsValid() and IsValid(task.ent) and not task:GetDisableTask() then
            _accum_0[_len_0] = task
            _len_0 = _len_0 + 1
          end
        end
        self.__class.CheckTasks = _accum_0
      end
    end,
    __tostring = function(self)
      return "[" .. tostring(self.__class.__name) .. ":" .. tostring(self.netID) .. "|" .. tostring(self.ent) .. "]"
    end,
    GetOwner = function(self)
      return self.ent
    end,
    IsNetworked = function(self)
      return self.NETWORKED
    end,
    IsGoingToNetwork = function(self)
      return self.NETWORKED_PREDICT
    end,
    SetIsGoingToNetwork = function(self, val)
      if val == nil then
        val = self.NETWORKED
      end
      self.NETWORKED_PREDICT = val
    end,
    IsLocal = function(self)
      return self.isLocal
    end,
    IsLocalObject = function(self)
      return self.isLocal
    end,
    GetNetworkID = function(self)
      return self.netID
    end,
    NetworkID = function(self)
      return self.netID
    end,
    NetID = function(self)
      return self.netID
    end,
    ReadNetworkData = function(self, len, ply, silent, applyEntities)
      if len == nil then
        len = 24
      end
      if ply == nil then
        ply = NULL
      end
      if silent == nil then
        silent = false
      end
      if applyEntities == nil then
        applyEntities = true
      end
      local data = self.__class:ReadNetworkData()
      local validPly = IsValid(ply)
      local states
      do
        local _accum_0 = { }
        local _len_0 = 1
        for key, _des_0 in pairs(data) do
          local keyValid, newVal
          keyValid, newVal = _des_0[1], _des_0[2]
          _accum_0[_len_0] = PPM2.NetworkChangeState(key, keyValid, newVal, self, len, ply)
          _len_0 = _len_0 + 1
        end
        states = _accum_0
      end
      for _, state in ipairs(states) do
        if not validPly or applyEntities or not isentity(state:GetValue()) then
          state:Apply()
          if not (silent) then
            self:NetworkDataChanges(state)
          end
        end
      end
    end,
    NetworkedIterable = function(self, grabEntities)
      if grabEntities == nil then
        grabEntities = true
      end
      local data
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, _des_0 in ipairs(self.__class.NW_Vars) do
          local strName, getName
          strName, getName = _des_0.strName, _des_0.getName
          if grabEntities or not isentity(self[strName]) then
            _accum_0[_len_0] = {
              getName,
              self[strName]
            }
            _len_0 = _len_0 + 1
          end
        end
        data = _accum_0
      end
      return data
    end,
    ApplyDataToObject = function(self, target, applyEntities)
      if applyEntities == nil then
        applyEntities = false
      end
      local _list_0 = self:NetworkedIterable(applyEntities)
      for _index_0 = 1, #_list_0 do
        local _des_0 = _list_0[_index_0]
        local key, value
        key, value = _des_0[1], _des_0[2]
        if target["Set" .. tostring(key)] then
          target["Set" .. tostring(key)](target, value)
        end
      end
      return target
    end,
    WriteNetworkData = function(self)
      for _, _des_0 in ipairs(self.__class.NW_Vars) do
        local strName, writeFunc
        strName, writeFunc = _des_0.strName, _des_0.writeFunc
        writeFunc(self[strName])
      end
    end,
    ReBroadcast = function(self)
      if not self.NETWORKED then
        return false
      end
      if CLIENT then
        return false
      end
      net.Start(self.__class.NW_Broadcast)
      net.WriteUInt16(self.netID)
      self:WriteNetworkData()
      net.Broadcast()
      return true
    end,
    Create = function(self)
      if self.NETWORKED then
        return 
      end
      if CLIENT and self.CREATED_BY_SERVER then
        return 
      end
      if SERVER then
        self.NETWORKED = true
      end
      self.NETWORKED_PREDICT = true
      if SERVER then
        net.Start(self.__class.NW_Create)
        net.WriteUInt16(self.netID)
        net.WriteEntity(self.ent)
        self:WriteNetworkData()
        local filter = RecipientFilter()
        filter:AddAllPlayers()
        if IsValid(self.ent) and self.ent:IsPlayer() then
          filter:RemovePlayer(self.ent)
        end
        return net.Send(filter)
      else
        self.__class.NW_WaitID = self.__class.NW_WaitID + 1
        self.waitID = self.__class.NW_WaitID
        net.Start(self.__class.NW_Create)
        local before = net.BytesWritten()
        net.WriteUInt16(self.waitID)
        self:WriteNetworkData()
        local after = net.BytesWritten()
        net.SendToServer()
        self.__class.NW_Waiting[self.waitID] = self
        return after - before
      end
    end,
    NetworkTo = function(self, targets)
      if targets == nil then
        targets = { }
      end
      net.Start(self.__class.NW_Create)
      net.WriteUInt16(self.netID)
      net.WriteEntity(self.ent)
      self:WriteNetworkData()
      return net.Send(targets)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, netID, ent)
      _class_0.__parent.__init(self)
      self.m_upperManeModel = Entity(-1)
      self.m_lowerManeModel = Entity(-1)
      self.m_tailModel = Entity(-1)
      self.m_socksModel = Entity(-1)
      self.m_newSocksModel = Entity(-1)
      self.recomputeTextures = true
      self.isValid = true
      self.removed = false
      self.valid = true
      self.NETWORKED = false
      self.NETWORKED_PREDICT = false
      for _, data in ipairs(self.__class.NW_Vars) do
        if data.defFunc then
          self[data.strName] = data.defFunc()
        end
      end
      if SERVER then
        self.netID = self.__class.NW_NextObjectID
        self.__class.NW_NextObjectID = self.__class.NW_NextObjectID + 1
      else
        if netID == nil then
          netID = -1
        end
        self.netID = netID
      end
      self.__class.NW_Objects[self.netID] = self
      if CLIENT then
        for i = 1, 1024 do
          if not self.__class.O_Slots[i] then
            self.slotID = i
            self.__class.O_Slots[i] = self
            break
          end
        end
        if not self.slotID then
          error('dafuq? No empty slots are available')
        end
      end
      self.isNWWaiting = false
      if type(ent) == 'number' then
        local entid = ent
        self.waitEntID = entid
        ent = Entity(entid)
        if not IsValid(ent) then
          self.isNWWaiting = true
          self.waitTTL = RealTimeL() + 60
          table.insert(self.__class.NW_WAIT, self)
          PPM2.LMessage('message.ppm2.debug.race_condition')
          return 
        end
      end
      if not IsValid(ent) then
        return 
      end
      self.ent = ent
      if IsValid(ent) then
        self.modelCached = ent:GetModel()
      end
      return self:SetupEntity(ent)
    end,
    __base = _base_0,
    __name = "NetworkedPonyData",
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
  self.AddNetworkVar = function(self, getName, readFunc, writeFunc, defValue, onSet, networkByDefault)
    if getName == nil then
      getName = 'Var'
    end
    if readFunc == nil then
      readFunc = (function() end)
    end
    if writeFunc == nil then
      writeFunc = (function() end)
    end
    if onSet == nil then
      onSet = (function(self, val)
        return val
      end)
    end
    if networkByDefault == nil then
      networkByDefault = true
    end
    local defFunc = defValue
    if type(defValue) ~= 'function' then
      defFunc = (function()
        return defValue
      end)
    end
    local strName = "_NW_" .. tostring(getName)
    self.NW_NextVarID = self.NW_NextVarID + 1
    local id = self.NW_NextVarID
    local tab = {
      strName = strName,
      readFunc = readFunc,
      getName = getName,
      writeFunc = writeFunc,
      defValue = defValue,
      defFunc = defFunc,
      id = id,
      onSet = onSet
    }
    table.insert(self.NW_Vars, tab)
    self.NW_VarsTable[id] = tab
    self.__base[strName] = defFunc()
    self.__base["Get" .. tostring(getName)] = function(self)
      return self[strName]
    end
    self.__base["Set" .. tostring(getName)] = function(self, val, networkNow)
      if val == nil then
        val = defFunc()
      end
      if networkNow == nil then
        networkNow = networkByDefault
      end
      local oldVal = self[strName]
      local nevVal = onSet(self, val)
      self[strName] = nevVal
      local state = PPM2.NetworkChangeState(strName, getName, nevVal, self)
      state.networkChange = false
      self:SetLocalChange(state)
      if not (networkNow and self.NETWORKED and (CLIENT and self.ent == LocalPlayer() or SERVER)) then
        return 
      end
      net.Start(self.__class.NW_Modify)
      net.WriteUInt(self:GetNetworkID(), 16)
      net.WriteUInt(id, 16)
      writeFunc(nevVal)
      if CLIENT then
        net.SendToServer()
      end
      if SERVER then
        return net.Broadcast()
      end
    end
  end
  self.NetworkVar = function(self, ...)
    return self:AddNetworkVar(...)
  end
  self.GetSet = function(self, fname, fvalue)
    self.__base["Get" .. tostring(fname)] = function(self)
      return self[fvalue]
    end
    self.__base["Set" .. tostring(fname)] = function(self, fnewValue)
      if fnewValue == nil then
        fnewValue = self[fvalue]
      end
      local oldVal = self[fvalue]
      self[fvalue] = fnewValue
      local state = PPM2.NetworkChangeState(fvalue, fname, fnewValue, self)
      state.networkChange = false
      return self:SetLocalChange(state)
    end
  end
  self.NW_WAIT = { }
  if CLIENT then
    hook.Add('OnEntityCreated', 'PPM2.NW_WAIT', function(ent)
      return timer.Simple(0, function()
        if not IsValid(ent) then
          return 
        end
        local dirty = false
        local entid = ent:EntIndex()
        local ttl = RealTimeL()
        local _list_0 = self.NW_WAIT
        for _index_0 = 1, #_list_0 do
          local controller = _list_0[_index_0]
          if controller.removed then
            controller.isNWWaiting = false
            dirty = true
          elseif controller.waitEntID == entid then
            controller.isNWWaiting = false
            controller.ent = ent
            controller.modelCached = ent:GetModel()
            controller:SetupEntity(ent)
            dirty = true
          elseif controller.waitTTL < ttl then
            dirty = true
            controller.isNWWaiting = false
          end
        end
        if dirty then
          do
            local _accum_0 = { }
            local _len_0 = 1
            local _list_1 = self.NW_WAIT
            for _index_0 = 1, #_list_1 do
              local controller = _list_1[_index_0]
              if controller.isNWWaiting then
                _accum_0[_len_0] = controller
                _len_0 = _len_0 + 1
              end
            end
            self.NW_WAIT = _accum_0
          end
        end
      end)
    end)
    hook.Add('NotifyShouldTransmit', 'PPM2.NW_WAIT', function(ent, should)
      return timer.Simple(0, function()
        if not IsValid(ent) then
          return 
        end
        local dirty = false
        local entid = ent:EntIndex()
        local ttl = RealTimeL()
        local _list_0 = self.NW_WAIT
        for _index_0 = 1, #_list_0 do
          local controller = _list_0[_index_0]
          if controller.removed then
            controller.isNWWaiting = false
            dirty = true
          elseif controller.waitEntID == entid then
            controller.isNWWaiting = false
            controller.ent = ent
            controller.modelCached = ent:GetModel()
            controller:SetupEntity(ent)
            dirty = true
          elseif controller.waitTTL < ttl then
            dirty = true
            controller.isNWWaiting = false
          end
        end
        if dirty then
          do
            local _accum_0 = { }
            local _len_0 = 1
            local _list_1 = self.NW_WAIT
            for _index_0 = 1, #_list_1 do
              local controller = _list_1[_index_0]
              if controller.isNWWaiting then
                _accum_0[_len_0] = controller
                _len_0 = _len_0 + 1
              end
            end
            self.NW_WAIT = _accum_0
          end
        end
      end)
    end)
  end
  self.OnNetworkedCreated = function(self, ply, len, nwobj)
    if ply == nil then
      ply = NULL
    end
    if len == nil then
      len = 0
    end
    if CLIENT then
      local netID = net.ReadUInt16()
      local entid = net.ReadUInt16()
      local obj = self.NW_Objects[netID] or self(netID, entid)
      obj.NETWORKED = true
      obj.CREATED_BY_SERVER = true
      obj.NETWORKED_PREDICT = true
      return obj:ReadNetworkData()
    else
      ply[self.NW_CooldownTimer] = ply[self.NW_CooldownTimer] or 0
      ply[self.NW_CooldownTimerCount] = ply[self.NW_CooldownTimerCount] or 0
      if ply[self.NW_CooldownTimer] < RealTimeL() then
        ply[self.NW_CooldownTimerCount] = 1
        ply[self.NW_CooldownTimer] = RealTimeL() + 10
      else
        ply[self.NW_CooldownTimerCount] = ply[self.NW_CooldownTimerCount] + 1
      end
      if ply[self.NW_CooldownTimerCount] >= 3 then
        ply[self.NW_CooldownMessage] = ply[self.NW_CooldownMessage] or 0
        if ply[self.NW_CooldownMessage] < RealTimeL() then
          PPM2.Message('Player ', ply, " is creating " .. tostring(self.__name) .. " too quickly!")
          ply[self.NW_CooldownMessage] = RealTimeL() + 1
        end
        return 
      end
      local waitID = net.ReadUInt16()
      local obj = self(nil, ply)
      obj.NETWORKED_PREDICT = true
      obj:ReadNetworkData()
      obj:Create()
      return timer.Simple(0.5, function()
        if not IsValid(ply) then
          return 
        end
        net.Start(self.NW_ReceiveID)
        net.WriteUInt(waitID, 16)
        net.WriteUInt(obj.netID, 16)
        return net.Send(ply)
      end)
    end
  end
  self.OnNetworkedModify = function(self, ply, len)
    if ply == nil then
      ply = NULL
    end
    if len == nil then
      len = 0
    end
    local id = net.ReadUInt16()
    local obj = self.NW_Objects[id]
    if not (obj) then
      if CLIENT then
        return 
      end
      net.Start(self.NW_Rejected)
      net.WriteUInt(id, 16)
      net.Send(ply)
      return 
    end
    if IsValid(ply) and obj.ent ~= ply then
      if CLIENT then
        error('Invalid realm for player being specified. If you are running on your own net.* library, check up your code')
      end
      net.Start(self.NW_Rejected)
      net.WriteUInt(id, 16)
      net.Send(ply)
      return 
    end
    local varID = net.ReadUInt16()
    local varData = self.NW_VarsTable[varID]
    if not (varData) then
      return 
    end
    local strName, getName, readFunc, writeFunc, onSet
    strName, getName, readFunc, writeFunc, onSet = varData.strName, varData.getName, varData.readFunc, varData.writeFunc, varData.onSet
    local newVal = onSet(obj, readFunc())
    if newVal == obj["Get" .. tostring(getName)](obj) then
      return 
    end
    local state = PPM2.NetworkChangeState(strName, getName, newVal, obj, len, ply)
    state:Apply()
    obj:NetworkDataChanges(state)
    if SERVER then
      net.Start(self.NW_Modify)
      net.WriteUInt(id, 16)
      net.WriteUInt(varID, 16)
      writeFunc(newVal)
      return net.SendOmit(ply)
    end
  end
  self.OnNetworkedDelete = function(self, ply, len)
    if ply == nil then
      ply = NULL
    end
    if len == nil then
      len = 0
    end
    local id = net.ReadUInt16()
    local obj = self.NW_Objects[id]
    if not (obj) then
      return 
    end
    return obj:Remove(true)
  end
  self.ReadNetworkData = function(self)
    local output
    do
      local _tbl_0 = { }
      for _, _des_0 in ipairs(self.NW_Vars) do
        local getName, strName, readFunc
        getName, strName, readFunc = _des_0.getName, _des_0.strName, _des_0.readFunc
        _tbl_0[strName] = {
          getName,
          readFunc()
        }
      end
      output = _tbl_0
    end
    return output
  end
  self.RenderTasks = { }
  self.CheckTasks = { }
  self.NW_Vars = { }
  self.NW_VarsTable = { }
  self.NW_Objects = { }
  if CLIENT then
    self.O_Slots = { }
  end
  self.NW_Waiting = { }
  self.NW_WaitID = -1
  self.NW_NextVarID = -1
  self.NW_Create = 'PPM2.NW.Created'
  self.NW_Modify = 'PPM2.NW.Modified'
  self.NW_Broadcast = 'PPM2.NW.ModifiedBroadcast'
  self.NW_Remove = 'PPM2.NW.Removed'
  self.NW_Rejected = 'PPM2.NW.Rejected'
  self.NW_ReceiveID = 'PPM2.NW.ReceiveID'
  self.NW_CooldownTimerCount = 'ppm2_NW_CooldownTimerCount'
  self.NW_CooldownTimer = 'ppm2_NW_CooldownTimer'
  self.NW_CooldownMessage = 'ppm2_NW_CooldownMessage'
  self.NW_NextObjectID = 0
  self.NW_NextObjectID_CL = 0x60000
  if SERVER then
    net.pool(self.NW_Create)
    net.pool(self.NW_Modify)
    net.pool(self.NW_Remove)
    net.pool(self.NW_ReceiveID)
    net.pool(self.NW_Rejected)
    net.pool(self.NW_Broadcast)
  end
  net.Receive(self.NW_Create, function(len, ply, obj)
    if len == nil then
      len = 0
    end
    if ply == nil then
      ply = NULL
    end
    return self:OnNetworkedCreated(ply, len, obj)
  end)
  net.Receive(self.NW_Modify, function(len, ply, obj)
    if len == nil then
      len = 0
    end
    if ply == nil then
      ply = NULL
    end
    return self:OnNetworkedModify(ply, len, obj)
  end)
  net.Receive(self.NW_Remove, function(len, ply, obj)
    if len == nil then
      len = 0
    end
    if ply == nil then
      ply = NULL
    end
    return self:OnNetworkedDelete(ply, len, obj)
  end)
  net.Receive(self.NW_ReceiveID, function(len, ply)
    if len == nil then
      len = 0
    end
    if ply == nil then
      ply = NULL
    end
    if SERVER then
      return 
    end
    local waitID = net.ReadUInt16()
    local netID = net.ReadUInt16()
    local obj = self.NW_Waiting[waitID]
    self.NW_Waiting[waitID] = nil
    if not (obj) then
      return 
    end
    obj.NETWORKED = true
    self.NW_Objects[obj.netID] = nil
    obj.netID = netID
    obj.waitID = nil
    self.NW_Objects[netID] = obj
  end)
  net.Receive(self.NW_Rejected, function(len, ply)
    if len == nil then
      len = 0
    end
    if ply == nil then
      ply = NULL
    end
    if SERVER then
      return 
    end
    local netID = net.ReadUInt16()
    local obj = self.NW_Objects[netID]
    if not (obj) then
      return 
    end
    if obj.__LastReject and obj.__LastReject > RealTimeL() then
      return 
    end
    obj.__LastReject = RealTimeL() + 3
    obj.NETWORKED = false
    return obj:Create()
  end)
  net.Receive(self.NW_Broadcast, function(len, ply)
    if len == nil then
      len = 0
    end
    if ply == nil then
      ply = NULL
    end
    if SERVER then
      return 
    end
    local netID = net.ReadUInt16()
    local obj = self.NW_Objects[netID]
    if not (obj) then
      return 
    end
    return obj:ReadNetworkData(len, ply)
  end)
  self:GetSet('UpperManeModel', 'm_upperManeModel')
  self:GetSet('LowerManeModel', 'm_lowerManeModel')
  self:GetSet('TailModel', 'm_tailModel')
  self:GetSet('SocksModel', 'm_socksModel')
  self:GetSet('NewSocksModel', 'm_newSocksModel')
  self:NetworkVar('Fly', rBool, wBool, false)
  self:NetworkVar('DisableTask', rBool, wBool, false)
  self:NetworkVar('UseFlexLerp', rBool, wBool, true)
  self:NetworkVar('FlexLerpMultiplier', rFloat(0, 10), wFloat, 1)
  self.SetupModifiers = function(self)
    for key, value in pairs(PPM2.PonyDataRegistry) do
      if value.modifiers then
        self:RegisterModifier(value.getFunc, 0, 0)
        if value.min or value.max then
          self:SetModifierMinMaxFinal(value.getFunc, value.min, value.max)
        end
        self:SetupLerpTables(value.getFunc)
        local strName = '_NW_' .. value.getFunc
        local funcLerp = 'Calculate' .. value.getFunc
        self.__base['Get' .. value.getFunc] = function(self)
          return self[funcLerp](self, self[strName])
        end
      end
    end
  end
  for key, value in pairs(PPM2.PonyDataRegistry) do
    self:NetworkVar(value.getFunc, value.read, value.write, value.default)
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  NetworkedPonyData = _class_0
end
PPM2.NetworkedPonyData = NetworkedPonyData
if CLIENT then
  net.Receive('PPM2.NotifyDisconnect', function()
    local netID = net.ReadUInt16()
    local data = NetworkedPonyData.NW_Objects[netID]
    if not data then
      return 
    end
    return data:Remove()
  end)
  net.Receive('PPM2.PonyDataRemove', function()
    local netID = net.ReadUInt16()
    local data = NetworkedPonyData.NW_Objects[netID]
    if not data then
      return 
    end
    return data:Remove()
  end)
else
  hook.Add('PlayerJoinTeam', 'PPM2.TeamWaypoint', function(ply, new)
    ply.__ppm2_modified_jump = false
  end)
  hook.Add('OnPlayerChangedTeam', 'PPM2.TeamWaypoint', function(ply, old, new)
    ply.__ppm2_modified_jump = false
  end)
end
local entMeta = FindMetaTable('Entity')
entMeta.GetPonyData = function(self)
  local self2 = self
  self = entMeta.GetTable(self)
  if not self then
    return 
  end
  if self.__PPM2_PonyData and self.__PPM2_PonyData.ent ~= self2 then
    self.__PPM2_PonyData.ent = self2
    if CLIENT then
      self.__PPM2_PonyData:SetupEntity(self2)
    end
  end
  return self.__PPM2_PonyData
end
