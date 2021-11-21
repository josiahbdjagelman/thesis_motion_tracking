% Camera Mounting Radius Calculations
% Author: Josiah Jagelman
% Date: 12/08/2021
% This calculates the required radius to mount the cameras on the annulus
% given a certain working distance or elevation. It also plots these values
% on a graph


% Clear figure, command window and workspace
clf;
clc;
clear;

% set the constant parameters
annulus_radius = 56.6;
camera_offset = 20;
annulus_radius = annulus_radius + camera_offset;
camera_length = 70;
move_on = 0;


% Receive user input (1 or 2)
while(move_on == 0)
    usr_in = input("Choose (1) Angle Elevation or (2) Working Distance: ", 's');
      
    if(isempty(str2num(usr_in)))
        disp("Please enter a valid number.")
    elseif(str2num(usr_in) == 1 || str2num(usr_in) == 2)
       move_on = 1;
    else
        disp("Please enter a valid number.")
    end

end

% If the user wants to input the elevation in degrees
if(str2num(usr_in) == 1)
    
    % maximum angle is 90 degrees
    elevation_deg = input("Input required angle in degrees (0-90): ");
    elevation_rad = elevation_deg/180*pi;
    working_distance = annulus_radius/sin(elevation_rad);
    mounting_radius = (working_distance + camera_length)*sin(elevation_rad);

   
    
% If the user wants to input the working distance
elseif(str2num(usr_in) == 2)
    
    % minimum working distance = 56.6mm due to the runway
    working_distance = input("Input required working distance in mm (66.6 - inf): ");
   
    elevation_rad = asin(annulus_radius/working_distance);
    
    elevation_deg = elevation_rad / pi * 180;
    
    mounting_radius = (working_distance+camera_length)*sin(elevation_rad);
end

% Print the key values
fprintf("Working distance: %.2f mm\n", working_distance);

fprintf("Angle Elevation: %.2f degrees\n", elevation_deg);

fprintf("Mounting Radius %.2f cm\n", mounting_radius/10);


% Plot the results against a range of working distances
% minimum working distance = 66.6mm due to the runway + clearance
wd = 66.6:0.1:800.0;
   
for(i = 1:length(wd))
    elev_rad = asin(annulus_radius/wd(i));

    elev_deg = elev_rad / pi * 180;

    m_r(i) = (wd(i)+camera_length)*sin(elev_rad);

end

figure(1)
clf;
plot(wd,m_r);
xlabel('wd (mm)');
ylabel('m_r (mm)');
title('Mounting Radius for different Working Distances');
grid on;

% Plot against a range of angles
elev_deg = 0.1:0.1:90;

for(i = 1:length(elev_deg))
    
    elev_rad = elev_deg(i)/180*pi;
    wd_current(i) = annulus_radius/sin(elev_rad);
    m_r2(i) = (wd_current(i) + camera_length)*sin(elev_rad);

end

figure(2)
clf;
plot(elev_deg,m_r2);
xlabel('elevation angle (degrees)');
ylabel('m_r (mm)');
title('Mounting Radius for different Angles');
grid on;


