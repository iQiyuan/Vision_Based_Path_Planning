% declare general function -- tested
function fun= f
    
    % general preparation
    fun.SelectCamera = @SelectCamera;
    fun.GetImage = @GetImage;
    
    % geometry transformation
    fun.GeoCalibration = @GeoCalibration;
    fun.GeoTransformation = @GeoTransformation;

    % template learning recognition
    fun.TemplateGeneration = @TemplateGeneration;
    fun.TemplateSelection = @TemplateSelection;
    fun.TemplateMatching = @TemplateMatching;

    % color learning recognition
    fun.ColorDataCollection = @ColorDataCollection;
    fun.ColorSphereConstruction = @ColorSphereConstruction;
    fun.ColorRecognition = @ColorRecognition;

    % get target location by different means
    fun.TargetByColor = @TargetByColor;
    fun.TargetByTemplate = @TargetByTemplate;
end

% function to select camera -- tested
function cam = SelectCamera(camid)
    if camid == "webcam"
        cam = webcam;
    elseif camid == "url of ipcamera 1"
        cam = ipcam("url, username, password, options");
    elseif camid == "url of ipcamera 2"
        cam = ipcam("url, username, password, options");
    elseif camid == "url of ipcamera 3"
        cam = ipcam("url, username, password, options");
    elseif camid == "url of ipcamera 4"
        cam = ipcam("url, username, password, options");
    end
end

% function to pre-process image -- tested
function [image, u, v] = GetImage(cam, gtpts)
    image = imresize(snapshot(cam), [512, 512]);
    if gtpts == true
        imshow(image); [u, v] = getpts;
    elseif gtpts == false
        u = 0; v = 0;
    end
end

% geomatric calibration -- tested
function homography = GeoCalibration()
    
    % get image u v coordinate
    camid = input("which camera for calibration: ");
    cam = SelectCamera(camid);
    [~, u, v] = GetImage(cam, true);

    % get user input real world coordinates
    sympref('FloatingPointOutput',true);
    x = [0, 0, 0, 0];
    y = [0, 0, 0, 0];
    for i = 1:4
        x(1, i) = input("real world x" + string(i) + " coordinate: ");
        y(1, i) = input("real world y" + string(i) + " coordinate: ");
    end

    % construct and solve equation
    syms a b c d e k g h;
    eqns = [x(1,1) == (u(1,1)*a + v(1,1)*b + c)/(u(1,1)*g + v(1,1)*h + 1),...
            y(1,1) == (u(1,1)*d + v(1,1)*e + k)/(u(1,1)*g + v(1,1)*h + 1),...
            x(1,2) == (u(2,1)*a + v(2,1)*b + c)/(u(2,1)*g + v(2,1)*h + 1),...
            y(1,2) == (u(2,1)*d + v(2,1)*e + k)/(u(2,1)*g + v(2,1)*h + 1),...
            x(1,3) == (u(3,1)*a + v(3,1)*b + c)/(u(3,1)*g + v(3,1)*h + 1),...
            y(1,3) == (u(3,1)*d + v(3,1)*e + k)/(u(3,1)*g + v(3,1)*h + 1),...
            x(1,4) == (u(4,1)*a + v(4,1)*b + c)/(u(4,1)*g + v(4,1)*h + 1),...
            y(1,4) == (u(4,1)*d + v(4,1)*e + k)/(u(4,1)*g + v(4,1)*h + 1)];
    param = solve(eqns, [a b c d e k g h]);

    % convert to transformation matrix
    homography = [param.a, param.b, param.c;
                  param.d, param.e, param.k;
                  param.g, param.h, 1];
end

% geomatric transformation -- tested
function [x, y] = GeoTransformation(homography, u, v)
    sympref('FloatingPointOutput',true)
    cameraframe = [u; v; 1;];
    worldframe_k = homography * cameraframe;
    worldframe = worldframe_k * (1/worldframe_k(3, 1));
    x = worldframe(1);
    y = worldframe(2);
end

% template genration function -- tested
function TemplateGeneration(cam, filename)
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
    imwrite(index, "./template/" + filename + ".tif")
end

% template selection function -- tested
function [tp_img, tmatcher, VideoOut, show, h, w] = TemplateSelection(tpid)
    show = input("show template match result? yes/no: ", "s");    
    tp_file = "./template/" + tpid + ".tif";
    tp_img = rgb2gray(im2double(imread(tp_file)));
    imshow(tp_img); [h, w] = size(tp_img);
    tmatcher = vision.TemplateMatcher;
    VideoOut = vision.VideoPlayer("Name", "Demo Matcher");
end

% template matching function -- tested
function location = TemplateMatching(cam, tp_img, h, w,...
                                     tmatcher, VideoOut, show)
    frame = imresize(snapshot(cam), [512, 512]);
    frame_gray = rgb2gray(im2double(frame));
    location = tmatcher(frame_gray, tp_img);
    if show == "yes"
        frame_gray = insertShape(frame_gray, "rectangle",...
                                 [location(1) - w/2,...
                                 location(2) - h/2, w, h],...
                                 "Color", "white");
        VideoOut(frame_gray);
    end
end

% color recognition obtain training data -- tested
function ColorDataCollection(cam)
    
    % read user specified color_data sheet
    filename = "color_data.xlsx";
    newfile = input("start a new traing? yes/no: ", "s");
    if newfile == "yes"
        sheetname = input("key in new sheet name: ", "s");
    else
        sheetname = input("select the sheet to be open: ", "s");
        Tr = readtable(filename, "Sheet", sheetname);
    end

    % whther to add new data
    if newfile == "no"
        selectnew = input("do you want add new point? yes/no: ", "s");
    else
        selectnew = "yes";
    end

    % write new data to file
    if selectnew =="yes"
        image = imresize(snapshot(cam), [512, 512]);
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
            writetable(Tw, filename, "Sheet", "info",...
                       "Range", "A1", "WriteVariableNames", 0);
        end
    else
        fprintf("data saved to color_data.xlsx");
    end
end

% color recognition sphere construction -- tested
function sphere = ColorSphereConstruction(location, frame, sphereID)

    % read in trained data
    filename = "color_data.xlsx";
    info = readtable(filename, "Sheet", "info");
    info = table2array(info); info(1,:) = [];

    % get sphere parameter
    rgb = frame(location(1), location(2), :);
    r = rgb(:, :, 1); 
    g = rgb(:, :, 2);
    b = rgb(:, :, 3);
    rm = info(sphereID, 1); gm = info(sphereID, 2); bm = info(sphereID, 3);
    rs = info(sphereID, 4); gs = info(sphereID, 5); bs = info(sphereID, 6);
    sphere = ((r - rm)^2)/(rs)^2 + ...
             ((g - gm)^2)/(gs)^2 + ...
             ((b - bm)^2)/(bs)^2; 
end

% obtain target location using color recognition -- tested
function [x, y] = TargetByColor(sphere, location, homography)
    if sphere <=1
        u = location(1); v = location(2);
        [x, y] = GeoTransformation(homography, u, v);
    end
end

% obtain target location using template matching -- tested
function [x, y] = TargetByTemplate (tpid, location, homography)
    if tpid == "template id for task1"
        u_tp1 = location(1); v_tp1 = location(2);
        [x, y] = GeoTransformation(homography, u_tp1, v_tp1);
    elseif tpid == "template id for task2"
        u_tp2 = location(1); v_tp2 = location(2);
        [x, y] = GeoTransformation(homography, u_tp2, v_tp2);
    elseif tpid == "template id for task3"
        u_tp3 = location(1); v_tp3 = location(2);
        [x, y] = GeoTransformation(homography, u_tp3, v_tp3);
    % add more according to template quantity
    end   
end


