function return_points = normalise_points(input_points)


    for i = 1:size(input_points,2);


        return_points(:,i) = input_points(:,i)/input_points(3,i);

    end
end
