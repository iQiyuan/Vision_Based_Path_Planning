fun = f;

%cam = fun.SelectCamera("webcam");

%[image, u, v] = fun.GetImage(cam, true);
%tf_matrix = fun.GeoCalibration();
%[x, y] = fun.GeoTransformation(tf_matrix, u, v);
%fun.TemplateGeneration(cam, "test")
%fun.ColorDataCollection(cam);

%[tp_img, tmatcher, VideoOut, show, h, w] = fun.TemplateSelection();
%while 1
%location = fun.TemplateMatching(cam, tp_img, h, w, tmatcher, VideoOut, show);
%end

%frame = imresize(snapshot(cam),[512,512]);
%location = [425, 184];
%sphere = fun.SphereConstruction(location, frame, 1);

%sphere = 0.8;
%location = [179, 199];
%homography = tf_matrix;
%[x, y] = fun.TargetByColor(sphere, location, tf_matrix);
