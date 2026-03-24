//#import "Basic";

// --- SHORTCUT DATA ---

vscode_shortcuts :: Shortcut_Entry.[
    .{"FILE",   "New Window",             "Ctrl+Shift+N"	},
    .{"FILE",   "Save As",                "Ctrl+Shift+S"	}, 
    .{"EDIT",   "Find in Files",          "Ctrl+Shift+F"	},
    .{"EDIT",   "Replace",                "Ctrl+H"			},
    .{"VIEW",   "Command Palette",        "Ctrl+Shift+P"	},
    .{"VIEW",   "Toggle Terminal",        "Ctrl+`"			},
    .{"CURSOR", "Add Multi-Cursor",       "Alt+Click"		},
    .{"CURSOR", "Move Line Up/Down",      "Alt+Up/Down"		},
    .{"DEBUG",  "Start Debugging",        "F5"				},
    .{"DEBUG",  "Step Over",              "F10"				}
];

micro_shortcuts :: Shortcut_Entry.[
    .{"CMD",    "Run command",            "Ctrl+B"          },
    .{"CMDS",   "Quit",                   "Ctrl+Q"          },
    .{"FIND",   "Find",                   "Ctrl+F"          }, 
    .{"FIND",   "Find next",              "Ctrl+N"          }, 
    .{"FIND",   "Find previous",          "Ctrl+P"          }, 
    .{"GOTO",   "Goto line number",       "Ctrl+I"	        }, 
    .{"GOTO",   "Goto first line",        "Ctrl+Up"			}, 
    .{"GOTO",   "Goto last line",         "Ctrl+Down"		}, 
    .{"GOTO",   "Goto start of line",     "Alt+A"		}, 
    .{"CMDS",   "Goto end of line",       "Alt+E"			}
];


// --- MENU ACTIONS ---

action_show_vscode :: () { 
    in_leaf_page       = true; 
    current_leaf_title = "VS CODE";
    current_leaf_data  = vscode_shortcuts; 
}

action_show_micro :: () { 
    in_leaf_page       = true; 
    current_leaf_title = "MICRO EDITOR";
    current_leaf_data  = micro_shortcuts; 
}

action_dummy :: () { 
    print("Action Triggered: Placeholder Function\n"); 
}

action_quit :: () { 
    global_quit = true; 
}

// Navigates up a folder if we are deep in a menu
menu_back :: () {
    if menu_stack.count > 0 {
        state := pop(*menu_stack);
        current_menu = state.menu;
        selected_menu_index = state.index;
    }
}

// Navigates down a folder 
go_to_submenu :: (submenu:[] Menu_Item) {
    array_add(*menu_stack, .{current_menu, selected_menu_index});
    current_menu = submenu;
    selected_menu_index = 0;
}


// --- MENU DEFINITIONS ---

options_menu :: Menu_Item.[
    .{ name = "Keyboard Controls", type = .LEAF, action = action_dummy },
    .{ name = "Gamepad Controls",  type = .LEAF, action = action_dummy },
    .{ name = "Music: On",         type = .LEAF, action = action_dummy },
    .{ name = "Back",              type = .LEAF, action = menu_back }
];

main_menu :: Menu_Item.[
    .{ name = "VSCode",  type = .LEAF,    action = action_show_vscode },
    .{ name = "micro",   type = .LEAF,    action = action_show_micro },
    .{ name = "Options", type = .SUBMENU, submenu = options_menu },
    .{ name = "Quit",    type = .LEAF,    action = action_quit }
];

