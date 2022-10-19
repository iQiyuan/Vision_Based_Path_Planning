% clear workspace
clear;

% connect to webcam
cam = webcam;

% set the loop limit
while (true)

    % froze an image
    image = snapshot(cam);

    % extract the color to be recognized

    % green, blue, red
    [BWg,~,maxg] = createMaskgreen(image);
    [BWb,~,maxb] = createMaskblue(image);
    [BWr,~,maxr] = createMaskred(image);

    % show a preview of above extraction process
    subplot(2,3,1); imshow(BWg);title("green filter");
    subplot(2,3,2); imshow(BWb);title("blue filter");
    subplot(2,3,3); imshow(BWr);title("red filter");

    % set a threshold for clean extracted color
    area_thr = 1000;

    % remove noise by largest area selection
    if (maxg > area_thr)
        [binaryImageg,maskedRgbImageg,maxg] = imgPostProcess(BWg,image);
        if (maxg > area_thr)
            % find centroid of recognized part
            [labeledImage, ~] = bwlabel(binaryImageg, 8);
            propsg = regionprops(labeledImage, binaryImageg, 'all');
            blobCentroidg = propsg.Centroid;
        end
    end

    if (maxb > area_thr)
        [binaryImageb,maskedRgbImageb,maxb] = imgPostProcess(BWb,image);
        if (maxb > area_thr)
            % find centroid of recognized part
            [labeledImage, ~] = bwlabel(binaryImageb, 8);
            propsb = regionprops(labeledImage, binaryImageb, 'all');
            blobCentroidb = propsb.Centroid;
        end
    end

    if (maxr > area_thr)
        [binaryImager,maskedRgbImager,maxr] = imgPostProcess(BWr,image);
        if (maxr > area_thr)
            % find centroid of recognized part
            [labeledImage, ~] = bwlabel(binaryImager, 8);
            propsr = regionprops(labeledImage, binaryImager, 'all');
            blobCentroidr = propsr.Centroid;
        end
    end
    
    % show result of blue recognition
    subplot(2,3,4); imshow(image);title("original image");
    subplot(2,3,5); imshow(binaryImageb);title("blue refined extraction");
    subplot(2,3,6); imshow(maskedRgbImageb);title("final blue");

    % labe the center of color extracted

    imshow(image);
    axis on;
    hold on;

    if (maxg > area_thr)
        plot(blobCentroidg(1), blobCentroidg(2), "rx", ...
             "MarkerSize", 15, "LineWidth", 2);
    end

    if (maxb > area_thr)
        plot(blobCentroidb(1), blobCentroidb(2), "rx", ...
             "MarkerSize", 15, "LineWidth", 2);
    end

    if (maxr > area_thr)
        plot(blobCentroidr(1), blobCentroidr(2), "rx", ...
             "MarkerSize", 15, "LineWidth", 2);
    end
    
    % take 1 image ever 1 second
    pause(0.1)

end
