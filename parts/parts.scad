include <utils.scad>



// --- Parameters ------------------------------------------------------------

BEAM_COLOR = "SlateGray";
PRINTED_PART_COLOR = "Orange";
METAL_COLOR = "Gainsboro";
BELT_COLOR = "Black";

X_BEAM_SIZE  = 370;
Y_BEAM_SIZE  = 331;
Z_BEAM_SIZE  = 359; 
ZX_BEAM_SIZE = 290; 

// Nema17 stepper motor specs
NEMA_17_SIZE = 42.3;
XYZ_NEMA_17_HEIGHT = 39.8;
E_NEMA_17_HEIGHT = 23;

// Gates pulleys specs
GATES_TOOTHED_IDLER_OUTER_DIAMETER = 15;

// E3D V6 heatblock
E3D_V6_HEATBLOCK_SIZE = [23, 16, 11.5];
E3D_V6_HEATBLOCK_SIZE_FILAMENT_PATH_OFFSET = 8;

// LM8UUE bearing specs
LM8UUE_L = 25;
LM8UUE_D = 16;

// LM12UUE bearing specs
LM12UUE_L = 32;
LM12UUE_D = 22;

// Extruder elements
BONDTECH_BMG_MOUNT_PLATE_SIZE = [23, 62];
BONDTECH_BMG_MOUNT_SHEET_THICKNESS = 3;
BONDTECH_BMG_MOUNT_HOLE_DIAMETER = 4;

// X axis design
X_ROD_DIAMETER = 8;
X_ROD_LENGTH = 500;
X_ROD_GAP = 50;

// Y axis design
Y_ROD_DIAMETER = 12;
Y_ROD_LENGTH = Y_BEAM_SIZE + 40;
Y_ROD_GAP = 170;

// Z axis design
Z_ROD_DIAMETER = 12;
Z_ROD_LENGTH = Z_BEAM_SIZE;
Z_ROD_GAP = X_BEAM_SIZE - 20; 

// Y rod holders
Y_ROD_HOLDER_SIZE = [50, 40, 2 * 4 + Y_ROD_DIAMETER];

// Y belt clamp
Y_BELT_CLAMP_SIZE = [40, 28, 28];
Y_BELT_CLAMP_FIXATION_HOLE_GAP = 26;

// Y end stop hammer
Y_ENDSTOP_HAMMER_THICKNESS = 10.5;

// Y motor mount
Y_MOTOR_MOUNT_WIDTH = 23;
Y_MOTOR_MOUNT_MOTOR_BEAM_GAP = 4;

// X bearing blocks
X_BEARING_LENGTH = LM8UUE_L;
X_BEARING_DIAMETER = LM8UUE_D;
X_BEARING_BLOCK_BEVEL = 1;
X_BEARING_BLOCK_SIZE = [34, 22, X_BEARING_LENGTH + X_BEARING_BLOCK_BEVEL];
X_BEARING_BLOCK_FIXATION_HOLE_GAP_X = 24;
X_BEARING_BLOCK_FIXATION_HOLE_GAP_Y = 13;

// Y bearing blocks
Y_BEARING_LENGTH = LM12UUE_L;
Y_BEARING_DIAMETER = LM12UUE_D;
Y_BEARING_BLOCK_BEVEL = 1;
Y_BEARING_BLOCK_SIZE = [40, 28, Y_BEARING_LENGTH + Y_BEARING_BLOCK_BEVEL];
Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X = 30.5;
Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y = 18;

// Y axis fitting jigs 
Y_AXIS_FITTING_JIG_TOLERANCE = .2;
Y_AXIS_FITTING_JIG_CHAMFER = 2;

BED_SIZE = 218;

BED_SUPPORT_ADJUSTEMENT_SCREW_GAP = 5;
BED_SUPPORT_ADJUSTEMENT_SCREW_SLOT_LENGTH = 3;
BED_SUPPORT_THICKNESS = 6;

M3_LASER_CUT_HOLE_DIAMETER = 3.;

M4_LASER_CUT_HOLE_DIAMETER = 4.;

M5_3D_PRINT_HOLE_DIAMETER = 5.2;
M5_LASER_CUT_HOLE_DIAMETER = 5.;


// --- Utilities -------------------------------------------------------------

// Circumradius of an octagon with size 1
octagon_circumradius = (sqrt(4 + 2 * sqrt(2))) / 2;

module k_negative_rectangle(size, chamfer) {
  square(size, center = true);
  polygon([
            [-(size[0] / 2 + chamfer), size[1] / 2],
            [  size[0] / 2 + chamfer,  size[1] / 2],
            [  size[0] / 2,            size[1] / 2 - chamfer],
            [ -size[0] / 2,            size[1] / 2 - chamfer]
          ], convexity = 1);
}



// --- Commonly used elements -------------------------------------------------

module m4_teardrop_3d_print() {
  kteardrop(M4_LASER_CUT_HOLE_DIAMETER / 2);
}

module m5_teardrop_3d_print() {
  kteardrop(M5_LASER_CUT_HOLE_DIAMETER / 2);
}

module m3_circle_laser_cut() {
  kcircle(M3_LASER_CUT_HOLE_DIAMETER / 2);
}

module m5_circle_laser_cut() {
  kcircle(M5_LASER_CUT_HOLE_DIAMETER / 2);
}



// --- GT2 belt ----------------------------------------------------------------------------------

module belt(length, diameter, width) {
  THICKNESS = 0.63;
  
  color(BELT_COLOR)
    linear_extrude(height = width, center = true)
      difference() {
        kcapsule(length, diameter / 2 + THICKNESS);
        kcapsule(length, diameter / 2);
      }
}



// --- Linear bearings ---------------------------------------------------------------------------

module lm12uue() {
  color(METAL_COLOR)
    difference() {
      kcylinder(LM12UUE_D / 2, LM12UUE_L);
      kcylinder(6, LM12UUE_L + 2);
    }
}



module lm8uue() {
  color(METAL_COLOR)
    difference() {
      kcylinder(LM8UUE_D / 2, LM8UUE_L);
      kcylinder(4, LM8UUE_L + 2);
    }
}



// --- Gates pulley idler for 9mm 2GT belts ------------------------------------------------------

module gates_toothed_idler_9mm() {
  HOLE_DIAMETER = 5;
  INNER_DIAMETER = 12.22;
  OUTER_DIAMETER = GATES_TOOTHED_IDLER_OUTER_DIAMETER;
  LENGTH = 14;
  BORDER_SIZE = 1.5;
  
  color(METAL_COLOR) {
    difference() {
      union() {
        kcylinder(INNER_DIAMETER / 2, LENGTH);
      
        translate([0, 0, (LENGTH - BORDER_SIZE) / 2])
          kcylinder(OUTER_DIAMETER / 2, BORDER_SIZE);
        
        translate([0, 0, -(LENGTH - BORDER_SIZE) / 2])
          kcylinder(OUTER_DIAMETER / 2, BORDER_SIZE);
      }
      
      kcylinder(HOLE_DIAMETER / 2, 16.);      
    }
  }
}



// --- Bondtech BMG extruder mount ---------------------------------------------------------------

module bondtech_bmg_mount() {
  color(METAL_COLOR) {
    linear_extrude(height = BONDTECH_BMG_MOUNT_SHEET_THICKNESS, center = true) {
      difference() {
        square(BONDTECH_BMG_MOUNT_PLATE_SIZE, center = true);
        translate([-15 / 2, -55 / 2])
          kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
        translate([ 15 / 2, -55 / 2])
          kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
        translate([-15 / 2,  55 / 2])
          kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
        translate([ 15 / 2,  55 / 2])
          kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
      }
    }
    
    translate([-(BONDTECH_BMG_MOUNT_PLATE_SIZE[0] + BONDTECH_BMG_MOUNT_SHEET_THICKNESS) / 2, 0, 43 / 2 + BONDTECH_BMG_MOUNT_SHEET_THICKNESS])
    rotate(90, [1, 0, 0])
    rotate(90, [0, 1, 0])
    linear_extrude(height = BONDTECH_BMG_MOUNT_SHEET_THICKNESS, center = true) {
      difference() {
        translate([0, -BONDTECH_BMG_MOUNT_SHEET_THICKNESS])
          square([43, 46], center = true);
        
        translate([0, -BONDTECH_BMG_MOUNT_SHEET_THICKNESS / 2]) {
          kcircle(23 / 2);
        
          translate([-31 / 2, -31 / 2])
            kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
          translate([ 31 / 2, -31 / 2])
            kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
          translate([-31 / 2,  31 / 2])
            kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
          translate([ 31 / 2,  31 / 2])
            kcircle(BONDTECH_BMG_MOUNT_HOLE_DIAMETER / 2);
        }
      }
    }
  }
}



// --- X bearing block --------------------------------------------------------

module x_bearing_block() {
  FLAT_HEIGHT = 3;
  A = X_BEARING_BLOCK_SIZE[0] - X_BEARING_BLOCK_FIXATION_HOLE_GAP_X;
  
  BEARING_BLOCK_FIXATION_HOLE_POS_LIST = [
    [-X_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0, -X_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ X_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0, -X_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [-X_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0,  X_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ X_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0,  X_BEARING_BLOCK_FIXATION_HOLE_GAP_Y]
  ] / 2;
  
  difference() {
    // Main shape
    linear_extrude(height = X_BEARING_BLOCK_SIZE[2], convexity = 2, center = true)
      difference() {
        // Bearing hole profile
        polygon([
          [ X_BEARING_BLOCK_SIZE[0] / 2, -X_BEARING_BLOCK_SIZE[1] / 2],
          [ X_BEARING_BLOCK_SIZE[0] / 2,  X_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [ X_BEARING_BLOCK_SIZE[0] / 2 - A,  X_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [ X_BEARING_BLOCK_SIZE[0] / 2 - A - FLAT_HEIGHT,  X_BEARING_BLOCK_SIZE[1] / 2],
          [-X_BEARING_BLOCK_SIZE[0] / 2 + A + FLAT_HEIGHT,  X_BEARING_BLOCK_SIZE[1] / 2], 
          [-X_BEARING_BLOCK_SIZE[0] / 2 + A,  X_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [-X_BEARING_BLOCK_SIZE[0] / 2,  X_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [-X_BEARING_BLOCK_SIZE[0] / 2, -X_BEARING_BLOCK_SIZE[1] / 2],        
        ], convexity = 1);
      
        // Bearing hole
        kcircle(X_BEARING_DIAMETER / 2);
      }
      
    // Fixation holes
    for(pos = BEARING_BLOCK_FIXATION_HOLE_POS_LIST)
      translate(pos)
        rotate(90, [1, 0, 0])
          linear_extrude(height = 2 * X_BEARING_BLOCK_SIZE[1], convexity = 1, center = true)
            rotate(90)
              m4_teardrop_3d_print();
    
    // Bearing hole bevel
    translate([0, 0, X_BEARING_BLOCK_SIZE[2] / 2])
      round_hole_bevel(X_BEARING_DIAMETER / 2, X_BEARING_BLOCK_BEVEL, [0, 0, 1]);    
  }  
}

//x_bearing_block();



// --- Y bearing block --------------------------------------------------------

module y_bearing_block() {
  FLAT_HEIGHT = 4;
  A = Y_BEARING_BLOCK_SIZE[0] - Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X;
  
  BEARING_BLOCK_FIXATION_HOLE_POS_LIST = [
    [-Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0, -Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0, -Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [-Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0,  Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, 0,  Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y]
  ] / 2;
  
  difference() {
    // Main shape
    linear_extrude(height = Y_BEARING_BLOCK_SIZE[2], convexity = 2, center = true)
      difference() {
        // Bearing hole profile
        polygon([
          [ Y_BEARING_BLOCK_SIZE[0] / 2, -Y_BEARING_BLOCK_SIZE[1] / 2],
          [ Y_BEARING_BLOCK_SIZE[0] / 2,  Y_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [ Y_BEARING_BLOCK_SIZE[0] / 2 - A,  Y_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [ Y_BEARING_BLOCK_SIZE[0] / 2 - A - FLAT_HEIGHT,  Y_BEARING_BLOCK_SIZE[1] / 2],
          [-Y_BEARING_BLOCK_SIZE[0] / 2 + A + FLAT_HEIGHT,  Y_BEARING_BLOCK_SIZE[1] / 2], 
          [-Y_BEARING_BLOCK_SIZE[0] / 2 + A,  Y_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [-Y_BEARING_BLOCK_SIZE[0] / 2,  Y_BEARING_BLOCK_SIZE[1] / 2 - FLAT_HEIGHT],
          [-Y_BEARING_BLOCK_SIZE[0] / 2, -Y_BEARING_BLOCK_SIZE[1] / 2],        
        ], convexity = 1);
      
        // Bearing hole
        kcircle(Y_BEARING_DIAMETER / 2);
      }
      
    // Fixation holes
    for(pos = BEARING_BLOCK_FIXATION_HOLE_POS_LIST)
      translate(pos)
        rotate(90, [1, 0, 0])
          linear_extrude(height = 2 * Y_BEARING_BLOCK_SIZE[1], convexity = 1, center = true)
            rotate(90)
              m5_teardrop_3d_print();
    
    // Bearing hole bevel
    translate([0, 0, Y_BEARING_BLOCK_SIZE[2] / 2])
      round_hole_bevel(Y_BEARING_DIAMETER / 2, Y_BEARING_BLOCK_BEVEL, [0, 0, 1]);
  }  
}

//y_bearing_block();



// --- Y axis fitting jig -----------------------------------------------------

module y_axis_fitting_jig_a_profile() {
  difference() {
    // Main shape
    square(size = [X_BEAM_SIZE, 40], center = true);
    
    // Y rod holder
    for(x = [-1, 1])
      translate([x * Y_ROD_GAP / 2, 10, 0])
        k_negative_rectangle([Y_ROD_HOLDER_SIZE[0] + 2 * Y_AXIS_FITTING_JIG_TOLERANCE, 20 + Y_AXIS_FITTING_JIG_TOLERANCE], Y_AXIS_FITTING_JIG_CHAMFER);
    
    // Fixation holes
    a = (X_BEAM_SIZE / 2 - Y_ROD_HOLDER_SIZE[0] / 2 - Y_ROD_GAP / 2) / 2;
    for(x = [-1, 1])
      translate([-x * (a + Y_ROD_HOLDER_SIZE[0] / 2 + Y_ROD_GAP / 2), 10, 0])
        m5_circle_laser_cut();
  }
}

module y_axis_fitting_jig_b_profile() {
  difference() {
    y_axis_fitting_jig_a_profile();
    
    translate([0, 10, 0])
      k_negative_rectangle([Y_MOTOR_MOUNT_WIDTH + 2 * Y_AXIS_FITTING_JIG_TOLERANCE, 20 + Y_AXIS_FITTING_JIG_TOLERANCE], Y_AXIS_FITTING_JIG_CHAMFER);
  }
}



// --- Bed support plate ------------------------------------------------------

module bed_support_plate_profile() {
  BED_FIXATION_HOLE_POS_COORDS_LIST =
    [[-1, -1], [-1, 1], [1, 1], [1, -1], [1, 0]];
  
  BEARING_BLOCK_FIXATION_HOLE_POS_LIST = [
    [-Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, -Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, -Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [-Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X,  Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X,  Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y]
  ] / 2;
  
 
  A = (Y_BEARING_BLOCK_SIZE[1] + Y_BEARING_BLOCK_BEVEL) / 2;
  BEARING_BLOCK_POS_COORDS_LIST = [
    [-Y_ROD_GAP / 2, 0],
    [ Y_ROD_GAP / 2,  (BED_SIZE / 4 - A)],
    [ Y_ROD_GAP / 2, -(BED_SIZE / 4 - A)]
  ];
  
  BELT_CLAMP_FIXATION_HOLE_POS_LIST = [
    [0,  Y_BELT_CLAMP_FIXATION_HOLE_GAP / 2],
    [0, -Y_BELT_CLAMP_FIXATION_HOLE_GAP / 2],
  ];
  
  BELT_CLAMP_COORDS = [16, 0];
  
  difference() {
    union() {
      // Main shape
      square(size = BED_SIZE, center = true);
      
      // Extensions for the sloted bed adjustment screw holes
      for(pos = BED_FIXATION_HOLE_POS_COORDS_LIST)
        translate((BED_SIZE / 2 - BED_SUPPORT_ADJUSTEMENT_SCREW_GAP) * pos)
          rotate(180 / 8)
            circle(r = 8 * octagon_circumradius, $fn = 8);
    }
    
    // Bed adjustment screw holes
    for(pos = BED_FIXATION_HOLE_POS_COORDS_LIST)
      translate((BED_SIZE / 2 - BED_SUPPORT_ADJUSTEMENT_SCREW_GAP) * pos)
        rotate(atan2(pos[1], pos[0]))
          translate([BED_SUPPORT_ADJUSTEMENT_SCREW_SLOT_LENGTH / 2, 0])
            kcapsule(BED_SUPPORT_ADJUSTEMENT_SCREW_SLOT_LENGTH, M3_LASER_CUT_HOLE_DIAMETER / 2);
    
    // Bearing block fixation holes
    for(bpos = BEARING_BLOCK_POS_COORDS_LIST)
      for(pos = BEARING_BLOCK_FIXATION_HOLE_POS_LIST)
        translate(bpos + pos)
          m5_circle_laser_cut();
      
    // Belt clamp fixation holes
    for(pos = BELT_CLAMP_FIXATION_HOLE_POS_LIST)
      translate(pos + BELT_CLAMP_COORDS)
        m5_circle_laser_cut();
    
    // Endstop hammer fixation hole
     translate([-(BED_SIZE / 2 - 8.75), -(BED_SIZE / 4 - A) - Y_BEARING_BLOCK_SIZE[2] / 2 + Y_ENDSTOP_HAMMER_THICKNESS / 2 + 20])
      m5_circle_laser_cut();
  }
}


module bed_support_plate_overlay() {
  BELT_CLAMP_COORDS = [14, 0];
  
  difference() {
  // Main shape
  square(size = BED_SIZE, center = true);
  
  translate([0, BED_SIZE / 2 - 16])
    text("this side up", size = 8, halign = "center", valign = "top");
    
  // Belt clamp fixation holes
  projection(cut = true)
    translate(BELT_CLAMP_COORDS)
        translate([-6, -Y_BELT_CLAMP_SIZE[0] / 2, Y_BELT_CLAMP_SIZE[2] /2])
        rotate(180, [0, 1, 0])
      rotate(90, [0, 0, 1])
    rotate(90, [1, 0, 0])
      import("./stl/y-belt-clamp.stl", convexity = 3);
  }
}


// --- Vslot -------------------------------------------------------------------------------------

module vslot_rail_shape() {
  PARAM_A = 5.68;
  PARAM_B = 6.25;
  PARAM_C = 7.80;
  PARAM_D = 1.80;
  PARAM_E = 1.64;
  PARAM_F = 4.30;
  
  A = [.5 * PARAM_A, 0];
  B = A + [PARAM_F - PARAM_E, PARAM_F - PARAM_E];
  C = B + [0, PARAM_E];
  D = [.5 * PARAM_B, PARAM_F];
  E = D + [PARAM_D, PARAM_D];
  F = E + [0, 5];
  
  polygon([A, B, C, D, E, F, mirror_x(F), mirror_x(E), mirror_x(D), mirror_x(C), mirror_x(B), mirror_x(A)]);
}

module vslot_rail_hole(length) {
  linear_extrude(length + 10, center = true)
    vslot_rail_shape();
}

module vslot_beam(length) {
  PARAM_C = 7.80;

  difference() {
    cube([length, 40, 20], center = true);

    translate([0, 10 + PARAM_C / 2, 0])    
      rotate(90, [0, 1, 0])
        vslot_rail_hole(length);

    translate([0, -(10 + PARAM_C / 2), 0]) 
      rotate(180, [0, 0, 1])    
      rotate(90, [0, 1, 0])
        vslot_rail_hole(length);
    
    translate([0, 10, (PARAM_C / 2)]) 
      rotate(90, [1, 0, 0])    
      rotate(90, [0, 1, 0])
        vslot_rail_hole(length);

    translate([0, -10, (PARAM_C / 2)]) 
      rotate(90, [1, 0, 0])    
      rotate(90, [0, 1, 0])
        vslot_rail_hole(length);
    
    translate([0, 10, -(PARAM_C / 2)]) 
      rotate(-90, [1, 0, 0])    
      rotate(90, [0, 1, 0])
        vslot_rail_hole(length);

    translate([0, -10, -(PARAM_C / 2)]) 
      rotate(-90, [1, 0, 0])    
      rotate(90, [0, 1, 0])
        vslot_rail_hole(length);
  }
}



// -----------------------------------------------------------------------------------------------

/*
BEARING_GAP = 2;

module x_rod() {
  color(METAL_COLOR)
    rotate(90, [0, 1, 0])
      kcylinder(X_ROD_DIAMETER / 2, X_ROD_LENGTH);
}

// Place the parts we need to attach together 
translate([0, 0, -X_ROD_GAP / 2])
  x_rod();
  
translate([0, 0, X_ROD_GAP / 2])
  x_rod();  

translate([-(LM8UUE_L + BEARING_GAP) / 2, 0, X_ROD_GAP / 2])
rotate(90, [0, 1, 0])
  lm8uue();

translate([ (LM8UUE_L + BEARING_GAP) / 2, 0, X_ROD_GAP / 2])
rotate(90, [0, 1, 0])
  lm8uue();

translate([0, 0, -X_ROD_GAP / 2])
rotate(90, [0, 1, 0])
  lm8uue();

translate([0, (30 + BONDTECH_BMG_MOUNT_SHEET_THICKNESS) / 2, -15])
rotate(180, [0, 0, 1])
rotate(90, [1, 0, 0])
 bondtech_bmg_mount();

rotate(90, [1, 0, 0]) 
  belt(500, GATES_TOOTHED_IDLER_OUTER_DIAMETER, 9);
*/


