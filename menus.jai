

vscode_shortcuts :: Shortcut_Entry.[
    .{"VIEW",   "Command Palette",        "Ctrl+Shift+P"				},
    .{"VIEW",   "Toggle Terminal",        "Ctrl+`"						},
    .{"CURSOR", "Add Multi-Cursor",       "Ctrl+Alt+Up/Down"			},
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
    .{"COPY",    "Enter copy mode",     "Prefix + ["      				},
    .{"COPY",    "Start select",     	"Ctrl + Space"      			},
    .{"COPY",    "End select",	     	"Alt + w"      					},
    .{"COPY",    "Paste",	     		"Prefix + ]"      					},
    
];

emacs_shortcuts :: Shortcut_Entry.[
	    .{"VIEW",    "Exit",    		"C-x C-c" 		     				},
];
	    


freecad_shortcuts :: Shortcut_Entry.[
    .{"VIEW",    "Reset View",    		"0vf" 		     				},

];

prusa_slicer_shortcuts :: Shortcut_Entry.[
    .{"VIEW",    "Iso view",    		"0"			      				},
    .{"VIEW",    "Top view",    		"1"      						},
];

tinkercad_shortcuts :: Shortcut_Entry.[
    .{"BASIC",    "Drop to ground",    	"D"			      				},
    .{"BASIC",    "Duplicate",    		"Ctrl+D"      					},	
    .{"BASIC",    "Align",    		    "L"		      					},	
    .{"BASIC",    "Group",    		    "Ctrl+G"		     			},	
    .{"BASIC",    "Ungroup",    		"Ctrl+Shift+G"		     		},
    .{"VIEW",     "Transparency",    	"T"					     		},
    .{"SKETCH",   "Straight Line",    	"1"					     		},
    .{"SKETCH",   "Curve",		    	"2"					     		},
    .{"SKETCH",   "Break Handle",    	"3"					     		},
    
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
    .{ name = "Keyboard Controls",	type = .ACTION, action = action_dummy 					},
    .{ name = "Gamepad Controls",	type = .ACTION, action = action_dummy 					},
    .{ name = "Music: On",			type = .ACTION, action = action_dummy 					},
    .{ name = "Back",              	type = .ACTION, action = menu_back 	  					},
];

// main_menu :: Menu_Item.[
//     .{ name = "vscode",  			type = .PAGE,    shortcuts = vscode_shortcuts 			},
//     .{ name = "micro",   			type = .PAGE,    shortcuts = micro_shortcuts 			},
//     .{ name = "tmux",   			type = .PAGE,    shortcuts = tmux_shortcuts 			},
//     .{ name = "tinkercad",   		type = .PAGE,    shortcuts = tinkercad_shortcuts 		},
//     .{ name = "freecad",   			type = .PAGE,    shortcuts = freecad_shortcuts 			},
//     .{ name = "prusaslicer",   		type = .PAGE,    shortcuts = prusa_slicer_shortcuts 	},
//     .{ name = "Quit",    			type = .ACTION,    action = action_quit 				},
// ];

// .{ name = "Options", type = .SUBMENU, submenu = options_menu },

// main_menu array generated
#insert #run -> string {
    builder: String_Builder;

    // Start building the static array literal
    append(*builder, "main_menu :: Menu_Item.[\n");

    // Read the source code of this exact file
    file_content, success := read_entire_file("menus.jai");
    if !success return "main_menu :: Menu_Item.[];\n";

    lines := split(file_content, "\n");

    // We split these markers into variables so the parser doesn't accidentally
    // match the code inside this #run block!
    marker_a := "_shortcuts";
    marker_b := ":: Shortcut_Entry";

    for line: lines {
        // Look for any line that defines a shortcut array
        if contains(line, marker_a) && contains(line, marker_b) && !contains(line, "marker_a") {

            // Extract the app's name (e.g., from "vscode_shortcuts ::", we get "vscode")
            parts := split(line, marker_a);
            if parts.count > 0 {
                app_name := trim(parts[0]);

                // Write out the menu item entry for this shortcut array
                print_to_builder(*builder, "    .{ name = \"%\", type = .PAGE, shortcuts = %_shortcuts },\n", app_name, app_name);
            }
        }
    }

    // Add your manual/fixed entries at the very bottom
    append(*builder, "    .{ name = \"Quit\", type = .ACTION, action = action_quit },\n");
    append(*builder, "];\n");

    generated_code := builder_to_string(*builder);
    //print("\n--- GENERATED MAIN MENU ---\n%\n---------------------------\n", generated_code);
    
    return generated_code;
};


#import "Basic";
#import "String";
#import "File";

