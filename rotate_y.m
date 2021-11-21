function return_matrix = rotate_y(angle)
    return_matrix = [cos(angle), 0, sin(angle); 0 1 0; -sin(angle), 0, cos(angle)];
end