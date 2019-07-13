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
    return math.Clamp(net.ReadDouble(), min, max)
  end
end
local wFloat = net.WriteDouble
local rBool = net.ReadBool
local wBool = net.WriteBool
local rColor = net.ReadColor
local wColor = net.WriteColor
local rString = net.ReadString
local wString = net.WriteString
local COLOR_FIXER
COLOR_FIXER = function(r, g, b, a)
  if r == nil then
    r = 255
  end
  if g == nil then
    g = 255
  end
  if b == nil then
    b = 255
  end
  if a == nil then
    a = 255
  end
  local func
  func = function(arg)
    if arg == nil then
      arg = Color(r, g, b, a)
    end
    if not IsColor(arg) then
      return Color(255, 255, 255)
    else
      r, g, b, a = arg.r, arg.g, arg.b, arg.a
      if r and g and b and a then
        return Color(r, g, b, a)
      else
        return Color(255, 255, 255)
      end
    end
  end
  return func
end
local URL_FIXER
URL_FIXER = function(arg)
  if arg == nil then
    arg = ''
  end
  arg = tostring(arg)
  if arg:find('^https?://') then
    return arg
  else
    return ''
  end
end
local rURL
rURL = function()
  return URL_FIXER(rString())
end
local FLOAT_FIXER
FLOAT_FIXER = function(def, min, max)
  if def == nil then
    def = 1
  end
  if min == nil then
    min = 0
  end
  if max == nil then
    max = 1
  end
  local defFunc
  defFunc = function()
    if type(def) ~= 'function' then
      return def
    end
  end
  if type(def) == 'function' then
    defFunc = def
  end
  return function(arg)
    if arg == nil then
      arg = defFunc()
    end
    return math.Clamp(tonumber(arg) or defFunc(), min, max)
  end
end
local INT_FIXER
INT_FIXER = function(def, min, max)
  if def == nil then
    def = 1
  end
  if min == nil then
    min = 0
  end
  if max == nil then
    max = 1
  end
  local defFunc
  defFunc = function()
    if type(def) ~= 'function' then
      return def
    end
  end
  if type(def) == 'function' then
    defFunc = def
  end
  return function(arg)
    if arg == nil then
      arg = defFunc()
    end
    return math.floor(math.Clamp(tonumber(arg) or defFunc(), min, max))
  end
end
PPM2.PonyDataRegistry = {
  ['age'] = {
    default = function()
      return PPM2.AGE_ADULT
    end,
    getFunc = 'Age',
    enum = {
      'FILLY',
      'ADULT',
      'MATURE'
    }
  },
  ['race'] = {
    default = function()
      return PPM2.RACE_EARTH
    end,
    getFunc = 'Race',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.RACE_ENUMS) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['wings_type'] = {
    default = function()
      return 0
    end,
    getFunc = 'WingsType',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliablePonyWings) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['gender'] = {
    default = function()
      return PPM2.GENDER_FEMALE
    end,
    getFunc = 'Gender',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AGE_ENUMS) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['weight'] = {
    default = function()
      return 1
    end,
    getFunc = 'Weight',
    min = PPM2.MIN_WEIGHT,
    max = PPM2.MAX_WEIGHT,
    type = 'FLOAT'
  },
  ['ponysize'] = {
    default = function()
      return 1
    end,
    getFunc = 'PonySize',
    min = PPM2.MIN_SCALE,
    max = PPM2.MAX_SCALE,
    type = 'FLOAT'
  },
  ['necksize'] = {
    default = function()
      return 1
    end,
    getFunc = 'NeckSize',
    min = PPM2.MIN_NECK,
    max = PPM2.MAX_NECK,
    type = 'FLOAT'
  },
  ['legssize'] = {
    default = function()
      return 1
    end,
    getFunc = 'LegsSize',
    min = PPM2.MIN_LEGS,
    max = PPM2.MAX_LEGS,
    type = 'FLOAT'
  },
  ['spinesize'] = {
    default = function()
      return 1
    end,
    getFunc = 'BackSize',
    min = PPM2.MIN_SPINE,
    max = PPM2.MAX_SPINE,
    type = 'FLOAT'
  },
  ['male_buff'] = {
    default = function()
      return PPM2.DEFAULT_MALE_BUFF
    end,
    getFunc = 'MaleBuff',
    min = PPM2.MIN_MALE_BUFF,
    max = PPM2.MAX_MALE_BUFF,
    type = 'FLOAT'
  },
  ['eyelash'] = {
    default = function()
      return 0
    end,
    getFunc = 'EyelashType',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.EyelashTypes) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['tail'] = {
    default = function()
      return 0
    end,
    getFunc = 'TailType',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableTails) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['tail_new'] = {
    default = function()
      return 0
    end,
    getFunc = 'TailTypeNew',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableTailsNew) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['mane'] = {
    default = function()
      return 0
    end,
    getFunc = 'ManeType',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableUpperManes) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['mane_new'] = {
    default = function()
      return 0
    end,
    getFunc = 'ManeTypeNew',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableUpperManesNew) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['manelower'] = {
    default = function()
      return 0
    end,
    getFunc = 'ManeTypeLower',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableLowerManes) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['manelower_new'] = {
    default = function()
      return 0
    end,
    getFunc = 'ManeTypeLowerNew',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableLowerManesNew) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['socks_texture'] = {
    default = function()
      return 0
    end,
    getFunc = 'SocksTexture',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.SocksTypes) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['socks_texture_url'] = {
    default = function()
      return ''
    end,
    getFunc = 'SocksTextureURL',
    type = 'URL'
  },
  ['tailsize'] = {
    default = function()
      return 1
    end,
    getFunc = 'TailSize',
    min = PPM2.MIN_TAIL_SIZE,
    max = PPM2.MAX_TAIL_SIZE,
    type = 'FLOAT'
  },
  ['cmark'] = {
    default = function()
      return true
    end,
    getFunc = 'CMark',
    type = 'BOOLEAN'
  },
  ['cmark_size'] = {
    default = function()
      return 1
    end,
    getFunc = 'CMarkSize',
    min = 0,
    max = 1,
    type = 'FLOAT'
  },
  ['cmark_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'CMarkColor',
    type = 'COLOR'
  },
  ['eyelash_color'] = {
    default = function()
      return Color(0, 0, 0)
    end,
    getFunc = 'EyelashesColor',
    type = 'COLOR'
  },
  ['eyelashes_phong_separate'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateEyelashesPhong',
    type = 'BOOLEAN'
  },
  ['fangs'] = {
    default = function()
      return false
    end,
    getFunc = 'Fangs',
    type = 'BOOLEAN'
  },
  ['bat_pony_ears'] = {
    default = function()
      return false
    end,
    getFunc = 'BatPonyEars',
    type = 'BOOLEAN'
  },
  ['claw_teeth'] = {
    default = function()
      return false
    end,
    getFunc = 'ClawTeeth',
    type = 'BOOLEAN'
  },
  ['cmark_type'] = {
    default = function()
      return 4
    end,
    getFunc = 'CMarkType',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.DefaultCutiemarks) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['cmark_url'] = {
    default = function()
      return ''
    end,
    getFunc = 'CMarkURL',
    type = 'URL'
  },
  ['body'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'BodyColor',
    type = 'COLOR'
  },
  ['eyebrows'] = {
    default = function()
      return Color(0, 0, 0)
    end,
    getFunc = 'EyebrowsColor',
    type = 'COLOR'
  },
  ['eyebrows_glow'] = {
    default = function()
      return false
    end,
    getFunc = 'GlowingEyebrows',
    type = 'BOOLEAN'
  },
  ['eyebrows_glow_strength'] = {
    default = function()
      return 1
    end,
    getFunc = 'EyebrowsGlowStrength',
    type = 'FLOAT',
    min = 0,
    max = 1
  },
  ['hide_manes'] = {
    default = function()
      return true
    end,
    getFunc = 'HideManes',
    type = 'BOOLEAN'
  },
  ['hide_manes_socks'] = {
    default = function()
      return true
    end,
    getFunc = 'HideManesSocks',
    type = 'BOOLEAN'
  },
  ['hide_manes_mane'] = {
    default = function()
      return true
    end,
    getFunc = 'HideManesMane',
    type = 'BOOLEAN'
  },
  ['hide_manes_tail'] = {
    default = function()
      return true
    end,
    getFunc = 'HideManesTail',
    type = 'BOOLEAN'
  },
  ['horn_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'HornColor',
    type = 'COLOR'
  },
  ['wings_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'WingsColor',
    type = 'COLOR'
  },
  ['separate_wings'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateWings',
    type = 'BOOLEAN'
  },
  ['separate_horn'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateHorn',
    type = 'BOOLEAN'
  },
  ['separate_magic_color'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateMagicColor',
    type = 'BOOLEAN'
  },
  ['horn_magic_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'HornMagicColor',
    type = 'COLOR'
  },
  ['horn_glow'] = {
    default = function()
      return false
    end,
    getFunc = 'HornGlow',
    type = 'BOOLEAN'
  },
  ['horn_glow_strength'] = {
    default = function()
      return 1
    end,
    getFunc = 'HornGlowSrength',
    min = 0,
    max = 1,
    type = 'FLOAT'
  },
  ['horn_detail_color'] = {
    default = function()
      return Color(90, 90, 90)
    end,
    getFunc = 'HornDetailColor',
    type = 'COLOR'
  },
  ['separate_eyes'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateEyes',
    type = 'BOOLEAN'
  },
  ['separate_mane'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateMane',
    type = 'BOOLEAN'
  },
  ['call_playerfootstep'] = {
    default = function()
      return true
    end,
    getFunc = 'CallPlayerFootstepHook',
    type = 'BOOLEAN'
  },
  ['disable_hoofsteps'] = {
    default = function()
      return false
    end,
    getFunc = 'DisableHoofsteps',
    type = 'BOOLEAN'
  },
  ['disable_wander_sounds'] = {
    default = function()
      return false
    end,
    getFunc = 'DisableWanderSounds',
    type = 'BOOLEAN'
  },
  ['disable_new_step_sounds'] = {
    default = function()
      return false
    end,
    getFunc = 'DisableStepSounds',
    type = 'BOOLEAN'
  },
  ['disable_jump_sound'] = {
    default = function()
      return false
    end,
    getFunc = 'DisableJumpSound',
    type = 'BOOLEAN'
  },
  ['disable_falldown_sound'] = {
    default = function()
      return false
    end,
    getFunc = 'DisableFalldownSound',
    type = 'BOOLEAN'
  },
  ['socks'] = {
    default = function()
      return false
    end,
    getFunc = 'Socks',
    type = 'BOOLEAN'
  },
  ['new_male_muzzle'] = {
    default = function()
      return true
    end,
    getFunc = 'NewMuzzle',
    type = 'BOOLEAN'
  },
  ['noflex'] = {
    default = function()
      return false
    end,
    getFunc = 'NoFlex',
    type = 'BOOLEAN'
  },
  ['socks_model'] = {
    default = function()
      return false
    end,
    getFunc = 'SocksAsModel',
    type = 'BOOLEAN'
  },
  ['socks_model_new'] = {
    default = function()
      return false
    end,
    getFunc = 'SocksAsNewModel',
    type = 'BOOLEAN'
  },
  ['socks_model_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'SocksColor',
    type = 'COLOR'
  },
  ['socks_new_model_color1'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'NewSocksColor1',
    type = 'COLOR'
  },
  ['socks_new_model_color2'] = {
    default = function()
      return Color(0, 0, 0)
    end,
    getFunc = 'NewSocksColor2',
    type = 'COLOR'
  },
  ['socks_new_model_color3'] = {
    default = function()
      return Color(0, 0, 0)
    end,
    getFunc = 'NewSocksColor3',
    type = 'COLOR'
  },
  ['socks_new_texture_url'] = {
    default = function()
      return ''
    end,
    getFunc = 'NewSocksTextureURL',
    type = 'URL'
  },
  ['suit'] = {
    default = function()
      return 0
    end,
    getFunc = 'Bodysuit',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliablePonySuits) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  },
  ['left_wing_size'] = {
    default = function()
      return 1
    end,
    getFunc = 'LWingSize',
    min = PPM2.MIN_WING,
    max = PPM2.MAX_WING,
    type = 'FLOAT'
  },
  ['left_wing_x'] = {
    default = function()
      return 0
    end,
    getFunc = 'LWingX',
    min = PPM2.MIN_WINGX,
    max = PPM2.MAX_WINGX,
    type = 'FLOAT'
  },
  ['left_wing_y'] = {
    default = function()
      return 0
    end,
    getFunc = 'LWingY',
    min = PPM2.MIN_WINGY,
    max = PPM2.MAX_WINGY,
    type = 'FLOAT'
  },
  ['left_wing_z'] = {
    default = function()
      return 0
    end,
    getFunc = 'LWingZ',
    min = PPM2.MIN_WINGZ,
    max = PPM2.MAX_WINGZ,
    type = 'FLOAT'
  },
  ['right_wing_size'] = {
    default = function()
      return 1
    end,
    getFunc = 'RWingSize',
    min = PPM2.MIN_WING,
    max = PPM2.MAX_WING,
    type = 'FLOAT'
  },
  ['right_wing_x'] = {
    default = function()
      return 0
    end,
    getFunc = 'RWingX',
    min = PPM2.MIN_WINGX,
    max = PPM2.MAX_WINGX,
    type = 'FLOAT'
  },
  ['right_wing_y'] = {
    default = function()
      return 0
    end,
    getFunc = 'RWingY',
    min = PPM2.MIN_WINGY,
    max = PPM2.MAX_WINGY,
    type = 'FLOAT'
  },
  ['right_wing_z'] = {
    default = function()
      return 0
    end,
    getFunc = 'RWingZ',
    min = PPM2.MIN_WINGZ,
    max = PPM2.MAX_WINGZ,
    type = 'FLOAT'
  },
  ['teeth_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'TeethColor',
    type = 'COLOR'
  },
  ['mouth_color'] = {
    default = function()
      return Color(219, 65, 155)
    end,
    getFunc = 'MouthColor',
    type = 'COLOR'
  },
  ['tongue_color'] = {
    default = function()
      return Color(235, 131, 59)
    end,
    getFunc = 'TongueColor',
    type = 'COLOR'
  },
  ['bat_wing_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'BatWingColor',
    type = 'COLOR'
  },
  ['bat_wing_skin_color'] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = 'BatWingSkinColor',
    type = 'COLOR'
  },
  ['separate_horn_phong'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateHornPhong',
    type = 'BOOLEAN'
  },
  ['separate_wings_phong'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateWingsPhong',
    type = 'BOOLEAN'
  },
  ['separate_mane_phong'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateManePhong',
    type = 'BOOLEAN'
  },
  ['separate_tail_phong'] = {
    default = function()
      return false
    end,
    getFunc = 'SeparateTailPhong',
    type = 'BOOLEAN'
  },
  ['alternative_fangs'] = {
    default = function()
      return false
    end,
    getFunc = 'AlternativeFangs',
    type = 'BOOLEAN'
  },
  ['hoof_fluffers'] = {
    default = function()
      return false
    end,
    getFunc = 'HoofFluffers',
    type = 'BOOLEAN'
  },
  ['hoof_fluffers_strength'] = {
    default = function()
      return 1
    end,
    getFunc = 'HoofFluffersStrength',
    min = 0,
    max = 1,
    type = 'FLOAT'
  },
  ['ears_size'] = {
    default = function()
      return 1
    end,
    getFunc = 'EarsSize',
    min = 0.1,
    max = 2,
    type = 'FLOAT'
  },
  ['bat_pony_ears_strength'] = {
    default = function()
      return 1
    end,
    getFunc = 'BatPonyEarsStrength',
    min = 0,
    max = 1,
    type = 'FLOAT'
  },
  ['fangs_strength'] = {
    default = function()
      return 1
    end,
    getFunc = 'FangsStrength',
    min = 0,
    max = 1,
    type = 'FLOAT'
  },
  ['clawteeth_strength'] = {
    default = function()
      return 1
    end,
    getFunc = 'ClawTeethStrength',
    min = 0,
    max = 1,
    type = 'FLOAT'
  },
  ['lips_color_inherit'] = {
    default = function()
      return true
    end,
    getFunc = 'LipsColorInherit',
    type = 'BOOLEAN'
  },
  ['nose_color_inherit'] = {
    default = function()
      return true
    end,
    getFunc = 'NoseColorInherit',
    type = 'BOOLEAN'
  },
  ['lips_color'] = {
    default = function()
      return Color(172, 92, 92)
    end,
    getFunc = 'LipsColor',
    type = 'COLOR'
  },
  ['nose_color'] = {
    default = function()
      return Color(77, 84, 83)
    end,
    getFunc = 'NoseColor',
    type = 'COLOR'
  },
  ['weapon_hide'] = {
    default = function()
      return true
    end,
    getFunc = 'HideWeapons',
    type = 'BOOLEAN'
  }
}
for _, _des_0 in ipairs({
  {
    '_left',
    'Left'
  },
  {
    '_right',
    'Right'
  },
  {
    '',
    ''
  }
}) do
  local internal, publicName
  internal, publicName = _des_0[1], _des_0[2]
  PPM2.PonyDataRegistry["eye_url" .. tostring(internal)] = {
    default = function()
      return ''
    end,
    getFunc = "EyeURL" .. tostring(publicName),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["eye_bg" .. tostring(internal)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "EyeBackground" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_hole" .. tostring(internal)] = {
    default = function()
      return Color(0, 0, 0)
    end,
    getFunc = "EyeHole" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_iris1" .. tostring(internal)] = {
    default = function()
      return Color(200, 200, 200)
    end,
    getFunc = "EyeIrisTop" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_iris2" .. tostring(internal)] = {
    default = function()
      return Color(200, 200, 200)
    end,
    getFunc = "EyeIrisBottom" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_irisline1" .. tostring(internal)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "EyeIrisLine1" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_irisline_direction" .. tostring(internal)] = {
    default = function()
      return false
    end,
    getFunc = "EyeLineDirection" .. tostring(publicName),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["eye_irisline2" .. tostring(internal)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "EyeIrisLine2" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_reflection" .. tostring(internal)] = {
    default = function()
      return Color(255, 255, 255, 127)
    end,
    getFunc = "EyeReflection" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_effect" .. tostring(internal)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "EyeEffect" .. tostring(publicName),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["eye_lines" .. tostring(internal)] = {
    default = function()
      return true
    end,
    getFunc = "EyeLines" .. tostring(publicName),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["eye_iris_size" .. tostring(internal)] = {
    default = function()
      return 1
    end,
    getFunc = "IrisSize" .. tostring(publicName),
    min = PPM2.MIN_IRIS,
    max = PPM2.MAX_IRIS,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["eye_derp" .. tostring(internal)] = {
    default = function()
      return false
    end,
    getFunc = "DerpEyes" .. tostring(publicName),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["eye_use_refract" .. tostring(internal)] = {
    default = function()
      return false
    end,
    getFunc = "EyeRefract" .. tostring(publicName),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["eye_cornera" .. tostring(internal)] = {
    default = function()
      return false
    end,
    getFunc = "EyeCornerA" .. tostring(publicName),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["eye_derp_strength" .. tostring(internal)] = {
    default = function()
      return 1
    end,
    getFunc = "DerpEyesStrength" .. tostring(publicName),
    min = PPM2.MIN_DERP_STRENGTH,
    max = PPM2.MAX_DERP_STRENGTH,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["eye_type" .. tostring(internal)] = {
    default = function()
      return 0
    end,
    getFunc = "EyeType" .. tostring(publicName),
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableEyeTypes) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  }
  PPM2.PonyDataRegistry["eye_reflection_type" .. tostring(internal)] = {
    default = function()
      return 0
    end,
    getFunc = "EyeReflectionType" .. tostring(publicName),
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableEyeReflections) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  }
  PPM2.PonyDataRegistry["hole_width" .. tostring(internal)] = {
    default = function()
      return 1
    end,
    getFunc = "HoleWidth" .. tostring(publicName),
    min = PPM2.MIN_PUPIL_SIZE,
    max = PPM2.MAX_PUPIL_SIZE,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["hole_height" .. tostring(internal)] = {
    default = function()
      return 1
    end,
    getFunc = "HoleHeight" .. tostring(publicName),
    min = PPM2.MIN_PUPIL_SIZE,
    max = PPM2.MAX_PUPIL_SIZE,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["iris_width" .. tostring(internal)] = {
    default = function()
      return 1
    end,
    getFunc = "IrisWidth" .. tostring(publicName),
    min = PPM2.MIN_PUPIL_SIZE,
    max = PPM2.MAX_PUPIL_SIZE,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["iris_height" .. tostring(internal)] = {
    default = function()
      return 1
    end,
    getFunc = "IrisHeight" .. tostring(publicName),
    min = PPM2.MIN_PUPIL_SIZE,
    max = PPM2.MAX_PUPIL_SIZE,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["eye_glossy_reflection" .. tostring(internal)] = {
    default = function()
      return 0.16
    end,
    getFunc = "EyeGlossyStrength" .. tostring(publicName),
    min = 0,
    max = 1,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry["hole_shiftx" .. tostring(internal)] = {
    default = function()
      return 0
    end,
    getFunc = "HoleShiftX" .. tostring(publicName),
    min = PPM2.MIN_HOLE_SHIFT,
    max = PPM2.MAX_HOLE_SHIFT,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["hole_shifty" .. tostring(internal)] = {
    default = function()
      return 0
    end,
    getFunc = "HoleShiftY" .. tostring(publicName),
    min = PPM2.MIN_HOLE_SHIFT,
    max = PPM2.MAX_HOLE_SHIFT,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["eye_hole_size" .. tostring(internal)] = {
    default = function()
      return .8
    end,
    getFunc = "HoleSize" .. tostring(publicName),
    min = PPM2.MIN_HOLE,
    max = PPM2.MAX_HOLE,
    type = 'FLOAT',
    modifiers = true
  }
  PPM2.PonyDataRegistry["eye_rotation" .. tostring(internal)] = {
    default = function()
      return 0
    end,
    getFunc = "EyeRotation" .. tostring(publicName),
    min = PPM2.MIN_EYE_ROTATION,
    max = PPM2.MAX_EYE_ROTATION,
    type = 'INT'
  }
end
for i = 1, 3 do
  PPM2.PonyDataRegistry["horn_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "HornURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["bat_wing_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "BatWingURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["bat_wing_skin_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "BatWingSkinURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["wings_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "WingsURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["horn_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "HornURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["bat_wing_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "BatWingURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["bat_wing_skin_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "BatWingSkinURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["wings_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "WingsURLColor" .. tostring(i),
    type = 'COLOR'
  }
end
for i = 1, 6 do
  PPM2.PonyDataRegistry["socks_detail_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "SocksDetailColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["mane_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "ManeColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["mane_detail_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "ManeDetailColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["mane_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "ManeURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["mane_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "ManeURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["tail_detail_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "TailDetailColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["tail_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "TailURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["tail_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "TailURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["tail_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "TailColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["lower_mane_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "LowerManeColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["lower_mane_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "LowerManeURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["lower_mane_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "LowerManeURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["upper_mane_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "UpperManeColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["upper_mane_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "UpperManeURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["upper_mane_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "UpperManeURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["lower_mane_detail_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "LowerManeDetailColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["upper_mane_detail_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "UpperManeDetailColor" .. tostring(i),
    type = 'COLOR'
  }
end
for i = 1, PPM2.MAX_BODY_DETAILS do
  PPM2.PonyDataRegistry["body_detail_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "BodyDetailColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["body_detail_" .. tostring(i)] = {
    default = function()
      return 0
    end,
    getFunc = "BodyDetail" .. tostring(i),
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.BodyDetailsEnum) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  }
  PPM2.PonyDataRegistry["body_detail_url_" .. tostring(i)] = {
    default = function()
      return ''
    end,
    getFunc = "BodyDetailURL" .. tostring(i),
    type = 'URL'
  }
  PPM2.PonyDataRegistry["body_detail_url_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "BodyDetailURLColor" .. tostring(i),
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry["body_detail_glow_" .. tostring(i)] = {
    default = function()
      return false
    end,
    getFunc = "BodyDetailGlow" .. tostring(i),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["body_detail_glow_strength_" .. tostring(i)] = {
    default = function()
      return 1
    end,
    getFunc = "BodyDetailGlowStrength" .. tostring(i),
    type = 'FLOAT',
    min = 0,
    max = 1
  }
end
for i = 1, PPM2.MAX_TATTOOS do
  PPM2.PonyDataRegistry["tattoo_type_" .. tostring(i)] = {
    default = function()
      return 0
    end,
    getFunc = "TattooType" .. tostring(i),
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.TATTOOS_REGISTRY) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  }
  PPM2.PonyDataRegistry["tattoo_posx_" .. tostring(i)] = {
    default = function()
      return 0
    end,
    getFunc = "TattooPosX" .. tostring(i),
    min = -100,
    max = 100,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry["tattoo_posy_" .. tostring(i)] = {
    default = function()
      return 0
    end,
    getFunc = "TattooPosY" .. tostring(i),
    fix = function(arg)
      if arg == nil then
        arg = 0
      end
      return math.Clamp(tonumber(arg) or 0, -100, 100)
    end,
    min = -100,
    max = 100,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry["tattoo_rotate_" .. tostring(i)] = {
    default = function()
      return 0
    end,
    getFunc = "TattooRotate" .. tostring(i),
    min = -180,
    max = 180,
    type = 'INT'
  }
  PPM2.PonyDataRegistry["tattoo_scalex_" .. tostring(i)] = {
    default = function()
      return 1
    end,
    getFunc = "TattooScaleX" .. tostring(i),
    min = 0,
    max = 10,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry["tattoo_glow_strength_" .. tostring(i)] = {
    default = function()
      return 1
    end,
    getFunc = "TattooGlowStrength" .. tostring(i),
    min = 0,
    max = 1,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry["tattoo_scaley_" .. tostring(i)] = {
    default = function()
      return 1
    end,
    getFunc = "TattooScaleY" .. tostring(i),
    min = 0,
    max = 10,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry["tattoo_glow_" .. tostring(i)] = {
    default = function()
      return false
    end,
    getFunc = "TattooGlow" .. tostring(i),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["tattoo_over_detail_" .. tostring(i)] = {
    default = function()
      return false
    end,
    getFunc = "TattooOverDetail" .. tostring(i),
    type = 'BOOLEAN'
  }
  PPM2.PonyDataRegistry["tattoo_color_" .. tostring(i)] = {
    default = function()
      return Color(255, 255, 255)
    end,
    getFunc = "TattooColor" .. tostring(i),
    type = 'COLOR'
  }
end
for _, ttype in ipairs({
  'Body',
  'Horn',
  'Wings',
  'BatWingsSkin',
  'Socks',
  'Mane',
  'Tail',
  'UpperMane',
  'LowerMane',
  'LEye',
  'REye',
  'BEyes',
  'Eyelashes',
  'Mouth',
  'Teeth',
  'Tongue'
}) do
  PPM2.PonyDataRegistry[ttype:lower() .. '_phong_exponent'] = {
    default = function()
      return 3
    end,
    getFunc = ttype .. 'PhongExponent',
    min = 0.04,
    max = 10,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_phong_boost'] = {
    default = function()
      return 0.09
    end,
    getFunc = ttype .. 'PhongBoost',
    min = 0.01,
    max = 1,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_phong_front'] = {
    default = function()
      return 1
    end,
    getFunc = ttype .. 'PhongFront',
    min = 0,
    max = 20,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_phong_middle'] = {
    default = function()
      return 5
    end,
    getFunc = ttype .. 'PhongMiddle',
    min = 0,
    max = 20,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_phong_sliding'] = {
    default = function()
      return 10
    end,
    getFunc = ttype .. 'PhongSliding',
    min = 0,
    max = 20,
    type = 'FLOAT'
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_phong_tint'] = {
    default = function()
      return Color(255, 200, 200)
    end,
    getFunc = ttype .. 'PhongTint',
    type = 'COLOR'
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_lightwarp_texture'] = {
    default = function()
      return 0
    end,
    getFunc = ttype .. 'Lightwarp',
    enum = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, arg in ipairs(PPM2.AvaliableLightwarps) do
        _accum_0[_len_0] = arg
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_lightwarp_texture_url'] = {
    default = function()
      return ''
    end,
    getFunc = ttype .. 'LightwarpURL',
    type = 'URL'
  }
  PPM2.PonyDataRegistry[ttype:lower() .. '_bumpmap_texture_url'] = {
    default = function()
      return ''
    end,
    getFunc = ttype .. 'BumpmapURL',
    type = 'URL'
  }
end
for _, _des_0 in ipairs(PPM2.PonyFlexController.FLEX_LIST) do
  local _continue_0 = false
  repeat
    local flex, active
    flex, active = _des_0.flex, _des_0.active
    if not active then
      _continue_0 = true
      break
    end
    PPM2.PonyDataRegistry["flex_disable_" .. tostring(flex:lower())] = {
      default = function()
        return false
      end,
      getFunc = "DisableFlex" .. tostring(flex),
      type = 'BOOLEAN'
    }
    _continue_0 = true
  until true
  if not _continue_0 then
    break
  end
end
local testMinimalBits = 0
for key, value in pairs(PPM2.PonyDataRegistry) do
  if value.enum then
    value.min = 0
    value.max = #value.enum - 1
    value.type = 'INT'
  end
  local _exp_0 = value.type
  if 'INT' == _exp_0 then
    if type(value.min) ~= 'number' then
      error("Variable " .. tostring(key) .. " has invalid minimal value (" .. tostring(type(value.min)) .. ")")
    end
    if type(value.max) ~= 'number' then
      error("Variable " .. tostring(max) .. " has invalid maximal value (" .. tostring(type(value.max)) .. ")")
    end
    value.fix = INT_FIXER(value.default, value.min, value.max)
    if value.min >= 0 then
      local selectBits = net.ChooseOptimalBits(value.max - value.min)
      testMinimalBits = testMinimalBits + selectBits
      value.read = rUInt(selectBits, value.min, value.max)
      value.write = wUInt(value.default(), selectBits)
    else
      local selectBits = net.ChooseOptimalBits(math.max(math.abs(value.max), math.abs(value.min)))
      testMinimalBits = testMinimalBits + selectBits
      value.read = rInt(selectBits, value.min, value.max)
      value.write = wInt(value.default(), selectBits)
    end
  elseif 'FLOAT' == _exp_0 then
    if type(value.min) ~= 'number' then
      error("Variable " .. tostring(key) .. " has invalid minimal value (" .. tostring(type(value.min)) .. ")")
    end
    if type(value.max) ~= 'number' then
      error("Variable " .. tostring(max) .. " has invalid maximal value (" .. tostring(type(value.max)) .. ")")
    end
    value.fix = FLOAT_FIXER(value.default, value.min, value.max)
    value.read = rFloat(value.min, value.max)
    value.write = function(arg)
      if arg == nil then
        arg = value.default()
      end
      return wFloat(arg)
    end
    testMinimalBits = testMinimalBits + 32
  elseif 'URL' == _exp_0 then
    value.fix = URL_FIXER
    value.read = rURL
    value.write = wString
    testMinimalBits = testMinimalBits + 8
  elseif 'BOOLEAN' == _exp_0 then
    value.fix = function(arg)
      if arg == nil then
        arg = value.default()
      end
      return tobool(arg)
    end
    value.read = rBool
    value.write = wBool
    testMinimalBits = testMinimalBits + 1
  elseif 'COLOR' == _exp_0 then
    local r, g, b, a
    do
      local _obj_0 = value.default()
      r, g, b, a = _obj_0.r, _obj_0.g, _obj_0.b, _obj_0.a
    end
    value.fix = COLOR_FIXER(r, g, b, a)
    value.read = rColor
    value.write = wColor
    testMinimalBits = testMinimalBits + 32
  else
    error("Unknown variable type - " .. tostring(value.type) .. " for " .. tostring(key))
  end
end
PPM2.testMinimalBits = testMinimalBits
for key, value in pairs(PPM2.PonyDataRegistry) do
  if not value.fix then
    error("Data has no fix function: " .. tostring(key))
  end
end
