function [abort,atttime,centerLook] = attentionAndCalebration(calebrate,vid,attimage,attsound,window,centerlocation,leftlocation,rightlocation,blank,sampling,totaltime)

% Display Calebration Screen
%     Display center for 5 second look
%     Display left for 5 second look
%     Display right for 5 second look


% choose three random images left, right, center
imagenums = randperm(10);
abort = 0;
centerimage = attimage{imagenums(1)};
leftimage = attimage{imagenums(2)};
rightimage = attimage{imagenums(3)};

%randsound  = randperm(10);
%centersound = attsound{sounds(1)};
%leftsound = attsound{sounds(2)};
%rightsound = attsound{sounds(3)};

beep=MakeBeep(500,0.25);
endbeep = MakeBeep(1000,0.25);
Snd('Open');

%[y, Fs, nbits, readinfo] = wavread(centersound);


% timing start
t0 = GetSecs;
t2 = t0;

fixationReport=[];
fixationReport=[fixationReport;{t2, 'AttGrab-','-', 'start',0}];

cumuLookCenter = 0;
cumuLookLeft = 0;
cumuLookRight = 0;
centerLook = 0;
atttime = 0;
lefttime = 0;
centertime = 0;
righttime = 0;
offtime = 0;
tempofftime = 0;

Screen('CopyWindow',blank,window);
Screen('flip',window);

Snd('Play',beep); % play beep sound.

% display center image
Screen('PutImage',window,centerimage{1},centerlocation);
Screen('flip',window);
imageflip = 2;

flipNum = 0;

soundnum = 0;

while 1
    flipNum = flipNum + 1;
    t1=t2;
    WaitSecs(sampling);
    t2 = GetSecs;
    dt = t2-t1;
    %dt = dt *1000; % convert from ms to s
    [response,responseText,abort,fixationReport,lefttime,centertime,righttime,offtime,tempofftime] = getInput(vid,fixationReport,t2,lefttime,centertime,righttime,offtime,tempofftime,'AttGrab-','-','-',dt);  
    
    if strcmp(response,'c')
        cumuLookCenter = cumuLookCenter + dt;
        centerLook = centerLook +dt;
        %fprintf('Center Look: %d\n',cumuLookCenter);
    elseif strcmp(response,'a')
        abort = 1;
        break;
    else
        centerLook = 0; % reset looking time
        %fprintf('No Look\n');
    end
    
    if mod(flipNum,30) == 0
        if imageflip == 1
            Screen('PutImage',window,centerimage{1},centerlocation);
            Screen('flip',window);
            imageflip = 2;
        else
            Screen('PutImage',window,centerimage{2},centerlocation);
            Screen('flip',window);
            imageflip = 1;
        end
        
        if soundnum ==0
            playFile('sounds/baby.wav');
            soundnum = 1;
        else
            playFile('sounds/look.wav');
            soundnum = 0;
        end
    end
    
    if centerLook > 2 % if baby's looked at the center for two seconds then move forward
        atttime = atttime + cumuLookCenter;
        Snd('Play',endbeep); % play beep sound.
        break
    end
    
    if totaltime >180
        break
    end
end

Screen('CopyWindow',blank,window);
Screen('flip',window);

if calebrate == true
    % display left and right stim
end
    