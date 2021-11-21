function return_matrix = rotate_x(angle)
    return_matrix = [1 0 0; 0 cos(angle) -sin(angle); 0 sin(angle) cos(angle)];
end