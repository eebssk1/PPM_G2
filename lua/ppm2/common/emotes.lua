PPM2.AVALIABLE_EMOTES = {
  {
    ['name'] = 'gui.ppm2.emotes.sad',
    ['sequence'] = 'sad',
    ['time'] = 6
  },
  {
    ['name'] = 'gui.ppm2.emotes.wild',
    ['sequence'] = 'wild',
    ['time'] = 3
  },
  {
    ['name'] = 'gui.ppm2.emotes.grin',
    ['sequence'] = 'big_grin',
    ['time'] = 6
  },
  {
    ['name'] = 'gui.ppm2.emotes.angry',
    ['sequence'] = 'anger',
    ['time'] = 7
  },
  {
    ['name'] = 'gui.ppm2.emotes.tongue',
    ['sequence'] = 'tongue',
    ['time'] = 10
  },
  {
    ['name'] = 'gui.ppm2.emotes.angrytongue',
    ['sequence'] = 'angry_tongue',
    ['time'] = 7
  },
  {
    ['name'] = 'gui.ppm2.emotes.pff',
    ['sequence'] = 'pffff',
    ['time'] = 4
  },
  {
    ['name'] = 'gui.ppm2.emotes.kitty',
    ['sequence'] = 'cat',
    ['time'] = 10
  },
  {
    ['name'] = 'gui.ppm2.emotes.owo',
    ['sequence'] = 'owo_alternative',
    ['time'] = 8
  },
  {
    ['name'] = 'gui.ppm2.emotes.ugh',
    ['sequence'] = 'ugh',
    ['time'] = 5
  },
  {
    ['name'] = 'gui.ppm2.emotes.lips',
    ['sequence'] = 'lips_licking',
    ['time'] = 5
  },
  {
    ['name'] = 'gui.ppm2.emotes.scrunch',
    ['sequence'] = 'scrunch',
    ['time'] = 6
  },
  {
    ['name'] = 'gui.ppm2.emotes.sorry',
    ['sequence'] = 'sorry',
    ['time'] = 4
  },
  {
    ['name'] = 'gui.ppm2.emotes.wink',
    ['sequence'] = 'wink_left',
    ['time'] = 2
  },
  {
    ['name'] = 'gui.ppm2.emotes.right_wink',
    ['sequence'] = 'wink_right',
    ['time'] = 2
  },
  {
    ['name'] = 'gui.ppm2.emotes.licking',
    ['sequence'] = 'licking',
    ['time'] = 6
  },
  {
    ['name'] = 'gui.ppm2.emotes.suggestive_lips',
    ['sequence'] = 'lips_licking_suggestive',
    ['time'] = 4
  },
  {
    ['name'] = 'gui.ppm2.emotes.suggestive_no_tongue',
    ['sequence'] = 'suggestive_wo',
    ['time'] = 4
  },
  {
    ['name'] = 'gui.ppm2.emotes.gulp',
    ['sequence'] = 'gulp',
    ['time'] = 1
  },
  {
    ['name'] = 'gui.ppm2.emotes.blah',
    ['sequence'] = 'blahblah',
    ['time'] = 3
  },
  {
    ['name'] = 'gui.ppm2.emotes.happi',
    ['sequence'] = 'happy_eyes',
    ['time'] = 4
  },
  {
    ['name'] = 'gui.ppm2.emotes.happi_grin',
    ['sequence'] = 'happy_grin',
    ['time'] = 5
  },
  {
    ['name'] = 'gui.ppm2.emotes.duck',
    ['sequence'] = 'duck',
    ['time'] = 3
  },
  {
    ['name'] = 'gui.ppm2.emotes.ducks',
    ['sequence'] = 'duck_insanity',
    ['time'] = 2
  },
  {
    ['name'] = 'gui.ppm2.emotes.quack',
    ['sequence'] = 'duck_quack',
    ['time'] = 4
  },
  {
    ['name'] = 'gui.ppm2.emotes.suggestive',
    ['sequence'] = 'suggestive',
    ['time'] = 4
  }
}
local AvaliableFiles
if CLIENT then
  do
    local _tbl_0 = { }
    for _, fil in ipairs(file.Find('materials/gui/ppm2/emotes/*', 'GAME')) do
      _tbl_0[fil] = true
    end
    AvaliableFiles = _tbl_0
  end
end
for i, data in pairs(PPM2.AVALIABLE_EMOTES) do
  data.id = i
  data.file = "materials/gui/ppm2/emotes/" .. tostring(data.sequence) .. ".png"
  data.filecrop = "gui/ppm2/emotes/" .. tostring(data.sequence) .. ".png"
  if CLIENT then
    data.fexists = AvaliableFiles[tostring(data.sequence) .. ".png"] or false
  end
end
do
  local _tbl_0 = { }
  for _, data in ipairs(PPM2.AVALIABLE_EMOTES) do
    _tbl_0[data.name] = data
  end
  PPM2.AVALIABLE_EMOTES_BY_NAME = _tbl_0
end
do
  local _tbl_0 = { }
  for _, data in ipairs(PPM2.AVALIABLE_EMOTES) do
    _tbl_0[data.sequence] = data
  end
  PPM2.AVALIABLE_EMOTES_BY_SEQUENCE = _tbl_0
end
