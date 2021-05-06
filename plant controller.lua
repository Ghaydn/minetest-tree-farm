--Infinite tree farm: plant controller
--
--License: GNU AGPL
--
--Download full code: github.com/Ghaydn/minetest-tree-farm
--

local deployer = "a"
local mulch = "d"
local chainsaw = "b"

local blink_interval = 0.2


if event.type == "program" then
  mem.var = {
    state = "off"
  }
  port[deployer] = false
  port[mulch] = false
  port[chainsaw] = false
  digiline_send("lcd", "Tree machine ready")
end

if event.type == "digiline" then
  if event.channel == "switch" then
    if event.msg == "on" then
      mem.var.state = "ready"
      port[deployer] = false
      port[mulch] = false
      port[chainsaw] = false
      digiline_send("lcd", "Turning on...")
      digiline_send("command", "recall")
    elseif event.msg == "off" then
      mem.var.state = "off"
      port[deployer] = false
      port[mulch] = false
      port[chainsaw] = false
      digiline_send("lcd", "Tree machine OFF")
    end

  elseif event.channel == "detector" then
    if mem.var.state ~= "off" then
      if event.msg == "tree" then
        mem.var.state = "chainsaw"
        port[deployer] = false
        port[mulch] = false
        port[chainsaw] = true
        digiline_send("lcd", "Found tree, using chainsaw")
        interrupt(blink_interval, "chainsaw")
      elseif event.msg == "sapling" then
        mem.var.state = "mulch"
        port[deployer] = false
        port[mulch] = true
        port[chainsaw] = false
        digiline_send("lcd", "Found sapling, using mulch")
        interrupt(blink_interval, "mulch")
      elseif event.msg == "air" then
        mem.var.state = "deployer"
        port[deployer] = true
        port[mulch] = false
        port[chainsaw] = false
        digiline_send("lcd", "Found nothing, placing sapling")
        interrupt(blink_interval, "deployer")
      end
    end
  end
end

if event.type == "interrupt" then
  if event.iid == "chainsaw" then
    if mem.var.state == "chainsaw" then
      port[chainsaw] = not port[chainsaw]
      interrupt(blink_interval, "chainsaw")
    end
  elseif event.iid == "mulch" then
    if mem.var.state == "mulch" then
      port[mulch] = not port[mulch]
      interrupt(blink_interval, "mulch")
    end
  elseif event.iid == "deployer" then
    if mem.var.state == "deployer" then
      port[deployer] = not port[deployer]
      interrupt(blink_interval, "deployer")
    end
  end
end
