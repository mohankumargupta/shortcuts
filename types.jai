#import "Math"; 

Menu_Item_Type :: enum {
    ACTION;
    PAGE;
    SUBMENU;
}

Menu_Item :: struct {
    name    : string;
    type    : Menu_Item_Type;
    action  : () -> ();        // Used if type == .ACTION
    submenu :[] Menu_Item;    // Used if type == .SUBMENU
    shortcuts:[] Shortcut_Entry; // Used if type == .PAGE
}

Menu_State :: struct {
    menu  :[] Menu_Item;
    index : int;
}

Shortcut_Entry :: struct {
    group  : string;
    action : string;
    keys   : string;
}

