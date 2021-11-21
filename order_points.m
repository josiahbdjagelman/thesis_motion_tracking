function ordered_points = order_points(points)

    check_unique = unique(points);
    
    if(length(check_unique) == length(points)    
        % Takes a 3xn array and sorts in ascending order a = according to the first axis.
        [sorted_X, sort_index_Y] = sort(points(1,:));

        ordered_points(1,:) = sorted_X;
        ordered_points(2,:) = points(2,sort_index_Y);
        ordered_points(3,:) = points(3,sort_index_Y);
        
        % Swap the last 2 points around to ensure a 
    else
        disp("non_unique")
    end
end