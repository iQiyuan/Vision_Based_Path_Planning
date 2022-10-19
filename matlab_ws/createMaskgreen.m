function [BWg,maskedRGBImageg,areag] = createMaskgreen(RGB)

    % Convert RGB image to HSV image
    Ig = rgb2hsv(RGB);

    % Define thresholds for channel 1 based on histogram settings
    channel1Ming = 0.249;
    channel1Maxg = 0.415;

    % Define thresholds for channel 2 based on histogram settings
    channel2Ming = 0.200;
    channel2Maxg = 1.000;

    % Define thresholds for channel 3 based on histogram settings
    channel3Ming = 0.000;
    channel3Maxg = 1.000;

    % Create mask based on chosen histogram thresholds
    sliderBWg = (Ig(:,:,1) >= channel1Ming ) & (Ig(:,:,1) <= channel1Maxg) & ...
                (Ig(:,:,2) >= channel2Ming ) & (Ig(:,:,2) <= channel2Maxg) & ...
                (Ig(:,:,3) >= channel3Ming ) & (Ig(:,:,3) <= channel3Maxg);

    BWg = sliderBWg;

    % get area of mask
    areag = bwarea(BWg);

    % Initialize output masked image based on input image.
    maskedRGBImageg = RGB;

    % Set background pixels where BW is false to zero.
    maskedRGBImageg(repmat(~BWg,[1 1 3])) = 0;

end