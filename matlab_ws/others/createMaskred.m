function [BWr,maskedRGBImager,arear] = createMaskred(RGB)

    % Convert RGB image to HSV image
    Ir = rgb2hsv(RGB);

    % Define thresholds for channel 1 based on histogram settings
    channel1Minr = 0.918;
    channel1Maxr = 0.082;

    % Define thresholds for channel 2 based on histogram settings
    channel2Minr = 0.200;
    channel2Maxr = 1.000;

    % Define thresholds for channel 3 based on histogram settings
    channel3Minr = 0.000;
    channel3Maxr = 1.000;

    % Create mask based on chosen histogram thresholds
    sliderBWr = (Ir(:,:,1) >= channel1Minr ) & (Ir(:,:,1) <= channel1Maxr) & ...
               (Ir(:,:,2) >= channel2Minr ) & (Ir(:,:,2) <= channel2Maxr) & ...
               (Ir(:,:,3) >= channel3Minr ) & (Ir(:,:,3) <= channel3Maxr);

    BWr = sliderBWr;

    % get area of mask
    arear = bwarea(BWr);

    % Initialize output masked image based on input image.
    maskedRGBImager = RGB;

    % Set background pixels where BW is false to zero.
    maskedRGBImager(repmat(~BWr,[1 1 3])) = 0;

end