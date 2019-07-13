DLib.CMessage(PPM2, 'PPM2')
local DEBUG_LEVEL = CreateConVar('ppm2_debug', '0', { }, 'Enables debug printing. LOTS OF IT. 1 - simple messages; 2 - messages with traceback.')
PPM2.DebugPrint = function(...)
  if DEBUG_LEVEL:GetInt() <= 0 then
    return 
  end
  local frmt = PPM2.formatMessage(DEBUG_COLOR, ...)
  MsgC(DEBUG_COLOR, PREFIX_DEBUG, unpack(frmt))
  MsgC('\n')
  if DEBUG_LEVEL:GetInt() >= 2 then
    MsgC(DEBUG_COLOR, debug.traceback())
    MsgC('\n')
  end
  return frmt
end
PPM2.TransformNewModelID = function(id)
  if id == nil then
    id = 0
  end
  local bgID = id % 16
  local maneModelID = math.floor(id / 16) + 1
  if maneModelID == 0 then
    maneModelID = 1
  end
  return maneModelID, bgID
end
do
  local randomColor
  randomColor = function(a)
    if a == nil then
      a = 255
    end
    return Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), a)
  end
  PPM2.Randomize = function(object, ...)
    local mane, manelower, tail = math.random(PPM2.MIN_UPPER_MANES_NEW, PPM2.MAX_UPPER_MANES_NEW), math.random(PPM2.MIN_LOWER_MANES_NEW, PPM2.MAX_LOWER_MANES_NEW), math.random(PPM2.MIN_TAILS_NEW, PPM2.MAX_TAILS_NEW)
    local irisSize = math.random(PPM2.MIN_IRIS * 10, PPM2.MAX_IRIS * 10) / 10
    do
      object:SetGender(math.random(0, 1), ...)
      object:SetRace(math.random(0, 3), ...)
      object:SetPonySize(math.random(85, 110) / 100, ...)
      object:SetNeckSize(math.random(92, 108) / 100, ...)
      object:SetLegsSize(math.random(90, 120) / 100, ...)
      object:SetWeight(math.random(PPM2.MIN_WEIGHT * 10, PPM2.MAX_WEIGHT * 10) / 10, ...)
      object:SetTailType(tail, ...)
      object:SetTailTypeNew(tail, ...)
      object:SetManeType(mane, ...)
      object:SetManeTypeLower(manelower, ...)
      object:SetManeTypeNew(mane, ...)
      object:SetManeTypeLowerNew(manelower, ...)
      object:SetBodyColor(randomColor(), ...)
      object:SetEyeIrisTop(randomColor(), ...)
      object:SetEyeIrisBottom(randomColor(), ...)
      object:SetEyeIrisLine1(randomColor(), ...)
      object:SetEyeIrisLine2(randomColor(), ...)
      object:SetIrisSize(irisSize, ...)
      object:SetManeColor1(randomColor(), ...)
      object:SetManeColor2(randomColor(), ...)
      object:SetManeDetailColor1(randomColor(), ...)
      object:SetManeDetailColor2(randomColor(), ...)
      object:SetUpperManeColor1(randomColor(), ...)
      object:SetUpperManeColor2(randomColor(), ...)
      object:SetUpperManeDetailColor1(randomColor(), ...)
      object:SetUpperManeDetailColor2(randomColor(), ...)
      object:SetLowerManeColor1(randomColor(), ...)
      object:SetLowerManeColor2(randomColor(), ...)
      object:SetLowerManeDetailColor1(randomColor(), ...)
      object:SetLowerManeDetailColor2(randomColor(), ...)
      object:SetTailColor1(randomColor(), ...)
      object:SetTailColor2(randomColor(), ...)
      object:SetTailDetailColor1(randomColor(), ...)
      object:SetTailDetailColor2(randomColor(), ...)
      object:SetSocksAsModel(math.random(1, 2) == 1, ...)
      object:SetSocksColor(randomColor(), ...)
    end
    return object
  end
end
local entMeta = FindMetaTable('Entity')
entMeta.IsPony = function(self)
  local model = self:GetModel()
  self.__ppm2_lastmodel = self.__ppm2_lastmodel or model
  if self.__ppm2_lastmodel ~= model then
    local data = self:GetPonyData()
    if data and data.ModelChanges then
      local oldModel = self.__ppm2_lastmodel
      self.__ppm2_lastmodel = model
      data:ModelChanges(oldModel, model)
    end
  end
  local _exp_0 = model
  if 'models/ppm/player_default_base.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_new.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_new_nj.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  elseif 'models/cppm/player_default_base.mdl' == _exp_0 then
    return true
  elseif 'models/cppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  else
    return false
  end
end
entMeta.IsNJPony = function(self)
  local model = self:GetModel()
  self.__ppm2_lastmodel = self.__ppm2_lastmodel or model
  if self.__ppm2_lastmodel ~= model then
    local data = self:GetPonyData()
    if data and data.ModelChanges then
      local oldModel = self.__ppm2_lastmodel
      self.__ppm2_lastmodel = model
      data:ModelChanges(oldModel, model)
    end
  end
  local _exp_0 = model
  if 'models/ppm/player_default_base_new_nj.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  elseif 'models/cppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  else
    return false
  end
end
entMeta.IsNewPony = function(self)
  local model = self:GetModel()
  self.__ppm2_lastmodel = self.__ppm2_lastmodel or model
  if self.__ppm2_lastmodel ~= model then
    local data = self:GetPonyData()
    if data and data.ModelChanges then
      local oldModel = self.__ppm2_lastmodel
      self.__ppm2_lastmodel = model
      data:ModelChanges(oldModel, model)
    end
  end
  return model == 'models/ppm/player_default_base_new.mdl' or model == 'models/ppm/player_default_base_new_nj.mdl'
end
entMeta.IsPonyCached = function(self)
  local _exp_0 = self.__ppm2_lastmodel
  if 'models/ppm/player_default_base.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_new.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_new_nj.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  elseif 'models/cppm/player_default_base.mdl' == _exp_0 then
    return true
  elseif 'models/cppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  else
    return false
  end
end
entMeta.IsNewPonyCached = function(self)
  local _exp_0 = self.__ppm2_lastmodel
  if 'models/ppm/player_default_base_new.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_new_nj.mdl' == _exp_0 then
    return true
  else
    return false
  end
end
entMeta.IsNJPonyCached = function(self)
  local _exp_0 = self.__ppm2_lastmodel
  if 'models/ppm/player_default_base_new_nj.mdl' == _exp_0 then
    return true
  elseif 'models/ppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  elseif 'models/cppm/player_default_base_nj.mdl' == _exp_0 then
    return true
  else
    return false
  end
end
entMeta.HasPonyModel = entMeta.IsPony
