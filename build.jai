#import "Basic";
#import "Compiler";

#run {
    set_build_options_dc(.{do_output=false});
    w := compiler_create_workspace();    
    options := get_build_options(w);
    options.output_executable_name = "shortcuts";    
    // Set the subsystem to Windows to hide the console
    options.additional_linker_arguments = .["/SUBSYSTEM:WINDOWS", "/ENTRY:mainCRTStartup"];
    set_build_options(options, w);
    add_build_file("shortcuts.jai", w);
    
}
