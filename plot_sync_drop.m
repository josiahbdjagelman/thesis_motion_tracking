% Clear command space and window
clear;
clc;

for i = 1:6
    
   data(:,:,i) = csvread(['summary', num2str(i), '.csv']); 
    
end

max_frames = 1800;

data(4, :, : ) = data(4, :, : )*1000/(max_frames*10);

col_num = 1;

for j = 1:3
    mean10min(j) = mean(data(4,j+col_num,:));
    min10min(j) =  min(data(4,j+col_num,:));
    
    err_low(j) = mean10min(j)- min10min(j) ;

    max10min(j) =  max(data(4,j+col_num,:));
    
    err_high(j) = max10min(j) - mean10min(j);
end

cam_num = 1:3;
    
figure(3);
clf;
bar(cam_num,mean10min);
grid on;
hold on;
er = errorbar(cam_num,mean10min,err_low,err_high);
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
hold off;
title('Synchronous Frame Drop 10 Min');
xlabel('Number of Synchronous Dropped Cameras');
ylabel('Number of Occurrences (per 1000 frames)');