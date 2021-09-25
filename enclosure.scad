include <pico.scad>;
include <utilities.scad>;

pillar_h = 3;
pillar_d_inner = 3;
pillar_d_outer = 6;
pillar_insert_depth = 1;

case_insert_d = 3.3;
case_insert_h = 5;

usb_hole_clearance = 2;
usb_hole_x = usb_x + usb_hole_clearance;
usb_hole_z = usb_z + usb_hole_clearance;

wall_thickness = 2;

port_leeway = 0.3;
serial_x = 10;
serial_y = 6;
serial_z = 7;
debug_x = 12.4;
debug_y = 6;
debug_z = 7;

connector_pcb_x = 25.6 - 2.54;
connector_pcb_y = 15;
connector_pcb_z = 1.6;
debug_y_offset = 1.7;
connector_x_offset = 7.9;
connector_hole_d = 2.6;
connector_hole_separation = 2.54 * 7;
connector_pcb_pillar_h = debug_z - wall_thickness;
connector_pcb_pico_separation = 2;
connector_hole_countersink_depth = 2;
lid_insert_depth = 1.5;

corner_radius = case_insert_d / 2 + wall_thickness;
corner_clearance = 1;
enclosure_x = connector_pcb_x + 2 * (case_insert_d + wall_thickness + corner_clearance);
enclosure_y = pico_y + corner_clearance;
enclosure_z = connector_pcb_y + pico_z + pillar_h + connector_pcb_pico_separation + lid_insert_depth;

light_pipe_diameter = 3.3;
light_pipe_support_depth = enclosure_z - pico_z - pillar_h - usb_z - 1;

button_presser_d = 5;

module connector_pcb_holes(){
    translate([-connector_hole_separation/2,0,0]){
        children();
    }
    translate([connector_hole_separation/2,0,0]){
        children();
    }
}

module connector_pcb_serial_pos(){
    translate([connector_x_offset + (serial_x - connector_pcb_x)/2, debug_y_offset +  (serial_y - connector_pcb_y)/2,(serial_z + connector_pcb_z)/2]){
        children();
    }
}

module connector_pcb_debug_pos(){
    translate([0, (connector_pcb_y - debug_y)/2,(debug_z + connector_pcb_z)/2]) {
        children();
    }
}

module connector_pcb_pos(){
    pico_top_pos = pico_z- enclosure_z/2 + pillar_h;
    sep = pico_top_pos + connector_pcb_y/2;
    translate([0, connector_pcb_pillar_h + connector_pcb_z/2 -enclosure_y/2, sep + connector_pcb_pico_separation]){
        rotate([90, 0, 0]){
            children();
        }
    }
}

switch_x_centre = enclosure_x / 2;
switch_y_centre = 0;
switch_z_centre = enclosure_z / 6;

module switch_pos(){
    translate([switch_x_centre, switch_y_centre, switch_z_centre]){
        children();
    }
}

switch_width = 10.2;
switch_height = 2.7;
switch_pillar_h = 4.5;
switch_pillar_sep = 20.32;

module switch_pcb_holes() {
    switch_pos(){
        for(pos = [[0, -switch_pillar_sep/2, 0,], [0, switch_pillar_sep/2, 0,]]){
            translate(pos){
                rotate([0, 90, 0]){
                    children();
                }
            }
        }
    }
}


module connector_pcb(){
    union(){
        difference(){
            cube([connector_pcb_x, connector_pcb_y, connector_pcb_z], center=true);
            
            connector_pcb_holes(){
                cylinder(h=2*connector_pcb_z, d=connector_hole_d, center=true, $fn =20);
            }
        }
        connector_pcb_serial_pos(){
            cube([serial_x, serial_y, serial_z], center=true);
        }
        connector_pcb_debug_pos(){
            cube([debug_x, debug_y, debug_z], center=true);
        }
    }
}

module enclosure_shape(){
    union(){
        // Basic outline
        difference(){
            rounded_rectangle(enclosure_x + 2* wall_thickness, enclosure_y + 2* wall_thickness, enclosure_z + 2* wall_thickness, corner_radius);
            rounded_rectangle(enclosure_x, enclosure_y, enclosure_z, corner_radius);
        }
        // Corner radii for case bolts
        difference(){
            intersection(){
                cube([enclosure_x, enclosure_y, enclosure_z], center=true);
        
                corners(enclosure_x - case_insert_d, enclosure_y - case_insert_d){
                    cylinder(r = corner_radius, h = enclosure_z, center=true, $fn=20);
                }
            }
        }
    }
}



module enclosure_main(){
    difference(){
        union(){
            enclosure_shape();
            
            // Pillars for connector PCB
            connector_pcb_pos(){
                connector_pcb_holes(){
                    translate([-0,0, (connector_pcb_pillar_h + connector_pcb_z)/2]){
                        difference(){
                            cylinder(d=pillar_d_outer, h= connector_pcb_pillar_h, center=true, $fn=20);
                            cylinder(d=connector_hole_d, h= connector_pcb_pillar_h + 1, center=true, $fn=20);
                        }
                    }
                }
            }
            
            // Pillars for switch PCB
            switch_pcb_holes(){
                translate([0, 0, -switch_pillar_h/2]){
                    difference(){
                        cylinder(d=pillar_d_outer, h= switch_pillar_h, center=true, $fn=20);
                        cylinder(d=connector_hole_d, h= switch_pillar_h + 1, center=true, $fn=20);
                    }
                }
            }
            
            // Base pillars to support pico
            translate([0,0,(pillar_h-enclosure_z)/2]){
                pico_holes(){
                    difference(){
                        cylinder(d=pillar_d_outer, h= pillar_h, center=true, $fn=20);
                        cylinder(d=pillar_d_inner, h= pillar_h + 1, center=true, $fn=20);
                    }
                }
            }
        }
        // Extra depth for Pico pillar inserts
        translate([0,0,(-enclosure_z)/2]){
            pico_holes(){
                difference(){
                    cylinder(d=pillar_d_inner, h= 2 * pillar_insert_depth, center=true, $fn=20);
                }
            }
        }
        // Remove top
        translate([0, 0, enclosure_z/2 + wall_thickness]){
            cube([2 * enclosure_x, 2 * enclosure_y, 2 * wall_thickness], center=true);
        }
        // Add holes for corner heat-set inserts
        corners(enclosure_x - case_insert_d, enclosure_y - case_insert_d){
            translate([0, 0, (enclosure_z - case_insert_h)/2]){
                cylinder(d=case_insert_d, h=case_insert_h, center=true, $fn=20);
            }
        }
        // Hole for Pico USB port
        translate([0, 0,  pillar_h + pico_z + (usb_hole_z - usb_hole_clearance -enclosure_z)/2]){
            pico_usb(){
                cube([usb_hole_x, usb_y + corner_clearance  + 2* wall_thickness, usb_hole_z], center=true);
            }
        }
        
        // Switch PCB holes
        switch_pcb_holes(){
            translate([0,0,wall_thickness]){
                rotate([180,0,0]){
                    bolt_hole(connector_hole_d, connector_hole_countersink_depth);
                }
            }
        }
        
        // Switch hole
        switch_pos(){
            cube([3 * wall_thickness, switch_width, switch_height], center=true);
        }
        
        // Debug and serial output holes
        connector_pcb_pos(){
            connector_pcb_serial_pos(){
                cube([serial_x + 2 * port_leeway, serial_y + 2 * port_leeway, serial_z * 2], center=true);
            }
            connector_pcb_debug_pos(){
                cube([debug_x + 2 * port_leeway, debug_y + 2 * port_leeway, debug_z * 2], center=true);
            }
            
            // Connector PCB mounting bolt holes
            connector_pcb_holes(){
                translate([-0,0,connector_pcb_pillar_h + wall_thickness + connector_pcb_z/2 + 0.001]){
                    rotate([180,0,0]){
                        bolt_hole(connector_hole_d, connector_hole_countersink_depth);
                    }
                }
            }

        }
    }
}

module enclosure_lid(){
    union(){
        difference(){
            enclosure_shape();
            // Remove top
            translate([0, 0, - wall_thickness]){
                cube([2 * enclosure_x, 2 * enclosure_y, enclosure_z + 2 * wall_thickness], center=true);
            }
            
            // Light pipe top hole
            pico_led(){
                translate([0,0,(enclosure_z - light_pipe_support_depth)/2]){
                    cylinder(d=light_pipe_diameter, h=enclosure_z *2, $fn=20);
                }
            }
            
            // Button presser hole
            pico_button(){
                cylinder(d=button_presser_d, h=enclosure_z *2, $fn=20);
            }
            
            // Bolt holes
            corners(enclosure_x - case_insert_d, enclosure_y - case_insert_d){
                translate([0, 0, (enclosure_z)/2 + wall_thickness]){
                    rotate([180, 0, 0]){
                        bolt_hole(connector_hole_d, connector_hole_countersink_depth);
                    }
                }
            }
        }
        
        // Light pipe support tube
        pico_led(){
            translate([0,0,(enclosure_z - light_pipe_support_depth)/2]){
                difference(){
                    cylinder(d=light_pipe_diameter + wall_thickness, h= light_pipe_support_depth, center=true, $fn=20);
                    cylinder(d=light_pipe_diameter, h= light_pipe_support_depth + 1, center=true, $fn=20);
                }
            }
            
        }
        
        
        // Lid inner ridge
        difference(){
            xy_inset(wall_thickness){
                difference(){
                    cube([enclosure_x, enclosure_y, enclosure_z], center=true);
                    enclosure_shape();
                }
            }
    
            translate([0,0,-lid_insert_depth]){
                cube([2 * enclosure_x, 2 * enclosure_y, enclosure_z], center=true);
            }
        }        
    }
}

module button_presser(){
    
}

translate([0,0,(pico_z-enclosure_z)/2 + pillar_h]){
    pico();
}


connector_pcb_pos(){
//    connector_pcb();
}

translate([0,0,0]){
//    enclosure_lid();
}

difference(){

    union(){
        enclosure_main();
        enclosure_lid();
    }
//    translate([0, 70,0]){
//        cube([100, 100, 100], center=true);
//    }
//    
    translate([0,-50,0]){
//        cube([100, 100, 100], center=true);
    }
//    translate([-50,0,0]){
//        cube([100, 100, 100], center=true);
//    }
//    
//    translate([0,0,-50]){
//        cube([100, 100, 100], center=true);
//    }
}