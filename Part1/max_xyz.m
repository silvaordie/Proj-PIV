function f = max_xyz(objects, xyz, img) 
    obs=max(max(objects(:,:)));
            cnt=1;
    for l=1:obs
       [x,y]=find(objects(:,:)==l );
       if(length(x)>1000)
           ind=reshape(objects,1 , 640*480 );
           rgbaux=reshape(double(img), [3, 640*480]);
           rgb(1,:)=rgbaux(1,:)./(rgbaux(1,:)+rgbaux(2,:)+rgbaux(3,:));
           rgb(2,:)=rgbaux(2,:)./(rgbaux(1,:)+rgbaux(2,:)+rgbaux(3,:));
           rgb(3,:)=rgbaux(3,:)./(rgbaux(1,:)+rgbaux(2,:)+rgbaux(3,:));

           hsv=rgb2hsv(rgb');
           h=hsv(objects(:,:)==l,1)';
           aux=histogram(h,100);
           hist=aux.Values;
           close;
           
           coords=zeros(3,length(x));
           for count=1:1:length(x);
            coords(:,count)=xyz.coord(x(count),y(count),:);
            
           end
           f.obj(cnt).maxx=max(coords(1,:));
           f.obj(cnt).maxy=max(coords(2,:));
           f.obj(cnt).maxz=max(coords(3,:));
           
           f.obj(cnt).minx=min(coords(1,:));
           f.obj(cnt).miny=min(coords(2,:)); 
           f.obj(cnt).minz=min(coords(3,:)); 
           f.obj(cnt).h=hist;
           cnt=cnt+1;
           
           
       end
    end 
    
    if(obs==0 || cnt==1)
       f.obj=nan; 
    end
end