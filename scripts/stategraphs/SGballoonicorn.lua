require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    EventHandler("attacked", function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_squeak")
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },     
    },    
   
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.container:Close()
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
        end,

        timeline =
        {
            TimeEvent(23*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")
                inst.components.container:DropEverything()
            end)
        },
    },    

    State{
        name = "open",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.components.sleeper:WakeUp()
            inst.AnimState:PlayAnimation("open")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_squeak") end),
        },        
    },

    State{
        name = "open_idle",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop_open")         
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },      
    },

    State{
        name = "close",
        tags = {""},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("closed")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_squeak") end),
        },        
    },
}

CommonStates.AddWalkStates(states, {
    walktimeline = 
    { 
        TimeEvent(1*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_bounce")
            inst.components.locomotor:RunForward() 
        end),
        TimeEvent(14*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_bounce")
            inst.components.locomotor:WalkForward()
        end),
    }
}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_squeak") end)
    },
    sleeptimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_sleep") end)
    },
    waketimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wyro/balloon_squeak") end)
    },
})

CommonStates.AddSimpleState(states, "hit", "hit", {"busy"})

return StateGraph("balloonicorn", states, events, "idle", actionhandlers)

