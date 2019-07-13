local PARSE_VECTOR
PARSE_VECTOR = function(str, X, Y, Z)
  if str == nil then
    str = '1.0 1.0 1.0'
  end
  if X == nil then
    X = 1
  end
  if Y == nil then
    Y = 1
  end
  if Z == nil then
    Z = 1
  end
  if str == '' then
    return Vector(X, Y, Z)
  end
  local x, y, z = str:match('([0-9.]+) ([0-9.]+) ([0-9.]+)')
  return Vector(tonumber(x) or X, tonumber(y) or Y, tonumber(z) or Z)
end
local PARSE_COLOR
PARSE_COLOR = function(str, r, g, b)
  if str == nil then
    str = '1.0 1.0 1.0'
  end
  if r == nil then
    r = 255
  end
  if g == nil then
    g = 255
  end
  if b == nil then
    b = 255
  end
  if str == '' then
    return Color(r, g, b)
  end
  local x, y, z
  do
    local _obj_0 = PARSE_VECTOR(str, r / 255, g / 255, b / 255)
    x, y, z = _obj_0[1], _obj_0[2], _obj_0[3]
  end
  return Color(x * 255, y * 255, z * 255)
end
local IMPORT_TABLE = {
  ['gender'] = {
    name = 'Gender',
    func = function(arg)
      if arg == nil then
        arg = 0
      end
      local num = tonumber(arg)
      return num == 0 and 'MALE' or 'FEMALE'
    end
  },
  ['coatcolor'] = {
    name = 'BodyColor',
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  },
  ['eyecolor_bg'] = {
    name = 'EyeBackground',
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  },
  ['eyecolor_grad'] = {
    name = 'EyeIrisBottom',
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  },
  ['eyecolor_iris'] = {
    name = 'EyeIrisTop',
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  },
  ['eyecolor_line1'] = {
    name = 'EyeIrisLine1',
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  },
  ['eyecolor_line2'] = {
    name = 'EyeIrisLine2',
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  },
  ['haircolor1'] = {
    name = {
      'ManeColor1',
      'TailColor1',
      'ManeColor2',
      'TailColor2'
    },
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  },
  ['eyejholerssize'] = {
    name = 'HoleWidth',
    func = function(arg)
      if arg == nil then
        arg = '1'
      end
      return tonumber(arg) or 1
    end
  },
  ['eyeirissize'] = {
    name = 'IrisSize',
    func = function(arg)
      if arg == nil then
        arg = '1'
      end
      return (tonumber(arg) or 1) * 1.2
    end
  },
  ['eyeholesize'] = {
    name = 'HoleSize',
    func = function(arg)
      if arg == nil then
        arg = '0.8'
      end
      return tonumber(arg) or 0.8
    end
  },
  ['bodyweight'] = {
    name = 'Weight',
    func = function(arg)
      if arg == nil then
        arg = 1
      end
      return tonumber(arg) or 1
    end
  },
  ['mane'] = {
    name = {
      'ManeType',
      'ManeTypeNew'
    },
    func = function(arg)
      if arg == nil then
        arg = 0
      end
      return (tonumber(arg) or 0) - 1
    end
  },
  ['manel'] = {
    name = {
      'ManeTypeLower',
      'ManeTypeLowerNew'
    },
    func = function(arg)
      if arg == nil then
        arg = 0
      end
      return (tonumber(arg) or 0) - 1
    end
  },
  ['tail'] = {
    name = {
      'TailType',
      'TailTypeNew'
    },
    func = function(arg)
      if arg == nil then
        arg = 0
      end
      return (tonumber(arg) or 0) - 1
    end
  },
  ['tailsize'] = {
    name = 'TailSize',
    func = function(arg)
      if arg == nil then
        arg = 1
      end
      return tonumber(arg) or 1
    end
  },
  ['cmark'] = {
    name = 'CMarkType',
    func = function(arg)
      if arg == nil then
        arg = 1
      end
      return (tonumber(arg) or 1) - 1
    end
  },
  ['cmark_enabled'] = {
    name = 'CMark',
    func = function(arg)
      if arg == nil then
        arg = '1'
      end
      return arg == '1' or arg == '2'
    end
  }
}
for i = 1, 8 do
  IMPORT_TABLE["bodydetail" .. tostring(i)] = {
    name = "BodyDetail" .. tostring(i),
    func = function(arg)
      if arg == nil then
        arg = 1
      end
      return (tonumber(arg) or 1) - 1
    end
  }
  IMPORT_TABLE["bodydetail" .. tostring(i) .. "_c"] = {
    name = "BodyDetailColor" .. tostring(i),
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  }
end
for i = 2, 6 do
  IMPORT_TABLE["haircolor" .. tostring(i)] = {
    name = {
      "ManeDetailColor" .. tostring(i - 1),
      "TailDetailColor" .. tostring(i - 1)
    },
    func = function(arg)
      if arg == nil then
        arg = '1.0 1.0 1.0'
      end
      return PARSE_COLOR(arg)
    end
  }
end
PPM2.ReadFromOldData = function(filename)
  if filename == nil then
    filename = '_current'
  end
  local read = file.Read("ppm/" .. tostring(filename) .. ".txt", 'DATA')
  if read == '' then
    return false
  end
  local split
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _, str in ipairs(string.Explode('\n', read:Replace('\r', ''))) do
      _accum_0[_len_0] = str:Trim()
      _len_0 = _len_0 + 1
    end
    split = _accum_0
  end
  local outputData = { }
  for _, line in ipairs(split) do
    local _continue_0 = false
    repeat
      local varID = line:match('([a-zA-Z0-9_]+)')
      if not varID or varID == '' then
        _continue_0 = true
        break
      end
      if not IMPORT_TABLE[varID] then
        _continue_0 = true
        break
      end
      local dt = IMPORT_TABLE[varID]
      local value = line:sub(#varID + 2)
      if type(dt.name) ~= 'table' then
        outputData[dt.name] = dt.func(value)
      else
        local get = dt.func(value)
        for _, name in ipairs(dt.name) do
          outputData[name] = get
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  local data = PPM2.PonyDataInstance(tostring(filename) .. "_imported", nil, false)
  for key, value in pairs(outputData) do
    data["Set" .. tostring(key)](data, value, false)
  end
  return data, outputData
end
