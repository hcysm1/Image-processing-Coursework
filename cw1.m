
%==========MONITORING WORMS==========%

clc;
imageFolder = dir('*.png'); %struct variable to store all the images with png format.
total_images = length(imageFolder);% calculates total number of images.
all_Area = cell(1,total_images); % cell array to store area of the worm body from all the images
all_Perim = cell(1,total_images);% cell array to store perimeter of the worm

%==========IMAGE ENHANCEMENT==========%

for total = 1 : total_images %loop to process all the images
    
    %==========STEP-1 READ ORGINAL IMAGE==========%
    
    Original_image = imread (imageFolder(total).name); %reading the images
    figure;
    subplot(2,2,1);%plotting images on 2x2 grid
    imshow(Original_image);%display original image.
    fontSize = 11;
    title('Step-1 Original Colour Image', 'FontSize', fontSize, 'Interpreter', 'None');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);  % Enlarge figure to full screen.
    
    %==========STEP-2 CONVERT COLOUR IMAGE TO GRAYSCALE==========%
    
    Grayscale_image = rgb2gray(Original_image); %converting colour images to grayscale.
    subplot(2,2,2);%plotting images on 2x2 grid
    imshow(Grayscale_image); %display grayscale image
    title('Step-2 RGB to Grayscale Image', 'FontSize', fontSize, 'Interpreter', 'None');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);  % Enlarge figure to full screen.
    
    %==========STEP-3 ADJUST CONTRAST OF GRAYSCALE IMAGE==========%
    
    I_contrast = imadjust(Grayscale_image,[0.25 0.67]); %adjusting contrast of grayscale images to make the worm more visible.
    subplot(2,2,3);%plotting images on 2x2 grid
    imshow(I_contrast); %display the result after contrast adjustment
    title('Step-3 Contrast Adjustment', 'FontSize', fontSize, 'Interpreter', 'None');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);  % Enlarge figure to full screen.
    
    %==========STEP-4 SHARPEN THE EDGES==========%
    
    filter = fspecial ('gaussian' ,10 ,7); %using gaussian filter to blur the image
    blur = imfilter (I_contrast, filter); %making the image blur after contrast adjustment
    I_unsharp = I_contrast - blur; %unsharp the image by first subtracting the blurred image from processed (adjusted contrast)image
    I_sharp = I_contrast + I_unsharp; %then add that unsharp image to the processed (adjusted contrast) image to make it sharp
    subplot(2,2,4);%plotting images on 2x2 grid
    imshow(I_sharp); %display the sharpened image
    title('Step-4 Sharpening the edges after contrast adjustment', 'FontSize', fontSize, 'Interpreter', 'None');
    sgtitle('1- IMAGE ENHANCEMENT');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]); % Enlarge figure to full screen.
    
    %==========GENERATING BINARY MASK==========%
    
    %==========STEP-5 GENERATE BINARY GRADIENT MASK==========%
    
    [~,threshold] = edge(I_sharp,'sobel');%Use edge and the Sobel operator to calculate the threshold value.
    fudgeFactor = 1.0;% Tune the threshold value
    b_g_mask = edge(I_sharp,'sobel',threshold * fudgeFactor); %use edge again to obtain a binary mask that contains the segmented worm.
    figure;
    subplot(2,2,1);%plotting images on 2x2 grid
    imshow(b_g_mask);% display the binary gradient mask
    title('Step-5 Binary Gradient mask', 'FontSize', fontSize, 'Interpreter', 'None');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]); % Enlarge figure to full screen.
    
    %==========STEP-6 DILATE THE IMAGE==========%
    
    se90 = strel('line',26,20);%Create two perpindicular linear structuring elements by using strel function.
    se0 = strel('line',26,85);
    I_dil = imdilate(b_g_mask,[se90 se0]);%dilate the image
    subplot(2,2,2);%plotting images on 2x2 grid
    imshow(I_dil);% display the dilated gradient mask
    title('Step-6 Dilated Gradient mask', 'FontSize', fontSize, 'Interpreter', 'None');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]); % Enlarge figure to full screen.
    
    %==========STEP-7 FILL INTERIOR GAPS==========%
    
    I_fill = imfill(I_dil,'holes');% fill the interior gaps in the image
    subplot(2,2,3);%plotting images on 2x2 grid
    imshow(I_dil);
    title('Step-7 Binary image with filled holes', 'FontSize', fontSize, 'Interpreter', 'None');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);  % Enlarge figure to full screen.
    
    %==========STEP-8 SMOOTH THE OBJECT AND GENERATE FINAL BINARY MASK==========%
    
    se90 = strel('square',14);
    se0 = strel('disk',14);
    Binary_mask = imerode(I_fill,[se90 se0]);
    Binary_mask = bwareaopen(Binary_mask,900); % remove extra noise
    Area = regionprops(Binary_mask,'Area'); % Calculate area of the segmented worm body
    all_Area{total} = Area.Area; % store the result in a cell array
    Perim = regionprops(Binary_mask,'all'); % calculate the perimeter
    all_Perim{total} = Perim.Perimeter; % store the result in a cell array
    subplot(2,2,4); %plotting images on 2x2 grid
    imshow(Binary_mask); % display the final binary mask
    title(sprintf('Step-8 Area of the worm body after noise removal = %d ', Area.Area)); %displaying area of the worm
    sgtitle('2- BINARY MASK OF THE WORM');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]); % Enlarge figure to full screen.
    
    %==========STEP-9 EXTRACT THE EDGE OF THE WORM==========%
    
    
    se90 = strel('square',4);
    se0 = strel('diamond',4);
    Dilated_binary_mask = imdilate(Binary_mask,[se90 se0]);% dilate the binary mask again to get the edge of worm
    Boundary = imsubtract(Dilated_binary_mask,Binary_mask);%subtract the binary mask from dilated binary mask
    figure;
    subplot(1,2,1);%plotting images on 1x2 grid
    imshow(Boundary);% display the boundary
    title(sprintf('Step-9 Perimeter of the worm body = %d Approx ', Perim.Perimeter));% display perimeter of worm
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);% Enlarge figure to full screen.
    
    %==========STEP-10 BOUNDARY OVERLAY==========%
    
    subplot(1,2,2);%plotting images on 1x2 grid
    imshow(labeloverlay(Original_image,Boundary))%display the boundary over the original image
    title('Step-10 Boundary overlay', 'FontSize', fontSize, 'Interpreter', 'None');
    sgtitle('3- EDGE EXTRACTION');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);% Enlarge figure to full screen.
    
    
    %========STEP-11 MASK OVERLAY========%
    
    figure;
    subplot(1,2,1);%plotting images on 1x2 grid
    imshow(labeloverlay(Original_image,Binary_mask))% display the binary mask over original image
    title('Step-11 Mask over original image', 'FontSize', fontSize, 'Interpreter', 'None');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);% Enlarge figure to full screen.
    
    %========STEP-12 MASKED COLOUR IMAGE========%
    
    mask = Binary_mask; %put binary_mask in mask
    Binary_mask = Original_image;%put original image in binary mask
    % extract the worm(original pixels) based onthe produced mask
    maskedColorImage = bsxfun(@times, Original_image, cast(mask, 'like', Original_image));
    subplot(1,2,2);%plotting images on 1x2 grid
    imshow(maskedColorImage);% display masked colour image
    title('Step-12 Masked colour image', 'FontSize', fontSize, 'Interpreter', 'None');
    sgtitle('4- WORM BODY');
    set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);% Enlarge figure to full screen.
    
end
     


