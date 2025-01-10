local mod_id = "arcade_mode"


local config = {
    required_credits = 4
}

local credits = {
    text = "Insert Credit",
    value = 0
}

--[[
  Changes the version fo the game to reflect that `arcade_mode` is active
--]]
local function on_enable()
    G.VERSION = '1.0.1n-ARCADE'
end

--[[
  Alternative to `create_UIBox_main_menu_buttons()` for Arcade style main menu. 

  Removes the profile, options, quit, collection, socials and mods buttons from the main menu. 
--]]
function create_UIBox_arcade_main_menu_buttons()
    local text_scale = 0.45

    -- local t = {
    --     n=G.UIT.ROOT, config = {align = "cm",colour = G.C.CLEAR}, nodes={
    --     {n=G.UIT.C, config={align = "bm"}, nodes={      
    --         {n=G.UIT.R, config={align = "cm", padding = 0.2, r = 0.1, emboss = 0.1, colour = G.C.L_BLACK, mid = true}, nodes={
    --         UIBox_button{id = 'main_menu_play', button = "setup_run", colour = G.C.BLUE, minw = 3.65, minh = 1.55, label = {localize('b_play_cap')}, scale = text_scale*2, col = true},
    --         }},
    --     }},
    -- }}

    local t = {
        n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
            {n=G.UIT.C, config={}, nodes = {
                {n=G.UIT.R, config = {align = "cm"}, nodes = {
                    credits.value >= config.required_credits and UIBox_button{id = 'main_menu_play', button = "setup_arcade_run", colour = G.C.BLUE, minw = 3.65, minh = 1.55, label = {localize('b_play_cap')}, scale = text_scale*2, col = true} or 
                    {n=G.UIT.T, config={ ref_table = credits, ref_value = "text", scale = 0.8, colour = G.C.UI.TEXT_LIGHT}},
                }},
                {n=G.UIT.R, config = {align = "cm", padding = 0.5, minw = 20}, nodes = {
                    {n=G.UIT.C, config={}, nodes = {
                        {n=G.UIT.R, config = {}, nodes = {
                            {n=G.UIT.T, config={ text = "Credits: ", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}},
                            {n=G.UIT.T, config={ ref_table = credits, ref_value = "value", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}},
                            config.required_credits > 1 and {n=G.UIT.T, config={ text = "/", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}} or nil,
                            config.required_credits > 1 and {n=G.UIT.T, config={ ref_table = config, ref_value = "required_credits", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}} or nil,
                        }},
                    }},
                }},
            }},
        }
    }

    return t
end

--[[
  Override `set_main_menu_UI()` function to load Arcade main menu
--]]
function set_main_menu_UI()
    G.MAIN_MENU_UI = UIBox{
        definition = create_UIBox_arcade_main_menu_buttons(), 
        config = {align="bmi", offset = {x=0,y=10}, major = G.ROOM_ATTACH, bond = 'Weak'}
    }
    G.MAIN_MENU_UI.alignment.offset.y = 0
    G.MAIN_MENU_UI:align_to_major()
    
    G.CONTROLLER:snap_to{node = G.MAIN_MENU_UI:get_UIE_by_ID('main_menu_play')}
end

function update_main_menu_UI()
    G.MAIN_MENU_UI:remove()

    G.MAIN_MENU_UI = UIBox{
        definition = create_UIBox_arcade_main_menu_buttons(), 
        config = {align="bmi", major = G.ROOM_ATTACH, bond = 'Weak'}
    }
end

G.FUNCS.setup_arcade_run = function(e)
    credits.value = credits.value - config.required_credits
    -- G.FUNCS.setup_run(e)

    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.run_arcade_setup(),
    }
    G.OVERLAY_MENU.config.no_esc = true
end

function G.UIDEF.run_arcade_setup()
    G.run_setup_seed = nil
    G.FUNCS.false_ret = function() return false end
    G.SETTINGS.current_setup = "New Run"

    -- Get the last deck used or set the deck to the red deck
    G.GAME.viewed_back = Back(get_deck_from_name(G.PROFILES[G.SETTINGS.profile].MEMORY.deck)) or Back(G.P_CENTERS.b_red)

    -- Get the last difficulty level used or set it to the lowest difficulty
    G.viewed_stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    G.FUNCS.change_stake({to_key = G.viewed_stake})

    local lwidth, rwidth = 1.4, 1.8
    local type_colour = G.C.BLUE
    local scale = 0.39

    -- Build the deck of cards display
    local area = CardArea(
        G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
        G.CARD_W,
        G.CARD_H, 
        {card_limit = 5, type = 'deck', highlight_limit = 0, deck_height = 0.75, thin_draw = 1})

    for i = 1, 10 do
        local card = Card(G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h, G.CARD_W, G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base, {playing_card = i, viewed_back = true})
        card.sprite_facing = 'back'
        card.facing = 'back'
        area:emplace(card)
        -- if i == 10 then G.sticker_card = card; card.sticker = get_deck_win_sticker(G.GAME.viewed_back.effect.center) end
    end

    local ordered_names, viewed_deck = {}, 1
    for k, v in ipairs(G.P_CENTER_POOLS.Back) do
        ordered_names[#ordered_names+1] = v.name
        if v.name == G.GAME.viewed_back.name then viewed_deck = k end
    end

    local t =   create_UIBox_generic_options({no_back = true, no_esc = true, contents ={
        {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
            {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm", minh = 3.8}, nodes={
                    create_option_cycle({options =  ordered_names, opt_callback = 'change_viewed_back', current_option = viewed_deck, colour = G.C.RED, w = 3.5, mid = 
                    {n=G.UIT.R, config={align = "cm", minh = 3.3, minw = 5}, nodes={
                        {n=G.UIT.C, config={align = "cm", colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes={
                            {n=G.UIT.C, config={align = "cm"}, nodes={
                            {n=G.UIT.R, config={align = "cm", shadow = false}, nodes={
                                {n=G.UIT.O, config={object = area}}
                            }},
                            }},{n=G.UIT.C, config={align = "cm", minh = 1.7, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
                                {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 4, maxw = 4, minh = 0.6}, nodes={
                                {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_back_name', object = Moveable()}},
                                }},
                                {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.7, r = 0.1}, nodes={
                                {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back', object = UIBox{definition = G.GAME.viewed_back:generate_UI(), config = {offset = {x=0,y=0}}}}}
                                }}       
                            }} 
                            }}     
                        }}
                    }),
                }},
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.R, config={minh = 1.7, minw = 7.3}, nodes={
                        {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_stake2', insta_func = true, object = Moveable()}},
                    }},
                }},
                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                    {n=G.UIT.R, config={align = "cm", minh = 0.17}, nodes={}},
                    {n=G.UIT.C, config={align = "cm", minw = 5, minh = 0.8, padding = 0.2, r = 0.1, hover = true, colour = G.C.BLUE, button = "start_setup_run", shadow = true, func = 'can_start_run'}, nodes={
                        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                            {n=G.UIT.T, config={text = localize('b_play_cap'), scale = 0.8, colour = G.C.UI.TEXT_LIGHT,func = 'set_button_pip'}}
                        }}
                    }},
                }},
            }},
        }},
    }})
    return t
  end

local function on_key_pressed(key)
    if key == "f5" then
        credits.value = credits.value + 1
        play_sound('coin5')
        play_sound('coin6')

        if credits.value >= config.required_credits then
            update_main_menu_UI()
            G.CONTROLLER:snap_to{node = G.MAIN_MENU_UI:get_UIE_by_ID('main_menu_play')}
        end
    elseif key == "f6" then
        credits.value = credits.value - 1
        play_sound('coin5')
        play_sound('coin6')

        if credits.value < config.required_credits then
            update_main_menu_UI()
        end
    elseif key == "f7" then
        G.FUNCS.quit()
    end
end

local keypressed_original = love.keypressed
function love.keypressed(key)
    keypressed_original(key)
	
    G.CONTROLLER:set_gamepad(G.CONTROLLER.keyboard_controller)
    G.CONTROLLER:set_HID_flags("button")
end

local keyreleased_original = love.keyreleased
function love.keyreleased(key)
    keyreleased_original(key)
	
    G.CONTROLLER:set_gamepad(G.CONTROLLER.keyboard_controller)
    G.CONTROLLER:set_HID_flags("button")
end

return {
    on_enable = on_enable,
    on_key_pressed = on_key_pressed,
}