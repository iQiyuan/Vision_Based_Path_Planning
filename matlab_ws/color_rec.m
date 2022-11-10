% setup workspace
clear;
cam = webcam;
filename = "color_data.xlsx";

% read in color recognition infomation
info = readtable("color_data.xlsx", "Sheet", "info");
info = table2array(info);
recognition = zeros(1, height(info)-1);


% import template file and prepare it
tp_name = input("what template to be used: ", "s");
tp_file = "./template/"+tp_name;
tp_img = rgb2gray(im2double(imread(tp_file)));
imshow(tp_img); [h, w] = size(tp_img);

% template matcher
tmatcher = vision.TemplateMatcher;
hVideoOut = vision.VideoPlayer('Name', 'Demo Matcher');

while true

    % strat tamplate matching give a coordinate
    frame = snapshot(cam);
    frame = imresize(frame, [512, 512]);
    frame_gray = rgb2gray(im2double(frame));
    location = tmatcher(frame_gray, tp_img);
    frame_gray = insertShape(frame_gray, "rectangle",...
                             [location(1) - w/2,...
                              location(2) - h/2, w, h],...
                             "Color", "white");
    hVideoOut(frame_gray);

    % start construct color sphere
    rgb = frame(location(1), location(2), :);
    r = rgb(:, :, 1); 
    g = rgb(:, :, 2);
    b = rgb(:, :, 3);
    
    for i = 2 : height(info)
        rm = info(i, 1); gm = info(i, 2); bm = info(i, 3);
        rs = info(i, 4); gs = info(i, 5); bs = info(i, 6);
        sphere = ((r - rm)^2)/(rs)^2 + ...
                 ((g - gm)^2)/(gs)^2 + ...
                 ((b - bm)^2)/(bs)^2;

        if sphere <= 1
            recognition(1, i-1) = 1;
        else
            recognition(1, i-1) = 0;
        end
    end
end
