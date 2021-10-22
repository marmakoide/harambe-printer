CHORD_LEN = .4; // Length of segments used to approximate curves


function mirror_x(U) =
  [-U[0], U[1]];



/*
 * Euclidean norm and distance
 */
 
function norm2(v) =
  sqrt(v * v);

function dist(A, B) =
	norm2([B[0] - A[0], B[1] - A[1]]);
  
  

/*
 * Rotate an object so that U aligns to V
 */
 
module align_to_axis(U, V) {
  rotate(acos(U * V), cross(U, V))
    children(0);
}



/*
 * Produce n evenly spaced values in [a, b] interval
 */
 
function linspace(a, b, n) =
  [ for (_i = [ 0 : n - 1 ] ) a + _i * (b - a) / (n - 1) ];
  
function linspace_noend(a, b, n) =
  [ for (_i = [ 0 : n - 1 ] ) a + _i * (b - a) / n ];




function chord_len_2_angle(radius, chord_len) =
  acos(1. - (chord_len * chord_len) / (2 * radius * radius));
	
function chord_len_2_step_count(chord_len, radius, angle) = 
  ceil(angle / chord_len_2_angle(radius, chord_len));

module kcircle_sector(radius, angle) {
	n = chord_len_2_step_count(CHORD_LEN, radius, angle);
	polygon(concat([[0,0]], radius * [for(angle = linspace(0, angle, n)) [cos(angle), sin(angle)]]), convexity = 1);
}



/*
 * Origin centered circle
 */

module kcircle(radius) {
	n = chord_len_2_step_count(CHORD_LEN, radius, 360);
	polygon(radius * [for(alpha = linspace_noend(0, 360, n)) [cos(alpha), sin(alpha)]], convexity = 1);	
}



/*
 * Origin centered cylinder, along Z axis
 */

module kcylinder(radius, height) {
	linear_extrude(height = height, center = true, convexity = 1)
		kcircle(radius);
}



/*
 * Origin centered cone, along Z axis
 */

module kcone(radius, height) {
  linear_extrude(height = height, center = true, scale = 0, convexity = 1)
    kcircle(radius);
}



/*
 * Origin centered capsule, along Z axis
 */


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



/*
 * Origin centered 'teardrop'
 */

module kteardrop(radius) {
  angle = 270;
	n = chord_len_2_step_count(CHORD_LEN, radius, angle);
  rotate(45)
    polygon(concat([[radius,-radius]], radius * [for(angle = linspace(0, angle, n)) [cos(angle), sin(angle)]]), convexity = 1);
}



/*
 * Unit octahedron
 */
 
module octahedron() {
  X = [1, 0, 0];
  Y = [0, 1, 0];
  Z = [0, 0, 1];
  
  polyhedron(
    points = [X, Y, Z, -X, -Y, -Z],
    faces = [
      [1, 0, 2],
      [0, 1, 5],
      [0, 4, 2],
      [4, 0, 5],
      [4, 3, 2],
      [3, 4, 5],
      [3, 1, 2],
      [1, 3, 5]  
    ],
    convexity = 2);
}



/*
 * Box centered on the origin, with a bevel on each edges
 */

module bevel_box(size, bevel) {
  s = (size[0] + size[1] + size[2]) / 2 - 2 * bevel;
  sz = (size[0] + size[1] - 2 * bevel) / sqrt(2);
  sx = (size[1] + size[2] - 2 * bevel) / sqrt(2);
  sy = (size[2] + size[0] - 2 * bevel) / sqrt(2);
  
  intersection() {
    cube(size, center = true);
    rotate(45, [0, 0, 1])
      cube([sz, sz, size[2]], center = true);
    rotate(45, [1, 0, 0])
      cube([size[0], sx, sx], center = true);
    rotate(45, [0, 1, 0])
      cube([sy, size[1], sy], center = true);    
    scale(s)
      octahedron();
  }
}



/*
 * Generate a bevel for a round hole
 */

module round_hole_bevel(radius, bevel, axis) {
  align_to_axis([0, 0, 1], axis) 
    linear_extrude(height = 2 * bevel, center = true, scale = (radius + 2 * bevel) / radius, convexity = 1)
      kcircle(radius);  
}