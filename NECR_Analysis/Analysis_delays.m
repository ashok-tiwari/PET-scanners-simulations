% NECR Analaysis Discovery MI scanner simulation using the scatter phantom
% Read delayed file for delayed rates estimations

clc; clear; close all; workspace
tic

delays = load('Delay_300_MBq.dat');
Singogram_Theta = delays(:,1);
Sinogram_S = delays(:,2);

hot = jet;  % change all colormap

% 2D histogram with 321 bins for theta and 641 bins for S (1 bin = 1mm)
delayed_coinc = hist3([Singogram_Theta, Sinogram_S], 'Nbins', [321 641]);

figure(1)
imshow(delayed_coinc, [], 'XData', [-320 320], 'YData', []);
colormap(flipud(hot)); colorbar;
axis on;
xlabel('S (mm)'); ylabel('Theta (rad)');
%title('Delayed coincidences (randoms) sinogram');
set(gca,'FontSize', 12);
print('plots/delayedsinogram', '-dpng', '-r400'); %<-Save as PNG with 400 DPI

% Apply Gaussian filter to take into account the effect of limited spatial resolution
for i = 1:321
    delayed_coinc(i, :) = imgaussfilt(delayed_coinc(i,:), 0.652);
end

% Note on value: 0.652
% Spatial resolution depends on the radial offset and the measurement direction and 
% values in the data sheet range between 4 mm and 4.8 mm for a 1cm offset,
% so, sigma (sd) = 1/3.125(FWHM (4.8mm)/(SQRT(8 ln 2))) = 0.652, where
% 3.125 mm is the voxel edge of GE scanner

% NEMA ANALYSIS WITH RANDOMS ESTIMATE 
% Step 1: Remove more than 12 cm from center
central_bin = (length(delayed_coinc) - 1)/2;
hc_coinc = delayed_coinc; 
hc_coinc(:, 1:(central_bin-120)) = 0; 
hc_coinc(:, (central_bin+120): end) = 0;

% Steps 2 and 3: Find the maximum pixel and shift rows (Alignment)
nbins = length(hc_coinc);
central_bin = round(nbins/2)-1;
for i = 1:321
    maxbin = max(hc_coinc(i, :));
    [x,y] = find(hc_coinc(i, :) == maxbin);
    shift = round(central_bin - y);
    row = hc_coinc(i, :);
    row = circshift(row, [0 shift]);
    hc_coinc(i, :) = row;
end

% Step 4: Sum projection
S_coinc = sum(hc_coinc).'; % transpose 

figure(2)
edges = linspace(-320, 320, 641); % create 641 bins
plot(edges, S_coinc, 'k', 'LineWidth', 1.5);
xlim([-320 320]);
%ylim([ ]);
grid on;
xlabel('S (mm)');
ylabel('Delayed coincidences (randoms)');
%title('Plot of delayed coincidences');
set(gca,'FontSize', 12);
print('plots/randoms', '-dpng', '-r400'); %<-Save as PNG with 400 DPI

% Total number of delayed coincidences
C_delayed = round(sum(S_coinc));

toc 

%{

%% Prompt coincidences 
coincidences = load('Coinc_2_MBq.dat');
Sinogram_Theta1 = coincidences(:,1);
Sinogram_S1 = coincidences(:,2);

% 2D histogram with 321 bins for Theta and 641 bins for S (1 bin = 1mm)
h_coinc1 = hist3([Sinogram_Theta1, Sinogram_S1], 'Nbins', [321 641]);
central_bin = (length(h_coinc1) - 1)/2;

% Apply Gaussian filter to take into account the effect of limited spatial resolution
for i = 1:321
    h_coinc1(i, :) = imgaussfilt(h_coinc1(i,:), 0.652);
end

% NEMA ANALYSIS WITH NO RANDOMS ESTIMATE 
% Step 1: Remove more than 12 cm from center
hc_coinc1 = h_coinc1; 
hc_coinc1(:, 1:(central_bin - 120)) = 0; 
hc_coinc1(:, (central_bin + 120): end) = 0;

% Steps 2 and 3: Find the maximum pixel and shift rows (Alignment)
nbins = length(hc_coinc1);
central_bin1 = round(nbins/2)-1;
for i = 1:321
    maxbin = max(hc_coinc1(i, :));
    [x,y] = find(hc_coinc1(i, :) == maxbin);
    shift = round(central_bin1 - y);
    row1 = hc_coinc1(i, :);
    row1 = circshift(row1, [0 shift]);
    hc_coinc1(i, :) = row1;
end

% Step 4: Sum projection
S_coinc1 = sum(hc_coinc1).';

% Total number of coincidences 
C_tot = round(sum(S_coinc1)); 

%% Compare total coincidences rate (prompts) and delayed coincidences
figure(3)
edges = linspace(-320, 320, 641); % create 641 bins
plot(edges, S_coinc1, 'r', 'LineWidth', 1.5); % Total coincidences
xlim([-320 320]);
xlabel('S (mm)');
ylabel('Number of coincidences');
grid on;
%title('Total coincidences and delayed coincidences');

hold on;

plot(edges, S_coinc, 'k', 'LineWidth', 1.5); % delayed coincidences
hold off;
set(gca,'FontSize', 12);
legend('total coincidences','delayed coincidences');
legend boxoff;
print('plots/prompts_and_delayed', '-dpng', '-r400');


%}
