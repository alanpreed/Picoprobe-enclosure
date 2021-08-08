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

// See https://cubehero.com/2013/12/31/creating-cookie-cutters-using-offsets-in-openscad/comment-page-1/
bounding_box = [5000, 5000, 5000];
module invert(bounds = bounding_box) {
    difference() {
        cube(bounds, true);
        children();
    }        
}

module inset(thickness, bounds = bounding_box){
    invert(bounds * 0.9){
        minkowski(){
            invert(){
                children();
            }
            cube([2 * thickness, 2 * thickness, 2 * thickness], center=true);
        }
    }
}

module xy_inset(thickness, bounds = bounding_box){
    difference(){
        children();

        scale([1, 1, 2]){
            inset(thickness, bounds) {
                children();
            }
        }
    }
}