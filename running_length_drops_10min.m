% Timestamp Analysis
% Author: Josiah Jagelman
% Date: 27/09/2021


for num_tests = 1:6


    for num_mins = [10]
    
        % Clear the Workspace and Command Window
        clearvars -except num_tests num_mins;
        clc;
        
        
        % Choose the number of data sheets
        num_cams = 6;
        threshold_milliseconds = 1;

        % Read the datasheets into Matlab
        data1 = csvread(['Test',num2str(num_tests),'/6cam/',num2str(num_mins),'min', '/camera0/Timestamp Data.csv']);
        data2 = csvread(['Test',num2str(num_tests),'/6cam/',num2str(num_mins),'min', '/camera1/Timestamp Data.csv']);
        data3 = csvread(['Test',num2str(num_tests),'/6cam/',num2str(num_mins),'min', '/camera2/Timestamp Data.csv']);
        data4 = csvread(['Test',num2str(num_tests),'/6cam/',num2str(num_mins),'min', '/camera3/Timestamp Data.csv']);
        data5 = csvread(['Test',num2str(num_tests),'/6cam/',num2str(num_mins),'min', '/camera4/Timestamp Data.csv']);
        data6 = csvread(['Test',num2str(num_tests),'/6cam/',num2str(num_mins),'min', '/camera5/Timestamp Data.csv']);

        % Extract just the pre-isp timestamps
        preisp1 = data1(:,3);
        preisp2 = data2(:,3);
        preisp3 = data3(:,3);
        preisp4 = data4(:,3);
        preisp5 = data5(:,3);
        preisp6 = data6(:,3);

        %% Test data in seconds
        %preisp1 = [50; 100;200;300;400;500;600;700;800];
        %preisp2 = [49.0001; 100;500;700;800];
        %preisp3 = [100;400; 700;800];

        threshold_test = 1*10^-6; % Change threshold value so that it is between 1 second difference


        %% Test 2 with a slightly smaller value than the rest (so that referencee will select that data point)
        %preisp1 = [14704050623000-1;14704083985000;14704117348000];
        %preisp2 = [14704050623000;14704117348000];
        %preisp3 = [14704050623000;14704117348000];

        length1 = length(preisp1);
        length2 = length(preisp2);
        length3 = length(preisp3);
        length4 = length(preisp4);
        length5 = length(preisp5);
        length6 = length(preisp6);

        max_length = max([length1, length2, length3, length4, length5, length6]);
        min_length = min([length1, length2, length3, length4, length5, length6]);


        preisp1(max_length+1) = 0;
        preisp2(max_length+1) = 0;
        preisp3(max_length+1) = 0;
        preisp4(max_length+1) = 0;
        preisp5(max_length+1) = 0;
        preisp6(max_length+1) = 0;

        preisp_all = [preisp1 preisp2 preisp3, preisp4, preisp5, preisp6];

        n_operations = 0;

        delete_n_rows = 0;
        row_count = 0;
        check_cols = 0;

        set_flag = 1;

        % Create a table with aligned data.
        aligned_data = [];

        % Sort the data
        for i = 1:length(preisp3)

            % Find the lowest timestamp within the row
            reference_timestamp = min([preisp_all(i,:)]);

            % For each column
            for j = 1:num_cams

                % Check if the current value is within the threshold of synced
                % frames
                if((abs(preisp_all(i,j) - reference_timestamp))/10^6<threshold_milliseconds)

                    % Add the data to the aligned data table
                    aligned_data(i,j) = preisp_all(i,j);


                    check_cols = check_cols + 1;

                    if(check_cols == num_cams && set_flag == 1)               
                       % Do not change this value
                       set_flag = 0;
                       delete_n_rows = i-1;
                    end


                else
                    check_cols = 0;
                    
                    % Count the number of times to align the data
                    n_operations = n_operations + 1;

                    % Fill out the table
                    aligned_data(i,j) = 0;

                    % Adjust our ISP data so that it can continue to be compared
                    % and processed by buffering the data with 0s

                    % Split the columns
                    preisp_a = preisp_all(:,1);
                    preisp_b = preisp_all(:,2);
                    preisp_c = preisp_all(:,3);
                    preisp_d = preisp_all(:,4);
                    preisp_e = preisp_all(:,5);
                    preisp_f = preisp_all(:,6);
                    
                    
                    % If adjusting column 1 (or column a)
                    if(j == 1)
                        preisp_a = [];
                        if(i == 1)
                            preisp_a(:,1) = [0;preisp_all(1:end,1)];
                        else
                            preisp_a(:,1) = [preisp_all(1:i-1, 1)', 0, preisp_all(i:end, 1)']';
                        end

                        preisp_b(length(preisp_b)+1) = 0;
                        preisp_c(length(preisp_c)+1) = 0;
                        preisp_d(length(preisp_d)+1) = 0;
                        preisp_e(length(preisp_e)+1) = 0;
                        preisp_f(length(preisp_f)+1) = 0;


                        
                    % If adjusting column 2 (or column b)    
                    elseif(j == 2)
                        preisp_b = [];
                        if(i == 1)
                            preisp_b(:,1) = [0;preisp_all(1:end,2)];
                        else
                            preisp_b = [preisp_all(1:i-1, 2)', 0, preisp_all(i:end, 2)']';
                        end
                        preisp_a(length(preisp_a)+1) = 0;
                        preisp_c(length(preisp_c)+1) = 0;
                        preisp_d(length(preisp_d)+1) = 0;
                        preisp_e(length(preisp_e)+1) = 0;
                        preisp_f(length(preisp_f)+1) = 0;
                        
                    % If adjusting column 3 (or column c)    
                    elseif(j == 3)
                        preisp_c = [];
                        if(i == 1)
                            preisp_c(:,1) = [0;preisp_all(1:end,3)];
                        else
                            preisp_c = [preisp_all(1:i-1, 3)', 0, preisp_all(i:end, 3)']';
                        end
                        preisp_a(length(preisp_a)+1) = 0;
                        preisp_b(length(preisp_b)+1) = 0;
                        preisp_d(length(preisp_d)+1) = 0;
                        preisp_e(length(preisp_e)+1) = 0;
                        preisp_f(length(preisp_f)+1) = 0;
                        
                    % If adjusting column 4 (or column d)    
                    elseif(j == 4)
                        preisp_d = [];
                        if(i == 1)
                            preisp_d(:,1) = [0;preisp_all(1:end,4)];
                        else
                            preisp_d = [preisp_all(1:i-1, 4)', 0, preisp_all(i:end, 4)']';
                        end
                        preisp_a(length(preisp_a)+1) = 0;
                        preisp_b(length(preisp_b)+1) = 0;
                        preisp_c(length(preisp_c)+1) = 0;
                        preisp_e(length(preisp_e)+1) = 0;
                        preisp_f(length(preisp_f)+1) = 0;
                        
                        
                    % If adjusting column 5 (or column e)    
                    elseif(j == 5)
                        preisp_e = [];
                        if(i == 1)
                            preisp_e(:,1) = [0;preisp_all(1:end,5)];
                        else
                            preisp_e = [preisp_all(1:i-1, 5)', 0, preisp_all(i:end, 5)']';
                        end
                        preisp_a(length(preisp_a)+1) = 0;
                        preisp_b(length(preisp_b)+1) = 0;
                        preisp_c(length(preisp_c)+1) = 0;
                        preisp_d(length(preisp_d)+1) = 0;
                        preisp_f(length(preisp_f)+1) = 0;
                        
                        
                    % If adjusting column 6 (or column f)    
                    elseif(j == 6)
                        preisp_f = [];
                        if(i == 1)
                            preisp_f(:,1) = [0;preisp_all(1:end,6)];
                        else
                            preisp_f = [preisp_all(1:i-1, 6)', 0, preisp_all(i:end, 6)']';
                        end
                        preisp_a(length(preisp_a)+1) = 0;
                        preisp_b(length(preisp_b)+1) = 0;
                        preisp_c(length(preisp_c)+1) = 0;
                        preisp_d(length(preisp_d)+1) = 0;
                        preisp_e(length(preisp_e)+1) = 0;
                    end

                    preisp_all = [];

                    preisp_all = [preisp_a, preisp_b, preisp_c, preisp_d, preisp_e, preisp_f];

                    preisp_a = [];
                    preisp_b = [];
                    preisp_c = [];
                    preisp_d = [];
                    preisp_e = [];
                    preisp_f = [];
                end


            end


        end


        % Delete the first n rows and the last row (with 3 0's)
        aligned_data_new = aligned_data(delete_n_rows+1:end-1,:);

        aligned_data = [];

        aligned_data = aligned_data_new;

        %% Differences analysis 

        % (ASSUMING THAT THE DATA CLEANUP DOESN'T INSERT 0s) 
        for i = 1:(length(aligned_data)-1)
                
            % Check to see if the data point is 0 (a buffer frame)
            if(((aligned_data(i+1,1)-aligned_data(i,1))/10^6) < 0 )
                differences1(i) = 0;
            else
                differences1(i) = (aligned_data(i+1,1)-aligned_data(i,1))/10^6;
                
            end
            
            
            % check to see if the data point is 0
            if(((aligned_data(i+1,2)-aligned_data(i,2))/10^6 )< 0 )
                differences2(i) = 0;
            else
                differences2(i) = (aligned_data(i+1,2)-aligned_data(i,2))/10^6;
            end
            
            % check to see if the data point is 0
            if(((aligned_data(i+1,3)-aligned_data(i,3))/10^6) < 0)
                differences3(i) = 0;
            else
                differences3(i) = (aligned_data(i+1,3)-aligned_data(i,3))/10^6;
            end
            
            % Check to see if the data point is 0 (a buffer frame)
            if(((aligned_data(i+1,4)-aligned_data(i,4))/10^6) < 0 )
                differences4(i) = 0;
            else
                differences4(i) = (aligned_data(i+1,4)-aligned_data(i,4))/10^6;
                
            end
            
            
            % check to see if the data point is 0
            if(((aligned_data(i+1,5)-aligned_data(i,5))/10^6 )< 0 )
                differences5(i) = 0;
            else
                differences5(i) = (aligned_data(i+1,5)-aligned_data(i,5))/10^6;
            end
            
            % check to see if the data point is 0
            if(((aligned_data(i+1,6)-aligned_data(i,6))/10^6) < 0)
                differences6(i) = 0;
            else
                differences6(i) = (aligned_data(i+1,6)-aligned_data(i,6))/10^6;
            end
            

        end

        differences = [differences1' differences2' differences3' differences4' differences5' differences6'];


        % Catch drops of 3 frames
        [row,col] = find(differences > (33.36 + threshold_milliseconds));

        check_synced_drop = differences(unique(row),:);

        check_count = 0;
        dropped_6_frames= 0;

        for(i = 1:length(check_synced_drop(:,1)))

            check_val = check_synced_drop(i,1); 

            if(check_val > 65)
                multiplier = round(check_val/66.754);
            end

            for j = 1:num_cams

                if(check_synced_drop(i,j) < (check_val)+1 && check_synced_drop(i,j)>(check_val)-1)
                   check_count = check_count +1;

                   % If they all equal the same
                   if(check_count == num_cams)
                       dropped_6_frames = dropped_6_frames + 1*multiplier;
                   end
                end

            end

            check_count = 0;
        end




        %% Summary Statistics
        n_synced_rows = 0;
        dropped_1_frame = 0;
        dropped_2_frames= 0;
        dropped_3_frames= 0;
        dropped_4_frames= 0;
        dropped_5_frames= 0;
        
        for i = 1:length(aligned_data)

            % Find the lowest timestamp within the row
            zero_timestamp = min([aligned_data(i,:)]);

            if(zero_timestamp ~= 0)
                % Fully synced rows
                n_synced_rows = n_synced_rows + 1;
            else
                count_dropped = 0;
                for(j = 1:num_cams)
                    
                    if(aligned_data(i,j) == zero_timestamp)
                        count_dropped = count_dropped + 1;

                    end

                end

                if(count_dropped == 1)
                    dropped_1_frame = dropped_1_frame + 1;
                elseif(count_dropped == 2)
                    dropped_2_frames = dropped_2_frames + 1;
                elseif(count_dropped == 3)
                    dropped_3_frames = dropped_3_frames + 1;
                elseif(count_dropped == 4)
                    dropped_4_frames = dropped_4_frames + 1;
                elseif(count_dropped == 5)
                    dropped_5_frames = dropped_5_frames + 1;
                else
                    dropped_6_frames = dropped_6_frames + 1;
                end
            end
        end



        % Calculate the number of run length drops:

        cam1_subsequent_drops = zeros(1,50);

        cam2_subsequent_drops = zeros(1,50);

        cam3_subsequent_drops = zeros(1,50);
        
        cam4_subsequent_drops = zeros(1,50);

        cam5_subsequent_drops = zeros(1,50);

        cam6_subsequent_drops = zeros(1,50);

        % Check each camera for synchronised drops
        for i = 1:(length(differences)-1)

            % If between 1 - 50 frames
            if(differences(i,1) > 34 && differences(i,1) < 1670)
                num_dropped = round(differences(i,1) / 33.363)-1;
                differences(i,1);
                cam1_subsequent_drops(num_dropped) = cam1_subsequent_drops(num_dropped) +1;
            end

            if(abs(differences(i,2)) > 34 && abs(differences(i,2)) < 1670)
                num_dropped = round(differences(i,2) / 33.363)-1;
                differences(i,2);
                cam2_subsequent_drops(num_dropped) = cam2_subsequent_drops(num_dropped) +1;

            end

            if(abs(differences(i,3)) > 34 && abs(differences(i,3)) < 1670)
                num_dropped = round(differences(i,3) / 33.363)-1;
                differences(i,3);
                cam3_subsequent_drops(num_dropped) = cam3_subsequent_drops(num_dropped) +1;
            end
            
            % If between 1 - 50 frames
            if(differences(i,4) > 34 && differences(i,4) < 1670)
                num_dropped = round(differences(i,4) / 33.363)-1;
                differences(i,4);
                cam4_subsequent_drops(num_dropped) = cam4_subsequent_drops(num_dropped) +1;
            end

            if(abs(differences(i,5)) > 34 && abs(differences(i,5)) < 1670)
                num_dropped = round(differences(i,5) / 33.363)-1;
                differences(i,5);
                cam5_subsequent_drops(num_dropped) = cam5_subsequent_drops(num_dropped) +1;

            end

            if(abs(differences(i,6)) > 34 && abs(differences(i,6)) < 1670)
                num_dropped = round(differences(i,6) / 33.363)-1;
                differences(i,6);
                cam6_subsequent_drops(num_dropped) = cam6_subsequent_drops(num_dropped) +1;
            end
            
        end
        
        cam1 = aligned_data(:,1);
        cam2 = aligned_data(:,2);
        cam3 = aligned_data(:,3);            
        cam4 = aligned_data(:,4);
        cam5 = aligned_data(:,5);
        cam6 = aligned_data(:,6);
        
        % Find the consecutive 0s in the data
        find_zeros1 = regionprops(bwlabel(cam1==0), 'Area', 'PixelIdxList');
        find_zeros2 = regionprops(bwlabel(cam2==0), 'Area', 'PixelIdxList');
        find_zeros3 = regionprops(bwlabel(cam3==0), 'Area', 'PixelIdxList');
        find_zeros4 = regionprops(bwlabel(cam4==0), 'Area', 'PixelIdxList');
        find_zeros5 = regionprops(bwlabel(cam5==0), 'Area', 'PixelIdxList');
        find_zeros6 = regionprops(bwlabel(cam6==0), 'Area', 'PixelIdxList');
        
        
        consecutive_frame_drop1 = [find_zeros1.Area];
        consecutive_frame_drop2 = [find_zeros2.Area];
        consecutive_frame_drop3 = [find_zeros3.Area];
        consecutive_frame_drop4 = [find_zeros4.Area];
        consecutive_frame_drop5 = [find_zeros5.Area];
        consecutive_frame_drop6 = [find_zeros6.Area];
        
        for i = 1:length(consecutive_frame_drop1)
            if (consecutive_frame_drop1(i) <=50)
                cam1_subsequent_drops(consecutive_frame_drop1(i)) = cam1_subsequent_drops(consecutive_frame_drop1(i)) + 1;
            end
        end
        
        for i = 1:length(consecutive_frame_drop2)
            if (consecutive_frame_drop2(i) <=50)
                cam2_subsequent_drops(consecutive_frame_drop2(i)) = cam2_subsequent_drops(consecutive_frame_drop2(i)) + 1;
            end
        end
        
        for i = 1:length(consecutive_frame_drop3)
            if (consecutive_frame_drop3(i) <=50)
                cam3_subsequent_drops(consecutive_frame_drop3(i)) = cam3_subsequent_drops(consecutive_frame_drop3(i)) + 1;
            end
        end
        
        for i = 1:length(consecutive_frame_drop4)
            if (consecutive_frame_drop4(i) <=50)
                cam4_subsequent_drops(consecutive_frame_drop4(i)) = cam4_subsequent_drops(consecutive_frame_drop4(i)) + 1;
            end
        end
        
        for i = 1:length(consecutive_frame_drop5)
            if (consecutive_frame_drop5(i) <=50)
                cam5_subsequent_drops(consecutive_frame_drop5(i)) = cam5_subsequent_drops(consecutive_frame_drop5(i)) + 1;
            end
        end
        
        for i = 1:length(consecutive_frame_drop6)
            if (consecutive_frame_drop6(i) <=50)
                cam6_subsequent_drops(consecutive_frame_drop6(i)) = cam6_subsequent_drops(consecutive_frame_drop6(i)) + 1;
            end
        end


        summary = [n_synced_rows, dropped_1_frame, dropped_2_frames, dropped_3_frames, dropped_4_frames, dropped_5_frames, dropped_6_frames, n_operations];
        summary2 = [[1:50]' cam1_subsequent_drops' cam2_subsequent_drops' cam3_subsequent_drops' cam4_subsequent_drops' cam5_subsequent_drops' cam6_subsequent_drops'];

        %dlmwrite(['summary',num2str(num_tests),'.csv'], summary,'delimiter',',','-append');
        dlmwrite(['running_drops_10min',num2str(num_tests),'.csv'], summary2, 'delimiter',',','-append');
    end

end

