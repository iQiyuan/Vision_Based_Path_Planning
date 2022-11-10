function [BWb,maskedRGBImageb,areab] = createMaskblue(RGB)

    % Convert RGB image to HSV image
    Ib = rgb2hsv(RGB);

    % Define thresholds for channel 1 based on histogram settings
    channel1Minb = 0.534;
    channel1Maxb = 0.750;

    % Define thresholds for channel 2 based on histogram settings
    channel2Minb = 0.200;
    channel2Maxb = 1.000;

    % Define thresholds for channel 3 based on histogram settings
    channel3Minb = 0.000;
    channel3Maxb = 1.000;

    % Create mask based on chosen histogram thresholds
    sliderBWb = (Ib(:,:,1) >= channel1Minb ) & (Ib(:,:,1) <= channel1Maxb) & ...
                (Ib(:,:,2) >= channel2Minb ) & (Ib(:,:,2) <= channel2Maxb) & ...
                (Ib(:,:,3) >= channel3Minb ) & (Ib(:,:,3) <= channel3Maxb);

    BWb = sliderBWb;

    % get area of mask
    areab = bwarea(BWb);

    % Initialize output masked image based on input image.
    maskedRGBImageb = RGB;

    % Set background pixels where BW is false to zero.
    maskedRGBImageb(repmat(~BWb,[1 1 3])) = 0;

end