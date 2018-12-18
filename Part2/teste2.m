%%
clear;
run 'vlfeat-0.9.21\toolbox\vl_setup'
d1=dir('corredor1\rgb_image1*.png');
dd1=dir('corredor1\depth1*.mat');

d2=dir('corredor1\rgb_image2*.png');
dd2=dir('corredor1\depth2*.mat');

load cameraparametersAsus.mat

imgseq1.rgb=d1;
imgseq1.depth=dd1;

imgseq2.rgb=d2;
imgseq2.depth=dd2;
clear d1 dd1 d2 dd2 
for k=1:length(imgseq1.rgb)      
        [fa, da] = vl_sift(single(rgb2gray(imread(['corredor1\', imgseq1.rgb(k).name])))) ;
        [fb, db] = vl_sift(single(rgb2gray(imread(['corredor1\', imgseq1.rgb(k).name])))) ;
        [m, s] = vl_ubcmatch(da, db) ;
        ms(1,k)=length(m);
end

[val ind] = sort(ms,'descend');


%%
idx=0;
for k=ind(1:3)

    Ia=single(rgb2gray(imread(['corredor1\', imgseq1.rgb(k).name]))) ;
    Ib=single(rgb2gray(imread(['corredor1\', imgseq2.rgb(k).name]))) ;   
    
    load(['corredor1\', imgseq1.depth(k).name]);
    Z=double(depth_array(:)')/1000;
    [v u]=ind2sub([480 640],(1:480*640));
    xyz1=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);
    
    load(['corredor1\', imgseq2.depth(k).name]);
    Z=double(depth_array(:)')/1000;
    [v u]=ind2sub([480 640],(1:480*640));
    xyz2=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);    
    
    iaux1=cam_params.Krgb*xyz1;
    iaux2=[cam_params.Krgb]*[cam_params.R, cam_params.T]*[xyz2 ; ones(1, length(xyz2))];
    
    ind1=[iaux1(1,:)./iaux1(3,:); iaux1(2,:)./iaux1(3,:)];
    ind2=[iaux2(1,:)./iaux2(3,:); iaux2(2,:)./iaux1(3,:)];
    
    [fa, da] = vl_sift(Ia) ;
    [fb, db] = vl_sift(Ib) ;
    [m, s] = vl_ubcmatch(da, db, 1.5) ;
    
    mcoords1=fa(1:2,m(1,:));
    mcoords2=fb(1:2,m(2,:));
    
    indices=[];
    fail=0;
    for i=1:1:length(mcoords1)
        
       err1=sqrt(sum(abs( ind1 - repmat( mcoords1(:,i),1,length(ind1)  ) ).^2));
       err2=sqrt(sum(abs( ind2 - repmat( mcoords2(:,i),1,length(ind2)  ) ).^2));
       
       [v1 idx1]=min(err1);
       [v2 idx2]=min(err2);
       
       if(v1<0.35 && v2<0.35)
            matches(1:3,idx+i-fail)=xyz1(:,idx1);
            matches(4:6,idx+i-fail)=xyz2(:,idx2);
       else
           fail=fail+1;
       end
    end
    idx=length(matches);
end
%%
niter=100;
aux=fix(rand(4*niter,1)*length(matches))+1;
numinliers=[];
th=0.35;
for k=0:1:niter-5
    P=matches(1:3, aux( (4*k+1):(4*k+4) ));
    P2=matches(4:6, aux( (4*k+1):(4*k+4) ));
    
    [ ~,~, transf ]=procrustes( P' , P2' , 'scaling', false, 'reflection', false );
    
    
    erro= abs(matches(1:3,:)-(transf.T*matches(4:6,:) +  repmat(transf.c(1,:)',1,length(matches(4:6,:)))));

    if(length(find(sqrt(sum(erro.^2))<th)) > max(numinliers))
        inliers=find(sqrt(sum(erro.^2))<th);
    end
    numinliers=[numinliers length(find(sqrt(sum(erro.^2))<th))]; 
end

points1=matches(1:3,inliers);
points2=matches(4:6,inliers);

[ ~,~, transf ]=procrustes( points1' , points2' , 'scaling', false, 'reflection', false );

load(['corredor1\', imgseq1.depth(1).name]);
Z=double(depth_array(:)')/1000;
[v u]=ind2sub([480 640],(1:480*640));
xyz1=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);

load(['corredor1\', imgseq2.depth(1).name]);
Z=double(depth_array(:)')/1000;
[v u]=ind2sub([480 640],(1:480*640));
xyz2=(inv(cam_params.Kdepth)*[Z.*u ;Z.*v;Z]);   

xyz2=[transf.T transf.c(1,:)']*[xyz2; ones(1,length(xyz2))];


pc1=pointCloud(xyz1');
pc2=pointCloud(xyz2');
figure(2);
hold on;
showPointCloud(pc1);
showPointCloud(pc2);
view(0,-90);