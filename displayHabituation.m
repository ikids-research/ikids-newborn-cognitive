function [abort,fixationReport] = displayHabituation(habstim, blank, triallabel, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage)
% Sum up time as a fixation (right or left) 2 sec look aways
%      allowed
% Quit when last 3 fixations are 50% length of original 3
% Use Attention Grabber when baby looks away for 5 sec
% End also if 180 sec have passed


t0=GetSecs;
t2=t0;

fixationReport=[];
fixationReport=[fixationReport;{t2, triallabel,'-', 'start',0}];


fprintf('preparing new images....\n');
Screen(window,'WaitBlanking') %wait until your gun moves to the top of the monitor. (only true for CRT monitors and analog LCDs)

Screen('CopyWindow',blank,window);
Screen('flip',window);

Screen('PutImage',window,habstim,leftlocation);
Screen('PutImage',window,habstim,rightlocation);
Screen('flip',window);

%Screen('CopyWindow',habstim,window,[XLeft YTop ThumbSize ThumbSize],[XLeftLoc Ycentre XLeftLoc+ThumbSize Ycentre+ThumbSize]);
%Screen('CopyWindow',habstim,window,[XLeft YTop ThumbSize ThumbSize],[XRightLoc Ycentre XRightLoc+ThumbSize Ycentre+ThumbSize]);

righttime = 0;
centertime = 0;
lefttime = 0;
offtime = 0;
attentiontime = 0;
tempofftime = 0; % used for finding 2 second off time
gPauseState = {0,0,0};
while 1 % start a loop
    [isGlobalPaused, gPauseState, ~] = getGlobalPauseState(gPauseState);
    while isGlobalPaused
        [isGlobalPaused, gPauseState, timeoutRemaining] = getGlobalPauseState(gPauseState);
        fprintf('Global pause in effect. Press Space Bar to Release. Timeout in %f seconds.\n', timeoutRemaining);
    end
    t1=t2; % start of experiment
    WaitSecs(sampling);% use to set the sampling rate, 60 Hz for here
    t2=GetSecs;
    dt=t2-t1; % the duration of the time press
    dt=dt*1000; % change into seconds
    % this gets a keyboard response or eyetracking response and classifies
    % it returning looking times and a fixation report.
    [response,abort,fixationReport,lefttime,centertime,righttime,offtime,tempofftime] = getInput(vid,fixationReport,t2,lefttime,centertime,righttime,offtime,tempofftime,'Habituation-',triallabel,place,dt); 
    
    if abort == 1
        break;
    end
    
    if tempofftime > 5000 % if baby has looked away for more than 5 seconds call up the attention grabber
        [abort,atttime] = attentionAndCalebration(false,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling);
        attentiontime = attentiontime + atttime;
        tempofftime = 0;
    end
    if abort == 1 % if you've found an abort, break out of the loop
        break;
    end
    if lefttime + righttime > 10000
        break;
    end
end

% blank the screen
Screen('CopyWindow',blank,window);
Screen('flip',window);

%Screen('CopyWindow',blank,window,[XLeft YTop ThumbSize ThumbSize],[XLeftLoc Ycentre XLeftLoc+ThumbSize Ycentre+ThumbSize]);
%Screen('CopyWindow',blank,window,[XLeft YTop ThumbSize ThumbSize],[XRightLoc Ycentre XRightLoc+ThumbSize Ycentre+ThumbSize]);


%write data from second trial

%dataFileName = ['data\' subject '\FixationReport' '_' num2str(TrialIndex) '_' num2str(session) '_Task1' '.xls'];
%fixationReport=[{'time','session','location','AOI','duration'};fixationReport];
%xlswrite(dataFileName, fixationReport);

% calculate total looking time

totallooktime = righttime + centertime + lefttime + offtime + attentiontime;

fprintf(['Habituation-',num2str(triallabel), ' look report \n']);
fprintf(['Look\tTime\tPercentage']);
fprintf(['Right time:\t',num2str(righttime), '\t', num2str(righttime/totallooktime)]);
fprintf(['Center time:\t',num2str(centertime), '\t', num2str(centertime/totallooktime)]);
fprintf(['Left time:\t',num2str(lefttime), '\t', num2str(lefttime/totallooktime)]);
fprintf(['Off time:\t',num2str(offtime), '\t', num2str(offtime/totallooktime)]);
fprintf(['AttGrab time:\t',num2str(attentiontime), '\t', num2str(attentiontime/totallooktime)]);
