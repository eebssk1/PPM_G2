local ENABLE_SCAILING = CreateConVar('ppm2_sv_dmg', '1', {
  FCVAR_NOTIFY
}, 'Enable hitbox damage scailing')
local HEAD = CreateConVar('ppm2_sv_dmg_head', '2', {
  FCVAR_NOTIFY
}, 'Damage scale when pony-player got shot in head')
local CHEST = CreateConVar('ppm2_sv_dmg_chest', '1', {
  FCVAR_NOTIFY
}, 'Damage scale when pony-player got shot in chest')
local STOMACH = CreateConVar('ppm2_sv_dmg_stomach', '1', {
  FCVAR_NOTIFY
}, 'Damage scale when pony-player got shot in stomach')
local LEFTARM = CreateConVar('ppm2_sv_dmg_lfhoof', '0.75', {
  FCVAR_NOTIFY
}, 'Damage scale when pony-player got shot in left-forward hoof')
local RIGHTARM = CreateConVar('ppm2_sv_dmg_rfhoof', '0.75', {
  FCVAR_NOTIFY
}, 'Damage scale when pony-player got shot in right-forward hoof')
local LEFTLEG = CreateConVar('ppm2_sv_dmg_lbhoof', '0.75', {
  FCVAR_NOTIFY
}, 'Damage scale when pony-player got shot in back-forward hoof')
local RIGHTLEG = CreateConVar('ppm2_sv_dmg_rbhoof', '0.75', {
  FCVAR_NOTIFY
}, 'Damage scale when pony-player got shot in back-forward hoof')
local sk_player_head = GetConVar('sk_player_head')
local sk_player_chest = GetConVar('sk_player_chest')
local sk_player_stomach = GetConVar('sk_player_stomach')
local sk_player_arm = GetConVar('sk_player_arm')
local sk_player_leg = GetConVar('sk_player_leg')
return hook.Add('ScalePlayerDamage', 'PPM2.PlayerDamage', function(self, group, dmg)
  if group == nil then
    group = HITGROUP_GENERIC
  end
  if not self:IsPonyCached() then
    return 
  end
  if not ENABLE_SCAILING:GetBool() then
    return 
  end
  local _exp_0 = group
  if HITGROUP_HEAD == _exp_0 then
    dmg:ScaleDamage(0.5)
  elseif HITGROUP_LEFTARM == _exp_0 or HITGROUP_RIGHTARM == _exp_0 or HITGROUP_LEFTLEG == _exp_0 or HITGROUP_RIGHTLEG == _exp_0 or HITGROUP_GEAR == _exp_0 then
    dmg:ScaleDamage(4)
  end
  local _exp_1 = group
  if HITGROUP_HEAD == _exp_1 then
    return dmg:ScaleDamage(HEAD:GetFloat())
  elseif HITGROUP_CHEST == _exp_1 then
    return dmg:ScaleDamage(CHEST:GetFloat())
  elseif HITGROUP_STOMACH == _exp_1 then
    return dmg:ScaleDamage(STOMACH:GetFloat())
  elseif HITGROUP_LEFTARM == _exp_1 then
    return dmg:ScaleDamage(LEFTARM:GetFloat())
  elseif HITGROUP_RIGHTARM == _exp_1 then
    return dmg:ScaleDamage(RIGHTARM:GetFloat())
  elseif HITGROUP_LEFTLEG == _exp_1 then
    return dmg:ScaleDamage(RIGHTLEG:GetFloat())
  elseif HITGROUP_RIGHTLEG == _exp_1 then
    return dmg:ScaleDamage(RIGHTLEG:GetFloat())
  elseif HITGROUP_GEAR == _exp_1 then
    return dmg:ScaleDamage(CHEST:GetFloat())
  else
    return dmg:ScaleDamage(1)
  end
end)
