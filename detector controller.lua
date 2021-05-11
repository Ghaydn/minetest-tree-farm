--Infinite tree farm: detector controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-tree-farm
--

local tree = "a"
local sapling = "b"
local air = "d" --not intended


local recall = function()
  if pin[tree] then
    digiline_send("detector", "tree")
  elseif pin[sapling] then
    digiline_send("detector", "sapling")
  elseif not pin[air] then
    digiline_send("detector", "air")
  end
end


if event.type == "program" then
  mem.var = {
    on = false
  }
end

if event.type == "digiline" then
  if event.channel == "switch" then
    if event.msg == "on" then
      mem.var.on = true
    elseif event.msg == "off" then
      mem.var.on = false
    end
  elseif event.channel == "command" and event.msg == "recall" and mem.var.on then
    recall()
  end
end

if event.type == "on" or event.type == "off" then
  if mem.var.on then
    recall()
  end
end
