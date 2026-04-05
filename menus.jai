//#import "Basic";

// --- SHORTCUT DATA ---

vscode_shortcuts :: Shortcut_Entry.[
    .{"FILE",   "New Window",             "Ctrl+Shift+N"				},
    .{"FILE",   "Save As",                "Ctrl+Shift+S"				}, 
    .{"EDIT",   "Find in Files",          "Ctrl+Shift+F"				},
    .{"EDIT",   "Replace",                "Ctrl+H"						},
    .{"VIEW",   "Command Palette",        "Ctrl+Shift+P"				},
    .{"VIEW",   "Toggle Terminal",        "Ctrl+`"						},
    .{"CURSOR", "Add Multi-Cursor",       "Alt+Click"					},
    .{"CURSOR", "Move Line Up/Down",      "Alt+Up/Down"					},
    .{"DEBUG",  "Start Debugging",        "F5"							},
    .{"DEBUG",  "Step Over",              "F10"							},
];

micro_shortcuts :: Shortcut_Entry.[
    .{"CMD",    "Run command",            "Ctrl+B"          			},
    .{"CMD",    "Command palette",        "Ctrl+E"          			},
    .{"FIND",   "Find",                   "Ctrl+F"          			}, 
    .{"FIND",   "Find next",              "Ctrl+N"          			}, 
    .{"FIND",   "Find previous",          "Ctrl+P"          			}, 
    .{"GOTO",   "Goto first line",        "Ctrl+Up"						}, 
    .{"GOTO",   "Goto last line",         "Ctrl+Down"					}, 
    .{"GOTO",   "Goto start of line",     "Alt+A"		    			}, 
    .{"CMDS",   "Goto end of line",       "Alt+E"						},
    .{"LINE",   "Duplicate line",         "Ctrl+D"						},
    .{"LINE",   "Move line down",         "Alt+Down"	   			    }, 
    .{"LINE",   "Move line up",           "Alt+Up"	       			    }, 
    .{"LINE",   "Goto line number",       "Ctrl+I"	       			    }, 
    .{"LINE",   "Delete line",            "Ctrl+k"	       			    }, 
    .{"LINE",   "Copy line",       		  "Ctrl+D,Ctrl+k"	            },
    .{"CURSOR", "Multiple cursors",       "Alt+Shift+Down"	 		    },
     
];
//TODO: When we add pagination, want to add Command palette commands, eg, help defaultkeys, replaceall "^\+" ""

tmux_shortcuts :: Shortcut_Entry.[
    .{"PANE",    "Split horizontally",  "Prefix + \""     				},
    .{"PANE",    "Split vertically",    "Prefix + %"      				},
    .{"WINDOW",  "Create window",       "Prefix + c"      				},
    .{"WINDOW",  "Next window",         "Prefix + n"      				},
    .{"WINDOW",  "Previous window",     "Prefix + p"      				},
    .{"SESSION", "Detach session",      "Prefix + d"      				},
    .{"WINDOW",  "List windows",        "Prefix + w"      				},
    .{"PANE",    "Switch pane",         "Prefix + Arrows" 				},
    .{"PANE",    "Toggle pane zoom",    "Prefix + z"      				},
    .{"COPY",    "Enter copy mode",     "Prefix + ["      				}
];

freecad_shortcuts :: Shortcut_Entry.[
    .{"VIEW",    "Reset View",    		"0vf" 		     				},

];

prusa_slicer_shortcuts :: Shortcut_Entry.[
    .{"VIEW",    "Iso view",    		"0"			      				},
    .{"VIEW",    "Top view",    		"1"      						},
];





// --- MENU ACTIONS ---


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
    .{ name = "Keyboard Controls", type = .ACTION, action = action_dummy },
    .{ name = "Gamepad Controls",  type = .ACTION, action = action_dummy },
    .{ name = "Music: On",         type = .ACTION, action = action_dummy },
    .{ name = "Back",              type = .ACTION, action = menu_back }
];



main_menu :: Menu_Item.[
    .{ name = "vscode",  		type = .PAGE,    shortcuts = vscode_shortcuts 	},
    .{ name = "micro",   		type = .PAGE,    shortcuts = micro_shortcuts 	},
    .{ name = "tmux",   		type = .PAGE,    shortcuts = tmux_shortcuts 	},
    .{ name = "freecad",   		type = .PAGE,    shortcuts = freecad_shortcuts 	},
    .{ name = "prusaslicer",   	type = .PAGE,    shortcuts = prusa_slicer_shortcuts 	},
    .{ name = "Quit",    		type = .ACTION,    action = action_quit 		}
];

// .{ name = "Options", type = .SUBMENU, submenu = options_menu },



