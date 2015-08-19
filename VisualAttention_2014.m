% Newborn Visual Attention Task 2015
% Last updated 8-11-2015 by Kevin Horecka

% Clear previous state information to create clean slate
clear all; clc; close all;

% Skip video synchronization test (see http://docs.psychtoolbox.org/Screen
% for more details)
Screen('Preferences','SkipSyncTests',1);

fprintf('Getting subject information... ');
% Get Start Up Info or recover a subject's info
subjectInfoStructure = getSubjectInfoUI();
if isempty(output)
    error('Form was cancelled - quitting.');
end
[subject, birthdate, birthtime, sex, age, experimentdate, ...
 experimenter_baby, experimenter_computer, place, session, ...
 condition, outputfile, outputfilesummary] = ...
    convertNewSubjectStructToOld(output);
fprintf('Done.\n');

fprintf('Loading Materials... ');
% start up all of the materials needed for the program
[sampling, attimage, habstim1, habstim2, stim1_1, stim1_2, stim2_1, stim2_2,...
    blank, vid, center_vec,centerlocation,leftlocation, rightlocation, window,triallabels,redSquare] = loadMaterials(condition);
fprintf('Done.\n');

global redSquare

abort = false;

ListenChar(2); % hids keypresses from matlab command window


% Wait till experimenter is ready then start experiment
fprintf('Press Any Key to Start.\n');
WaitSecs(1);
FlushEvents('keyDown');
KbWait();

% Major experimental loop
while ~abort % continue until the end of the trial or until an abort key is pressed
    disp('test');
    %[abort,atttime] = attentionAndCalebration(true); % display attention grabber and use for eye calebration
    if abort == true; break; end
    
    % Depending on condition display face or pattern then do the reverse

% First Block
    % Habituation
    if place == 1 % habituation block

        fprintf('first hab block\n');
        %Attention grabber and calebration
        [abort,attimeHab1,centerLookHab1] = attentionAndCalebration(true,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,0,outputfile,outputfilesummary,habstim1);
        if abort == true; break; end
        [abort,fixationReportHab1] = displayTwoImages('hab',habstim1,habstim1, blank, triallabels{1}, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage,outputfile,outputfilesummary);
        if abort == true; break; end
        place = place + 1;
        

%     %Test Trial original
%     elseif place == 2
%         fprintf('test 1 block\n');
%         if abort == true; break; end
%         place = place + 1;
        

    %Test Trial original
    elseif place == 2
        fprintf('test 1 block\n');

        % Attention Grabber
        [abort,att2time,centerLookTest1_1] = attentionAndCalebration(false,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,0,outputfile,outputfilesummary,habstim1);
        if abort == true; break; end
        % Present novel and familiar using attention grabber as necessary;
        % end when stim presented for 20 sec
        [abort,test11time] = displayTwoImages('test',stim1_1, stim1_2, blank, triallabels{2}, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage,outputfile,outputfilesummary);
        if abort == true; break; end
        place = place + 1;
        
    %Test Trial reversed
    elseif place == 3
        % Attention Grabber
        fprintf('test 2 block\n');
        [abort,att3time,centerLookTest1_2] = attentionAndCalebration(false,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,0,outputfile,outputfilesummary,habstim1);
        if abort == true; break; end
        % Present novel and familiar flipped using attention grabber as
        % necessary; end when stim presented for 20 sec
        [abort,test12time] = displayTwoImages('test',stim1_2, stim1_1, blank, triallabels{3}, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage,outputfile,outputfilesummary);
        if abort == true; break; end
        place = place + 1;
    
% Second Block
    % Habituation
    elseif place == 4 % habituation block
        %Attention grabber and calebration
        fprintf('second hab block\n');
        [abort,att4time,centerLookHab2] = attentionAndCalebration(true,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,0,outputfile,outputfilesummary,habstim2);
        if abort == true; break; end
        [abort,hab2time] = displayTwoImages('hab',habstim2,habstim2,blank, triallabels{4}, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage,outputfile,outputfilesummary);
        if abort == true; break; end
        % Sum up time as a fixation (right or left) 2 sec look aways
        %      allowed
        % Quit when last 3 fixations are 50% length of original 3
        % Use Attention Grabber when baby looks away for 5 sec
        % End also if 180 sec have passed
        place = place + 1;

    %Test Trial original
    elseif place == 5
        % Attention Grabber
        fprintf('test 1 block\n');
        [abort,att5time,centerLookTest1_1] = attentionAndCalebration(false,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,0,outputfile,outputfilesummary,habstim2);
        if abort == true; break; end
        % Present novel and familiar using attention grabber as necessary;
        % end when stim presented for 20 sec
        [abort,test21time] = displayTwoImages('test',stim2_1, stim2_2,blank, triallabels{5}, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage,outputfile,outputfilesummary);
        if abort == true; break; end
        place = place + 1;
        
    %Test Trial reversed
    elseif place == 6
        % Attention Grabber
        fprintf('test 2 block\n');
        [abort,att6time,centerLookTest1_2] = attentionAndCalebration(false,vid,attimage,window,centerlocation,leftlocation,rightlocation,blank,sampling,0,outputfile,outputfilesummary,habstim2);
        if abort == true; break; end
        % Present novel and familiar flipped using attention grabber as
        % necessary; end when stim presented for 20 sec
        [abort,test22time] = displayTwoImages('test',stim2_2,stim2_1,blank, triallabels{6}, place, vid, window,centerlocation,leftlocation,rightlocation,sampling,attimage,outputfile,outputfilesummary);
        place = place + 1;
        
    elseif place == 7
        %abort = true;
        %clear screen
        break;
    end
end

if abort == true
    % make a recovery file
    formatString = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
    recoveryNameFile = ['data/',subject,'/',subject,'_recovery.txt'];
    recoveryFile = fopen(recoveryNameFile, 'w');
    fprintf(recoveryFile, formatString, subject, age, sex, experimentdate, session, birthday, birthtime, num2str(place),experimenter_baby,experimenter_computer,condition);
end
    
fprintf('Experiment complete or aborted\n');
clear screen
ListenChar(0); % shows keypresses from matlab command window

fclose('all');

