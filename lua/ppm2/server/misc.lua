net.pool('PPM2.RequestPonyData')
net.pool('PPM2.PlayerRespawn')
net.pool('PPM2.PlayerDeath')
net.pool('PPM2.PostPlayerDeath')
net.pool('PPM2.Require')
net.pool('PPM2.EditorStatus')
net.pool('PPM2.NotifyDisconnect')
net.pool('PPM2.PonyDataRemove')
net.pool('PPM2.RagdollEdit')
net.pool('PPM2.RagdollEditFlex')
net.pool('PPM2.RagdollEditEmote')
net.pool('PPM2.EditorCamPos')
CreateConVar('ppm2_sv_draw_hands', '1', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED,
  FCVAR_ARCHIVE
}, 'Should draw hooves as viewmodel')
CreateConVar('ppm2_sv_editor_dist', '0', {
  FCVAR_NOTIFY,
  FCVAR_REPLICATED,
  FCVAR_ARCHIVE
}, 'Distance limit in PPM/2 Editor/2')
resource.AddWorkshop('933203381')
net.receive('PPM2.EditorCamPos', function(len, ply)
  if len == nil then
    len = 0
  end
  if ply == nil then
    ply = NULL
  end
  if not ply:IsValid() then
    return 
  end
  if ply.__ppm2_lcpt and ply.__ppm2_lcpt > RealTime() then
    return 
  end
  ply.__ppm2_lcpt = RealTime() + 0.1
  local camPos, camAng = net.ReadVector(), net.ReadAngle()
  local filter = RecipientFilter()
  filter:AddPVS(ply:GetPos())
  filter:RemovePlayer(ply)
  if filter:GetCount() == 0 then
    return 
  end
  net.Start('PPM2.EditorCamPos')
  net.WritePlayer(ply)
  net.WriteVector(camPos)
  net.WriteAngle(camAng)
  return net.Send(filter)
end)
return net.Receive('PPM2.EditorStatus', function(len, ply)
  if len == nil then
    len = 0
  end
  if ply == nil then
    ply = NULL
  end
  if not IsValid(ply) then
    return 
  end
  return ply:SetNWBool('PPM2.InEditor', net.ReadBool())
end)
