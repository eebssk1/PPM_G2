local ENABLE_EMOTES_IN_CHAT = CreateConVar('ppm2_cl_emotes_chat', '1', {
  FCVAR_ARCHIVE
}, 'Show emotes list while chatbox is open')
local ENABLE_EMOTES_IN_CONTEXT = CreateConVar('ppm2_cl_emotes_context', '1', {
  FCVAR_ARCHIVE
}, 'Show emotes list while context menu is open')
net.Receive('PPM2.DamageAnimation', function()
  local ent = net.ReadEntity()
  if not IsValid(ent) or not ent:GetPonyData() then
    return 
  end
  return hook.Call('PPM2_HurtAnimation', nil, ent)
end)
net.Receive('PPM2.KillAnimation', function()
  local ent = net.ReadEntity()
  if not IsValid(ent) or not ent:GetPonyData() then
    return 
  end
  return hook.Call('PPM2_KillAnimation', nil, ent)
end)
net.Receive('PPM2.AngerAnimation', function()
  local ent = net.ReadEntity()
  if not IsValid(ent) or not ent:GetPonyData() then
    return 
  end
  return hook.Call('PPM2_AngerAnimation', nil, ent)
end)
net.Receive('PPM2.PlayEmote', function()
  local emoteID = net.ReadUInt(8)
  local ply = net.ReadEntity()
  local isEndless = net.ReadBool()
  local shouldStop = net.ReadBool()
  if not IsValid(ply) or not ply:GetPonyData() then
    return 
  end
  if not PPM2.AVALIABLE_EMOTES[emoteID] then
    return 
  end
  return hook.Call('PPM2_EmoteAnimation', nil, ply, PPM2.AVALIABLE_EMOTES[emoteID].sequence, PPM2.AVALIABLE_EMOTES[emoteID].time, isEndless, shouldStop)
end)
if IsValid(PPM2.EmotesPanelContext) then
  PPM2.EmotesPanelContext:Remove()
end
if IsValid(PPM2.EmotesPanel) then
  PPM2.EmotesPanel:Remove()
end
local CONSOLE_EMOTES_COMMAND
CONSOLE_EMOTES_COMMAND = function(ply, cmd, args)
  if ply == nil then
    ply = LocalPlayer()
  end
  if cmd == nil then
    cmd = ''
  end
  if args == nil then
    args = { }
  end
  args[1] = args[1] or ''
  local emoteID = tonumber(args[1])
  local isEndless = tobool(args[2])
  local shouldStop = tobool(args[3])
  if emoteID then
    if not PPM2.AVALIABLE_EMOTES[emoteID] then
      PPM2.LMessage('message.ppm2.emotes.invalid', emoteID)
      return 
    end
    net.Start('PPM2.PlayEmote')
    net.WriteUInt(emoteID, 8)
    net.WriteBool(isEndless)
    net.WriteBool(shouldStop)
    net.SendToServer()
    return hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), PPM2.AVALIABLE_EMOTES[emoteID].sequence, PPM2.AVALIABLE_EMOTES[emoteID].time)
  else
    emoteID = args[1]:lower()
    if not PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID] then
      PPM2.LMessage('message.ppm2.emotes.invalid', emoteID)
      return 
    end
    net.Start('PPM2.PlayEmote')
    net.WriteUInt(PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID].id, 8)
    net.WriteBool(isEndless)
    net.WriteBool(shouldStop)
    net.SendToServer()
    return hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), emoteID, PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID].time)
  end
end
local CONSOLE_DEF_LIST
do
  local _accum_0 = { }
  local _len_0 = 1
  for _, _des_0 in ipairs(PPM2.AVALIABLE_EMOTES) do
    local sequence
    sequence = _des_0.sequence
    _accum_0[_len_0] = 'ppm2_emote "' .. sequence .. '"'
    _len_0 = _len_0 + 1
  end
  CONSOLE_DEF_LIST = _accum_0
end
local CONSOLE_EMOTES_AUTOCOMPLETE
CONSOLE_EMOTES_AUTOCOMPLETE = function(cmd, args)
  if cmd == nil then
    cmd = ''
  end
  if args == nil then
    args = ''
  end
  args = args:Trim()
  if args == '' then
    return CONSOLE_DEF_LIST
  end
  local output = { }
  for _, _des_0 in ipairs(PPM2.AVALIABLE_EMOTES) do
    local sequence
    sequence = _des_0.sequence
    if string.find(sequence, '^' .. args) then
      table.insert(output, 'ppm2_emote "' .. sequence .. '"')
    end
  end
  return output
end
concommand.Add('ppm2_emote', CONSOLE_EMOTES_COMMAND, CONSOLE_EMOTES_AUTOCOMPLETE)
local BUTTON_CLICK_FUNC
BUTTON_CLICK_FUNC = function(self, isEndless, shouldStop)
  if isEndless == nil then
    isEndless = false
  end
  if shouldStop == nil then
    shouldStop = false
  end
  if self.sendToServer then
    net.Start('PPM2.PlayEmote')
    net.WriteUInt(self.id, 8)
    net.WriteBool(isEndless)
    net.WriteBool(shouldStop)
    net.SendToServer()
    return hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), self.sequence, self.time, isEndless, shouldStop)
  else
    return hook.Call('PPM2_EmoteAnimation', nil, self.target, self.sequence, self.time, isEndless, shouldStop)
  end
end
local BUTTON_TEXT_COLOR = Color(255, 255, 255)
local IMAGE_PANEL_THINK
IMAGE_PANEL_THINK = function(self)
  self.lastThink = RealTimeL() + .4
  if self:IsHovered() then
    if not self.oldHover then
      self.oldHover = true
      self.hoverPnl:SetVisible(true)
      local x, y = self:LocalToScreen(0, 0)
      return self.hoverPnl:SetPos(x - 256, y - 224)
    end
  else
    if self.oldHover then
      self.oldHover = false
      return self.hoverPnl:SetVisible(false)
    end
  end
end
local HOVERED_IMAGE_PANEL_THINK
HOVERED_IMAGE_PANEL_THINK = function(self)
  if not self.parent:IsValid() then
    self:Remove()
    return 
  end
  if self.parent.lastThink < RealTimeL() then
    return self:SetVisible(false)
  end
end
PPM2.CreateEmotesPanel = function(parent, target, sendToServer)
  if target == nil then
    target = LocalPlayer()
  end
  if sendToServer == nil then
    sendToServer = true
  end
  local self = vgui.Create('DPanel', parent)
  self:SetSkin('DLib_Black')
  self:SetSize(200, 300)
  self.Paint = function(self, w, h)
    if w == nil then
      w = 0
    end
    if h == nil then
      h = 0
    end
    surface.SetDrawColor(0, 0, 0, 150)
    return surface.DrawRect(0, 0, w, h)
  end
  self.scroll = vgui.Create('DScrollPanel', self)
  do
    local _with_0 = self.scroll
    _with_0:Dock(FILL)
    _with_0:SetSkin('DLib_Black')
    _with_0:SetSize(200, 300)
    _with_0.Paint = function() end
    _with_0:SetMouseInputEnabled(true)
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _, _des_0 in ipairs(PPM2.AVALIABLE_EMOTES) do
      local name, id, sequence, time, fexists, filecrop
      name, id, sequence, time, fexists, filecrop = _des_0.name, _des_0.id, _des_0.sequence, _des_0.time, _des_0.fexists, _des_0.filecrop
      do
        local btn = vgui.Create('DButton', self.scroll)
        btn.id = id
        btn.time = time
        btn.sequence = sequence
        btn.sendToServer = sendToServer
        btn.target = target
        btn.DoClick = BUTTON_CLICK_FUNC
        btn:SetSize(200, 32)
        btn:SetText(name)
        btn:SetFont('HudHintTextLarge')
        btn:Dock(TOP)
        do
          local _with_0 = btn:Add('DCheckBox')
          btn.checkbox = _with_0
          _with_0:Dock(RIGHT)
          _with_0:DockMargin(2, 8, 2, 8)
          _with_0:SetSize(16, 16)
          _with_0:SetChecked(false)
          _with_0.Think = function()
            if IsValid(target) then
              do
                local ponyData = target:GetPonyData()
                if ponyData then
                  do
                    local renderController = ponyData:GetRenderController()
                    if renderController then
                      do
                        local emotesController = renderController:CreateEmotesController()
                        if emotesController then
                          return _with_0:SetChecked(emotesController:HasSequence(sequence) and emotesController:GetSequence(sequence):GetInfinite())
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          _with_0.OnChange = function(checkbox3, newVal)
            if _with_0.suppress then
              return 
            end
            if newVal then
              BUTTON_CLICK_FUNC(btn, true)
            end
            if not newVal then
              return BUTTON_CLICK_FUNC(btn, false, true)
            end
          end
        end
        if fexists then
          local image = vgui.Create('DImage', btn)
          do
            image:Dock(LEFT)
            image:SetSize(32, 32)
            image:SetImage(filecrop)
            image:SetMouseInputEnabled(true)
            image.hoverPnl = vgui.Create('DImage')
            image.Think = IMAGE_PANEL_THINK
            image.oldHover = false
            do
              local _with_0 = image.hoverPnl
              _with_0:SetMouseInputEnabled(false)
              _with_0:SetVisible(false)
              _with_0:SetImage(filecrop)
              _with_0:SetSize(256, 256)
              _with_0.Think = HOVERED_IMAGE_PANEL_THINK
              _with_0.parent = image
            end
            image.OnRemove = function()
              if IsValid(image.hoverPnl) then
                return image.hoverPnl:Remove()
              end
            end
          end
        end
        _ = btn
        _accum_0[_len_0] = btn
      end
      _len_0 = _len_0 + 1
    end
    self.buttons = _accum_0
  end
  for _, btn in ipairs(self.buttons) do
    self.scroll:AddItem(btn)
  end
  self:SetVisible(false)
  self:SetMouseInputEnabled(false)
  return self
end
hook.Add('ContextMenuCreated', 'PPM2.Emotes', function(self)
  if not IsValid(self) then
    return 
  end
  if not ENABLE_EMOTES_IN_CONTEXT:GetBool() then
    return 
  end
  if IsValid(PPM2.EmotesPanelContext) then
    PPM2.EmotesPanelContext:Remove()
  end
  PPM2.EmotesPanelContext = PPM2.CreateEmotesPanel(self)
  PPM2.EmotesPanelContext:SetPos(ScrW() / 2 - 100, ScrH() - 300)
  PPM2.EmotesPanelContext:SetVisible(true)
  PPM2.EmotesPanelContext:SetMouseInputEnabled(true)
  return timer.Create('PPM2.ContextMenuEmotesUpdate', 1, 0, function()
    if not IsValid(PPM2.EmotesPanelContext) then
      timer.Remove('PPM2.ContextMenuEmotesUpdate')
      return 
    end
    if not IsValid(LocalPlayer()) then
      return 
    end
    local status = LocalPlayer():IsPony()
    PPM2.EmotesPanelContext:SetVisible(status)
    return PPM2.EmotesPanelContext:SetMouseInputEnabled(status)
  end)
end)
hook.Add('StartChat', 'PPM2.Emotes', function()
  if not IsValid(PPM2.EmotesPanel) and ENABLE_EMOTES_IN_CHAT:GetBool() then
    PPM2.EmotesPanel = PPM2.CreateEmotesPanel()
    PPM2.EmotesPanel:SetPos(ScrW() - 500, ScrH() - 300)
  end
  if IsValid(PPM2.EmotesPanel) then
    if LocalPlayer():IsPony() then
      PPM2.EmotesPanel:SetVisible(true)
      PPM2.EmotesPanel:SetMouseInputEnabled(true)
      return PPM2.EmotesPanel:RequestFocus()
    else
      PPM2.EmotesPanel:SetVisible(false)
      PPM2.EmotesPanel:SetMouseInputEnabled(false)
      return PPM2.EmotesPanel:KillFocus()
    end
  end
end)
return hook.Add('FinishChat', 'PPM2.Emotes', function()
  if IsValid(PPM2.EmotesPanel) then
    PPM2.EmotesPanel:KillFocus()
    PPM2.EmotesPanel:SetVisible(false)
    return PPM2.EmotesPanel:SetMouseInputEnabled(false)
  end
end)
