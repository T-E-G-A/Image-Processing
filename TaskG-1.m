clear all;
close all;
clc;

% Initialize webcam
camera = webcam;

% Structuring elements for image processing
morph_element = strel('disk', 10); % Morphological structuring element
edge_element = strel('disk', 3); % Element for dilating edges

% Marker styles for geometric points
center_marker = 'bo'; % Blue circle
median_marker = 'm*'; % Magenta star

figure;

% Real-time processing loop
while true
    % Capture an image from the webcam
    live_image = snapshot(camera);

    % Convert image to double precision
    image_scaled = im2double(live_image);

    % Threshold values for object detection
    Red_min = 0.0; Red_max = 0.5;
    Green_min = 0.0; Green_max = 0.5;
    Blue_min = 0.5; Blue_max = 1.0;

    % Create a binary mask based on thresholds
    binary_mask = (image_scaled(:,:,1) >= Red_min & image_scaled(:,:,1) <= Red_max) & ...
                  (image_scaled(:,:,2) >= Green_min & image_scaled(:,:,2) <= Green_max) & ...
                  (image_scaled(:,:,3) >= Blue_min & image_scaled(:,:,3) <= Blue_max);

    % Clean the binary image using morphological operations
    processed_mask = imclose(binary_mask, morph_element); % Close small gaps
    processed_mask = imopen(processed_mask, morph_element); % Remove noise
    processed_mask = imfill(processed_mask, 'holes'); % Fill internal holes

    % Detect edges and dilate them for visibility
    edge_map = edge(processed_mask, 'sobel'); % Find edges
    expanded_edges = imdilate(edge_map, edge_element); % Expand edge regions

    % Overlay boundary on the original image
    outlined_image = live_image; % Copy the original image
    outlined_image = im2uint8(outlined_image); % Convert to uint8
    for channel_idx = 1:3
        color_channel = outlined_image(:,:,channel_idx);
        color_channel(expanded_edges) = 255 * (channel_idx == 1); % Highlight edges in red
        outlined_image(:,:,channel_idx) = color_channel;
    end

    % Compute centroid using region properties
    region_properties = regionprops(processed_mask, 'Centroid'); % Find centroid
    if ~isempty(region_properties)
        centroid_point = region_properties.Centroid;
    else
        centroid_point = [NaN, NaN];
    end

    % Compute medoid using distance transform
    distance_map = bwdist(~processed_mask); % Distance transformation
    [~, max_index] = max(distance_map(:));
    [medoid_row, medoid_col] = ind2sub(size(processed_mask), max_index);
    medoid_point = [medoid_col, medoid_row];

    % Overlay centroid and medoid markers
    if ~any(isnan(centroid_point))
        outlined_image = insertShape(outlined_image, 'Circle', [centroid_point, 5], 'Color', 'blue', 'LineWidth', 5); % Centroid
    end
    outlined_image = insertShape(outlined_image, 'Circle', [medoid_point, 5], 'Color', 'magenta', 'LineWidth', 5); % Medoid

    % Display images in a 2x2 grid
    subplot(2, 2, 1);
    imshow(live_image);
    title('Live Image');

    subplot(2, 2, 2);
    imshow(binary_mask);
    title('Binary Mask');

    subplot(2, 2, 3);
    imshow(processed_mask);
    title('Processed Mask');

    subplot(2, 2, 4);
    imshow(outlined_image);
    title('Highlighted Image (Edges, Centroid, Medoid)');

    % Pause for visualization
    pause(0.1);
end

% Release the webcam when finished
clear camera;



