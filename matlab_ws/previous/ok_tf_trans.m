% calibration matrix is obtained start real time transformation
sympref('FloatingPointOutput',true)

while (true)
    image = snapshot(cam);

    imshow(image);
    [U, V] = getpts;
    camera_frame = [U; V; 1;];

    tf_result_k = tf_matrix * camera_frame;
    tf_result = tf_result_k * (1/tf_result_k(3, 1));
    double(tf_result);
    disp(tf_result);
    
    pause(1)
end