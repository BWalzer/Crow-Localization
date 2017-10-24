% function [preloc, realloc] = Crow_2D_Experiment(sfile1, sfile2, sfile3, sfile4, t_s, t_e, hyp_plot)
clear all;
close all;
hyp_plot = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------Crow_2D_Experiment---------------------------------
% This function attempts to locate a crow within an array of 4 microphones. 
% INPUTS: - sfile1, sfile2, sfile3, sfile4, t_s, t_e
%           The four sound files and the start and end time of the call
%           attempting to be localized. 
%
%         - hyp_plot: a switch to plot the hyperbolas calculated or not. true
%                     plots the hyperbolas, false does not plot. If the funciton is
%                     called without these values specified, the default is
%                     set to true
%                     and can be changed below.
%
% OUTPUTS: - preloc, realloc: a preliminary estimate of the location of the
% call's origin, and the "real" location which is calculated using an
% algorithm based on error analysis to locate the signal more precisely.
% Both calculations are based on the intersections of hyperbolae between
% the four microphones, generated by the difference of time of arrival of a
% sound to the four microphones.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Receiver Locations


receivernum = 4; % Number of Recorders
x_r(1) = 0; x_r(2) = 3; x_r(3) = 0.0; x_r(4) = 3;
y_r(1) = 0; y_r(2) = 0.0; y_r(3) = 3; y_r(4) = 3;
z_r(1:receivernum) = 0;



%% Read File %%
% Read the file
% And specify start time and end time of the sound you wish to localize. 

t_s = 672; %Start time
t_e = 673; %End time

<<<<<<< Updated upstream
t_s_section3 = t_s-0.01; %Start time
t_e_section3 = t_e-0.01; %End time

[FileName1,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file'); [data11,Fs] = audioread(FileName1); data1 = data11(t_s*Fs:t_e*Fs,2);
[FileName2,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file'); [data22,Fs] = audioread(FileName2);data2 = data22(t_s*Fs:t_e*Fs,2);
[FileName3,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file'); [data33,Fs] = audioread(FileName3); data3 = data33(t_s_section3*Fs:t_e_section3*Fs,1);
=======
%Rough estimate correction for Microphone 3's time error.

t_s_mic3 = t_s-0.01; %Start time 
t_e_mic3 = t_e-0.01; %End time 

[FileName1,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file'); [data11,Fs] = audioread(FileName1); data1 = data11(t_s*Fs:t_e*Fs,2);
[FileName2,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file'); [data22,Fs] = audioread(FileName2);data2 = data22(t_s*Fs:t_e*Fs,2);
[FileName3,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file'); [data33,Fs] = audioread(FileName3); data3 = data33(t_s_mic3*Fs:t_e_mic3*Fs,1);
>>>>>>> Stashed changes
[FileName4,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file'); [data44,Fs] = audioread(FileName4); data4 = data44(t_s*Fs:t_e*Fs,2);

n = 7;
beginFreq = 500/(Fs/2);
endFreq = 2500/(Fs/2);
[b,a] = butter(n,[beginFreq, endFreq], 'bandpass');

%Filter Signals%
data1 = filter(b, a, data1);
data2 = filter(b, a, data2);
data3 = filter(b, a, data3);
data4 = filter(b, a, data4);


L = length(data1); % length of signal in time
c = 343; % speed of sound (m/s)
NFFT = 2^nextpow2(L); % Length of the FFT
t = (0:L-1)/Fs;    % Time vector (s)
F = ((0:NFFT-1)/(NFFT))*Fs;   % Frequency vector (Hz)
k = 2*pi*F/c;                 % Wave number

%% Plot Spectrogram
Nfft = 256;    win_size = 125;    ovlap = 0.90;
[~,FFM_1,TTM_1,PM_1] = spectrogram(data1,hanning(win_size),round(ovlap*win_size),Nfft,Fs);
[~,FFM_2,TTM_2,PM_2] = spectrogram(data2,hanning(win_size),round(ovlap*win_size),Nfft,Fs);
[~,FFM_3,TTM_3,PM_3] = spectrogram(data3,hanning(win_size),round(ovlap*win_size),Nfft,Fs);
[~,FFM_4,TTM_4,PM_4] = spectrogram(data4,hanning(win_size),round(ovlap*win_size),Nfft,Fs);

figure(6)
subplot(4,1,1)
imagesc(TTM_1,FFM_1(1:Nfft/2+1)/1000,10*log10(PM_1(1:Nfft/2+1,:))/10e-6);axis xy;colormap(jet)
subplot(4,1,2)
imagesc(TTM_2,FFM_2(1:Nfft/2+1)/1000,10*log10(PM_2(1:Nfft/2+1,:))/10e-6);axis xy;colormap(jet)
subplot(4,1,3)
imagesc(TTM_3,FFM_3(1:Nfft/2+1)/1000,10*log10(PM_3(1:Nfft/2+1,:))/10e-6);axis xy;colormap(jet)
subplot(4,1,4)
imagesc(TTM_4,FFM_4(1:Nfft/2+1)/1000,10*log10(PM_4(1:Nfft/2+1,:))/10e-6);axis xy;colormap(jet)
xlabel('Time(s)')
ylabel('Frequency(kHz)')
title('Element 1')
%%
Fmin = 500;                                                               % Minimum Frequency (Hz)
Fmax = 2500;                                                               % Maximum Frequency (Hz)
[~,Imin] = min(abs(F-Fmin));                                               % Minimum Frequency Index
[~,Imax] = min(abs(F-Fmax));                                               % Maximum Frequency Index

%If the funciton was called without a value for 'hyp_plot', the default
%is set to true (yes plots)
if ~exist('hyp_plot', 'var')
    hyp_plot = true;
end


%% ********************* Localization ***********************
% ************************* CROSS CORRELATION *****************************
x_grid = (-1:0.001:2);
y_grid = (-1:0.001:2);

cor_12 = xcorr(data1,data2,'coef');
cor_13 = xcorr(data1,data3,'coef');
cor_14 = xcorr(data1,data4,'coef');
cor_34 = xcorr(data3,data4,'coef');
cor_24 = xcorr(data2,data4, 'coeff');
cor_23 = xcorr(data2,data3, 'coeff');

[~, max_ind_12] = max(cor_12);
[~, max_ind_13] = max(cor_13);
[~, max_ind_14] = max(cor_14);
[~, max_ind_34] = max(cor_34);
[~, max_ind_24] = max(cor_24);
[~, max_ind_23] = max(cor_23);

% time delay between element 1 and 2
if max_ind_12 >= L  
    t_max_12 = t(max_ind_12-L+1); 
else
    t_max_12 = -t(L-max_ind_12+1);
end

% time delay between element 1 and 3
if max_ind_13 >= L
       t_max_13 = t(max_ind_13-L+1); 
else
    t_max_13 = -t(L-max_ind_13+1);
end   

% time delay between element 1 and 4
if max_ind_14 >= L    
    t_max_14 = t(max_ind_14-L+1); 
else
    t_max_14 = -t(L-max_ind_14+1);
end   

% time delay between element 3 and 2

if max_ind_34 >= L    
    t_max_34 = t(max_ind_34-L+1); 
else
    t_max_34 = -t(L-max_ind_34+1);
end   

% time delay between element 2 and 4
if max_ind_24 >= L    
    t_max_24 = t(max_ind_24-L+1);
else
    t_max_24 = -t(L-max_ind_24+1);
end

% time delay between element 2 and 3
if max_ind_23 >= L    
    t_max_23 = t(max_ind_23-L+1); 
else
    t_max_23 = -t(L-max_ind_23+1);
end   


%% **************************** HYPERBOLA **********************************
%This section creates the hyperbolas that arise from the time difference of
%arrivals that we calculated above. There are 6 hyperbolas between the
%4 microphones. 

%The hyperbolas that are between mics 1_2, 1_3, 2_4, 3_4 are simple to
%create (i.e, the hyperbola_points function will do everything for you with
%the right values). However, the hyperbolas between 1_4 and 2_3 are more
%difficult because they require rotation after the fact, and some
%translations.

%number of points on the hyperbola, more points results in a more precise
%calculation, but will take more time to calculate.
point_num = 1000;


%Hyperbola between mics 1 and 2, plotted in BLACK
    
a_12 = abs(t_max_12)*c/2; %a value for the hypoerbola
c_12 =  sqrt((x_r(1)-x_r(2))^2+(y_r(1)-y_r(2))^2+(z_r(1)-z_r(2))^2); %c value for the hyperbola
b_12 = sqrt(c_12^2-a_12^2); %b value for the hyperbola
x_mid_12 = (x_r(1)+x_r(2))/2; %calculates the x-value at the midpoint between the two microphones
y_mid_12 = (y_r(1)+y_r(2))/2; %calculates the y-value at the midpoint between the two microphones
%hyperbola_points is a function that takes all the different parts of the
%hyperbola, and creates a matrix of size 2 x (point_num*2+1), where the
%first row is the x values and the second row is the y values. See the
%hyperbola_points function for more detail
[h_12(1,:), h_12(2,:)] = hyperbola_points(a_12, b_12, x_mid_12, y_mid_12, x_r(1)-5, x_r(4)+5, y_r(1)-5, y_r(4)+5, point_num, 1);


%Hyperbola between mics 1 and 3, plotted in RED

a_13 = abs(t_max_13)*c/2;
c_13 =  sqrt((x_r(1)-x_r(3))^2+(y_r(1)-y_r(3))^2+(z_r(1)-z_r(3))^2); 
b_13 = sqrt(c_13^2-a_13^2);
x_mid_13 = (x_r(1)+x_r(3))/2; 
y_mid_13 = (y_r(1)+y_r(3))/2;
[h_13(1,:), h_13(2,:)] = hyperbola_points(a_13, b_13, x_mid_13, y_mid_13, x_r(1)-5, x_r(4)+5, y_r(1)-5, y_r(4)+5, point_num, 2);



%Hyperbola between mics 1 and 4, plotted in PURPLE
%(BW) I'm attempting to plot the hyperbola as if point 4 was on the x axis,
%preserving distance between the points

x_4_rotated = x_r(1) + sqrt((x_r(4) - x_r(1))^2 + (y_r(4) - y_r(1))^2); %preserving the distance between points 1 and 4
y_4_rotated = y_r(1); %rotating point 4 down to be in line horizontally with recorder 1
a_14 = abs(t_max_14)*c/2; 
c_14 = sqrt((x_r(1) - x_4_rotated)^2 + (y_r(1) - y_4_rotated)^2 + (z_r(1) - z_r(4))^2);
b_14 = sqrt(c_14^2-a_14^2);
x_mid_14 = (x_r(1) + x_4_rotated)/2;
y_mid_14 = (y_r(1) + y_4_rotated)/2;
[h_14(1,:), h_14(2,:)] = hyperbola_points(a_14, b_14, x_mid_14, y_mid_14, x_r(1)-5, x_r(4)+5, y_r(1)-5, y_r(4)+5, point_num, 1);

%Because the h_14 hyperbolas was initially calculated as if recorder 4 was
%inline horizontally with recorder 1, the hyperbola needs to be rotated up
%by theta_14 radians. This is calculated by taking the arctan of the ratio
%of the y distance between recorders 1 and 4, given by y_r(4) - y_r(1), 
%and the x distance between recorders 1 and 4, given by x_r(4) - x_r(1)
theta_14 = atan(abs(y_r(4) - y_r(1)) / abs(x_r(4) - x_r(1))); 

%the 4x8 rotation matrix, this rotates the hyperbola by theta_14 degrees
%counterclockwise, centered at the origin.
rotation = [cos(theta_14) -sin(theta_14);
             sin(theta_14) cos(theta_14)];
h_14 = rotation * h_14;


% 
% %Hyperbola between mics 3 and 4, plotted in BLUE

a_34 = abs(t_max_34)*c/2;
c_34 =  sqrt((x_r(3)-x_r(4))^2+(y_r(3)-y_r(4))^2+(z_r(3)-z_r(4))^2); 
b_34 = sqrt(c_34^2-a_34^2);
x_mid_34 = (x_r(3)+x_r(4))/2;
y_mid_34 = (y_r(3)+y_r(4))/2;
[h_34(1,:), h_34(2,:)] = hyperbola_points(a_34, b_34, x_mid_34, y_mid_34, x_r(1)-5, x_r(4)+5, y_r(1)-5, y_r(4)+5, point_num, 1);


%Hyperbola between mics 2 and 3, plotted in Green
x_3_rotated = x_r(2) - sqrt((x_r(2) - x_r(3))^2 + (y_r(2) - y_r(3))^2);
y_3_rotated = y_r(2);
a_23 = abs(t_max_23)*c/2;
c_23 = sqrt((x_r(3) - x_3_rotated)^2 + (y_r(3) - y_3_rotated)^2); %excluding z for now, because it's 0 in testing
b_23 = sqrt(c_23^2 - a_23^2);
x_mid_23 = (x_3_rotated + x_r(2))/2;
y_mid_23 = (y_3_rotated + y_r(2))/2;
[h_23(1,:), h_23(2,:)] = hyperbola_points(a_23, b_23, x_mid_23, y_mid_23, x_r(1)-5, x_r(4)+5, y_r(1)-5, y_r(4)+5, point_num, 1);

%shift the hyperbola over, so it can be rotated about the origin
h_23(1,:) = h_23(1,:) - x_r(2);

%rotation matrix, rotates theta_23 radians counterclockwise, centered about
%the origin
theta_23 = -atan(abs(y_r(3) - y_r(2)) / abs(x_r(3) - x_r(2)));
rotation = [cos(theta_23) -sin(theta_23);
             sin(theta_23) cos(theta_23)];
h_23 = rotation * h_23;
h_23(1,:) = h_23(1,:) + x_r(2);


% %Hyperbola between mics 2 and 4, plotted in Cyan

a_24 = abs(t_max_24)*c/2;
c_24 = sqrt((x_r(2) - x_r(4))^2 + (y_r(2) - y_r(4))^2 + (z_r(2) - z_r(4))^2);
b_24 = sqrt(c_24^2 - a_24^2);
x_mid_24 = (x_r(2) + x_r(4))/2;
y_mid_24 = (y_r(2) + y_r(4))/2;
[h_24(1,:), h_24(2,:)] = hyperbola_points(a_24, b_24, x_mid_24, y_mid_24, x_r(1)-5, x_r(4)+5, y_r(1)-5, y_r(4)+5, point_num, 2);



%% plotting the hyperbolas
if hyp_plot == true %hyp_plot == TRUE -> plot hyperbolas, hyp_plot == FALSE -> no plotting
    figure (7); %creates a new window
    xlim([x_r(1)-.01 x_r(2)+0.01]); %restricts the plot window 
    ylim([y_r(1)-0.01 x_r(2)+.01]); %restricts the plot window

    hold on; %stops changes being made to the configuration of the plots
%     plot(x_s,y_s,'dk','MarkerFaceColor','y','markersize',14,'LineWidth',1); %plots a Green diamond at the simulated source location
    plot(x_r(1),y_r(1),'ob','MarkerFaceColor','b','markersize',14,'LineWidth',1); %plots a blue dot at the location of the four microphones
    plot(x_r(2),y_r(2),'ob','MarkerFaceColor','b','markersize',14,'LineWidth',1); 
    plot(x_r(3),y_r(3),'ob','MarkerFaceColor','b','markersize',14,'LineWidth',1);
    plot(x_r(4),y_r(4),'ob','MarkerFaceColor','b','markersize',14,'LineWidth',1);
    legend('Actual Source Location','Receivers Location') %adds a legend to the plot

    %Plots the hyperbola between mics 1 and 2: Black

    plot(h_12(1,:),h_12(2,:),'k'); 

    
    %Plots the hyperbola between mics 1 and 3: Red

    plot(h_13(1,:),h_13(2,:),'r'); 

    %Plots the hyperbola between mics 1 and 4: Magenta

    plot(h_14(1,:), h_14(2,:), 'm');
  

    %Plots the hyperbola between mics 3 and 4: Blue

    plot(h_34(1,:),h_34(2,:),'b');

    
    %Plots the hyperbola between mics 2 and 4: Cyan

    plot(h_24(1,:), h_24(2,:), 'c');

 
    %Plots the hyperbola between mics 2 and 3: Green
    plot(h_23(1,:), h_23(2,:), 'g');
  
    
%     
% %%%%%%%%%%%%%%%%%%    CALCULATION OF INTERSECTIONS  %% %%%%%%%%%%%%%%%
% This section calculates all the intersections of the 6 hyperbolae in the
% relevant region based on the time difference."Intersections" between
% parallel hyperbolae are excluded. NOTE: Because Hyperbola 23 is shifted
% and rotated, it uses a different version of hypsect than the others. Its
% shifting and rotation causes the arcs that would correspond to positive
% and negative time differences for the other hyperbolae switch. 
%                     

            %Intersections between h_12 and the others
    qmin1213 = hypsect(h_12, h_13, t_max_12, t_max_13);
    plot (qmin1213(1), qmin1213(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    qmin1214 = hypsect(h_12, h_14, t_max_12, t_max_14);
    plot (qmin1214(1), qmin1214(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    qmin1223 = hypsectB(h_23, h_12, t_max_23, t_max_12);
    plot (qmin1223(1), qmin1223(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    qmin1224 = hypsect(h_12, h_24, t_max_12, t_max_24);
    plot (qmin1224(1), qmin1224(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
            %Intersections between h_13 and the others (exlcuding those
            %already calculated above)
    
    qmin1314 = hypsect(h_13, h_14, t_max_13, t_max_14);
    plot (qmin1314(1), qmin1314(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    qmin1323 = hypsectB(h_23, h_13, t_max_23, t_max_13);
    plot (qmin1323(1), qmin1323(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
      
    qmin1334 = hypsect(h_13, h_34, t_max_13, t_max_34);
    plot (qmin1334(1), qmin1334(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    %Intersections between h_14 and the others (exlcuding those
            %already calculated above)
    
    qmin1423 = hypsectB(h_23, h_14, t_max_23, t_max_14);
    plot (qmin1423(1), qmin1423(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    qmin1424 = hypsect(h_14, h_24, t_max_14, t_max_24);
    plot (qmin1424(1), qmin1424(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    qmin1434 = hypsect(h_14, h_34, t_max_14, t_max_34);
    plot (qmin1434(1), qmin1434(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    %Intersections between h_23 and the others (exlcuding those
            %already calculated above)
    
    qmin2324 = hypsectB(h_23, h_24, t_max_23, t_max_24);
    plot (qmin2324(1), qmin2324(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    qmin2334 = hypsectB(h_23, h_34, t_max_23, t_max_34);
    plot (qmin2334(1), qmin2334(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    %Intersections between h_24 and the others (exlcuding those
            %already calculated above)
    
    qmin2434 = hypsect(h_24, h_34, t_max_24, t_max_34);
    plot (qmin2434(1), qmin2434(2),'dk','MarkerFaceColor','r','markersize',11,'LineWidth',1);
    
    %------------------CALCULATION OF PRELIMINARY LOCATION----------------------%
    %   The preliminary calculation is calculated by taking the mean
    %   of the x and y coordinates of all the intersectionsn calculated
    %   above. This location is the plotted as a magenta diamond. 
    
    prexmatrix = [qmin1213(1),qmin1214(1),qmin1223(1),qmin1224(1),qmin1314(1),qmin1323(1),qmin1334(1),qmin1423(1),qmin1424(1),qmin1434(1),qmin2324(1),qmin2334(1),qmin2434(1)];
    
    preymatrix = [qmin1213(2),qmin1214(2),qmin1223(2),qmin1224(2),qmin1314(2),qmin1323(2),qmin1334(2),qmin1423(2),qmin1424(2),qmin1434(2),qmin2324(2),qmin2334(2),qmin2434(2)];
    
    preloc = [mean(meanmaker(prexmatrix)),mean(meanmaker(preymatrix))];
    plot (preloc(1), preloc(2),'dk','MarkerFaceColor','m','markersize',11,'LineWidth',1);
    
    
%%%%%%%%%%%CREATING SECTIONS%%%%%%%%    
%Divided the array within the 4 microphones into 9 sections
%  _____ _____ _____
% |     |     |     |
% |  7  |  8  |  9  |
% |_____|_____|_____|
% |     |     |     |
% |  4  |  5  |  6  |
% |_____|_____|_____|
% |     |     |     |
% |  1  |  2  |  3  |
% |_____|_____|_____|

%Size of Space 

Space_x = x_r(4);
Space_y = y_r(4);

%Section 1 
if (preloc(1) < Space_x/3) && (preloc(2) < Space_y/3)
    Space = 1;
end
%Section 2
if (preloc(1) > Space_x/3) && (preloc(1) < 2*Space_x/3) && (preloc(2) < Space_y/3)
    Space = 2;
end
%Section 3
if (preloc(1) > 2*Space_x/3) && (preloc(2) < Space_y/3)
    Space = 3;
end
%Section 4 
if (preloc(1) < Space_x/3) && (preloc(2) > Space_y/3) && (preloc(2) < 2*Space_y/3)
    Space = 4;
end
%Section 5
if (preloc(1) > Space_x/3) && (preloc(1) < 2*Space_x/3) && (preloc(2) > Space_y/3) && (preloc(2) < 2*Space_y/3)
    Space = 5;
end
%Section 6
if (2*Space_x/3 < preloc(1)) && (preloc(2) > Space_y/3) && (preloc(2) < 2*Space_y/3)
    Space = 6;
end
%Section 7 
if (preloc(1) < Space_x/3) && ( preloc(2) > 2*Space_y/3) 
    Space = 7;
end
%Section 8
if (preloc(1) > Space_x/3) && (preloc(1) < 2*Space_x/3) && (preloc(2) > 2*Space_y/3) 
    Space = 8;
end
%Section 9
if (2*Space_x/3 < preloc(1)) && (preloc(2) > 2*Space_y/3) 
    Space = 9;
end

%%-----------CALCULATING REAL LOCATION-----------%%
%   The "real" location is calculated by eliminating intersections
%   involving hyerbolae found to be least accurate in a given region of the
%   grid (through error analysis). It is then plotted as a blue diamond. 

realloc = [0,0];

if (Space == 1)
    rexmatrix = [qmin1213(1),qmin1214(1),qmin1223(1),qmin1314(1),qmin1323(1),qmin1423(1)];
    reymatrix = [qmin1213(2),qmin1214(2),qmin1223(2),qmin1314(2),qmin1323(2),qmin1423(2)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end

if (Space == 2)
    rexmatrix = [qmin1214(1),qmin1223(1),qmin1423(1),qmin1434(1),qmin2334(1)];
    reymatrix = [qmin1214(2),qmin1223(2),qmin1423(2),qmin1434(2),qmin2334(2)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end

if (Space == 3)
    rexmatrix = [qmin1214(1),qmin1223(1),qmin1224(1),qmin1423(1),qmin1424(1),qmin2324(1)];
    reymatrix = [qmin1214(2),qmin1223(2),qmin1224(2),qmin1423(2),qmin1424(2),qmin2324(2)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end

if (Space == 4)
    rexmatrix = [qmin1314(1),qmin1323(1),qmin1423(1),qmin1424(1),qmin2324(1)];
    reymatrix = [qmin1314(2),qmin1323(2),qmin1423(2),qmin1424(2),qmin2324(2)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end

if (Space == 5)
    realloc = preloc;
end

if (Space == 6)
    rexmatrix = [qmin1314(1),qmin1323(1),qmin1423(1),qmin1424(1),qmin2324(1)];
    reymatrix = [qmin1314(2),qmin1323(2),qmin1423(2),qmin1424(2),qmin2324(2)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end

if (Space == 7)
    rexmatrix = [qmin1314(1),qmin1323(1),qmin1334(1),qmin1423(1),qmin1434(1),qmin2334(1)];
    reymatrix = [qmin1314(2),qmin1323(2),qmin1334(2),qmin1423(2),qmin1434(2),qmin2334(2)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end

if (Space == 8)
    rexmatrix = [qmin1214(1),qmin1223(1),qmin1423(1),qmin1434(1),qmin2334(1)];
    reymatrix = [qmin1214(2),qmin1223(2),qmin1423(2),qmin1434(2),qmin2334(2)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end

if (Space == 9)
    rexmatrix = [qmin1423(1),qmin1424(1),qmin1434(1),qmin2324(1),qmin2334(1),qmin2434(1)];
    reymatrix = [qmin1423(1),qmin1424(1),qmin1434(1),qmin2324(1),qmin2334(1),qmin2434(1)];
    realloc = [mean(meanmaker(rexmatrix)),mean(meanmaker(reymatrix))];
end


    plot (realloc(1), realloc(2),'dk','MarkerFaceColor','c','markersize',11,'LineWidth',1);
    

    grid on
    title ('Crow Localization')
    xlabel('x axis') % x-axis label
    ylabel('y axis') % y-axis label
    pbaspect([1 1 1])
end
%%%%%%% HYPSECT FUNCTION (For Type I Intersections)%%%%%%%%
% This is the function called to calculate the intersections of hyperbolae.
% It compares each point on the first hyperbola within a given quadrant to
% every point on the second and finds where the distance between them is a
% minimum, i.e. where they intersect. There is also a HYPSECT function for
% those intersections involving hyperbola 23, since the way it is shifted
% and rotated makes its positive and negative arcs opposite to every other
% hyperbola. 
%                 -Virdie Guy-
    function [hypmin] = hypsect(hyp1, hyp2, time1, time2)
    hypmin = [0,0,inf];
    if (time1 == 0) || (time2 == 0)
    end
    if (time1 < 0) && (time2 < 0) 
    for i = 1:(length(hyp1)-1)/2
        for j = 1:(length(hyp2)-1)/2
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
    end
     if (time1 > 0) && (time2 > 0) 
    for i = (length(hyp1)+3)/2:length(hyp1)
        for j = (length(hyp2)+3)/2:length(hyp2)
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
     end
     if (time1 > 0) && (time2 < 0) 
    for i = (length(hyp1)+3)/2:length(hyp1)
        for j = 1:(length(hyp2)-1)/2
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
     end
     if (time1 < 0) && (time2 > 0) 
    for i = 1:(length(hyp1)-1)/2
        for j = (length(hyp2)+3)/2:length(hyp2)
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
     end
    
   
    end
    %%%%%HYPSECTB%% This is for dealing with intersections with hyperbola 23. 
    % NOTE: For this to be accurate, hyp1 and time1 MUST correspond to h_23
    % and t_max_23, respectively. 
    
     function [hypmin] = hypsectB(hyp1, hyp2, time1, time2)
    hypmin = [0,0,inf];
    if (time1 == 0) || (time2 == 0)
    end
    if (time1 < 0) && (time2 < 0) 
    for i = (length(hyp1)+3)/2:length(hyp1)
        for j = 1:(length(hyp2)-1)/2
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
    end
     if (time1 > 0) && (time2 > 0) 
    for i = 1:(length(hyp1)-1)/2
        for j = (length(hyp2)+3)/2:length(hyp2)
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
     end
     if (time1 > 0) && (time2 < 0) 
    for i = 1:(length(hyp1)-1)/2
        for j = 1:(length(hyp2)-1)/2
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
     end
     if (time1 < 0) && (time2 > 0) 
    for i = (length(hyp1)+3)/2:length(hyp1)
        for j = (length(hyp2)+3)/2:length(hyp2)
    distancenum = sqrt((hyp1(1,i) - hyp2(1,j))^2 + (hyp1(2,i) - hyp2(2,j))^2);
    if distancenum < hypmin(3)
        hypmin = [hyp1(1,i), hyp1(2,i), distancenum];
    end
        end
    end
     end
    
   
     end
    
    %%%%%%%%%MEANMAKER FUNCTION%%%%%%%%%
    %This is used for generating the means used in calculating the
    %estimated locations based on intersections of hyperbolae. 
    
   function [meanmat] = meanmaker(inputmat)
    tracker = 0;
    for i = 1:length(inputmat)
        if inputmat(i) > 0
            tracker = tracker + 1;
            meanmat(tracker) = inputmat(i);
        end
    end
 end
    