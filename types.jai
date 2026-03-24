#import "Math"; 

Menu_Item_Type :: enum {
    LEAF;
    SUBMENU;
}

Menu_Item :: struct {
    name    : string;
    type    : Menu_Item_Type;
    action  : () -> ();        // Used if type == .LEAF
    submenu :[] Menu_Item;    // Used if type == .SUBMENU
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

