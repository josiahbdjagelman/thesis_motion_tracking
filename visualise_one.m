% Thesis Scanner Simulation
% Plot the view of a camera

% Clear command window and workspace and reset figures
clear;
clc;
%clf reset;

% SECTION I - Plotting the world coordinates and camera

% Set the points of the scanner
origin = [0,0,0];

% Plot the coordinates of the points of interest in the world frame (front
% and back of scanner
scanner_front = [40,40,40;40,40,-40;40,-40,40;40,-40,-40];

scanner_back = [-40,40,40;-40,40,-40;-40,-40,40;-40,-40,-40];

% Convert these to cartesian coordinates
x_origin = origin(1);
y_origin = origin(2);
z_origin = origin(3);


x_front = scanner_front(:,1)';
y_front = scanner_front(:,2)';
z_front = scanner_front(:,3)';

x_back = scanner_back(:,1)';
y_back = scanner_back(:,2)';
z_back = scanner_back(:,3)';

% Visualise the points
figure(1);
clf;
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('Z (mm)');
title('Camera Perspectives from different angles');
axis equal;
axis manual;
axis([-150,400,-150,150, -150, 150]);
view([0.5,-1,0.5]);
hold on;
plot3(x_origin,y_origin,z_origin, '.', 'Color', 'blue','MarkerSize',12);
grid on;
plot3(x_front,y_front,z_front, '.', 'Color', 'red','MarkerSize',12);
plot3(x_back,y_back,z_back, '.', 'Color', 'green','MarkerSize',12);

% Plot a centre line
plot3([-60,60],[0,0],[0,0], '--');

% The position from the origin of the centre of the annulus
dist_from_origin = 170; %-60

% The position of the point of interest we are measuring (determines the
% downwards angle of the cameras)
poi = 10;

endi=1;

endj=1;
% 
% for i = 1:endi
%     dist_from_origin = 60;
%     poi = poi - 5*(i-1);
% 
%     for j = 1:endj

        % dist_from_origin = dist_from_origin + (j-1)*1;
        

        % set the constant parameters of the cameras
        annulus_radius = 56.6; % The diagonal distance
        camera_offset = 20; % half of lens width
        annulus_radius = annulus_radius + camera_offset;
        camera_centre_length = 20; % change if lens changes
        full_camera_length = 70;


        elevation_rad = atan(annulus_radius/(dist_from_origin-poi));

        % maximum angle is 90 degrees
        working_distance_to_lens = annulus_radius/sin(elevation_rad);
        camera_centre_radius = (working_distance_to_lens + camera_centre_length)*sin(elevation_rad);
        mounting_radius = (working_distance_to_lens + full_camera_length)*sin(elevation_rad);


        num_cameras = 6;

        if num_cameras == 6
            angle_ranges = [-120:48:120];
        elseif num_cameras == 4 
            angle_ranges = [-90:60:90];
        elseif num_cameras == 3
            angle_ranges = [-90:90:90];
        end

        %angle_ranges = 0;
        figure_counter = 1;
        for annulus_angle = angle_ranges


            %annulus_angle = 0;
            angle_from_midline = annulus_angle/180*pi;


            % Calculate distances and angles given the parameters
            dist_from_poi = dist_from_origin-poi;
            elev_angle = atan2(camera_centre_radius,dist_from_poi);
            % Angles for the rotational matrices
            theta_x = angle_from_midline;
            theta_y1 = pi/2+elev_angle;

            % Calculate the absolute rotations as measured in the world frames
            Rx = rotate_x(theta_x);
            Ry1 = rotate_y(theta_y1);

            % Calculate the rotation and translation matrix for the rigid3D pose
            R = Ry1*Rx;
            t = [dist_from_origin camera_centre_radius*sin(angle_from_midline) camera_centre_radius*cos(angle_from_midline)];
            t2 = [dist_from_origin+full_camera_length*sin(elev_angle) mounting_radius*sin(angle_from_midline) mounting_radius*cos(angle_from_midline)];

            % Get the pose of the camera
            pose = rigid3d(R,t);

            % Plot the camera
            figure(1);
            hold on;
            cam = plotCamera('AbsolutePose', pose,'Size',20, 'Label', ['Camera ', num2str(figure_counter)]);

            % Plot the point of interest and the centre line axis of the camera
            plot3(poi,0,0,'b*');
            plot3([poi,dist_from_origin],[0,camera_centre_radius*sin(angle_from_midline)],[0,camera_centre_radius*cos(angle_from_midline)],'b--')


            % SECTION II - Virtual Pinhole Camera Model
            % Intrinsic Matrix
            focal_length = 12;
            scale_pixels = 1/(3.75*10^-3);
            f_x = focal_length * scale_pixels;
            f_y = focal_length * scale_pixels;
            x_0 = 0;
            y_0 = 0;
            s = 0;

            K = [f_x s x_0; 0 f_y y_0; 0 0 1];

            % Camera Resolution
            width = 1937;
            height = 1217;  

            % Create a rotation matrix for each rotation
            Ry90 = rotate_y(pi/2);
            Ry180 = rotate_y(pi);
            Rx_elev = rotate_x(elev_angle);
            Rz90 =  rotate_z(pi/2);
            Rz_optical_axis = rotate_z(theta_x);
% 
%             % Plot the translated camera coordinates
            plot3(t(1),t(2),t(3), 'g*', 'MarkerSize', 13);
            plot3(t2(1),t2(2),t2(3), 'b*', 'MarkerSize', 13);
            
            
            % Relative rotation of camera w.r.t the World Frame
            R = Rx_elev*-Rz_optical_axis*Ry180*Rz90*Ry90;

            t1 = -[R*t'];

            % External Matrix
            E = [R t1;];

            % Camera Matrix
            P = K*E;

            % Put all the world points into an array
            world_points = [[x_origin;y_origin;z_origin;], [x_front;y_front; z_front], [x_back; y_back;z_back]];
            front_points = [x_front;y_front; z_front;ones(1,length(z_front))];
            origin = [x_origin;y_origin;z_origin; 1];
            back_points = [x_back; y_back; z_back; ones(1,length(z_back))];

            %im_points = P*world_points;

            im_front = P*front_points;
            im_back = P*back_points;
            im_origin = P*origin;

            im_front = normalise_points(im_front);
            im_back = normalise_points(im_back);
            im_origin = normalise_points(im_origin);

            horiz_fov = 84.8; % Horizontal FOV degrees
            vertical_fov = 65.4; % Vertical FOV degrees

            % Horizontal and vertical range
            view_horiz_range = (dist_from_origin-40)*tan(horiz_fov/2*pi/180);
            view_vert_range = (dist_from_origin-40)*tan(vertical_fov/2*pi/180);


            camera_points = [40, -view_horiz_range, -view_vert_range, 1;40, -view_horiz_range, view_vert_range,1; 40, view_horiz_range, -view_vert_range,1;40, view_horiz_range, view_vert_range,1;];

            view_camera = P*[camera_points]';

            view_camera = normalise_points(view_camera);

            figure(2);
             if(figure_counter == 1)
                    clf;
                end

            subplot(2,3,figure_counter)
            %axis equal;
            plot(im_back(1,:), im_back(2,:), 'g.', 'MarkerSize', 12);
            hold on;
            plot(im_front(1,:), im_front(2,:), 'r.', 'MarkerSize', 12);
            plot(im_origin(1,:), im_origin(2,:), 'b.', 'MarkerSize', 12);

            plot(view_camera(1,:), view_camera(2,:), 'b.', 'MarkerSize',6);
            title(['Camera ' num2str(figure_counter) ' View']);
            xlabel('u');
            ylabel('v');
            grid on;
            %axis manual;
            ax = gca;
            set(ax,'XDir', 'reverse', 'YDir', 'reverse');
            axis square;
            axis equal;
            xlim([-width/2, width/2]);
            ylim([-height/2, height/2]);

            
            
            % Check whether or not the points are out of bound:
            xq = im_front(1,:);
            yq = im_front(2,:);
            xv = [-width/2, width/2];
            yv = [-height/2,height/2];
            
            [in, on] = inpolygon(xq, yq,xv,yv);
            
            poly2_FOV = polyshape([-width/2, -width/2, width/2, width/2],[-height/2, height/2, height/2, -height/2]);

            if(in < 4)
                
                figure(10)
                if(figure_counter == 1)
                    clf;
                end
                subplot(2,3,figure_counter)
                plot(poly2_FOV);
                grid on;
                xlabel('Pixels')
                ylabel('Pixels')
                title(['Camera ' num2str(figure_counter) ' View']);

            end
            
            % Compute the boundaries and their respective areas
            [boundary_front, area_front] = boundary(im_front(1,:)', im_front(2,:)');

            [boundary_back, area_back] = boundary(im_back(1,:)', im_back(2,:)');

            hold on;
            
            figure(2)
            plot(im_back(1,boundary_back), im_back(2, boundary_back), 'Color', 'green')

            plot(im_front(1,boundary_front), im_front(2, boundary_front), 'Color', 'red')
            
            figure(10)
            plot(im_back(1,boundary_back), im_back(2, boundary_back), 'Color', 'green')

            plot(im_front(1,boundary_front), im_front(2, boundary_front), 'Color', 'red')

            [xi, yi] = polyxpoly(im_back(1,boundary_front),im_back(2, boundary_front),im_front(1,boundary_front),im_front(2,boundary_front));

%            plot(xi,yi,'r+')

            % Create 2 areas of intersection
            poly1 = polyshape(im_back(1,boundary_front),im_back(2, boundary_front));

            poly2 = polyshape(im_front(1,boundary_front),im_front(2, boundary_front));

            polyout = intersect(poly1,poly2);
% 
            plot(polyout);

            poly_intersect_back = intersect(polyout, poly2_FOV);
            
            figure(2)

            plot(poly_intersect_back);


            
            figure(10)

            plot(poly_intersect_back);

            poly_intersect_front = intersect(poly2,poly2_FOV);
            
            plot(poly_intersect_front);
                 if(figure_counter == 3 || figure_counter ==6)
                    legend('FOV', 'Back of Scanner', 'Front of Scanner', 'Visible Back', 'Visible back within FOV', 'Visible front within FOV');
                end

            area_front1 = polyarea(poly_intersect_front.Vertices(:,1),poly_intersect_front.Vertices(:,2));

            area_back1 = polyarea(poly_intersect_back.Vertices(:,1),poly_intersect_back.Vertices(:,2));
         
            
            
            
            area_camera = width * height;
                       
            
            ratio_front(figure_counter) = area_front1/area_camera * 100;
%             ratio_back(figure_counter) = area_back/area_camera * 100;
            ratio_intersect(figure_counter) = area_back1/area_back * 100

            figure_counter = figure_counter + 1;

        end

%         scanner_ratio4(i,j) = mean(ratio_intersect);
%         
%         ratio_front_heatmap4(i,j) = mean(ratio_front);
%         
%         
%         area_heatmap4(i,j) = area_front;
%         
%         area_intersect_heatmap4(i,j) = area_intersect;
% %         
%         
%         
%         scanner_ratio12(i,j) = mean(ratio_intersect);
%         
%         ratio_front_heatmap12(i,j) = mean(ratio_front);
%         
%         
%         area_heatmap12(i,j) = area_front;
%         
%         area_intersect_heatmap12(i,j) = area_intersect;
%         
        
        
%     end
%     disp(i);
% end
% 
% %% Generate heatmaps
% % 
% figure(3);
% heatmap(scanner_ratio12/100);
% title('Ratio of Back of Scanner Visible Compared to Calculated Back Area(4mm Lens)');
% xlabel('Distance from origin (mm)');
% ylabel('Point of interest location on x-axis (mm)');
% ax = gca;
% ax.XData = [60:1:109];
% ay = gca;
% ay.YData = [50:-5:-195];
% colorbar;
% colormap jet;
% 
% figure(4);
% heatmap(ratio_front_heatmap12/100);
% title('Ratio of Front of Scanner Compared to Total FOV (4mm Lens)');
% xlabel('Distance from origin (mm)');
% ylabel('Point of interest location on x-axis (mm)');
% ax = gca;
% ax.XData = [60:1:109];
% ay = gca;
% ay.YData = [50:-5:-195];
% colorbar;
% colormap jet;
% 
% figure(5);
% heatmap(scanner_ratio12/100.*ratio_front_heatmap12/100);
% title('Combined Heat maps Showing Optimal Parameters (4mm)');
% xlabel('Distance from origin (mm)');
% ylabel('Point of interest location on x-axis (mm)');
% ax = gca;
% ax.XData = [60:1:109];
% ay = gca;
% ay.YData = [50:-5:-195];
% colorbar;
% colormap jet;

% 
% 
% figure(6);
% heatmap(area_intersect_heatmap12/100);
% title('Area Intersecting the back');
% xlabel('Distance from scanner');
% ylabel('Interest Point From Origin');
% colorbar;
% colormap jet;
% 
% 
% figure(8);
% heatmap((ratio_front_heatmap12 .* scanner_ratio12));
% title('Combined Heatmaps Showing Optimal Parameters 12mm');
% xlabel('Distance from scanner');
% ylabel('Interest Point From Origin');
% colorbar;
% colormap jet;
% caxis([0,40000]);

% 
% figure(9);
% %heatmap((ratio_front_heatmap4 .* scanner_ratio4));
% title('Combined Heatmaps Showing Optimal Parameters 4mm');
% xlabel('Distance from scanner');
% ylabel('Interest Point From Origin');
% colorbar;
% colormap jet;
% caxis([0,10000]);

