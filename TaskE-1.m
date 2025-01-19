% Clear workspace, close all figures, and clear command window
clear all;
close all;
clc;

% Step 1: Load the cleaned binary mask
cleanedMask = imread('cleaned_filled_binary_image.png'); 

% Step 2: Convert the binary mask to logical
cleanedMaskLogical = imbinarize(cleanedMask);

% Step 3: Enhance the binary mask using morphological operations
se = strel('disk', 2); % Structuring element
enhancedMask = imdilate(cleanedMaskLogical, se); % Dilate
enhancedMask = imerode(enhancedMask, se); % Erode

% Step 4: Smooth the binary mask using Gaussian filter
smoothedMask = imgaussfilt(double(enhancedMask), 1);

% Step 5: Detect edges using Canny edge detection
edges = edge(smoothedMask, 'Canny', [0.1 0.3]);

% Step 6: Ensure the outline is connected by dilating the edges
connectedEdges = imdilate(edges, strel('disk', 7)); % Further dilation to connect gaps

% Step 7: Create a new binary image with black background and white traces
tracedImage = zeros(size(connectedEdges)); 
tracedImage(connectedEdges) = 255;

% Step 8: Save the traced image
imwrite(uint8(tracedImage), 'traced_binary_mask.png');

% Step 9: Load the original RGB image
originalImage = imread('C:\Users\edwar\MATLAB\IP_Sessment\IP_Test.jpg');

% Step 10: Get the foam finger boundary
foamFingerBoundary = bwperim(cleanedMaskLogical);

% Step 11: Create a copy of the original image for annotation
annotatedImage = originalImage;

% Step 12: Define the color for the boundary
boundaryColor = [255, 0, 0]; % Red

% Step 13: Annotate the boundary on the original image
for c = 1:3 
    channel = annotatedImage(:,:,c);
    channel(foamFingerBoundary) = boundaryColor(c);
    annotatedImage(:,:,c) = channel;
end

% Step 14: Thicken the boundary for better visibility
thickBoundary = imdilate(foamFingerBoundary, strel('disk', 7)); % Larger dilation for a continuous boundary
for c = 1:3 
    channel = annotatedImage(:,:,c);
    channel(thickBoundary) = boundaryColor(c);
    annotatedImage(:,:,c) = channel;
end

% Step 15: Display the traced binary image
figure;
subplot(1, 2, 1);
imshow(uint8(tracedImage));
title('Traced Binary Mask with Thick Edges');

% Step 16: Display the annotated image
subplot(1, 2, 2);
imshow(annotatedImage);
title('Annotated Image with Thick Foam Finger Boundary');

% Step 17: Save the annotated image
imwrite(annotatedImage, 'annotated_image.png');



