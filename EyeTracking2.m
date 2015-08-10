function [eye_direction, center_vec] = EyeTracking2(vid,CalebrateCenterOrNot,center_vec)

% if exist('vid')
%     stop(vid);
% end
% %clear;clc;close all;
% vid = videoinput('macvideo', 1, 'YCbCr422_640x480','ReturnedColorSpace','rgb');
% triggerconfig(vid, 'manual');
% start(vid)

featureVec=[-3;-3;-2;0;-3;-3;-2;0;1;-1;-3;-1;2;3;3;0;];
%center_vec=[];
%frames=1;
u=1;
t=1;
pre_cur_vec=zeros(4,1);
direction=0;
accumL=uint8(0);
accumC=uint8(0);
accumR=uint8(0);
flag=1;

%while 1
I=getsnapshot (vid);
I=imresize(I,[720 1280]);
eyedetector=vision.CascadeObjectDetector('baby-eye.xml','MinSize',[40 70],'MaxSize',[50 88]); % change min size if needed but keep the ratio between two numbers.
bbox = step(eyedetector, I);
[val,ind]=min(bbox(:,1));
bbox=bbox(ind,:);
if ~isempty(bbox) && bbox(2)<450 && bbox(1)<610
    I_small=I(bbox(2)-5:bbox(2)+bbox(4)+5,bbox(1)-5:bbox(1)+bbox(3)+5,:);
    I_small=imresize(I_small,[100 200]);
    I_small_gray=rgb2gray(I_small);
    I_small_gray=medfilt2(I_small_gray,[7 7], 'symmetric');
    C=corner(I_small_gray(30:75,150:192),'Harris','QualityLevel',0.1);
    C2=C+[149*ones(1,size(C,1));29*ones(1,size(C,1))]';
    %HOG matching
    if ~isempty(C2)
        matchingRate=zeros(size(C2,1),1);
        for i=1:size(C2,1)
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
            matchingRate(i)=(200-C2(i,1))^-3*sum(currfeatureVec.*featureVec)/norm(featureVec)/norm(currfeatureVec);
        end
        [~,ind]=max(matchingRate);
        % x center calculate
        var_row=var(double(I_small_gray),0,2);
        var_col=var(double(I_small_gray),0,1);
        var_I=var_row*var_col;
        [var_gradient_X,var_gradient_Y]=gradient(var_I);
        col_sum=abs(sum(var_gradient_X,1));
        [val, indL]=max(col_sum);
        if indL>5 && indL<185
            col_sum(indL-5:indL+15)=0;
        else
            continue;
        end
        I_small(:,indL,1)=255;
        [val, indR]=max(col_sum);
        I_small(:,indR,1)=255;
        centers=(indL+indR)/2;      % x center of iris
        % radii=abs(indL-indR);
        radii=1;
        % if this trial should be taken as a calebration then use this
        % code
        if CalebrateCenterOrNot == True%frames<=10
            center_vec=[center_vec;(centers-C2(ind,1))/radii];      %divide by radii !!!
            %frames=frames+1
            centers_temp=centers;
            % otherwise use this code to
        else %CalebrateCenterOrNot == False %frames==11
            center_vec_avg=mean(center_vec);
            %frames=12
            pre_cur_vec(1)=center_vec_avg;
            pre_cur_vec(3)=center_vec_avg;
            pre_cur_vec(4)=center_vec_avg;
        %else
            cur_vec=(centers-C2(ind,1))/radii;                    %current vector from corner to iris
            %cur_vec denoising
            pre_cur_vec(mod(t,4)+1)=cur_vec;
            cur_vec_avg=mean(pre_cur_vec);
            eye_vec=(cur_vec-center_vec_avg);
            plot(-eye_vec(1),20-0.1*t,'r*');hold on;
            axis([-15 15 -20 20]);
            %To see whether the iris and eye corner are correctly located, uncomment
            %the following 3 lines and add a break point to "close figure 2". Then run
            %the program,and press F5 to continue frame by frame.
            %                figure;
            %                imshow(I_small);hold on;plot(C2(ind,1),C2(ind,2),'r*')
            %                close figure 2;
            drawnow
            threshold_L=-8; % threshold left - change to lower
            threshold_R=10; % threshold right
            accumC=uint8(accumC-1+2*(-eye_vec>threshold_L && -eye_vec<threshold_R));
            accumL=uint8(accumL-1+2*(-eye_vec<=threshold_L));
            accumR=uint8(accumR-1+2*(-eye_vec>=threshold_R));
            
            if accumC>=5
                direction=0;
                accumC=5;
            elseif accumL>=5
                direction=-1;
                accumL=5;
            elseif accumR>=5
                direction=1;
                accumR=5;
            end
            
            switch direction
                case 0
                    disp('              center');
                    eye_direction = 'center';
                case -1
                    disp('left')
                    eye_direction = 'left';
                case 1
                    disp('                                 right')
                    eye_direction = 'right';
                otherwise
            end
            t=t+1;
        end
    else
        disp('Corner');
        u;
    end
else
    disp('NO eye detected');
end
%end

% Problematic!!
%(1) the detected eye region are not aligned. Size are different: normalize
%by dividing radii
%(2) the eye may rotate!!
%now testing the eye_vector norm consistency: medfilt2 helps!! Next try:
%quickest change detection
%use row and column variance to find iris
%average over frames to remove corner location noise (require fast FPS)
%need to use high resolution cam to get more eye region pixels !!
%requires uniform lighting, otherwise eye deteciton fails.
%corner noise mainly vertically