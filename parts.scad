// all dimensions in millimeters

// see: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features#$fa,_$fs_and_$fn
$fs = 2; // minimum size of a circle fragment, default=2, min=0.01
$fa = 15; // a circle has fragments = 360 divided by this number, default=12, min=0.01
$fn = $preview ? 24 : 80; // number of fragments in a circle, when non-zero $fs and $fa are ignored, default=0
chamfer_extrude = $preview ? 4 : 12;

use <../3d-designs/common.scad>;

CLIP_HT = 47.2; // 47.8 as measured
CLIP_D = 41.2; // 41.2 - 42.5 as measured, based on style variation
CLIP_WALL = 2;

LS_WIDEST_DIA = 75; // 66.7 as measured, the widest part of any saber parts
ANG = 110; // angle of opening for clip

module lightsaber_mount() {
	difference() {
		translate([0, 0, -CLIP_HT/2]) // center on the Z access
		linear_extrude(height = CLIP_HT)
		clip_2d();
		CLIP_V_HT = 5; // vertical height of the clip endpoint (approximate)
		translate([(CLIP_HT - CLIP_V_HT * 2) / 2 + .33, 0, 0])
		cosblock(w = CLIP_HT - CLIP_V_HT*2, h = CLIP_D + CLIP_WALL * 2);

		// translate([20, 0, 0])
		// rotate([90, 0, 0])
		// cylinder(d = 40, h = CLIP_HT, center = true);

		SCREW_SPREAD = 15;
		translate([0,0,SCREW_SPREAD])
		screwhole();
		translate([0,0,-SCREW_SPREAD])
		screwhole();

	}

	module screwhole() {
		translate([-CLIP_D/2-2,0,0])
		rotate([0, 90, 0])
		drywall_screw();
	}
}
// lightsaber_mount();

module clip_2d() {
	// the clip
	offset(r = CLIP_WALL/2) {
		difference() {
			circle(d = CLIP_D + CLIP_WALL + 0.01);
			circle(d = CLIP_D + CLIP_WALL);
			rotate(-ANG/2)
			piece(d = 50, angle = ANG);
		}
	}
	// double check the inner clip diameter
	// color("silver") circle(d = CLIP_D);

	// wall foot
	WALL_PLATE_THICKNESS = 4;
	OUTER_R = 2;
	difference() {
		translate([-LS_WIDEST_DIA/2, 0 ])
	  offset(OUTER_R) offset(-8) offset(8) {
			union() {
				translate([WALL_PLATE_THICKNESS/2, 0])
				square([WALL_PLATE_THICKNESS, CLIP_D + CLIP_WALL * 2 - OUTER_R*2], center = true);
				translate([WALL_PLATE_THICKNESS + 7, 0])
				square([12, 10], center = true);
				translate([LS_WIDEST_DIA/2, 0])
				circle(d = CLIP_D + CLIP_WALL*2 - OUTER_R * 2);
			}
		}
		// make flat wall plate with sharp corners
		translate([-5 - LS_WIDEST_DIA/2, 0])
		square([10, CLIP_D + CLIP_WALL*2], center = true);

		// cut out inner circle
		circle(d = CLIP_D + CLIP_WALL*2 - 0.1);

		// chop off mating edge
		translate([CLIP_D - CLIP_D/2 + 2, 0])
		square(CLIP_D*2, center = true);
	}
}
// clip_2d();

//polygon(coswave_2d(10, 100));
function coswave_2d(h = 10, w = 100) = [
	for (phi = [0 : 1 : 360]) [phi * w / 360, h/2 * cos(phi) + h/2], [360 * w / 360, 0], [0, 0]
];

module cosblock(w = 100, h = 100) {
	translate([0, -h/2, 0])
	rotate([-90, -90, 0])
	linear_extrude(height = h)
	translate([-w/2, -w/2])
	difference() {
		square(w);
		COS_H = (CLIP_D/2 + CLIP_WALL)* cos(ANG/2);
		echo(COS_H);
		polygon(coswave_2d(COS_H, w));
	}
}

KYBER_LENGTH = 34.85; // 34.85 as measured
KYBER_D1 = 17.3;
KYBER_D2 = 15.2;
KYBER_H1 = 6.4;
KYBER_H2 = 4.3;
module kyber_crystal() {
	color("purple")
	hull() {
		cylinder(d1 = 0, d2 = KYBER_D2, h = KYBER_H2);
		translate([0, 0, KYBER_LENGTH - KYBER_H1])
		cylinder(d1 = KYBER_D1, d2 = 0, h = KYBER_H1);
	}
}
// kyber_crystal();

// move parts depending on single view (rendering) or group view (all parts)
module render(part, location, named) {
	if (part == "all" || part == named) {
		MOVE = (part != "all") ?  [0, 0, 0] : location;
		translate(MOVE) children();
	}
	echo(parent_module(0));
}

PART = "all";
echo(str("render ", PART));
render(PART, [0, 0, 0], "lightsaber_mount") lightsaber_mount();
