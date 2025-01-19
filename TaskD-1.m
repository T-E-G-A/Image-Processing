% Clear workspace, close all figures, and clear command window
clear all;
close all;
clc;

% Step 1: Load the image
imagePath = 'C:\Users\edwar\MATLAB\IP_Sessment\IP_Test.jpg';
foamFingerImage = imread(imagePath); % Read the image

% Step 2: Convert to double precision for processing
foamFingerImageDouble = im2double(foamFingerImage); % Convert image to double precision

% Step 3: Define RGB thresholds for blue foam finger
lowerThreshold = [0, 0, 0.39]; % Lower threshold for blue
upperThreshold = [0.39, 0.39, 1]; % Upper threshold for blue

% Step 4: Create a binary mask based on the RGB thresholds
binaryMask = (foamFingerImageDouble(:,:,1) >= lowerThreshold(1) & ...
             foamFingerImageDouble(:,:,1) <= upperThreshold(1)) & ...
            (foamFingerImageDouble(:,:,2) >= lowerThreshold(2) & ...
             foamFingerImageDouble(:,:,2) <= upperThreshold(2)) & ...
            (foamFingerImageDouble(:,:,3) >= lowerThreshold(3) & ...
             foamFingerImageDouble(:,:,3) <= upperThreshold(3));

% Step 5: Remove small noise using morphological operations
cleanBinaryMask = bwareaopen(binaryMask, 500); % Remove objects smaller than 500 pixels

% Step 6: Fill black dots (holes) inside the foam finger
filledBinaryMask = imfill(cleanBinaryMask, 'holes'); % Fill any holes in the binary mask

% Step 7: Convert the filled binary mask to uint8 format for display
binaryMaskUint8 = uint8(filledBinaryMask) * 255; % Convert logical mask to uint8 for display

% Step 8: Display the original and filled binary images
figure;
subplot(1, 2, 1);
imshow(foamFingerImage); % Display original image
title('Original Image');
subplot(1, 2, 2);
imshow(binaryMaskUint8); % Display filled binary mask image
title('Cleaned and Filled Binary Image of Foam Finger');

% Step 9: Save the cleaned and filled binary image
imwrite(binaryMaskUint8, 'cleaned_filled_binary_image.png'); % Save cleaned binary mask image

% Step 10: Convert cleaned and filled binary mask to logical
binaryMaskLogical = imbinarize(binaryMaskUint8); % Ensure binary mask is logical

% Step 11: Convert binary mask to 3-channel image for RGB multiplication
binaryMask3ch = cat(3, binaryMaskLogical, binaryMaskLogical, binaryMaskLogical); % Create 3-channel mask

% Step 12: Multiply the original image by the binary mask
resultImage = uint8(double(foamFingerImage) .* double(binaryMask3ch)); % Element-wise multiplication

% Step 13: Display the isolated foam finger (RGB masked by binary image)
figure;
imshow(resultImage); % Display result image
title('RGB Image with Binary Mask Applied (Foam Finger Isolated)');

% Step 14: Save the result image
imwrite(resultImage, 'isolated_foam_finger.png'); % Save isolated foam finger image





