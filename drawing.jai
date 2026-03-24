//#import "GetRect_LeftHanded";
//Simp :: #import "Simp";

// --- Color Palette ---
SHORTCUT_COLORS :: Vector4.[
    .{1.0, 1.0, 1.0, 1.0}, // 0: White
    .{1.0, 0.0, 0.0, 1.0}, // 1: Red
    .{1.0, 0.7, 0.2, 1.0}, // 2: Orange
    .{1.0, 0.7, 0.6, 1.0}, // 3: Peach
    .{1.0, 1.0, 0.0, 1.0}, // 4: Yellow
    .{0.0, 1.0, 0.0, 1.0}, // 5: Green
    .{0.0, 1.0, 1.0, 1.0}, // 6: Cyan
    .{0.2, 0.6, 1.0, 1.0}, // 7: Light Blue
    .{0.8, 0.4, 1.0, 1.0}, // 8: Purple
    .{1.0, 0.0, 1.0, 1.0}  // 9: Magenta
];


draw_menu_frame :: (dt: float, mouse_moved: bool) -> bool {
    action_triggered_by_mouse := false;

    // Teal/Cyan background
    Simp.clear_render_target(0.12, 0.76, 0.76, 1.0);
    ui_per_frame_update(my_window, window_width, window_height, current_time);

    my_theme := default_overall_theme;

    // --- Title Label ---
    title_theme := my_theme.label_theme;
    title_theme.font = title_font; 
    title_theme.text_color = .{1.0, 1.0, 1.0, 1.0}; 

    title_h := cast(float) window_height * 0.12;
    title_rect := get_rect(0, cast(float) window_height * 0.08, cast(float) window_width, title_h);
    
    title_text := ifx menu_stack.count > 0 then "Options" else "Shortcuts App";
    label(title_rect, title_text, *title_theme);

    // --- Menu Buttons ---
    button_theme := my_theme.button_theme;
    button_theme.font = menu_font;
    button_theme.label_theme.alignment = .Left;

    // Transparent Backgrounds to make buttons look like pure text labels
    button_theme.surface_color       = .{0, 0, 0, 0};
    button_theme.surface_color_over  = .{0, 0, 0, 0};
    button_theme.surface_color_down  = .{0, 0, 0, 0};
    button_theme.surface_color_flash = .{0, 0, 0, 0};
    button_theme.frame_color         = .{0, 0, 0, 0};
    button_theme.frame_color_over    = .{0, 0, 0, 0};
    button_theme.frame_color_down    = .{0, 0, 0, 0};
    button_theme.frame_color_flash   = .{0, 0, 0, 0};

    // Text colors
    color_salmon_pink := Vector4.{0.95, 0.45, 0.50, 1.0};
    color_yellow_gold := Vector4.{0.95, 0.85, 0.20, 1.0};
    color_bright_yell := Vector4.{1.00, 0.95, 0.30, 1.0};

    button_theme.text_color_over    = color_bright_yell;
    button_theme.text_color_pressed = color_bright_yell;

    //menu_y := cast(float) window_height * 0.26;
    //item_height := cast(float) window_height * 0.055;

    // CHANGED: Create a centered "box" for the menu items rather than using the full screen width.
    // menu_w := cast(float) window_width * 0.35; // Take up 35% of the screen width
    // if menu_w < 350.0 then menu_w = 350.0;     // Ensure it doesn't get too squished on small screens
    // menu_x := (cast(float) window_width - menu_w) * 0.5; // Center it horizontally

    // --- NEW: Dynamic Menu Centering ---
    // 1. Measure the width of the longest string in the current menu
    max_text_width := 0.0;
    for current_menu {
        w := cast(float) Simp.prepare_text(menu_font, it.name);
        if w > max_text_width then max_text_width = w;
    }
    
    // 2. Create a tight bounding box around the text (adding GetRect's default left padding)
    pad := cast(float) menu_font.em_width * button_theme.label_theme.alignment_pad_ems;
    menu_w := max_text_width + (pad * 2.0); 
    menu_x := (cast(float) window_width - menu_w) * 0.5;     

    // CHANGED: Push the menu down a bit more, and increase the height of each item for breathing room
    menu_y := cast(float) window_height * 0.35;
    item_height := cast(float) window_height * 0.08; 

    for current_menu {
        //r := get_rect(0, menu_y, cast(float) window_width, item_height);
        r := get_rect(menu_x, menu_y, menu_w, item_height);

        if it_index == selected_menu_index {
            button_theme.text_color = color_yellow_gold;
        } else {
            button_theme.text_color = color_salmon_pink;
        }
        
        pressed, state := button(r, it.name, *button_theme, identifier = it_index);
        
        if (state.status & .OVER) && mouse_moved {
            selected_menu_index = it_index;
        }

        if pressed {
            selected_menu_index = it_index;
            action_triggered_by_mouse = true;
        }

        menu_y += item_height;
    }

    draw_popups();
    Simp.swap_buffers(my_window);

    return action_triggered_by_mouse;
}

draw_shortcuts_page :: (program_name: string, shortcuts:[] Shortcut_Entry) {
    // Pure arcade black background
    Simp.clear_render_target(0.0, 0.0, 0.0, 1.0);
    ui_per_frame_update(my_window, window_width, window_height, current_time);

    base_theme: Label_Theme;
    base_theme.font = arcade_font;
    
    // --- Draw Title ---
    title_theme := base_theme;
    title_theme.alignment = .Center;
    title_theme.text_color = .{0.0, 1.0, 1.0, 1.0}; // Cyan
    
    title_text := tprint("% SHORTCUTS", program_name);
    label(get_rect(0, 50, cast(float)window_width, 40), title_text, *title_theme);

    // --- Layout Math for Columns ---
    w_float := cast(float) window_width;
    
    col1_rect := get_rect(w_float * 0.15, 0, w_float * 0.20, 0); // Group
    col2_rect := get_rect(w_float * 0.35, 0, w_float * 0.35, 0); // Action
    col3_rect := get_rect(w_float * 0.70, 0, w_float * 0.15, 0); // Keys
    
    row_y := 140.0;
    row_h := 40.0;

    // --- Draw Headers ---
    header_theme := base_theme;
    header_theme.text_color = .{1.0, 1.0, 0.0, 1.0}; // Yellow
    
    header_theme.alignment = .Left;
    col1_rect.y = row_y; col1_rect.h = row_h;
    label(col1_rect, "GROUP", *header_theme);
    
    header_theme.alignment = .Left;
    col2_rect.y = row_y; col2_rect.h = row_h;
    label(col2_rect, "ACTION", *header_theme);
    
    header_theme.alignment = .Right;
    col3_rect.y = row_y; col3_rect.h = row_h;
    label(col3_rect, "KEYBINDING", *header_theme);

    // --- Draw Shortcut Entries ---
    row_y += 60.0; // Gap between header and first shortcut
    entry_theme := base_theme;

    for entry : shortcuts {
        color_idx := it_index % SHORTCUT_COLORS.count;
    
        // Group Column (Column 1) - Gray tone
        entry_theme.text_color = .{0.5, 0.5, 0.5, 1.0}; 
        entry_theme.alignment = .Left;
        col1_rect.y = row_y;
        label(col1_rect, entry.group, *entry_theme);
        
        // Action Column (Column 2) - White
        entry_theme.text_color = .{1.0, 1.0, 1.0, 1.0}; 
        entry_theme.alignment = .Left;
        col2_rect.y = row_y;
        label(col2_rect, entry.action, *entry_theme);
        
        // Keybindings Column (Column 3) - Pacman Palette
        entry_theme.text_color = SHORTCUT_COLORS[color_idx];
        entry_theme.alignment = .Right;
        col3_rect.y = row_y;
        label(col3_rect, entry.keys, *entry_theme);
        
        row_y += row_h;
        /*
        color_idx := it_index % SHORTCUT_COLORS.count;
        entry_theme.text_color = SHORTCUT_COLORS[color_idx];
        entry_theme.alignment = .Left;
        col1_rect.y = row_y;
        label(col1_rect, entry.group, *entry_theme);
        
        entry_theme.alignment = .Left;
        col2_rect.y = row_y;
        label(col2_rect, entry.action, *entry_theme);
        
        entry_theme.alignment = .Right;
        col3_rect.y = row_y;
        label(col3_rect, entry.keys, *entry_theme);
        
        row_y += row_h;
        */
    }

    // --- Draw Pinky the Ghost ---
    ghost_x := col3_rect.x + col3_rect.w - 36.0; 
    draw_retro_ghost(ghost_x, row_y + 15.0);

    // --- Draw Footer ---
    footer_theme := base_theme;
    footer_theme.alignment = .Left;
    footer_theme.text_color = .{1.0, 1.0, 1.0, 1.0}; // White
    label(get_rect(50, cast(float)(window_height - 60), 300, 40), "ESC TO RETURN", *footer_theme);

    draw_popups();
    Simp.swap_buffers(my_window);
}

draw_retro_ghost :: (x: float, y: float) {
    Simp.set_shader_for_color(true);
    
    body_color := Vector4.{0.98, 0.55, 0.65, 1.0}; // Pinky
    white      := Vector4.{1.0, 1.0, 1.0, 1.0};
    blue       := Vector4.{0.1, 0.2, 0.8, 1.0};

    w := 36.0;
    h := 28.0;
    
    Simp.immediate_quad(x, y+8, x+w, y+h, body_color);
    Simp.immediate_quad(x+6, y, x+w-6, y+8, body_color);
    Simp.immediate_quad(x,    y+h, x+10, y+h+8, body_color);
    Simp.immediate_quad(x+13, y+h, x+23, y+h+8, body_color);
    Simp.immediate_quad(x+26, y+h, x+36, y+h+8, body_color);

    Simp.immediate_quad(x+6,  y+10, x+14, y+20, white);
    Simp.immediate_quad(x+20, y+10, x+28, y+20, white);

    Simp.immediate_quad(x+10, y+14, x+14, y+19, blue);
    Simp.immediate_quad(x+24, y+14, x+28, y+19, blue);

    Simp.immediate_flush();
}

