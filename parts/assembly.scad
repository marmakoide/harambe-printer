include <parts.scad>

Y_AXIS_POS = 0; //BED_SIZE / 2; //BED_SIZE - 9;

BEAM_COLOR = "SlateGray";
PRINTED_PART_COLOR = "Orange";



module nema17() {
  CUBE_SIZE = [NEMA_17_SIZE, 33, NEMA_17_HEIGHT];
  
  SHAFT_DIAMETER = 5;
  SHAFT_LENGTH = 24;
  
  FLANGE_DIAMETER = 22;
  FLANGE_HEIGHT = 2;
  
  FIXATION_HOLES_DIAMETER = 3.5;
  FIXATION_HOLES_GAP = 31; 
  FIXATION_HOLES_DEPTH = 15;

  cyl_resolution = 16;
  
  difference() {
    union() {
      // Main body
      color("DarkSlateGray")
        hull() {
          cube(CUBE_SIZE, center = true);
          rotate(90, [0, 0, 1])
            cube(CUBE_SIZE, center = true);
         }

      // Flange
      color("Gainsboro")
        translate([0, 0, (CUBE_SIZE[2] / 2) - 1])
          cylinder(h = FLANGE_HEIGHT + 1, d = FLANGE_DIAMETER, center = true, $fn = cyl_resolution);
      
      // Shaft
      color("Gainsboro")
        translate([0, 0, (CUBE_SIZE[2] + SHAFT_LENGTH) / 2])
          cylinder(h = SHAFT_LENGTH, d = SHAFT_DIAMETER, center = true, $fn = cyl_resolution);
    }

    // Fixation holes
    //color("DarkSlateGray")
    translate([0, 0, (CUBE_SIZE[2] / 2) - (FIXATION_HOLES_DEPTH / 2) + 1])
      for(i = [-.5, .5], j = [-.5, .5])
        translate([i * FIXATION_HOLES_GAP, j * FIXATION_HOLES_GAP, 0])
          cylinder(h = FIXATION_HOLES_DEPTH + 1, d = FIXATION_HOLES_DIAMETER, center = true, $fn = cyl_resolution);
  }
}

module beam(length) {
  color(BEAM_COLOR)
    cube([length, 40, 20], center = true);
}

module x_beam() {
  rotate(90, [1, 0, 0])
    beam(X_BEAM_SIZE);
}

module y_beam() {
  rotate(90, [0, 0, 1])
    beam(Y_BEAM_SIZE);
}

module y_rod() {
  color("Gainsboro")
    rotate(90, [1, 0, 0])
      kcylinder(Y_ROD_DIAMETER / 2, Y_ROD_LENGTH);
}

module y_bearing_block_() {
  color(PRINTED_PART_COLOR)
    rotate(90, [1, 0, 0])
    rotate(180, [0, 0, 1])
      y_bearing_block();
}

module y_belt_clamp() {
  color(PRINTED_PART_COLOR)
    translate([0, -Y_BELT_CLAMP_SIZE[0] / 2, 0])
    rotate(90, [0, 0, 1])
    rotate(90, [1, 0, 0])
      import("./stl/y-belt-clamp.stl", convexity = 3);
}

module y_motor_mount() {
  color(PRINTED_PART_COLOR)
    rotate(90, [0, 0, 1])
    rotate(90, [1, 0, 0])
      import("./stl/y-motor-mount.stl", convexity = 3);
}

module y_pulley_idler() {
  color(PRINTED_PART_COLOR)
    rotate(180, [0, 1, 0])
    rotate(90, [0, 0, -1])
      import("./stl/y-pulley-idler.stl");
}

module gantry_assembly() {
  translate([0, -(Y_BEAM_SIZE / 2 + 10), 20])
    x_beam();
  translate([0,  (Y_BEAM_SIZE / 2 + 10), 20])
    x_beam();
  translate([-(Y_BEAM_SIZE / 2), 0, 10])
    y_beam();  
  translate([ (Y_BEAM_SIZE / 2), 0, 10])
    y_beam();
}

module bed_support_plate() {
  color("Burlywood")
    linear_extrude(height = BED_SUPPORT_THICKNESS, convexity = 10, center = true)
      bed_support_plate_profile();  
}

module y_motor_assembly() {
  y_motor_mount();
  translate([-(NEMA_17_HEIGHT + Y_MOTOR_MOUNT_WIDTH) / 2, NEMA_17_SIZE / 2 + 4, -6.15])
  rotate(90, [0, 1, 0])
    nema17();
}



module bed_assembly() {
  // bed support plate
  translate([0, 0, BED_SUPPORT_THICKNESS / 2 + Y_BEARING_BLOCK_SIZE[1] / 2])
    bed_support_plate();
  
  // belt clamps
  translate([10, 0, 0])
   rotate(180, [0, 0, 1])
    translate([0, 0, 0])
    y_belt_clamp();
  
  // bearing blocks
  A = (Y_BEARING_BLOCK_SIZE[1] + Y_BEARING_BLOCK_CHAMFER) / 2;
  
  translate([-Y_ROD_GAP / 2, -(BED_SIZE / 4 - A), 0])
    y_bearing_block_();
  
  translate([-Y_ROD_GAP / 2, (BED_SIZE / 4 - A), 0])
    y_bearing_block_();
  
  translate([Y_ROD_GAP / 2, 0, 0])
    y_bearing_block_();
}

module printer_assembly() {
  // gantry
  gantry_assembly();
  
  translate([0, -Y_BEAM_SIZE / 2, 40])
    y_motor_assembly();
  
  translate([0,  Y_BEAM_SIZE / 2, 40])
    y_pulley_idler();
  
  // Y rods
  translate([0, 0, 40 + Y_ROD_DIAMETER / 2]) {
    translate([-Y_ROD_GAP / 2, 0, 0])
      y_rod();
  
    translate([ Y_ROD_GAP / 2, 0, 0])
      y_rod();
  }
  
  // bed
  translate([0, Y_AXIS_POS - BED_SIZE / 2, 40 + 6])
    bed_assembly();
}

printer_assembly();