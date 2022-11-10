% setup workspace
clear;
cam = webcam;
image = imresize(snapshot(cam), [512, 512]);
imshow(image); sp=getrect;

% generate corped image as new template
sp(1) = max(floor(sp(1)), 1);
sp(2) = max(floor(sp(2)), 1);
sp(3) = min(ceil(sp(1) + sp(3)));
sp(4) = min(ceil(sp(2) + sp(4)));
index=image(sp(2):sp(4), sp(1): sp(3),:);
image(index)
% Write image to graphics file.
imwrite(index, "./template/corped.tif")