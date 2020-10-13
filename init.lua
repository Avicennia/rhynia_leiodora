 -- luacheck: globals rhyn minetest shout
local thismod = minetest.get_current_modname()
--local modpath = minetest.get_modpath(thismod)
local tm = thismod
--local parentmod = "rhyn"
local genera = {"leiodora"}

local function attempt_propagate(pos)
    rhyn.f.pollen(pos,_,_,"leiodora_spore.png",5)
    local num = math.random(1000)
    return num > 930 and rhyn.f.propagate(pos)
end


for g = 1, #genera do
rhyn.modules[tm] = {genera = {genera[g]}}

local stage = {steps = {1,2,3}, stages = {"imm","mat","sen"}}
local st = {}
for n = 1, 3 do
    for nn = 1, 3 do
        --local ind = n - 1
        local name = tm..":"..genera[1].."_"..stage.stages[n].."_"..stage.steps[nn]
    table.insert(st,{name})
    end
end
st[10] = {"air"}
local def = {
    parentmod = tm,
    visual = "plantlike",
    genus = "leiodora",
    root_dim = 2,
    health_max = 10,
    growth_interval = 1000,
    growth_factor = {names = {"nc_fire:ash"},values = {8}},
    survival_factor = {names = {"group:igniter"}, values = {-9}},
    spore_dis_rad = 3,
    condition_factor = {},
    catchments = {base = 1, ext = 2},
    structure = {st[1],st[2],st[3],st[4],st[5],st[6],st[7],st[8],st[9],st[10]},
    stage = stage,
    traits = {growth_opt = true, pt2condition = true},
    acts = {
       on_tick = function(...)
            local val = rhyn.f.selectify(...)
            local pos,genus = val[1], val[2]
            local data = rhyn.f.nominate(minetest.get_node(pos).name)

            if(not rhyn.f.is_rooted(pos,genus))then return rhyn.rn(pos) end
            if(rhyn.f.kill_if_health(pos,0))then return end
            rhyn.f.alter_health(pos,-rhyn.f.spot_check(pos,"group:igniter"))
            if(data.stage == "mat" and tonumber(data.step) > 2)then
                attempt_propagate(pos)
            end
            local function incr()
            rhyn.f.growth_tick(pos)
            end
            incr()
          end,
        on_propagate = function(...)

        end
    }
}

rhyn.f.register_emulsion(def)

    local k = genera[g]
    local v = def
    for n = 1, #v.stage.stages do
        for nn = 1, #v.stage.steps do
            local name = k.."_"..v.stage.stages[n].."_"..v.stage.steps[nn]
            local ndef = {
                genus = k,
                name = tm..":"..name,
                description = k,
                paramtype = "light",
                sunlight_propagates = true,
                drawtype = "plantlike",
                tiles = {name..".png"},
                groups = {planty = 1, rhyn_plant = 1},
                on_construct = function(pos)
                local meta = minetest.get_meta(pos)
                meta:set_int("rhyn_gl",nn+(#v.stage.stages*(n-1)))
                meta:set_int("rhyn_ci",1)
                meta:set_int("rhyn_h",v.health_max)
                end,
                on_punch = function(pos)
                    local m = minetest.get_meta(pos)
                    shout("GROWTH: "..m:get_int("rhyn_gi"))
                    shout("CONDITION: "..m:get_int("rhyn_ci"))
                    shout("HEALTH: "..rhyn.f.check_health(pos))
                    shout("LIGHT: "..minetest.get_node_light(pos))
                    return --rhyn.rn(pos) --shout(rhyn.f.ass_check(pos,2,false))
                end
            }
            rhyn.f.rnode(ndef)
        end
    end
    rhyn.f.assign_soils_alt(genera[g])

end

