function [abort,fixationReport] = displayTwoImages(trialtype,leftstim,rightstim, blank, triallabel, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage,outputfile,outputfilesummary)
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


%Screen('CopyWindow',habstim,window,[XLeft YTop ThumbSize ThumbSize],[XLeftLoc Ycentre XLeftLoc+ThumbSize Ycentre+ThumbSize]);
%Screen('CopyWindow',habstim,window,[XLeft YTop ThumbSize ThumbSize],[XRightLoc Ycentre XRightLoc+ThumbSize Ycentre+ThumbSize]);

righttime = 0;
centertime = 0;
lefttime = 0;
offtime = 0;
attentiontime = 0;
tempofftime = 0; % used for finding 2 second off time
totaltime = 0;
fixationlist = []; % used to list fixations for habituation
tempfixation = 0;
breaklist = [];
tempbreak = 0;
fixationbreaklist = {};

start = 1; % to denote the starting loop

Screen('PutImage',window,leftstim,leftlocation);
Screen('PutImage',window,rightstim,rightlocation);
Screen('PutImage',window,[0,0,0],centerlocation);  % place a black square in the middle to hide the center square which might attract some babies attention
Screen('flip',window);

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
    %dt=dt*1000; % change into seconds
    % this gets a keyboard response or eyetracking response and classifies
    % it returning looking times and a fixation report.
    [response,responseText,abort,fixationReport,lefttime,centertime,righttime,offtime,tempofftime] = getInput(vid,fixationReport,t2,lefttime,centertime,righttime,offtime,tempofftime,'Habituation-',triallabel,place,dt,outputfile,outputfilesummary);     
    
    if abort == 1
        break;
    end
    
    totaltime = totaltime + dt;
    
    
    if abort == 1 % if you've found an abort, break out of the loop
        break;
    end
    
	if totaltime > 180
        break;
    end
    if strcmp(trialtype,'hab')
        
        if tempbreak > 2 && tempfixation > 0 % if baby has looked away for longer than two seconds then end fixation and record in fixation list
            fixationlist = [fixationlist,tempfixation];
            fprintf(['fixation finished: ', num2str(tempfixation),'\n']);
            tempfixation = 0;
            tempbreak = 0;
            
        elseif strcmp(response,'l') || strcmp(response, 'r')
            tempbreak = 0;
            tempfixation = tempfixation + dt;
        elseif strcmp(response,'n')
            tempbreak = tempbreak + dt;
        end
        
        if length(fixationlist) >= 6 % if there are at least 6 fixations, calculate the ending possible criteria
            firstthree = sum(fixationlist(1:3));
            habcriteria = firstthree * .5; % criteria is 50% of the original three looking times
            lastthree = sum(fixationlist(length(fixationlist)-2:length(fixationlist)));
            if lastthree < habcriteria % the baby has habituated if their last three looks are less than 50% of the original
                fprintf(['first three: ',firstthree,'\n']);
                fprintf(['hab criteria: ',habcriteria,'\n']);
                fprintf(['last three: ',lastthree,'\n']);
                break;
            end
        end
    else
        % it is a test trial so wait 20 seconds or 180 total
        if lefttime + righttime + centertime + offtime > 20
            break;
        end
    end
    
    if tempofftime > 2 % if baby has looked away for more than 2 seconds call up the attention grabber
        [abort,atttime,centerLook] = attentionAndCalebration(false,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,totaltime,outputfile,outputfilesummary);
        attentiontime = attentiontime + atttime;
        tempofftime = 0;
        % put back on the images for the trial
        Screen('PutImage',window,leftstim,leftlocation);
        Screen('PutImage',window,rightstim,rightlocation);
        Screen('flip',window);
        totaltime = totaltime + atttime;
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

fprintf([num2str(trialtype),'-',num2str(triallabel), ' look report \n']);
fprintf(['Look\t\t\t\tTime\t\tPercentage\n']);
fprintf(['Baby''s Left time:\t',num2str(righttime), '\t\t', num2str(round((righttime/totallooktime) *100),2.1),'\n']);
fprintf(['Center time:\t\t',num2str(centertime), '\t\t', num2str(round((centertime/totallooktime) *100),2.1),'\n']);
fprintf(['Baby''s Right time:\t',num2str(lefttime), '\t\t', num2str(round((lefttime/totallooktime) *100),2.1),'\n']);
fprintf(['Off time:\t\t\t',num2str(offtime), '\t\t', num2str(round((offtime/totallooktime) *100),2.1),'\n']);
fprintf(['AttGrab time:\t\t',num2str(attentiontime),'\n']);


fprintf(outputfilesummary,[num2str(trialtype),'-',num2str(triallabel), ' look report \n']);
fprintf(outputfilesummary,['\tLook\t\t\t\tTime\t\tPercentage\n']);
fprintf(outputfilesummary,['\tBaby''s Left time:\t',num2str(righttime), '\t\t', num2str(round((righttime/totallooktime) *100),2.1),'\n']);
fprintf(outputfilesummary,['\tCenter time:\t\t',num2str(centertime), '\t\t', num2str(round((centertime/totallooktime) *100),2.1),'\n']);
fprintf(outputfilesummary,['\tBaby''s Right time:\t',num2str(lefttime), '\t\t', num2str(round((lefttime/totallooktime) *100),2.1),'\n']);
fprintf(outputfilesummary,['\tOff time:\t\t\t',num2str(offtime), '\t\t', num2str(round((offtime/totallooktime) *100),2.1),'\n']);
fprintf(outputfilesummary,['\tAttGrab time:\t\t',num2str(attentiontime),'\n']);


fprintf('Press Any Key to Continue.\n');
WaitSecs(2);
FlushEvents('keyDown');
KbWait();