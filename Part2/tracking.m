function  frame=tracking(imgseq1, cam_params, camtoW)  

    for k=1:length(imgseq1.rgb)
        imgs(k).rgb=imread([imgseq1.rgb(k).name]);
        load([imgseq1.depth(k).name]);
        imgsd(:,:,k)=double(depth_array)/1000;
        
        Z=double(depth_array(:)')/1000;
        [v u]=ind2sub([480 640],(1:480*640));
        t=inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z];
        t=[camtoW.R, camtoW.T]*[t; ones(1,length(t))];
        xyz(k).coord=reshape(t',[480,640,3]);
    end

    objects=bg_subtraction(imgsd,imgs);
    
    siz=size(objects);
    for k=1:siz(3)
        frame(k)=max_xyz(objects(:,:,k), xyz(k), imgs(k).rgb);
    end
    
end