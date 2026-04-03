#import "Basic";
#import "Math";
#import "Window_Creation";
#import "File";
Input :: #import "Input";
Simp  :: #import "Simp";
#import "GetRect_LeftHanded";
Sound :: #import "Sound_Player";

// #load includes other source files into the EXACT SAME SCOPE.
// They don't need to be compiled separately or imported.
#load "types.jai";
#load "menus.jai";
#load "drawing.jai";

// --- COMPILE-TIME ASSET EMBEDDING ---
embed_file :: (filepath: string) -> string {
    data, success := read_entire_file(filepath);
    if !success print("Warning: Failed to load file at compile time: %\n", filepath);
    return data;
}

// The compiler runs the function and bakes the returned bytes into the .exe
CLICK_WAV_DATA :: #run embed_file("click.wav");
FONT_DATA      :: #run embed_file("Karla-Regular.ttf");
// ------------------------------------

// --- GLOBAL APPLICATION STATE ---
window_width  : s32 = 1380;
window_height : s32 = 720;
my_window     : Window_Type;

current_time : float64;
last_time    : float64;

arcade_font : *Simp.Dynamic_Font;
title_font  : *Simp.Dynamic_Font;
menu_font   : *Simp.Dynamic_Font;

// State properties shared with menus.jai and drawing.jai
global_quit         := false;
current_menu        : [] Menu_Item;
menu_stack          : [..] Menu_State;

in_leaf_page        := false;
current_leaf_title  := "";
current_leaf_data   :[] Shortcut_Entry;

selected_menu_index : int = 0;
last_mouse_x        : int;
last_mouse_y        : int;

ITEMS_PER_PAGE      :: 10; 
current_leaf_page   : int = 0;

main :: () {
    // 1. App Startup
    current_menu = main_menu;

    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    my_window = create_window(window_width, window_height, "Shortcuts App");
    Simp.set_render_target(my_window, .LEFT_HANDED);
    ui_init();

    // 2. Load Fonts
    //font_path := ".";
    //font_name := "Karla-Regular.ttf"; 
    //arcade_font = Simp.get_font_at_size(font_path, font_name, 28);
    font_bytes := cast([] u8) FONT_DATA;
    title_font  = Simp.get_font_at_size(font_bytes, 64);
    menu_font   = Simp.get_font_at_size(font_bytes, 42);
    arcade_font = Simp.get_font_at_size(font_bytes, 28);
    
    if !title_font || !menu_font || !arcade_font {
        print("Warning: Failed to load fonts from embedded data!\n");
    }

    // 3. Load Audio
    sound_success := Sound.sound_player_init(.{});
    if !sound_success print("Warning: Failed to initialize Sound_Player.\n");
    
    click_sound := Sound.load_audio_data("click.wav", CLICK_WAV_DATA);
    click_sound.volume_scale = 0.3; // Lower base volume globally
    if !click_sound.loaded print("Warning: Could not load click data\n");

    // Grab starting mouse position
    last_mouse_x, last_mouse_y, _ = get_mouse_pointer_position(my_window, false);

    // 4. Main App Loop
    while !global_quit {
        current_time = seconds_since_init();
        dt := cast(float)(current_time - last_time);
        Clamp(*dt, 0, 0.1);
        last_time = current_time;

        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);
            if it.window == my_window {
                window_width  = it.width;
                window_height = it.height;
            }
        }

        // Calculate Mouse deltas
        mouse_x, mouse_y, _ := get_mouse_pointer_position(my_window, false);
        mouse_moved := (mouse_x != last_mouse_x) || (mouse_y != last_mouse_y);
        last_mouse_x = mouse_x;
        last_mouse_y = mouse_y;

        // Route A: We are rendering a Leaf (Shortcuts) Page
        if in_leaf_page {
            for event: Input.events_this_frame {
                if event.type == .QUIT then global_quit = true;
                if event.type == .KEYBOARD && event.key_pressed  {
                    if event.key_code == .ESCAPE || event.key_code == .BACKSPACE {
                       in_leaf_page = false; // Go back to the menu!
                    } else if event.key_code == .ARROW_LEFT || event.key_code == .ARROW_UP {
                       // Previous Page
                       if current_leaf_page > 0 then current_leaf_page -= 1;
                    } else if event.key_code == .ARROW_RIGHT || event.key_code == .ARROW_DOWN {
                       // Next Page
                       max_pages := (current_leaf_data.count + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE;
                       if current_leaf_page < max_pages - 1 then current_leaf_page += 1;
                   } 
                }
                
                getrect_handle_event(event);
            }
            
            draw_shortcuts_page(current_leaf_title, current_leaf_data);
            
        } 
        // Route B: We are rendering a Main Menu
        else {
            action_triggered := false;
            previous_menu_index := selected_menu_index;

            for event: Input.events_this_frame {
                if event.type == .QUIT then global_quit = true;
                
                // Handle Keyboard Navigation
                if event.type == .KEYBOARD && event.key_pressed {
                    if event.key_code == .ARROW_UP {
                        selected_menu_index -= 1;
                        if selected_menu_index < 0 then selected_menu_index = current_menu.count - 1;
                    } else if event.key_code == .ARROW_DOWN {
                        selected_menu_index += 1;
                        if selected_menu_index >= current_menu.count then selected_menu_index = 0;
                    } else if event.key_code == .ENTER || event.key_code == #char " " {
                        action_triggered = true;
                    } else if event.key_code == .ESCAPE || event.key_code == .BACKSPACE {
                        menu_back();
                    }
                }

                getrect_handle_event(event);
            }

            // Render Menu Frame
            mouse_clicked := draw_menu_frame(dt, mouse_moved);

            // Audio Feedback on selection change
            if selected_menu_index != previous_menu_index {
                if click_sound.loaded {
                    stream := Sound.make_stream(*click_sound, .UI);
                    if stream then Sound.start_playing(stream);
                }
            }

            // Execute menu actions
            if action_triggered || mouse_clicked {
                item := current_menu[selected_menu_index];
                
                if item.type == .SUBMENU {
                    go_to_submenu(item.submenu);
                } else if item.type == .ACTION {
                    if item.action then item.action();
                } else if item.type == .PAGE {
                    // Generic data-driven page routing!
                    in_leaf_page       = true;
                    current_leaf_page  = 0;
                    current_leaf_title = item.name;       // Uses the string from the Menu_Item
                    current_leaf_data  = item.shortcuts;  // Feeds the array to the drawing function
                }            
            }
        }

        // Housekeeping
        Sound.update();
        reset_temporary_storage();
        sleep_milliseconds(10);
    }
    
    Sound.sound_player_shutdown();
}

