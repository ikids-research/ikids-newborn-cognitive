function [abort,atttime,centerLook] = attentionAndCalebration(calebrate,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,totaltime,outputfile,outputfilesummary,calebrationstim)

global redSquare
global leftlocationred
global rightlocationred

% Display Calebration Screen
%     Display center for 5 second look
%     Display left for 5 second look
%     Display right for 5 second look

global imagenums
%attention grabber to use - go through each in order then increment by 1
if imagenums == 0
    imagenums = 1;
elseif imagenums >= 9
    imagenums = 1;
else
    imagenums = imagenums +1;
end


% choose three random images left, right, center
abort = 0;
centerimage = attimage{imagenums};
%[look,lookFs] = audioread('sounds/look.wav');
[attsound_ref, attsound_fs] = audioread(centerimage{3});

beep=MakeBeep(500,0.25);
endbeep = MakeBeep(1000,0.25);
Snd('Open');

% timing start
t0 = GetSecs;
t2 = t0;

fixationReport=[];
fixationReport=[fixationReport;{t2, 'AttGrab-','-', 'start',0}];

cumuLookCenter = 0;
centerLook = 0;
atttime = 0;
lefttime = 0;
centertime = 0;
righttime = 0;
offtime = 0;
tempofftime = 0;
cumuLookLeft = 0;
leftLook = 0;
cumuLookRight = 0;
rightLook =0;

Screen('CopyWindow',blank,window);
Screen('flip',window);

Snd('Play',beep); % play beep sound.

% display center image
Screen('PutImage',window,centerimage{1},centerlocation);
Screen('flip',window);
imageflip = 2;

flipNum = 0;
soundnum = 0;

gPauseState = {0,0,0};
while 1 % start a loop
    [isGlobalPaused, gPauseState, ~] = getGlobalPauseState(gPauseState);
    while isGlobalPaused
        [isGlobalPaused, gPauseState, timeoutRemaining] = getGlobalPauseState(gPauseState);
        fprintf('Global pause in effect. Press Space Bar to Release. Timeout in %f seconds.\n', timeoutRemaining);
    end
    flipNum = flipNum + 1;
    t1=t2;
    WaitSecs(sampling);
    t2 = GetSecs;
    dt = t2-t1;
    %dt = dt *1000; % convert from ms to s
    [response,responseText,abort,fixationReport,lefttime,centertime,righttime,offtime,tempofftime] = getInput(vid,fixationReport,t2,lefttime,centertime,righttime,offtime,tempofftime,'AttGrab-','-','-',dt,outputfile,outputfilesummary);
    
    if strcmp(response,'c')
        cumuLookCenter = cumuLookCenter + dt;
        centerLook = centerLook +dt;
        %fprintf('Center Look: %d\n',cumuLookCenter);
        % add to center_vec
    elseif strcmp(response,'a')
        abort = 1;
        break;
    else
        centerLook = 0; % reset looking time
        %fprintf('No Look\n');
    end
    
    if mod(flipNum,60) == 0
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
            sound(attsound_ref,attsound_fs);
            soundnum = 1;
        else
            %sound(look,lookFs);
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
    
    imageflip = 2;
    flipNum = 0;
    soundnum = 0;
    
    Screen('CopyWindow',blank,window);
    Screen('flip',window);
    % display left stim
    Snd('Play',beep); % play beep sound.
    
    Screen('PutImage',window,[0,0,0],centerlocation);  % place a black square in the middle to hide the center square which might attract some babies attention
    Screen('flip',window);
    
    gPauseState = {0,0,0};
    while 1 % start a loop
        [isGlobalPaused, gPauseState] = getGlobalPauseState(gPauseState);
        [isGlobalPaused, gPauseState, ~] = getGlobalPauseState(gPauseState);
        while isGlobalPaused
            [isGlobalPaused, gPauseState, timeoutRemaining] = getGlobalPauseState(gPauseState);
            fprintf('Global pause in effect. Press Space Bar to Release. Timeout in %f seconds.\n', timeoutRemaining);
        end
        flipNum = flipNum + 1;
        t1=t2;
        WaitSecs(sampling);
        t2 = GetSecs;
        dt = t2-t1;
        
        if mod(flipNum,30) == 0
            if imageflip == 1
                Screen('PutImage',window,redSquare,leftlocation);
                Screen('PutImage',window,[0,0,0],centerlocation);  % place a black square in the middle to hide the center square which might attract some babies attention
                %Screen('PutImage',window,calebrationstim,leftlocation);
                Screen('flip',window);
                imageflip = 2;
            else
                Screen('PutImage',window,blank,leftlocationred);
                Screen('PutImage',window,[0,0,0],centerlocation);  % place a black square in the middle to hide the center square which might attract some babies attention
                Screen('PutImage',window,calebrationstim,leftlocation);
                Screen('flip',window);
                imageflip = 1;
            end
        end
        %Screen('PutImage',window,redSquare,leftlocationred);
        %Screen('PutImage',window,calebrationstim,leftlocation);
        %Screen('PutImage',window,blank,rightlocation);
        
        
        %while 1
        
        %WaitSecs(sampling);
        %dt = dt *1000; % convert from ms to s
        [response,responseText,abort,fixationReport,lefttime,centertime,righttime,offtime,tempofftime] = getInput(vid,fixationReport,t2,lefttime,centertime,righttime,offtime,tempofftime,'AttGrab-','-','-',dt,outputfile,outputfilesummary);
        
        if strcmp(response,'r')
            cumuLookLeft = cumuLookLeft + dt;
            leftLook = leftLook +dt;
            %fprintf('Center Look: %d\n',cumuLookCenter);
        elseif strcmp(response,'a')
            abort = 1;
            break;
        else
            leftLook = 0; % reset looking time
            %fprintf('No Look\n');
        end
        
        if leftLook > 2 % if baby's looked at the left for five seconds then move forward
            atttime = atttime + cumuLookLeft;
            Snd('Play',endbeep); % play beep sound.
            break
        end
        
    end
    
    imageflip = 2;
    flipNum = 0;
    soundnum = 0;
    
    Screen('CopyWindow',blank,window);
    Screen('flip',window);
    
    Screen('PutImage',window,[0,0,0],centerlocation);  % place a black square in the middle to hide the center square which might attract some babies attention
    Screen('flip',window);
    
    % display right stim
    Snd('Play',beep); % play beep sound.
    
    gPauseState = {0,0,0};
    while 1 % start a loop
        [isGlobalPaused, gPauseState, ~] = getGlobalPauseState(gPauseState);
        while isGlobalPaused
            [isGlobalPaused, gPauseState, timeoutRemaining] = getGlobalPauseState(gPauseState);
            fprintf('Global pause in effect. Press Space Bar to Release. Timeout in %f seconds.\n', timeoutRemaining);
        end
        flipNum = flipNum + 1;
        t1=t2;
        WaitSecs(sampling);
        t2 = GetSecs;
        dt = t2-t1;
        
        if mod(flipNum,30) == 0
            if imageflip == 1
                Screen('PutImage',window,redSquare,rightlocation);
                Screen('PutImage',window,[0,0,0],centerlocation);  % place a black square in the middle to hide the center square which might attract some babies attention
                %Screen('PutImage',window,calebrationstim,rightlocation);
                Screen('flip',window);
                imageflip = 2;
            else
                Screen('PutImage',window,blank,rightlocationred);
                Screen('PutImage',window,[0,0,0],centerlocation);  % place a black square in the middle to hide the center square which might attract some babies attention
                Screen('PutImage',window,calebrationstim,rightlocation);
                Screen('flip',window);
                imageflip = 1;
            end

        end
        
        %Screen('PutImage',window,blank,leftlocation);
        %Screen('PutImage',window,redSquare,rightlocationred);
        %Screen('PutImage',window,calebrationstim,rightlocation);
        
        
        if abort == 1
            break;
        end
        
        %dt = dt *1000; % convert from ms to s
        [response,responseText,abort,fixationReport,lefttime,centertime,righttime,offtime,tempofftime] = getInput(vid,fixationReport,t2,lefttime,centertime,righttime,offtime,tempofftime,'AttGrab-','-','-',dt,outputfile,outputfilesummary);
        
        if strcmp(response,'l')
            cumuLookRight = cumuLookRight + dt;
            rightLook = rightLook +dt;
            %fprintf('Center Look: %d\n',cumuLookCenter);
        elseif strcmp(response,'a')
            abort = 1;
            break;
        else
            rightLook = 0; % reset looking time
            %fprintf('No Look\n');
        end
        
        if rightLook > 2 % if baby's looked at the right for five seconds then move forward
            atttime = atttime + cumuLookRight;
            Snd('Play',endbeep); % play beep sound.
            break
        end
        
    end
    
end
