--Infinite tree farm: ON/OFF switch
--
--License: GNU AGPL
--
--Download full code: github.com/Ghaydn/minetest-tree-farm
--

if event.type == "on" then
  digiline_send("switch", "on")
elseif event.type == "off" then
  digiline_send("switch", "off")
end
