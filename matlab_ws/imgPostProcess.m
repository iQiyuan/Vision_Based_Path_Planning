% this function filter noise, fill in holes, take biggest color as target
function [Newmask,maskedRgbImage,total] = imgPostProcess(Oldmask,orginalImg)

    [labeledImage, ~] = bwlabel(Oldmask);
    blobMeasurements = regionprops(labeledImage, 'area', 'Centroid');
    allAreas = [blobMeasurements.Area];
    [~, sortIndexes] = sort(allAreas, 'descend');

    biggestBlob = ismember(labeledImage, sortIndexes(1:1));
    binaryImage = biggestBlob > 0;

    %fill in all hole in mask
    Newmask = imfill(binaryImage,"holes");

    %get area of mask
    total = bwarea(Newmask);

    %Reapply mask to picture
    maskedRgbImage = bsxfun(@times, orginalImg, cast(Newmask, 'like', orginalImg));

end