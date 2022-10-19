% video source
filename = './test_examples/test.mp4';
video_stream = VideoReader(filename);
% template
temp_file = './test_examples/template_buoyer.png';
temp_img = rgb2gray(im2double(imread(temp_file)));
[H,W] = size(temp_img);
% template matcher
tmatcher = vision.TemplateMatcher;
hVideoOut = vision.VideoPlayer('Name', 'Demo Matcher');
% we read 1 frame per second, i.e. sampling ratio 1hz
counter = 1;
while hasFrame(video_stream)
    % read frame
    frame = readFrame(video_stream);
    if rem(counter-1, 30) == 0
        frame_gray = imresize(rgb2gray(im2double(frame)),[512,512]);
        % find location
        location = tmatcher(frame_gray, temp_img);
        % show the box
        frame_gray = insertShape(frame_gray, 'rectangle', [location(1)-W/2, location(2)-H/2, W,H], 'Color', 'white');
        hVideoOut(frame_gray);
    end
    counter = counter + 1;
end
                        