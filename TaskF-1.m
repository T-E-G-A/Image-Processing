% Clear workspace, close all figures, and clear command window
clear all;
close all;
clc;

% Step 1: Load the cleaned binary mask from Task D
final_cleaned_binary_mask = imread('cleaned_filled_binary_image.png'); % Load cleaned binary mask

% Step 2: Convert the cleaned binary mask to logical
binary_mask_logical = imbinarize(final_cleaned_binary_mask); % Convert binary mask to logical

% Step 3: Calculate the centroid
stats = regionprops(binary_mask_logical, 'Centroid'); % Get region properties
centroid = stats.Centroid; % Get the centroid coordinates [x, y]

% Step 4: Calculate the medoid
[y_indices, x_indices] = find(binary_mask_logical); % Get the indices of the mask
medoid_x = median(x_indices); % Calculate median for x-coordinates
medoid_y = median(y_indices); % Calculate median for y-coordinates
medoid = [medoid_x, medoid_y]; % Create medoid coordinate [x, y]

% Step 5: Convert binary mask to RGB for visualization
cleaned_binary_with_markers = cat(3, binary_mask_logical * 255, binary_mask_logical * 255, binary_mask_logical * 255); % Convert binary to RGB

% Step 6: Add centroid marker (green circle) with enhanced visibility
marker_size = 15; % Increased marker size
line_thickness = 5; % Thicker lines for visibility
cleaned_binary_with_markers = insertShape(cleaned_binary_with_markers, 'Circle', ...
    [centroid(1), centroid(2), marker_size], 'Color', 'green', 'LineWidth', line_thickness);

% Step 7: Add medoid marker (red cross) with enhanced visibility
line_length = 15; % Increased length of the cross
cleaned_binary_with_markers = insertShape(cleaned_binary_with_markers, 'Line', ...
    [medoid(1) - line_length, medoid(2), medoid(1) + line_length, medoid(2)], 'Color', 'red', 'LineWidth', line_thickness);
cleaned_binary_with_markers = insertShape(cleaned_binary_with_markers, 'Line', ...
    [medoid(1), medoid(2) - line_length, medoid(1), medoid(2) + line_length], 'Color', 'red', 'LineWidth', line_thickness);

% Step 8: Display the cleaned binary image with markers
figure;
imshow(cleaned_binary_with_markers);
title('Cleaned Binary Image with Centroid (Green) and Medoid (Red) Markers');

% Step 9: Save the cleaned binary image with markers
imwrite(cleaned_binary_with_markers, 'cleaned_binary_with_centroid_medoid_markers.png'); % Save the image

% Step 10: Load the original RGB image
image_rgb = imread('IP_Test.jpg'); % Replace 'original_image.png' with the correct file name

% Step 11: Annotate the centroid and medoid on the original RGB image
% Add centroid marker (green circle)
image_with_annotation = insertShape(image_rgb, 'Circle', ...
    [centroid(1), centroid(2), marker_size], 'Color', 'green', 'LineWidth', line_thickness);

% Add medoid marker (red cross)
image_with_annotation = insertShape(image_with_annotation, 'Line', ...
    [medoid(1) - line_length, medoid(2), medoid(1) + line_length, medoid(2)], 'Color', 'red', 'LineWidth', line_thickness);
image_with_annotation = insertShape(image_with_annotation, 'Line', ...
    [medoid(1), medoid(2) - line_length, medoid(1), medoid(2) + line_length], 'Color', 'red', 'LineWidth', line_thickness);

% Step 12: Display the annotated original RGB image
figure;
imshow(image_with_annotation);
title('Original RGB Image with Centroid (Green) and Medoid (Red) Markers');

% Step 13: Save the annotated original RGB image
imwrite(image_with_annotation, 'rgb_image_with_centroid_medoid_markers.png'); % Save the image

% Step 14: Output the centroid and medoid coordinates
disp(['Centroid: (', num2str(centroid(1)), ', ', num2str(centroid(2)), ')']);
disp(['Medoid: (', num2str(medoid(1)), ', ', num2str(medoid(2)), ')']);




