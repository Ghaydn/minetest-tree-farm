--Infinite tree farm: mulch production controller
--
--License: GNU AGPL
--
--Download full code: github.com/Ghaydn/minetest-tree-farm
--

local max_trees = 99
local max_leaves = max_trees * 8

local pie = 0.5

local craft = "blue"
local skip = "green"
local injector = "black"

local recalc = function()
  if mem.var.total_trees >= max_trees or mem.var.total_leaves >= max_leaves then
    local ratio = math.floor(mem.var.leaves / mem.var.trees)
    mem.var.trees = mem.var.trees - ratio
    mem.var.leaves = mem.var.leaves - ratio * 8
    mem.var.total_trees = mem.var.trees
    mem.var.total_leaves = mem.var.leaves
  end
end

if event.type == "program" then
  mem.var = {
    on = false,
    leaves = 0,
    trees = 0,
    total_leaves = 0,
    total_trees = 0
  }
  interrupt(10, "blink")
  digiline_send("lcd_p", "Mulch controller ready")
end

if event.type == "digiline" then
  if event.channel == "switch" then
    if event.msg == "on" then
      mem.var.on = true
      digiline_send("lcd_p", "Mulch controller ON")
    elseif event.msg == "off" then
      mem.var.on = false
      port[injector] = false
      digiline_send("lcd_p", "Mulch controller OFF")
    end
  end
end

if event.type == "item" then
  if not mem.var.on then
    return skip
  end

  if event.item.name == "default:tree" then
    mem.var.total_trees = mem.var.total_trees + event.item.count
    recalc()
    digiline_send("lcd_p", "Trees input: " .. event.item.count .. ", total trees: " .. mem.var.total_trees .. ", total leaves: " .. mem.var.total_leaves)
    if mem.var.total_trees > max_trees * pie then
      return skip
    else
      mem.var.trees = mem.var.total_trees
      return craft
    end
  elseif event.item.name == "default:leaves" then
    mem.var.total_leaves = mem.var.total_leaves + event.item.count
    recalc()
    digiline_send("lcd_p", "Leaves input: " .. event.item.count .. ", total trees: " .. mem.var.total_trees .. ", total leaves: " .. mem.var.total_leaves)
    if mem.var.total_leaves > max_leaves * pie then
      return skip
    else
      mem.var.leaves = mem.var.total_leaves
      return craft
    end
  else
    return skip
  end
end

if event.type == "interrupt" then
  if event.iid == "blink" then
    if mem.var.on then
      port[injector] = not port[injector]
    end
    interrupt(10, "blink")
  end
end
