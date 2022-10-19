% clear workspace
clear;

% set camera variable
cam = webcam;

% get calibration image from webcam
image_cal = snapshot(cam);

% get basic image info for later use
% for my webcam rows = 720, columns = 1280, color = 3
[rows, columns, ~] = size(image_cal);

% user select 4 pixel points on image_cal
imshow(image_cal);
[u, v] = getpts;

% user input 4 corresponding coordinate
x = [1, 2, 3, 4];
y = [0, 0, 0, 0];

for c = 1:4
    disp("this is data set: ");
    disp(c);

    promtx = "real world x 1~4 coordinate: ";
    x(1,c) = input(promtx);
    promty = "real world y 1~4 coordinate: ";
    y(1,c) = input(promty);
end

% define transformation parameter equation system
sympref('FloatingPointOutput',true);
syms a b c d e f g h;
eqns = [x(1, 1) == (u(1, 1)*a + v(1, 1)*b + c)/(u(1, 1)*g + v(1, 1)*h + 1),...
        y(1, 1) == (u(1, 1)*d + v(1, 1)*e + f)/(u(1, 1)*g + v(1, 1)*h + 1),...
        x(1, 2) == (u(2, 1)*a + v(2, 1)*b + c)/(u(2, 1)*g + v(2, 1)*h + 1),...
        y(1, 2) == (u(2, 1)*d + v(2, 1)*e + f)/(u(2, 1)*g + v(2, 1)*h + 1),...
        x(1, 3) == (u(3, 1)*a + v(3, 1)*b + c)/(u(3, 1)*g + v(3, 1)*h + 1),...
        y(1, 3) == (u(3, 1)*d + v(3, 1)*e + f)/(u(3, 1)*g + v(3, 1)*h + 1),...
        x(1, 4) == (u(4, 1)*a + v(4, 1)*b + c)/(u(4, 1)*g + v(4, 1)*h + 1),...
        y(1, 4) == (u(4, 1)*d + v(4, 1)*e + f)/(u(4, 1)*g + v(4, 1)*h + 1)];

param = solve(eqns, [a b c d e f g h]);

% convert to transformation matrix
tf_matrix = [param.a, param.b, param.c;
             param.d, param.e, param.f;
             param.g, param.h, 1];

% plot out the accurate area
subplot(1, 3, 1), imshow(image_cal);
title("area of workspace"); hold on;

px = [u(1, 1) u(2, 1) u(3, 1) u(4, 1) u(1, 1)];
py = [v(1, 1) v(2, 1) v(3, 1) v(4, 1) v(1, 1)];
line(px, py, "color", "r", "LineWidth", 2);

% create mask for later process
subplot(1, 3, 2);
mask = poly2mask(px, py, rows, columns);
imshow(mask), title("mask generated");

% show masked image
subplot(1, 3, 3);
image_bw = imbinarize(image_cal);
image_masked = insertObjectMask(image_bw, mask);
imshow(image_masked), title("masked image");
