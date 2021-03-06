use <2d.scad>;
use <random_maze_generator.scad>;

wall_height = 5;
wall_thickness = 4; 

cylinder_radius = 40;
cylinder_height = 100;

vertical_blocks = 10;
horizontal_blocks = 20;


/* 
 * modules for creating a maze
 *
 */


module horizontal_wall(radius, angle_from, length, thickness = 1, height = 1) {
    angle_difference = 180 * length / (PI() * radius);
    angle_to = angle_from + angle_difference;
    linear_extrude(thickness) arc(radius, [angle_from, angle_to], height);
}

module vertical_wall(radius, angle_from, length, thickness = 1, height = 1) {
     translate([0, 0, thickness]) mirror([0, 0, 1]) horizontal_wall(radius, angle_from, thickness, length + thickness, height);
}

module maze_cylinder(cylinder_r_h, blocks_v_h, maze_vector, wall_thickness = 1, wall_height = 1) {
    cylinder_r = cylinder_r_h[0];
    cylinder_h = cylinder_r_h[1];
    v_blocks = blocks_v_h[0];
    h_blocks = blocks_v_h[1];
    
    step_angle = 360 / h_blocks;
    
    horizontal_wall_length = 2 * PI() * cylinder_r / h_blocks;
    vertical_wall_length = cylinder_h / v_blocks;
    
    vertical_wall_angle = wall_thickness * 180 / (PI() * cylinder_r);
    
    for(vi = [0:len(maze_vector) - 1]) {
        cord = maze_vector[vi];
        i = cord[0] - 1;
        j = cord[1] - 1;
        v = cord[3];
        
        if(v == 1 || v == 3) {
            translate([0, 0, -j * vertical_wall_length]) 
                horizontal_wall(cylinder_r, i * step_angle, horizontal_wall_length, wall_thickness, wall_height);
        }
        if(v == 2 || v == 3) {
            translate([0, 0, -j * vertical_wall_length]) 
                vertical_wall(cylinder_r, i * step_angle + step_angle - vertical_wall_angle, vertical_wall_length, wall_thickness, wall_height);
        }
    } 
    
    translate([0, 0, -cylinder_h])
         horizontal_wall(cylinder_r, 0, 2 * PI() * cylinder_r, wall_thickness, wall_height);
     
     translate([0, 0, -cylinder_h]) cylinder(h=cylinder_h + wall_thickness, r=cylinder_r, $fn=96);
}

maze_vector = go_maze(1, 1, vertical_blocks, horizontal_blocks, replace([horizontal_blocks, 1, 0, UP_RIGHT_WALL()], [horizontal_blocks, 1, 0, UP_WALL()], init_maze(vertical_blocks, horizontal_blocks)));

maze_cylinder([cylinder_radius, cylinder_height], [vertical_blocks, horizontal_blocks], maze_vector, wall_thickness, wall_height);


