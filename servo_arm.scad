$fn = 40;

HOLDER_THICKNESS = 1;
SCREW_DIAMETER = 2.5;

// @Todo: add HOLDER_THICKNESS and SCREW_DIAMETER in Spline definition and eventually clear

/**
 *  Head / Tooth parameters
 *  Futaba 3F Standard Spline
 *  http://www.servocity.com/html/futaba_servo_splines.html
 *  external diameter, tooth count, tooth height, tooth length, tooth width, thickness
 */
FUTABA_3F_SPLINE = [5.92, 25, 0.3, 0.7, 0.1, 4];

module servo_futaba_3f(length, count) {
    servo_arm(FUTABA_3F_SPLINE, [length, count]);
}

module servo_standard(length, count) {
    servo_futaba_3f(length, count);
}

/**
 *  Tooth
 *
 *    |<-w->|
 *    |_____|___
 *    /     \  ^h
 *  _/       \_v
 *   |<--l-->|
 *
 *  - tooth length (l)
 *  - tooth width (w)
 *  - tooth height (h)
 *  - thickness
 *
 */
module servo_head_tooth(length, width, height, thickness) {
    linear_extrude(height = thickness) {
        polygon([[-length / 2, 0], [-width / 2, height], [width / 2, height], [length / 2,0]]);
    }
}

/**
 *  With PLA material, use clear at 0.3
 *  For ABS, use 0
 */
module servo_head(params, clear = 0) {

    diameter = params[0];
    count = params[1];
    height = params[2];
    length = params[3];
    width = params[4];
    thickness = params[5];

    % cylinder(r = diameter / 2, h = thickness + 1);

    cylinder(r = diameter / 2 - height + 0.03 + clear, h = thickness);

    for (i = [0 : count]) {
        rotate([0, 0, i * (360 / count)]) {
            translate([0, diameter / 2 - height + clear, 0]) {
                servo_head_tooth(length, width, height, thickness);
            }
        }
    }
}

/**
 *  Servo hold
 *  - Head / Tooth parameters
 *  - Arms params (length and count)
 */
module servo_arm(params, arms) {

    diameter = params[0];
    count = params[1];
    height = params[2];
    length = params[3];
    width = params[4];
    thickness = params[5];

    arm_length = arms[0];
    arm_count = arms[1];

    /**
     *  Servo arm
     *  - length is from center to last hole
     */
    module arm(length, width, head_height, thickness, hole_count = 1) {

        screw_diameter = 1.6;

        difference() {
            union() {
                cylinder(r = width / 2, h = thickness);

                linear_extrude(height = thickness) {
                    polygon([[-width / 2, 0], [-width / 3, length], [width / 3, length],[width / 2, 0]]);
                }

                translate([0, length, 0]) {
                    cylinder(r = width / 3, h = thickness);
                }

                if (length >= 12) {
                    translate([-thickness / 2 + 2, 3.8, -4]) {
                        rotate([90, 0, 0]) {
                            rotate([0, -90, 0]) {
                                linear_extrude(height = thickness) {
                                    polygon([[-length / 1.7, 4], [0, 4], [0, - head_height + 5], [-2, - head_height + 5]]);
                                }
                            }
                        }
                    }
                }
            }

            // Hole
            for (i = [0 : hole_count - 1]) {
                //translate([0, length - (length / hole_count * i), -1]) {
                translate([0, length - (4 * i), -1]) {
                    cylinder(r = screw_diameter / 2, h = 10);
                }
            }

            cylinder(r = SCREW_DIAMETER / 2, h = 10);
        }
    }

    difference() {
        translate([0, 0, 0.1]) {
            cylinder(r = diameter / 2 + HOLDER_THICKNESS, h = thickness + 1);
        }

        cylinder(r = SCREW_DIAMETER / 2, h = 10);

        servo_head(params);
    }

    // Arm
    translate([0, 0, thickness]) {
        for (i = [0 : arm_count - 1]) {
            rotate([0, 0, i * (360 / arm_count)]) {
                arm(arm_length, diameter + HOLDER_THICKNESS * 2, thickness, 2);
            }
        }
    }
}

module demo() {
    rotate([0, 180, 0])
        servo_standard(20, 4);
}

demo();

