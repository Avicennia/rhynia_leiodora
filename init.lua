 -- luacheck: globals rhynia minetest
local thismod = minetest.get_current_modname()
--local modpath = minetest.get_modpath(thismod)
local tm = thismod
--local parentmod = "rhynia"
local genera = {"leiodora"}

local function attempt_propagate(pos)
    rhynia.f.pollen(pos,_,_,"leiodora_spore.png",5)
    local num = math.random(1000)
    return num > 930 and rhynia.f.propagate(pos)
end


for g = 1, #genera do
rhynia.modules[tm] = {genera = {genera[g]}}

local stage = {steps = {1,2,3}, stages = {"imm","mat","sen"}}
local st = {}
for n = 1, 9 do
        local name = tm..":"..genera[1].."_"..n
    table.insert(st,{name})
end
st[10] = {"air"}
local def = {
    parentmod = tm,
    visual = "plantlike",
    genus = "leiodora",
    root_dim = 2,
    health_max = 10,
    growth_interval = 100,
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
            local val = rhynia.u.selectify(...)
            local pos,genus = val[1], val[2]
            local data = rhynia.f.nominate(minetest.get_node(pos).name)

            if(not rhynia.f.is_rooted(pos,genus))then return rhynia.u.rn(pos) end
            if(rhynia.f.kill_if_health(pos,0))then return end
            rhynia.f.alter_health(pos,-rhynia.f.spot_check(pos,"group:igniter"))
            if(data.stage == 6)then
                attempt_propagate(pos)
            end
            local function incr()
            rhynia.f.growth_tick(pos)
            end
            incr()
          end,
        on_propagate = function(...)

        end
    }
}

rhynia.f.register_emulsion(def)

    local k = genera[g]
    local v = def
    for n = 1, 9 do
            local name = k.."_"..n
            local ndef = {
                genus = k,
                name = tm..":"..name,
                description = k,
                paramtype = "light",
                sunlight_propagates = true,
                drawtype = "plantlike",
                tiles = {name..".png"},
                groups = {planty = 1, rhynia_plant = 1},
                on_construct = function(pos)
                local meta = minetest.get_meta(pos)
                meta:set_int("rhynia_gl",n)
                meta:set_int("rhynia_ci",1)
                meta:set_int("rhynia_h",v.health_max)
                end,
                on_punch = function(pos)
                    local m = minetest.get_meta(pos)
                    local function shout(g)
                        return rhynia.u.sh(g)
                    end
                    shout("GROWTH: "..m:get_int("rhynia_gi"))
                    shout("CONDITION: "..m:get_int("rhynia_ci"))
                    shout("HEALTH: "..rhynia.f.check_health(pos))
                    shout("LIGHT: "..rhynia.f.average_light_spot(pos))
                    return --rhynia.rn(pos) --shout(rhynia.f.ass_check(pos,2,false))
                end
            }
            rhynia.f.rnode(ndef)
        end
        rhynia.f.assign_soils_alt(genera[g])
    end

