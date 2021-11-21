function return_matrix = rotate_z(angle)
    return_matrix = [cos(angle), -sin(angle), 0; sin(angle), cos(angle), 0; 0 0 1];
end
