### By Damian Brakel ###
set plugin_name "auto_load_profile"


namespace eval ::plugins::${plugin_name} {
    variable author "Damian"
    variable contact "via Diaspora"
    variable description "This app extension allows you to set a profile to auto load when the app starts or wakes from sleep"
    variable version 1.0.0
    variable min_de1app_version {1.40.1}

    proc build_ui {} {
        # Unique name per page
        set page_name "auto_load_profile"
        dui page add $page_name
        set background_colour #fff
        set disabled_colour #ccc
        set foreground_colour #2b6084
        set button_label_colour #fAfBff
        set text_colour #2b6084
        set red #DA515E
        set green #0CA581
        set blue #49a2e8
        set brown #A1663A
        set orange #fe7e00
        set font "notosansuiregular"
        set font_bold "notosansuibold"


        if {![info exist ::settings(auto_load_profile_filename)]} {
            set ::settings(auto_load_profile_filename) No
            set ::settings(auto_load_profile_title) No
        }
        dui add canvas_item rect $page_name 0 0 2560 1600 -fill $background_colour -width 0
        dui add dtext $page_name 1280 240 -text [translate "Auto Load Profile"] -font [dui font get $font_bold 28] -fill $text_colour -anchor "center" -justify "center"
        dui add variable $page_name 2510 1560 -font [dui font get $font 12] -fill $text_colour -anchor e -justify right -textvariable {Version $::plugins::auto_load_profile::version  by $::plugins::auto_load_profile::author}

        dui add variable $page_name 990 600 -font [dui font get $font 18] -fill $text_colour -anchor e -justify right -width 800 -textvariable {auto load profile = $::settings(auto_load_profile_title)}
        dui add variable $page_name 990 740 -font [dui font get $font 18] -fill $text_colour -anchor e -justify right -textvariable {current profile = $::settings(profile_title)}
        dui add variable $page_name 1660 650 -font [dui font get $font 16] -fill $orange -anchor w -width 600 -textvariable {$::settings(auto_load_profile_title) [translate "profile will automatically load when the app starts up or wakes from sleep"]}
        dui add dbutton $page_name 1030 540 \
            -bwidth 500 -bheight 120 \
            -shape round -fill $foreground_colour -radius 60 \
            -label [translate "clear auto load"] -label_font [dui font get $font_bold 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {set ::settings(auto_load_profile_filename) "No"; set ::settings(auto_load_profile_title) "No"; save_settings}
        dui add dbutton $page_name 1030 680 \
            -bwidth 500 -bheight 120 \
            -shape round -fill $foreground_colour -radius 60 \
            -label [translate "set to auto load"] -label_font [dui font get $font_bold 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {set ::settings(auto_load_profile_filename) $::settings(profile_filename); set ::settings(auto_load_profile_title) $::settings(profile_title); save_settings}
        dui add dbutton $page_name 1080 1200 \
            -bwidth 400 -bheight 120 \
            -shape round -fill $foreground_colour -radius 60 \
            -label [translate "Exit"] -label_font [dui font get $font_bold 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {if {$::settings(skin) == "DSx"} {restore_DSx_live_graph}; set_next_page off off; dui page load off; }

    return $page_name
    }

    proc load_profile { args } {
        if {$::settings(auto_load_profile_filename) != "No"} {
            select_profile $::settings(auto_load_profile_filename)
            if {$::settings(settings_profile_type) == "settings_2c2" || $::settings(settings_profile_type) == "settings_2c"} {
                array set ::current_adv_step [lindex $::settings(advanced_shot) 0]
            }
            save_settings_to_de1
            save_settings
            de1_send_steam_hotwater_settings
            set ::settings(profile_has_changed) 0
            profile_has_changed_set_colors
            update_de1_explanation_chart
            fill_profiles_listbox
        }
    }

    proc auto_load_profile_listener {} {
        ::register_state_change_handler Sleep Idle ::plugins::auto_load_profile::load_profile
    }

    proc main {} {
        auto_load_profile_listener
        ::plugins::auto_load_profile::load_profile
        plugins gui auto_load_profile [build_ui]
    }
}
