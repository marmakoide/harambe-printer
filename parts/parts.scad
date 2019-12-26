// --- Parameters ------------------------------------------------------------

Y_ROD_DIAMETER = 12;
Y_ROD_GAP = 170;

Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X = 30.5;
Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y = 18;

Y_BELT_CLAMP_FIXATION_HOLE_GAP = 20;

BED_SIZE = 218;
BED_SUPPORT_ADJUSTEMENT_SCREW_GAP = 4;
BED_SUPPORT_ADJUSTEMENT_SCREW_SLOT_LENGTH = 2;

M4_LASER_CUT_HOLE_DIAMETER = 4.;

M5_3D_PRINT_HOLE_DIAMETER = 5.2;
M5_LASER_CUT_HOLE_DIAMETER = 5.;

CHORD_LEN = .4; // Length of segments used to approximate curves



// --- Utilities -------------------------------------------------------------

function norm2(v) =
  sqrt(v * v);

function dist(A, B) =
	norm2([B[0] - A[0], B[1] - A[1]]);
  
  

// Circumradius of an octagon with size 1
octagon_circumradius = (sqrt(4 + 2 * sqrt(2))) / 2;



/*
 * Produce n evenly spaced values in [a, b] interval
 */
 
function linspace(a, b, n) =
  [ for (_i = [ 0 : n - 1 ] ) a + _i * (b - a) / (n - 1) ];
  
function linspace_noend(a, b, n) =
  [ for (_i = [ 0 : n - 1 ] ) a + _i * (b - a) / n ];
      
  

/*
 * Generic shape definition
 */

function chord_len_2_angle(radius, chord_len) =
  acos(1. - (chord_len * chord_len) / (2 * radius * radius));
	
function chord_len_2_step_count(chord_len, radius, angle) = 
  ceil(angle / chord_len_2_angle(radius, chord_len));

module kcircle_sector(radius, angle) {
	n = chord_len_2_step_count(CHORD_LEN, radius, angle);
	polygon(concat([[0,0]], radius * [for(angle = linspace(0, angle, n)) [cos(angle), sin(angle)]]), convexity = 1);
}

module kcircle(radius) {
	n = chord_len_2_step_count(CHORD_LEN, radius, 360);
	polygon(radius * [for(alpha = linspace_noend(0, 360, n)) [cos(alpha), sin(alpha)]], convexity = 1);	
}

module kcylinder(radius, height) {
	linear_extrude(height = height, center = true)
		kcircle(radius);
}

module kcapsule(length, radius) {
	n = chord_len_2_step_count(CHORD_LEN, radius, 180);

	hi = [for(alpha = linspace( -90,  90., n)) [radius * cos(alpha) + length / 2, radius * sin(alpha)]];
	lo = [for(alpha = linspace(  90,  270, n)) [radius * cos(alpha) - length / 2, radius * sin(alpha)]];

	polygon(concat(hi, lo), convexity = 1);
}

module kcapsule_from_end_points(A, B, radius) {
	length = dist(A, B);
	U = [B[0] - A[0], B[1] - A[1]] / length;
	
	translate(.5 * [A[0] + B[0], A[1] + B[1]])
		rotate(atan2(U[1], U[0]))
			kcapsule(length, radius);
}


 
// --- Bed support plate ------------------------------------------------------

module bed_support_plate() {
  BED_FIXATION_HOLE_POS_COORDS_LIST =
    [[-1, -1], [-1, 1], [1, 1], [1, -1], [-1, 0]];
  
  BEARING_BLOCK_FIXATION_HOLE_POS_LIST = [
    [-Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, -Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X, -Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [-Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X,  Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y],
    [ Y_BEARING_BLOCK_FIXATION_HOLE_GAP_X,  Y_BEARING_BLOCK_FIXATION_HOLE_GAP_Y]
  ] / 2;
  
  BEARING_BLOCK_POS_COORDS_LIST = [
    [-Y_ROD_GAP / 2,  (BED_SIZE / 2 - 17 - BED_SIZE / 4)],
    [-Y_ROD_GAP / 2, -(BED_SIZE / 2 - 17 - BED_SIZE / 4)],  
    [ Y_ROD_GAP / 2, 0]
  ];
  
  BELT_CLAMP_FIXATION_HOLE_POS_LIST = [
    [0,  Y_BELT_CLAMP_FIXATION_HOLE_GAP / 2],
    [0, -Y_BELT_CLAMP_FIXATION_HOLE_GAP / 2],
  ];
  
  BELT_CLAMP_COORDS_LIST = [
    [-15.5,  (BED_SIZE / 2 - 16 - BED_SIZE / 4)],
    [-15.5, -(BED_SIZE / 2 - 16 - BED_SIZE / 4)],
  ];
  
  difference() {
    union() {
      // Main shape
      square(size = BED_SIZE, center = true);
      
      // Extensions for the sloted bed adjustment screw holes
      for(pos = BED_FIXATION_HOLE_POS_COORDS_LIST)
        translate((BED_SIZE / 2 - BED_SUPPORT_ADJUSTEMENT_SCREW_GAP) * pos)
          rotate(180 / 8)
            circle(r = (2 * BED_SUPPORT_ADJUSTEMENT_SCREW_GAP) * octagon_circumradius, $fn = 8);
    }
    
    // Bed adjustment screw holes
    for(pos = BED_FIXATION_HOLE_POS_COORDS_LIST)
      translate((BED_SIZE / 2 - BED_SUPPORT_ADJUSTEMENT_SCREW_GAP) * pos)
        rotate(atan2(pos[1], pos[0]))
          translate([BED_SUPPORT_ADJUSTEMENT_SCREW_SLOT_LENGTH / 2, 0])
            kcapsule(BED_SUPPORT_ADJUSTEMENT_SCREW_SLOT_LENGTH, M4_LASER_CUT_HOLE_DIAMETER / 2);
    
    // Bearing block fixation holes
    for(bpos = BEARING_BLOCK_POS_COORDS_LIST)
      for(pos = BEARING_BLOCK_FIXATION_HOLE_POS_LIST)
        translate(bpos + pos)
          kcircle(M5_LASER_CUT_HOLE_DIAMETER / 2);
      
    // Belt clamp fixation holes
    for(bpos = BELT_CLAMP_COORDS_LIST)
      for(pos = BELT_CLAMP_FIXATION_HOLE_POS_LIST)
        translate(bpos + pos)
          kcircle(M5_LASER_CUT_HOLE_DIAMETER / 2);  
  }
}

bed_support_plate();