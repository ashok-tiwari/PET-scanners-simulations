% Coounts rate and NECR calculations according to NEMA protocol NU 2-2018

% Discovery MI scanner (4-ring) simulation using the 2 m long scatter phantom for
% Count rates estimations

clc; clear; close all; workspace
tic

% Load and plot the sinogram data generated from .root file
coincidences = load('Coinc_300_MBq.dat');
Sinogram_Theta = coincidences(:,1);
Sinogram_S = coincidences(:,2);

hot = jet;  % change all colormap

% 2D histogram with 321 bins for Theta and 641 bins for S (1 bin = 1mm)
h_coinc = hist3([Sinogram_Theta, Sinogram_S], 'Nbins', [321 641]);
central_bin = (length(h_coinc) - 1)/2;

figure(1)
imshow(h_coinc, [], 'XData', [-320 320], 'YData', [ ]);
colormap(flipud(hot)); colorbar;
axis on; 
xlabel('S (mm)'); ylabel('Theta');
set(gca,'FontSize', 12);
%title('Sinogram of Coincidences');
set(gcf,'position', [0,0,600,400]);
print('plots/plot1', '-dpng', '-r600');

% Apply Gaussian filter to take into account the effect of limited spatial resolution
% 'imgaussfilt' is matlab inbuilt function for 2-D Gausssian filetring of images
for i = 1:321
    h_coinc(i, :) = imgaussfilt(h_coinc(i,:), 0.652);
end

% Note on value: 0.652
% Spatial resolution depends on the radial offset and the measurement direction and 
% values in the data sheet range between 4 mm and 4.8 mm for a 1cm offset,
% so, sigma (sd) = 1/voxel size(FWHM (4.8mm)/(SQRT(8 ln 2))) = 0.652

% NEMA ANALYSIS WITH RANDOMS FROM DELAYED COINCIDENCES 
% Step 1: Remove data located on more than 12 cm from center
hc_coinc = h_coinc; 
hc_coinc(:, 1:(central_bin - 120)) = 0; 
hc_coinc(:, (central_bin + 120): end) = 0;

% Visualize the sinogram after applying the Gaussian filter and pixels farther than 12
% cm to zero
figure(2)
imshow(hc_coinc(), [], 'XData', [-320 320], 'YData', []);
colormap(flipud(hot)); colorbar;
axis on;
xlabel('S (mm)'); ylabel('Theta');
set(gca,'FontSize', 12);
%caption = sprintf('Sinogram after applying Gaussian filter and pixels farther than 12 cm to zero');
%title(caption);
%%title({'Sinogram after applying Gaussian filter'; 'and pixels farther than 12 cm to zero'});
set(gcf,'position', [0,0,600,400]);
print('plots/plot2', '-dpng', '-r600');

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

figure(3)
imshow(hc_coinc(), [], 'XData', [-320 320], 'YData', []);
colormap(flipud(hot)); colorbar;
axis on;
xlabel('S (mm)'); ylabel('Theta');
set(gca,'FontSize', 12);
%title('Sinogram after alignment a/c to max. values for each projection angle');
set(gcf,'position', [0,0,600,400]);
print('plots/plot3', '-dpng', '-r600');

% Step 4: Sum projection
S_coinc = sum(hc_coinc).';
length_S_coinc = length(S_coinc);

% Plot coincidences rate vs S
figure(4)
edges = linspace(-320, 320, 641); % create 641 bins
plot(edges, S_coinc, 'k', 'LineWidth', 1.5);
xlim([-320 320]);
grid on;
xlabel('S (mm)'); ylabel('Number of coincidences');
set(gca,'FontSize', 12);
%title('Coincidences vs S (mm)');
set(gcf,'position', [0,0,600,400]);
print('plots/plot4', '-dpng', '-r600');

% Total number of coincidences 
C_tot = round(sum(S_coinc));  

% Step 5: 40 mm strip
Central = S_coinc((central_bin - 20):(central_bin + 20));

% Central 40 mm strip after sum projection
figure(5)
edges2 = linspace(-20, 20, 41); % create 41 bins
plot(edges2, Central, 'k', 'LineWidth', 1.5);
xlim([-320 320]);
grid on;
xlabel('S (mm)'); ylabel('Number of coincidences');
set(gca,'FontSize', 12);
%title('Central 40 mm strip after sum projection');
set(gcf,'position', [0,0,600,400]);
print('plots/plot5', '-dpng', '-r600');


% Step 6: Average of the 2 pixel values located at two ends of 40 mm strip
Background_counts = round(((Central(1) + Central(41))/2)*41);
C = round(sum(Central));
C_rs = round(Background_counts + (C_tot - C));
C_trues = C_tot - C_rs;

% Use delayed window for randoms, and then finally scatter counts by
% subtracting the randoms from C_rs.

toc