PPM2.USE_HIGHRES_BODY = CreateConVar('ppm2_cl_hires_body', '0', {
  FCVAR_ARCHIVE
}, 'Use high resoluation when rendering pony bodies. AFFECTS ONLY TEXTURE COMPILATION TIME (increases lag spike on pony data load)')
PPM2.USE_HIGHRES_TEXTURES = CreateConVar('ppm2_cl_hires_generic', '0', {
  FCVAR_ARCHIVE
}, 'Create 1024x1024 textures instead of 512x512 on texture compiling')
local RELOADABLE_MATERIALS = { }
PPM2.RELOADABLE_MATERIALS = RELOADABLE_MATERIALS
concommand.Add('ppm2_reload_materials', function()
  local cTime = SysTime()
  for _, mat in ipairs(RELOADABLE_MATERIALS) do
    do
      local texname = mat:GetString('$basetexture')
      if texname then
        mat:SetTexture('$basetexture', texname)
      end
    end
    do
      local texture = mat:GetTexture('$basetexture')
      if texture then
        texture:Download()
      end
    end
    mat:Recompute()
  end
  PPM2.PonyTextureController.URL_MATERIAL_CACHE = { }
  PPM2.PonyTextureController.SessionID = math.random(1, 1000)
  PPM2.Message('Reloaded textures in ', math.floor((SysTime() - cTime) * 100000) / 100, ' milliseconds.')
  RunConsoleCommand('ppm2_reload')
  return RunConsoleCommand('ppm2_require')
end)
local _Material = Material
local _CreateMaterial = CreateMaterial
local Material
Material = function(path)
  local matNew, time = _Material(path)
  table.insert(RELOADABLE_MATERIALS, matNew)
  return matNew, time
end
local CreateMaterial
CreateMaterial = function(name, shader, data)
  local matNew, time = _CreateMaterial(name, shader, data)
  table.insert(RELOADABLE_MATERIALS, matNew)
  return matNew, time
end
local module = {
  BODY_DETAILS = {
    Material('models/ppm2/partrender/body_leggrad1.png'),
    Material('models/ppm2/partrender/body_lines1.png'),
    Material('models/ppm2/partrender/body_stripes1.png'),
    Material('models/ppm2/partrender/body_headstripes1.png'),
    Material('models/ppm2/partrender/body_freckles.png'),
    Material('models/ppm2/partrender/body_hooves1.png'),
    Material('models/ppm2/partrender/body_hooves2.png'),
    Material('models/ppm2/partrender/body_headmask1.png'),
    Material('models/ppm2/partrender/body_hooves1_crit.png'),
    Material('models/ppm2/partrender/body_hooves2_crit.png'),
    Material('models/ppm2/partrender/body_spots1.png'),
    Material('models/ppm2/partrender/body_robotic.png'),
    Material('models/ppm2/partrender/dash-e.png'),
    Material('models/ppm2/partrender/eye_scar.png'),
    Material('models/ppm2/partrender/eye_wound.png'),
    Material('models/ppm2/partrender/body_scar.png'),
    Material('models/ppm2/partrender/gear_socks.png'),
    Material('models/ppm2/partrender/sharp_hooves.png'),
    Material('models/ppm2/partrender/sharp_hooves2.png'),
    Material('models/ppm2/partrender/separated_muzzle.png'),
    Material('models/ppm2/partrender/eye_scar_left.png'),
    Material('models/ppm2/partrender/eye_scar_right.png')
  },
  UPPER_MANE_DETAILS = {
    [4] = {
      Material('models/ppm2/partrender/upmane_5_mask0.png')
    },
    [5] = {
      Material('models/ppm2/partrender/upmane_6_mask0.png')
    },
    [7] = {
      Material('models/ppm2/partrender/upmane_8_mask0.png'),
      Material('models/ppm2/partrender/upmane_8_mask1.png')
    },
    [8] = {
      Material('models/ppm2/partrender/upmane_9_mask0.png'),
      Material('models/ppm2/partrender/upmane_9_mask1.png'),
      Material('models/ppm2/partrender/upmane_9_mask2.png')
    },
    [9] = {
      Material('models/ppm2/partrender/upmane_10_mask0.png')
    },
    [10] = {
      Material('models/ppm2/partrender/upmane_11_mask0.png'),
      Material('models/ppm2/partrender/upmane_11_mask1.png'),
      Material('models/ppm2/partrender/upmane_11_mask2.png')
    },
    [11] = {
      Material('models/ppm2/partrender/upmane_12_mask0.png')
    },
    [12] = {
      Material('models/ppm2/partrender/upmane_13_mask0.png')
    },
    [13] = {
      Material('models/ppm2/partrender/upmane_14_mask0.png')
    },
    [14] = {
      Material('models/ppm2/partrender/upmane_15_mask0.png')
    }
  },
  LOWER_MANE_DETAILS = {
    [4] = {
      Material('models/ppm2/partrender/dnmane_5_mask0.png')
    },
    [7] = {
      Material('models/ppm2/partrender/dnmane_8_mask0.png'),
      Material('models/ppm2/partrender/dnmane_8_mask1.png')
    },
    [8] = {
      Material('models/ppm2/partrender/dnmane_9_mask0.png'),
      Material('models/ppm2/partrender/dnmane_9_mask1.png')
    },
    [9] = {
      Material('models/ppm2/partrender/dnmane_10_mask0.png'),
      Material('models/ppm2/partrender/dnmane_10_mask1.png'),
      Material('models/ppm2/partrender/dnmane_10_mask2.png')
    },
    [10] = {
      Material('models/ppm2/partrender/dnmane_11_mask0.png'),
      Material('models/ppm2/partrender/dnmane_11_mask1.png')
    },
    [11] = {
      Material('models/ppm2/partrender/dnmane_12_mask0.png')
    }
  },
  TAIL_DETAILS = {
    [4] = {
      Material('models/ppm2/partrender/tail_5_mask0.png')
    },
    [7] = {
      Material('models/ppm2/partrender/tail_8_mask0.png'),
      Material('models/ppm2/partrender/tail_8_mask1.png'),
      Material('models/ppm2/partrender/tail_8_mask2.png'),
      Material('models/ppm2/partrender/tail_8_mask3.png'),
      Material('models/ppm2/partrender/tail_8_mask4.png')
    },
    [9] = {
      Material('models/ppm2/partrender/tail_10_mask0.png')
    },
    [10] = {
      Material('models/ppm2/partrender/tail_11_mask0.png'),
      Material('models/ppm2/partrender/tail_11_mask1.png'),
      Material('models/ppm2/partrender/tail_11_mask2.png')
    },
    [11] = {
      Material('models/ppm2/partrender/tail_12_mask0.png'),
      Material('models/ppm2/partrender/tail_12_mask1.png')
    },
    [12] = {
      Material('models/ppm2/partrender/tail_13_mask0.png')
    },
    [13] = {
      Material('models/ppm2/partrender/tail_14_mask0.png')
    }
  },
  SOCKS_PATCHS = {
    'models/props_pony/ppm/ppm_socks/socks_striped_unlit',
    'models/props_pony/ppm2/ppm_socks/custom/geometric1_1.png',
    'models/props_pony/ppm2/ppm_socks/custom/geometric2_1.png',
    'models/props_pony/ppm2/ppm_socks/custom/geometric3_1.png',
    'models/props_pony/ppm2/ppm_socks/custom/geometric4_1.png',
    'models/props_pony/ppm2/ppm_socks/custom/geometric5_1.png',
    'models/props_pony/ppm2/ppm_socks/custom/geometric6_1.png',
    'models/props_pony/ppm2/ppm_socks/custom/geometric7_1.png',
    'models/props_pony/ppm2/ppm_socks/custom/geometric8_1.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/dark1.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers10.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers11.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers12.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers13.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers14.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers15.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers16.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers17.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers18.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers19.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers2.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers20.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers3.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers4.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers5.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers6.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers7.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers8.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/flowers9.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/grey1.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/grey2.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/grey3.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/hearts1.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/hearts2.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/snow1.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper1.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper2.png',
    'models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper3.png'
  },
  SOCKS_DETAILS_PATCHS = {
    [2] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric1_4.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric1_5.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric1_6.png'
    },
    [3] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric2_3.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric2_4.png'
    },
    [4] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric3_2.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric3_3.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric3_5.png'
    },
    [5] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric4_2.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric4_3.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric4_4.png'
    },
    [6] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric5_4.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric5_5.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric5_6.png'
    },
    [7] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric6_2.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric6_3.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric6_4.png'
    },
    [8] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric7_3.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric7_4.png'
    },
    [9] = {
      'models/props_pony/ppm2/ppm_socks/custom/geometric8_2.png',
      'models/props_pony/ppm2/ppm_socks/custom/geometric8_3.png'
    }
  }
}
local additionTable
additionTable = function(...)
  local tab = {
    ['$ignorez'] = 1,
    ['$vertexcolor'] = 1,
    ['$vertexalpha'] = 1,
    ['$nolod'] = 1
  }
  local args = {
    ...
  }
  for i = 1, #args, 2 do
    local key, val = args[i], args[i + 1]
    tab[key] = val
  end
  return tab
end
do
  local _accum_0 = { }
  local _len_0 = 1
  for _, id in ipairs(module.SOCKS_PATCHS) do
    _accum_0[_len_0] = Material(id)
    _len_0 = _len_0 + 1
  end
  module.SOCKS_MATERIALS = _accum_0
end
do
  local _tbl_0 = { }
  for i, data in pairs(module.SOCKS_DETAILS_PATCHS) do
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #data do
        local path = data[_index_0]
        _accum_0[_len_0] = Material(path)
        _len_0 = _len_0 + 1
      end
      _tbl_0[i] = _accum_0
    end
  end
  module.SOCKS_DETAILS = _tbl_0
end
do
  local _accum_0 = { }
  local _len_0 = 1
  for _, mark in ipairs(PPM2.DefaultCutiemarks) do
    _accum_0[_len_0] = Material("models/ppm2/cmarks/" .. tostring(mark) .. ".png")
    _len_0 = _len_0 + 1
  end
  module.CUTIEMARKS = _accum_0
end
do
  local _accum_0 = { }
  local _len_0 = 1
  for _, mat in ipairs({
    'clothes_royalguard',
    'clothes_sbs_full',
    'clothes_sbs_light',
    'clothes_wbs_full',
    'clothes_wbs_light',
    'spidermane_light',
    'spidermane_full'
  }) do
    _accum_0[_len_0] = Material("models/ppm2/texclothes/" .. tostring(mat) .. ".png")
    _len_0 = _len_0 + 1
  end
  module.SUITS = _accum_0
end
do
  local _accum_0 = { }
  local _len_0 = 1
  for _, fil in ipairs(PPM2.TATTOOS_REGISTRY) do
    if fil ~= 'NONE' then
      _accum_0[_len_0] = Material("models/ppm2/partrender/tattoo/" .. tostring(fil:lower()) .. ".png")
      _len_0 = _len_0 + 1
    end
  end
  module.TATTOOS = _accum_0
end
local debugwhite = {
  ['$basetexture'] = 'models/debug/debugwhite',
  ['$ignorez'] = 1,
  ['$vertexcolor'] = 1,
  ['$vertexalpha'] = 1,
  ['$nolod'] = 1
}
module.EYE_OVALS = {
  Material('models/ppm2/partrender/eye_oval.png'),
  Material('models/ppm2/partrender/eye_oval_aperture.png')
}
module.EYE_REFLECTIONS = {
  Material('models/ppm2/partrender/eye_reflection.png'),
  Material('models/ppm2/partrender/eye_reflection_crystal_foal.png'),
  Material('models/ppm2/partrender/eye_reflection_crystal_unisex.png'),
  Material('models/ppm2/partrender/eye_reflection_foal.png'),
  Material('models/ppm2/partrender/eye_reflection_male.png')
}
module.DEBUGWHITE = CreateMaterial('PPM2.Debugwhite', 'UnlitGeneric', debugwhite)
module.HAIR_MATERIAL_COLOR = CreateMaterial('PPM2.ManeTextureBase', 'UnlitGeneric', debugwhite)
module.TAIL_MATERIAL_COLOR = CreateMaterial('PPM2.TailTextureBase', 'UnlitGeneric', debugwhite)
module.WINGS_MATERIAL_COLOR = CreateMaterial('PPM2.WingsMaterialBase', 'UnlitGeneric', debugwhite)
module.HORN_MATERIAL_COLOR = CreateMaterial('PPM2.HornMaterialBase', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm2/base/horn'))
module.BODY_MATERIAL = CreateMaterial('PPM2.BodyTexture', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm2/base/body'))
module.HORN_DETAIL_BUMP = CreateMaterial('PPM2.HornBumpMapRenderer', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm2/base/horn_normal'))
module.HORN_DETAIL_COLOR = Material('models/ppm2/partrender/horn_detail.png')
module.EYE_OVAL = Material('models/ppm2/partrender/eye_oval.png')
module.EYE_GRAD = Material('models/ppm2/partrender/eye_grad.png')
module.EYE_EFFECT = Material('models/ppm2/partrender/eye_effect.png')
module.EYE_LINE_L_1 = Material('models/ppm2/partrender/eye_line_l1.png')
module.EYE_LINE_R_1 = Material('models/ppm2/partrender/eye_line_r1.png')
module.EYE_LINE_L_2 = Material('models/ppm2/partrender/eye_line_l2.png')
module.EYE_LINE_R_2 = Material('models/ppm2/partrender/eye_line_r2.png')
module.EYEBROWS = Material('models/ppm2/partrender/eyebrows.png')
module.PONY_SOCKS = Material('models/ppm2/texclothes/pony_socks.png')
module.LIPS = Material('models/ppm2/partrender/lips.png')
module.NOSE = Material('models/ppm2/partrender/nose.png')
module.EYE_CORNERA = Material('models/ppm2/eyes/eye_cornea')
module.EYE_CORNERA_OVAL = Material('models/ppm2/eyes/eye_cornea_oval')
module.EYE_EXTRA = Material('models/ppm2/eyes/eye_extra')
module.EYE_EXTRA2 = Material('models/ppm2/eyes/eye_extra2')
module.EYE_LIGHTWARP = Material('models/ppm2/eyes/eye_lightwarp')
module.EYE_REFLECTION2 = Material('models/ppm2/eyes/eye_reflection')
PPM2.MaterialsRegistry = module
return module
