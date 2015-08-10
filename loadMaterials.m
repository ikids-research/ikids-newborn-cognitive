function [sampling, attimage, habstim1, habstim2, stim1_1, stim1_2, stim2_1, stim2_2, blank, vid, center_vec,centerlocation,leftlocation, rightlocation, window,triallabels,redSquare] = loadMaterials(condition)
% This function loads all images and prepares the windows for the trials.

% uncomment this when eyetracking is up and running
% if exist('vid')
%     stop(vid);
% end

vid = 0;
center_vec = [];

% set the sampling rate
 sampling = 1/60;

% set some colors and window parameters
background = [50,50,50];  % color in Red, Green, Blue

% skip sync tests
Screen('Preference', 'SkipSyncTests', 1)

% open a window screen
[window, rect] = Screen(1,'OpenWindow', background);

% some window measurements
XLeft=rect(RectLeft); 
XRight=rect(RectRight);
YTop=rect(RectTop); 
YBottom=rect(RectBottom);
Xcenter=XRight./2;
Ycenter=YBottom./2;
LeftXcenter = XRight./4;
RightXcenter = XRight./4*3;


% image sizes in pixels
centerImageSize = 350;
sideImageSize = 600;
Y_offset = -75;
X_offset = 120;

sideImageSize2 = 650;

centerlocation = [Xcenter-(centerImageSize/2),Ycenter-(centerImageSize/2)-200+Y_offset,Xcenter+(centerImageSize/2), Ycenter+(centerImageSize/2)-200+Y_offset];
leftlocation = [LeftXcenter-sideImageSize/2-X_offset, Ycenter-sideImageSize/2, LeftXcenter+sideImageSize/2-X_offset, Ycenter+sideImageSize/2];
rightlocation = [RightXcenter-sideImageSize/2+X_offset, Ycenter-sideImageSize/2, RightXcenter+sideImageSize/2+X_offset, Ycenter+sideImageSize/2];

leftlocationred = [LeftXcenter-sideImageSize2/2-X_offset, Ycenter-sideImageSize2/2, LeftXcenter+sideImageSize2/2-X_offset, Ycenter+sideImageSize2/2];
rightlocationred = [RightXcenter-sideImageSize2/2+X_offset, Ycenter-sideImageSize2/2, RightXcenter+sideImageSize2/2+X_offset, Ycenter+sideImageSize2/2];

global leftlocationred
global rightlocationred
global imagenums
imagenums = 0;

%-----------------------------------------------------------
% prepare images.
%-----------------------------------------------------------
ThumbSize=700; 
%flashSize=216;
Padding =ThumbSize/2;  % padding between the two images.
%XLeftLoc=Xcentre-ThumbSize-Padding;
zXRightLoc=Xcenter+Padding;

fprintf('Load Attention Images\n');

% load attention grabbing images \\ fix this
attimage1_1 = imread('images/simpleAttImages/att_image1_1.png');
attimage2_1= imread('images/simpleAttImages/att_image2_1.png');
attimage3_1 = imread('images/simpleAttImages/att_image3_1.png');
attimage4_1 = imread('images/simpleAttImages/att_image4_1.png');
attimage5_1= imread('images/simpleAttImages/att_image5_1.png');
attimage6_1 = imread('images/simpleAttImages/att_image6_1.png');
attimage7_1 = imread('images/simpleAttImages/att_image7_1.png');
attimage8_1 = imread('images/simpleAttImages/att_image8_1.png');
% attimage9_1 = imread('images/simpleAttImages/9_1.jpg');
% attimage10_1 = imread('images/simpleAttImages/10_1.jpg');

attimage1_2 = imread('images/simpleAttImages/att_image1_2.png');
attimage2_2= imread('images/simpleAttImages/att_image2_2.png');
attimage3_2 = imread('images/simpleAttImages/att_image3_2.png');
attimage4_2 = imread('images/simpleAttImages/att_image4_2.png');
attimage5_2= imread('images/simpleAttImages/att_image5_2.png');
attimage6_2 = imread('images/simpleAttImages/att_image6_2.png');
attimage7_2 = imread('images/simpleAttImages/att_image7_2.png');
attimage8_2 = imread('images/simpleAttImages/att_image8_2.png');
% attimage9_2 = imread('images/simpleAttImages/2-10.jpg');
% attimage10_2 = imread('images/simpleAttImages/2-11.jpg');

attimage = {{attimage1_1, attimage1_2}, {attimage2_1, attimage2_2}, {attimage3_1, attimage3_2}, {attimage4_1, attimage4_2}, {attimage5_1, attimage5_2}, {attimage6_1, attimage6_2}, {attimage7_1, attimage7_2}, {attimage8_1, attimage8_2}};%, {attimage9_1, attimage9_2}, {attimage10_1, attimage10_2}};

fprintf('Load Experimental Images\n');

% load images for face and geometric images
faceYoungFile = imread('images/1-pair-young-face[6X8in].bmp');
faceOldFile = imread('images/1-pair-old-face[6X8in].bmp');
geoOriginalFile = imread('images/Pattern_Familiar.bmp');
geoNewFile = imread('images/Pattern_Novel.bmp');

% load red boarder image for calebration

redSquare = imread('images/red_outline.bmp');


fprintf('Load Textures');

% make all the images off screen images
faceOld = faceOldFile; 
faceYoung = faceYoungFile;
geoBlackX = geoOriginalFile;
geoWhiteX = geoNewFile;

% presentation time
frames=FrameRate(window);

% MIGHT NEED TO MESS WITH THESE
%ShortStiTime =floor(frames./20); %present stimuli for about 50ms.
%LongStiTime =floor(frames./10); %present stimuli for about 100ms.

%HideCursor;
%present the stimuli
%a blank pattern to overlap the previous stimuli at the same location.
RectBlank=[XLeft YTop XRight YBottom];

blank = Screen(window,'OpenoffscreenWindow',background,RectBlank);


%for i=1:length(attimage)
%    attimagedisplays(i) = Screen(window,'OpenoffscreenWindow',background,{[XLeft YTop ThumbSize ThumbSize]});
%    Screen(attimagedisplays(i),'PutImage',attimage{i},{[XLeft YTop ThumbSize ThumbSize]});
%end

% for eyetracking, start the camera, and start a vector that the program
% will use to account for the center look calebrations

% uncomment these when you have eyetracker working
%vid = videoinput('macvideo', 1, 'YCbCr422_640x480'],['ReturnedColorSpace'],['rgb');
%triggerconfig(vid, 'manual');
%start(vid)
%center_vec=[];
triallabels = [];

switch condition
	case 1
        habstim1 = faceOld;
        stim1_1 = faceYoung;
        stim1_2 = faceOld;
        
        habstim2 = geoBlackX;
        stim2_1 = geoWhiteX;
        stim2_2 = geoBlackX;
        
        triallabels = {'faceOldHab','faceNovelLeft','faceNovelRight','geoBlackXHab','geoNovelLeft','geoNovelRight'};
    
    case 2
        habstim1 = faceYoung;
        stim1_1 = faceYoung;
        stim1_2 = faceOld;
        
        habstim2 = geoWhiteX;
        stim2_1 = geoWhiteX;
        stim2_2 = geoBlackX;
        
        triallabels = {'faceYoungHab','faceNovelRight','faceNovelLeft','geoWhiteXHab','geoNovelRight','geoNovelLeft'};
        
    case 3
        habstim1 = faceOld;
        stim1_1 = faceOld;
        stim1_2 = faceYoung;
        
        habstim2 = geoBlackX;
        stim2_1 = geoBlackX;
        stim2_2 = geoWhiteX;
        
        triallabels = {'faceOldHab','faceNovelRight','faceNovelLeft','geoBlackXHab','geoNovelRight','geoNovelLeft'};
    
    case 4
        habstim1 = faceYoung;
        stim1_1 = faceOld;
        stim1_2 = faceYoung;
        
        habstim2 = geoWhiteX;
        stim2_1 = geoBlackX;
        stim2_2 = geoWhiteX;
        
        triallabels = {'faceYoungHab','faceNovelLeft','faceNovelRight','geoWhiteXHab','geoNovelLeft','geoNovelRight'};
        
        
    case 5
        habstim1 = geoBlackX;
        stim1_1 = geoWhiteX;
        stim1_2 = geoBlackX;
        
        habstim2 = faceOld;
        stim2_1 = faceYoung;
        stim2_2 = faceOld;
        
        triallabels = {'geoBlackXHab','geoNovelLeft','geoNovelRight','faceOldHab','faceNovelLeft','faceNovelRight'};
        
    case 6
        habstim1 = geoWhiteX;
        stim1_1 = geoWhiteX;
        stim1_2 = geoBlackX;
        
        habstim2 = faceYoung;
        stim2_1 = faceYoung;
        stim2_2 = faceOld;
        
        triallabels = {'geoWhiteXHab','geoNovelRight','geoNovelLeft','faceYoungHab','faceNovelRight','faceNovelLeft'};
        
    case 7
        habstim1 = geoBlackX;
        stim1_1 = geoBlackX;
        stim1_2 = geoWhiteX;
        
        habstim2 = faceOld;
        stim2_1 = faceOld;
        stim2_2 = faceYoung;
        
        triallabels = {'geoBlackXHab','geoNovelRight','geoNovelLeft','faceOldHab','faceNovelRight','faceNovelLeft'};
        
    case 8
        habstim1 = geoWhiteX;
        stim1_1 = geoBlackX;
        stim1_2 = geoWhiteX;
        
        habstim2 = faceYoung;
        stim2_1 = faceOld;
        stim2_2 = faceYoung;
        
        triallabels = {'geoWhiteXHab','geoNovelLeft','geoNovelRight','faceYoungHab','faceNovelLeft','faceNovelRight'};
        
end
        

% Screen(window,'PutImage',check,{[XLeftLoc Ycentre XLeftLoc+ThumbSize Ycentre+ThumbSize]});
% Screen(window,'PutImage',check,{[XRightLoc Ycentre XRightLoc+ThumbSize Ycentre+ThumbSize]});
% Screen(window,'WaitBlanking',LongStiTime); %StiTime


