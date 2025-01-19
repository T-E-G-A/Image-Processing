clear all;
close all;
clc;

% Initialize webcam
camera_device = webcam;

% Structuring elements for image processing
close_element = strel('disk', 10); % Larger structuring element for closing gaps
expand_element = strel('disk', 3); % Smaller structuring element for edge dilation

% Marker styles for points
center_point_marker = 'bo'; % Blue circle
middle_point_marker = 'm*'; % Magenta star

% Variables to track gestures
previous_center = []; % Previous centroid for motion tracking
gesture_movement_threshold = 20; % Minimum movement for gesture detection
gesture_label = ''; % Text to display the detected gesture

figure;

% Real-time image processing loop
while true
    % Capture a frame from the webcam
    captured_frame = snapshot(camera_device);
    scaled_frame = im2double(captured_frame); % Convert to double precision

    % Threshold values for object detection
    red_lower = 0.0; red_upper = 0.5;
    green_lower = 0.0; green_upper = 0.5;
    blue_lower = 0.5; blue_upper = 1.0;

    % Generate a binary mask based on thresholds
    binary_mask = (scaled_frame(:,:,1) >= red_lower & scaled_frame(:,:,1) <= red_upper) & ...
                   (scaled_frame(:,:,2) >= green_lower & scaled_frame(:,:,2) <= green_upper) & ...
                   (scaled_frame(:,:,3) >= blue_lower & scaled_frame(:,:,3) <= blue_upper);

    % Clean the binary mask using morphological operations
    refined_mask = imclose(binary_mask, close_element); % Close gaps
    refined_mask = imopen(refined_mask, close_element); % Remove small artifacts
    refined_mask = imfill(refined_mask, 'holes'); % Fill internal holes

    % Detect edges and thicken them
    detected_edges = edge(refined_mask, 'sobel'); % Edge detection
    dilated_edges = imdilate(detected_edges, expand_element); % Expand edges

    % Overlay boundaries on the captured frame
    overlay_image = captured_frame; % Copy the captured frame
    overlay_image = im2uint8(overlay_image); % Convert to uint8
    for channel_index = 1:3
        color_layer = overlay_image(:,:,channel_index);
        color_layer(dilated_edges) = 255 * (channel_index == 1); % Highlight edges in red
        overlay_image(:,:,channel_index) = color_layer;
    end

    % Compute the centroid using region properties
    regions = regionprops(refined_mask, 'Centroid'); % Find centroid
    if ~isempty(regions)
        center_point = regions.Centroid;
    else
        center_point = [NaN, NaN]; % Handle case with no detected center
    end

    % Compute the medoid using distance transformation
    distance_field = bwdist(~refined_mask); % Distance transformation
    [~, max_distance_idx] = max(distance_field(:));
    [medoid_row, medoid_col] = ind2sub(size(refined_mask), max_distance_idx);
    middle_point = [medoid_col, medoid_row];

    % Annotate the centroid and medoid on the overlay image
    if ~any(isnan(center_point))
        overlay_image = insertShape(overlay_image, 'Circle', [center_point, 5], 'Color', 'blue', 'LineWidth', 5); % Mark centroid
    end
    overlay_image = insertShape(overlay_image, 'Circle', [middle_point, 5], 'Color', 'magenta', 'LineWidth', 5); % Mark medoid

    % --- Gesture Detection Logic ---
    if ~isempty(previous_center) && ~any(isnan(center_point))
        % Compute motion vector
        x_shift = center_point(1) - previous_center(1); % Change in x
        y_shift = center_point(2) - previous_center(2); % Change in y

        % Detect significant motion
        if abs(x_shift) > abs(y_shift) && abs(x_shift) > gesture_movement_threshold
            if x_shift > 0
                gesture_label = 'Right Swipe';
            else
                gesture_label = 'Left Swipe';
            end
        elseif abs(y_shift) > abs(x_shift) && abs(y_shift) > gesture_movement_threshold
            if y_shift > 0
                gesture_label = 'Down Swipe';
            else
                gesture_label = 'Up Swipe';
            end
        end
    end

    % Update the previous centroid
    previous_center = center_point;

    % Annotate the gesture label on the overlay image
    overlay_image = insertText(overlay_image, [10, 10], gesture_label, 'FontSize', 20, 'BoxColor', 'yellow', 'TextColor', 'black');

    % --- Display the images in a 2x2 layout ---
    subplot(2, 2, 1);
    imshow(captured_frame);
    title('Captured Frame');

    subplot(2, 2, 2);
    imshow(binary_mask);
    title('Binary Mask');

    subplot(2, 2, 3);
    imshow(refined_mask);
    title('Refined Mask');

    subplot(2, 2, 4);
    imshow(overlay_image);
    title('Overlay Image (Edges, Centroid, Medoid, Gesture)');

    % Pause for frame rate control
    pause(0.1); % Adjust based on your webcam frame rate
end

% Release the webcam after processing
clear camera_device;
