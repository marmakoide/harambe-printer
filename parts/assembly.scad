include <parts.scad>

X_AXIS_POS = 0 - BED_SIZE / 2;
Y_AXIS_POS = BED_SIZE / 2; //BED_SIZE - 9;
Z_AXIS_POS = 0;



/*
 * Prefab parts
 */

module bmg_extruder() {
  CUBE_SIZE = [42, 33, 33];
  
  hull() {
    cube(CUBE_SIZE, center = true);
    rotate(90, [0, 0, 1])
      cube(CUBE_SIZE, center = true);
  }
  
  
}



module nema17(length) {
  CUBE_SIZE = [NEMA_17_SIZE, 33, length];
  
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
      color(METAL_COLOR)
        translate([0, 0, (CUBE_SIZE[2] / 2) - 1])
          cylinder(h = FLANGE_HEIGHT + 1, d = FLANGE_DIAMETER, center = true, $fn = cyl_resolution);
      
      // Shaft
      color(METAL_COLOR)
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




/*
 * Gantry parts
 */

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

module z_beam() {
  rotate(90, [0, 0, 1])
  rotate(90, [0, 1, 0])
    beam(Z_BEAM_SIZE);
}

module zx_beam() {
  rotate(90, [1, 0, 0])
    beam(ZX_BEAM_SIZE);
}



/*
 * X axis parts
 */

module x_rod() {
  color(METAL_COLOR)
    rotate(90, [0, 1, 0])
      kcylinder(X_ROD_DIAMETER / 2, X_ROD_LENGTH);
}

module x_bearing_block_() {
  color(PRINTED_PART_COLOR)
    rotate(90, [0, 1, 0])
    rotate(180, [1, 0, 0])
      x_bearing_block();
}

module x_axis_carriage_assembly() {
  // extruder mount plate
  translate([0, X_BEARING_BLOCK_SIZE[1] / 2 + BONDTECH_BMG_MOUNT_SHEET_THICKNESS / 2, 0])
    rotate(180, [0, 1, 0])
    rotate(-90, [1, 0, 0])
    bondtech_bmg_mount();

  // extruder stepper motor
  translate([0, X_BEARING_BLOCK_SIZE[1] / 2 + 43 / 2 + BONDTECH_BMG_MOUNT_SHEET_THICKNESS, 0])
    rotate(180, [0, 1, 0])
    rotate(-90, [0, 1, 0])
      nema17(E_NEMA_17_HEIGHT);
  
  // extruder
  translate([31, X_BEARING_BLOCK_SIZE[1] / 2 + 43 / 2 + BONDTECH_BMG_MOUNT_SHEET_THICKNESS, 0])
    rotate(180, [0, 1, 0])
    rotate(90, [0, 1, 0])  
      bmg_extruder();
  
  // bearing blocks
  translate([-X_BEARING_BLOCK_SIZE[2] / 2, 0, X_ROD_GAP / 2])
    x_bearing_block_();
  
  translate([ X_BEARING_BLOCK_SIZE[2] / 2, 0, X_ROD_GAP / 2])
    x_bearing_block_();
  
  translate([0, 0, -X_ROD_GAP / 2])
    x_bearing_block_();  
}

module x_axis_assembly() {
  // bearing blocks
  translate([X_AXIS_POS, 0, 0])
    x_axis_carriage_assembly();
  
  // X rods
  translate([0, 0, -X_ROD_GAP / 2])
    x_rod();
  
  translate([0, 0, X_ROD_GAP / 2])
    x_rod();  
}



/*
 * Y axis parts
 */

module y_rod() {
  color(METAL_COLOR)
    rotate(90, [1, 0, 0])
      kcylinder(Y_ROD_DIAMETER / 2, Y_ROD_LENGTH);
}

module y_bearing_block_() {
  color(PRINTED_PART_COLOR)
    rotate(90, [1, 0, 0])
    rotate(180, [0, 0, 1])
      y_bearing_block();
}

module y_end_stop_support() {
  color(PRINTED_PART_COLOR)
    import("./stl/y-endstop-support.stl", convexity = 3);
}

module y_end_stop_hammer_support() {
  color(PRINTED_PART_COLOR)
    rotate(180, [0, 0, 1])
    import("./stl/y-endstop-hammer-support.stl", convexity = 3);
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

module y_pulley_idler_assembly() {
  y_pulley_idler();
  
  translate([0, -18.25, 15 - 21.15])
  rotate(90, [0, 1, 0])
    gates_toothed_idler_9mm();
}

module y_motor_assembly() {
  y_motor_mount();
  
  translate([-(XYZ_NEMA_17_HEIGHT + Y_MOTOR_MOUNT_WIDTH) / 2, NEMA_17_SIZE / 2 + 4, -6.15])
  rotate(90, [0, 1, 0])
    nema17(XYZ_NEMA_17_HEIGHT);
}



module y_axis_assembly() {
  translate([0, -Y_BEAM_SIZE / 2, 0])
    y_motor_assembly();
  
  translate([0,  Y_BEAM_SIZE / 2, 0])
    y_pulley_idler_assembly();
  
  translate([-Y_ROD_GAP / 2 - 50, -Y_BEAM_SIZE / 2 - 10, 0])
    y_end_stop_support();
  
  // Belt
  translate([0, 0, 15 - 21.15])
  rotate(90, [0, 0, 1])
  rotate(90, [1, 0, 0])
    belt(Y_BEAM_SIZE - 40, GATES_TOOTHED_IDLER_OUTER_DIAMETER, 9);

  // Y rods
  translate([0, 0, Y_ROD_DIAMETER / 2 + 4]) {
    translate([-Y_ROD_GAP / 2, 0, 0])
      y_rod();
  
    translate([ Y_ROD_GAP / 2, 0, 0])
      y_rod();
  }  
}



/*
 * Bed parts
 */

module bed_support_plate() {
  color("Burlywood")
    linear_extrude(height = BED_SUPPORT_THICKNESS, convexity = 10, center = true)
      bed_support_plate_profile();  
}

module bed_assembly() {
   A = (Y_BEARING_BLOCK_SIZE[1] + Y_BEARING_BLOCK_CHAMFER) / 2;
  
  // bed support plate
  translate([0, 0, BED_SUPPORT_THICKNESS / 2 + Y_BEARING_BLOCK_SIZE[1] / 2])
    bed_support_plate();
  
  // belt clamps
  translate([10, 0, 0])
   rotate(180, [0, 0, 1])
    translate([0, 0, 0])
    y_belt_clamp();
  
  // end stop hammer
  translate([-(BED_SIZE / 2 - 16), -(BED_SIZE / 4 - A) - Y_BEARING_BLOCK_SIZE[2] / 2 + Y_ENDSTOP_HAMMER_THICKNESS / 2 + 20, BED_SUPPORT_THICKNESS / 2 + Y_BEARING_BLOCK_SIZE[1] / 2 + BED_SUPPORT_THICKNESS / 2])
    y_end_stop_hammer_support();

  // bearing blocks 
  translate([-Y_ROD_GAP / 2, 0, 0]) {
    rotate(90, [1, 0, 0])
      lm12uue();

    y_bearing_block_();
  }
  
  translate([ Y_ROD_GAP / 2, -(BED_SIZE / 4 - A), 0]) {
    rotate(90, [1, 0, 0])
      lm12uue();
    
    y_bearing_block_();
  }
  
  translate([ Y_ROD_GAP / 2, (BED_SIZE / 4 - A), 0]) {
    rotate(90, [1, 0, 0])
      lm12uue();

    y_bearing_block_();
  }
}



/*
 * Overall assembly
 */

module gantry_assembly() {
  translate([0, -(Y_BEAM_SIZE / 2 + 10), 20])
    x_beam();
  translate([0,  (Y_BEAM_SIZE / 2 + 10), 20])
    x_beam();
  translate([-(Y_BEAM_SIZE / 2), 0, 10])
    y_beam();  
  translate([ (Y_BEAM_SIZE / 2), 0, 10])
    y_beam();
  translate([-(X_BEAM_SIZE / 2 - 20), 0, Z_BEAM_SIZE / 2 + 20]) 
    z_beam();
  translate([ (X_BEAM_SIZE / 2 - 20), 0, Z_BEAM_SIZE / 2 + 20]) 
    z_beam();
  translate([0, 0, Z_BEAM_SIZE])   
    zx_beam();
}



module printer_assembly() {
  // gantry
  gantry_assembly();
  
  // bed
  translate([0, Y_AXIS_POS - BED_SIZE / 2, 40 + 6 + 4])
    bed_assembly();
  
  // x axis
  translate([0, 30, 40 + X_ROD_GAP + 40])
    x_axis_assembly();
  
  // y axis
  translate([0, 0, 40])  
    y_axis_assembly();
}


module belt(length, diameter, width) {
  THICKNESS = 0.63;
  
  color(BELT_COLOR)
    linear_extrude(height = width, center = true)
      difference() {
        kcapsule(length, diameter / 2 + THICKNESS);
        kcapsule(length, diameter / 2);
      }
}


printer_assembly();