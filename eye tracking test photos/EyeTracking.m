if exist('vid')
    stop(vid);
end
clear;clc;close all;
vid = videoinput('macvideo', 1, 'YCbCr422_640x480','ReturnedColorSpace','rgb');
%vid = videoinput('macvideo',1);
triggerconfig(vid, 'manual');
start(vid)
featureVec=[-3;-3;-2;0;-3;-3;-2;0;1;-1;-3;-1;2;3;3;0;];
center_vec=[];
frame=1;
u=1;
t=1;
pre_cur_vec=zeros(4,2);
while 1
    I=getsnapshot (vid);
    eyedetector=vision.CascadeObjectDetector('baby-eye.xml','MinSize',[40 70],'MaxSize',[50 88]);
    bbox = step(eyedetector, I);
%      shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[255 255 0]); 
%      I_eye = step(shapeInserter, I, int32(bbox)); 
    [val,ind]=min(bbox(:,1));
    bbox=bbox(ind,:);
    if ~isempty(bbox) && bbox(2)<450 && bbox(1)<610      %(1)horizontal(2) vertical
        I_small=I(bbox(2)-5:bbox(2)+bbox(4)+5,bbox(1)-5:bbox(1)+bbox(3)+5,:);
        I_small=imresize(I_small,[100 160]); 
        I_small_gray=rgb2gray(I_small);
        I_small_gray=medfilt2(I_small_gray,[5 5],'symmetric');
        C=corner(I_small_gray(30:75,120:154),'Harris','QualityLevel',0.1);
        C2=C+[119*ones(1,size(C,1));29*ones(1,size(C,1))]';
        %HOG matching
        if ~isempty(C2)
              matchingRate=zeros(size(C2,1),1);
            for i=1:size(C2,1)
                if C2(i,1)+8>160
                    continue;
                end
                region=double(rgb2gray(I_small(C2(i,2)-14:C2(i,2)+5,C2(i,1)-11:C2(i,1)+8,:)));
                region_cell=mat2cell(region,[5 5 5 5],[5 5 5 5]);
                currfeatureVec=zeros(16,1);
                for m=1:4
                    for n=1:4
                        subcell=cell2mat(region_cell(m,n));
                        [GradientX,GradientY]=gradient(subcell);
                        Gradient_mag=sqrt(GradientX.^2+GradientY.^2);
                        Gradient_mag=Gradient_mag./sum(Gradient_mag(:));             %HOG normalized gradient magnitude
                        Gradient_dir=atan2(GradientY,-GradientX).*Gradient_mag;      %weighted direction %try absolute angle value later
                        currfeatureVec(n+4*(m-1))=round(sum(Gradient_dir(:))/(pi/4));
                    end
                end
                  matchingRate(i)=(160-C2(i,1))^-3*sum(currfeatureVec.*featureVec)/norm(featureVec)/norm(currfeatureVec);
            end
            [val,ind]=max(matchingRate);    
            [centers, radii] = imfindcircles(I_small_gray,[20 30],'ObjectPolarity','dark','Sensitivity',0.92);
            if size(radii)==1
                if frame<=10
                    center_vec=[center_vec;(centers-C2(ind,:))/radii];      %divide by radii !!!
                    frame=frame+1
                elseif frame==11
                     center_vec_avg=mean(center_vec);
                     frame=12
                     pre_cur_vec(1,:)=center_vec_avg;
                     pre_cur_vec(3,:)=center_vec_avg;
                     pre_cur_vec(4,:)=center_vec_avg;
                else
                    cur_vec=(centers-C2(ind,:))/radii ;                    %current vector from corner to iris
                  %% cur_vec denoising
                    pre_cur_vec(mod(t,4)+1,:)=cur_vec; 
                    cur_vec_avg=mean(pre_cur_vec);
                    eye_vec=10*(cur_vec_avg-center_vec_avg);                   %the vector corresponds to screen gaze point
%                     if 10*(cur_vec-center_vec_avg)>1
%                           figure;
%                           imshow(I_small);hold on;
%                           plot(C2(:,1),C2(:,2),'r*');
%                           plot(C2(ind,1),C2(ind,2),'bo');
%                           h=viscircles(centers,radii);
%                           close;
%                     end
                    plot(-eye_vec(1),-eye_vec(2),'r*');hold on;
                    axis([-15 15 -8 8]);    
                    drawnow
                    t=t+1;            
                end
            else
                disp('Circle');
                u;
            end
        else
            disp('Corner');
            u;
        end
    else
        disp('NO eye detected');
    end
end

imshow(I_small);hold on;
plot(C2(:,1),C2(:,2),'r*');
plot(C2(ind,1),C2(ind,2),'bo');
h=viscircles(centers,radii);