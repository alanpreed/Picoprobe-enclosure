include <pico.scad>;

pillar_h = 3;
pillar_d_inner = 3;
pillar_d_outer = 6;

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
connector_hole_countersink_depth = 1.4;
lid_insert_depth = 1.5;



corner_radius = case_insert_d / 2 + wall_thickness;
corner_clearance = 1;
enclosure_x = connector_pcb_x + 2 * (case_insert_d + wall_thickness + corner_clearance);
enclosure_y = pico_y + corner_clearance;
enclosure_z = connector_pcb_y + pico_z + pillar_h + connector_pcb_pico_separation + lid_insert_depth;

light_pipe_diameter = 3.1;
light_pipe_support_depth = enclosure_z - pico_z - pillar_h - usb_z - 1;





module corners(x_size, y_size){
    for(p = [[x_size/2, y_size/2, 0],
            [-x_size/2, y_size/2, 0],
            [-x_size/2, -y_size/2, 0],
            [x_size/2, -y_size/2, 0]]) {
        translate(p){
            children();
        }
    }
}

module rounded_rectangle(x, y, z, radius){
    union(){
        cube([x - 2 * radius, y, z], center=true);
        cube([x, y - 2 * radius, z], center=true);

        corners(x - 2 * radius, y - 2 * radius){
            cylinder(r = radius, h = z, center=true, $fn=30);
        }
    }
}

module bolt_hole(diameter, countersink_depth){
//    countersink_depth = 1.4;
//    diameter = 2.5;
    union(){
        rotate_extrude(angle=360, $fn=20){
            polygon([[0,0], [0, countersink_depth], [diameter/2, countersink_depth], [2.25, 0]]);
        }
        translate([0, 0, countersink_depth/2]){
            cylinder(r=diameter/2, h=20, $fn=20);
            
        }
    }
}

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
    translate([0, connector_pcb_pillar_h + connector_pcb_z/2 -enclosure_y/2, sep + connector_pcb_pico_separation]){
        rotate([90, 0, 0]){
            children();
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
            union(){
                enclosure_shape();
                

            }
            // Remove top
            translate([0, 0, - wall_thickness]){
                cube([2 * enclosure_x, 2 * enclosure_y, enclosure_z + 2 * wall_thickness], center=true);
            }
            
            pico_led(){
                cylinder(d=light_pipe_diameter, h=enclosure_z *2, $fn=20);
            }
        }
        pico_led(){
            translate([0,0,(enclosure_z - light_pipe_support_depth)/2]){
                difference(){
                    cylinder(d=light_pipe_diameter + wall_thickness, h= light_pipe_support_depth, center=true, $fn=20);
                    cylinder(d=light_pipe_diameter, h= light_pipe_support_depth + 1, center=true, $fn=20);
                }
            }
            
        }
    }
}



translate([0,0,(pico_z-enclosure_z)/2 + pillar_h]){
    pico();
}
// Top of pico z offset from origin
pico_top_pos = pico_z- enclosure_z/2 + pillar_h;
echo(pico_top_pos);

// Separation
sep = pico_top_pos + connector_pcb_y/2;
echo(sep);

connector_pcb_pos(){
    connector_pcb();
}

translate([50,0,0]){
    enclosure_lid();
}

difference(){

    enclosure_main();
//    enclosure_shape2();
//    translate([0,0,enclosure_z/2 +50 - wall_thickness]){
//        cube([100, 100, 100], center=true);
//    }
}