% setup workspace
clear;
cam = webcam;
image = snapshot(cam);
filename = "color_data.xlsx";

% read user specified color_data sheet
newfile = input("start a new traing? yes/no: ", "s");
if newfile == "yes"
    sheetname = input("key in new sheet name: ", "s");
else
    sheetname = input("select the sheet to be open: ", "s");
    Tr = readtable("color_data.xlsx", "Sheet", sheetname);
end

% whther to add new data
if newfile == "no"
    selectnew = input("do you want add new point? yes/no: ", "s");
else
    selectnew = "yes";
end

% write new data to file
if selectnew =="yes"
    image = imresize(image, [512, 512]);
    imshow(image); [u, v] = getpts;
    u = int16(u); v = int16(v);
    u_len = length(u);
    r = zeros(u_len, 1, "double");
    g = zeros(u_len, 1, "double");
    b = zeros(u_len, 1, "double");

    % obtain training data
    for i = 1 : u_len
        rgb = image(u(i, 1), v(i, 1), :);
        r(i, 1) = rgb(:, :, 1); 
        g(i, 1) = rgb(:, :, 2);
        b(i, 1) = rgb(:, :, 3);
    end

    % write training data to excel sheet
    Tw = table(r, g, b);
    if newfile == "yes"
        writetable(Tw, filename, "Sheet", sheetname);
    else
        T_size = size(Tr); T_len = T_size(1, 1);
        T_len = string(T_len);
        writetable(Tw, filename, "Sheet", sheetname,...
                   "Range", "A"+T_len, "WriteVariableNames", 0);
    end
end

% ask if need to train now or stop here
train = input("start to train now? yes/no: ", "s");
if train == "yes"
    sheets = sheetnames("color_data.xlsx");
    info = zeros(length(sheets), 6);
    for i = 2 : length(sheets)
        T = readtable("color_data.xlsx", "Sheet", sheets(i));
        Tm = mean(T{:, ["r", "g", "b"]});
        Ts = std(T{:, ["r", "g", "b"]});
        for m = 1 : 3
            info(i, m) = Tm(1, m);
            info(i, m+3) = Ts(1, m);
        end
        Tw = table(info);
        Tr = readtable("color_data.xlsx", "Sheet", "info");
        T_size = size(Tr); T_len = T_size(1, 1);
        T_len = string(T_len);
        writetable(Tw, filename, "Sheet", "info",...
               "Range", "A1", "WriteVariableNames", 0);
    end
else
    fprintf("data saved to color_data.xlsx");
end
