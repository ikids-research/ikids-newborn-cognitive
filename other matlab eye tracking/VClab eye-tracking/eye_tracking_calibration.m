function eye_tracking_calibration
%% INITIALIZE FUNCTIONS AND VARIABLES *************************************************************

% Close all open figures and PTB screens
clear all class mex java; close all force hidden; Screen('CloseAll');
% Choose a new stream for number randomization
RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', sum(100*clock)));
% configure DAQ board (eye signal) [analog input] -------------------------------------------------
daqreset;
ai = analoginput('nidaq','Dev1');
addchannel(ai,[0 1]);
ai.SampleRate = 1000;
ai.Channel.UnitsRange = [-5 5];
ai.Channel.SensorRange = [-5 5];
ai.Channel.InputRange = [-5 5];
ai.SamplesPerTrigger = 2;
ai.TriggerRepeat = 0;
% DAQ board (reward) [digital output] -------------------------------------------------------------
dio = digitalio('nidaq', 'Dev1');
addline(dio, 0, 'out'); putvalue(dio, 0);
% PsychToolbox functions and preferences ----------------------------------------------------------
WaitSecs(0.1); GetSecs;
Screen('Preference', 'VisualDebugLevel', 0, 'SuppressAllWarnings', 1);
% PTB keyboard check for pressed keys
keylist = zeros(1, 256);
    keylist(81) = 1; % This is "q" key
KbQueueCreate([], keylist);

%% TASK PARAMETERS ********************************************************************************
Subject = 'monkey';

Eye = 'left';

% The allData variable stores 2 analog signals: EyeDataX and EyeDataY;
% the analog sources of these signals have to be written here in the same order. 
AnalogSignalsSource = {'P-CR Hori'; 'P-CR Vert'};

intertrial_interval  = 7;
wait4fix           = 2;
time4fix             = .2;
FixationWindowRadius = 2;
totaltrials          = 1;
% Gain and offset
Xgain   = 10;
Xoffset = 0;
Ygain   = 10;
Yoffset = 0;
% Choose positions to show (1 is the central one, 2 to 9 from right in counterclockwise manner)
pos2show = [1 2 4 6 8];
BufferLength = 25; % in samples

% Fixations Points parameters ---------------------------------------------------------------------
StimSize     = 20; % size of the stimuli in pixels
eccentricity = 6;  % distance of the stimuli from the center in degrees
angs = [0 45 90 135 180 225 270 315]; % all positions (in degrees)

%% SCREEN PARAMETERS ******************************************************************************
screensize_pix = [1280 1024];    % screen resolution
screensize_cm  = [36 28.8];      % screen size in cm
screendistance = 65;             % viewing distance in cm 
% Calculate Pixels/Degree ratios
pixcm = mean(screensize_cm ./ screensize_pix); % size of a pixel in cm
pixdeg = atand(pixcm/screendistance);          % size of a pixel in degrees
degpix = 1/pixdeg;                             % size of a deg in pixels
    screensize_vdeg = atand(screensize_cm./screendistance); % size of screen in degrees
radians = (angs./360.*(2*pi))';           % convert degrees to radians
coors(:,1) = cos(radians)*eccentricity;   % Calculate all x coordinates
coors(:,2) = sin(radians)*eccentricity;   % Calculate all y coordinates
pixs = degpix.*coors;                     % Convert angles to pixels
pixs = ceil(.5+pixs);                     % round up size of dots in pixel
TargetPos = [0 0; coors];                 % Add central fixation target
centerX = screensize_pix(1)/2;            % Calculate the center of the screen (X)
centerY = screensize_pix(2)/2;            % Calculate the center of the screen (Y)
X1 = centerX - StimSize/2;                % Coordinates of rectangles corners
    X2 = centerX + StimSize/2;
Y1 = centerY - StimSize/2;
    Y2 = centerY + StimSize/2;
% Coordinates of the targets (centers and rectangles)
fCenter = [centerX, centerY];
fRect = [X1, Y1, X2, Y2];
for n = 1:8
    fCenter(n+1,:) = pixs(n,:)+[centerX centerY];
    fRect(n+1,:) =  [X1+(pixs(n,1)),Y1-(pixs(n,2)),X2+(pixs(n,1)),Y2-(pixs(n,2))];
end
% Divide targets presentations evenly among trials
repetitions = floor(totaltrials/numel(pos2show));
presentation_vec = repmat(pos2show,1,repetitions);
presentation_vec = [presentation_vec pos2show(randi(length(pos2show),1,totaltrials-length(presentation_vec)))];
% Shuffle order of presetations
presentation_vec = presentation_vec(randperm(length(presentation_vec)));
%% EXPERIMENTER DISPLAY
% Screen and figure parameters
bgnColor = get(0,'DefaultUIControlBackgroundColor');
figWidth = 1000; figHeight = 700;
figPos = [1 screensize_pix(2)-figHeight-20 figWidth figHeight];
% Create the figure
figure('Color',bgnColor,'MenuBar','none','Name','Eye Position','NumberTitle','off','Position',figPos);
% Create data plot
plot_size = 16.5;
    Xaxeslim =[-round(screensize_vdeg(1)/2) round(screensize_vdeg(1)/2)]; Xaxeslim = [floor(Xaxeslim(1)/10)*10 ceil(Xaxeslim(2)/10)*10];
    Yaxeslim =[-round(screensize_vdeg(2)/2) round(screensize_vdeg(2)/2)]; Yaxeslim = [floor(Yaxeslim(1)/10)*10 ceil(Yaxeslim(2)/10)*10];
hAxes = axes('Units','centimeters','Position',[1.5 1.5 plot_size plot_size],    ...
             'Box','on','XTick',Xaxeslim(1):10:Xaxeslim(2),'YTick',Yaxeslim(1):10:Yaxeslim(2));
        % Draw grid
        for ii = Xaxeslim(1)+10:10:Xaxeslim(2)-10
            if ii == 0
                line([ii ii],[Yaxeslim(1) Yaxeslim(2)],'color',[.4 .4 .4],'linestyle',':')
            else
                line([ii ii],[Yaxeslim(1) Yaxeslim(2)],'color',[.7 .7 .7],'linestyle',':')
            end
        end
        for ii = Yaxeslim(1)+10:10:Yaxeslim(2)-10
            if ii == 0
                line([Xaxeslim(1) Xaxeslim(2)],[ii ii],'color',[.4 .4 .4],'linestyle',':')
            else
                line([Xaxeslim(1) Xaxeslim(2)],[ii ii],'color',[.7 .7 .7],'linestyle',':')
            end
        end
        % Draw lines corresponding to the edges of the screen
        screen_edge_coors = atand([-screensize_cm(1)/2 screensize_cm(1)/2 ;...
                                   -screensize_cm(2)/2 screensize_cm(2)/2 ] ./screendistance);
        line([screen_edge_coors(1,1) screen_edge_coors(1,1)],[screen_edge_coors(2,1) screen_edge_coors(2,2)],'color','k')
        line([screen_edge_coors(1,2) screen_edge_coors(1,2)],[screen_edge_coors(2,1) screen_edge_coors(2,2)],'color','k')
        line([screen_edge_coors(1,1) screen_edge_coors(1,2)],[screen_edge_coors(2,1) screen_edge_coors(2,1)],'color','k')
        line([screen_edge_coors(1,1) screen_edge_coors(1,2)],[screen_edge_coors(2,2) screen_edge_coors(2,2)],'color','k')
        % Axes properties
        axis equal;  hold on;
        set(hAxes,'XLim',Xaxeslim,'YLim',Yaxeslim); % Must be declared after "axis equal"
        xlabel('X [degrees]'); ylabel('Y [degrees]');
        
% Plot all the positions of the stimuli
DOTsize_cm = pixcm * StimSize;
DOTsize_deg = atand(DOTsize_cm / screendistance);
targetradius = (plot_size / abs(max([diff(Xaxeslim) diff(Yaxeslim)])) * DOTsize_deg) /2.54*72; % "/2.54" is for converting cm to in, "*72" from inches to points
plot(TargetPos(:,1),TargetPos(:,2),'ks','markersize',mean(targetradius));
Htarget = plot(NaN,NaN,'gs','markersize',mean(targetradius));
% Current eye position
eyeX = NaN; eyeY = NaN;
    Hgaze = plot(eyeX,eyeY,'+','Color','b');
% Current stimulus fixation window
markerradius = (plot_size / abs(max([diff(Xaxeslim) diff(Yaxeslim)])) * 2*FixationWindowRadius) /2.54*72; % "/2.54" is for converting cm to in, "*72" from inches to points
Hfixwin = line('XData',NaN,'YData',NaN,'marker','o', 'markersize', markerradius,'linestyle','none');
% Check if the fixation window radius is larger than the distance between % targets (i.e. check if fixation windows are overlapping)
chord = abs(2*eccentricity*sin(angs(2)/2));
if chord > FixationWindowRadius *2
    str_msg = 'NON-overlapping windows'; % or "Mutually exclusive fixation windows"
else
    str_msg = 'Overlapping windows'; % or "Non-mutually exclusive fixation windows'
end

% Write task info and acquisition parameters in the blank area of the figure
htext(1) = text(22,15,'...','fontsize',13);
text(22,19,sprintf('%s (%i trials)',Subject,totaltrials),'fontsize',13);
text(22,0,sprintf('Gain X = %1.0f; Y = %1.0f\nOffset X = %1.2f; Y = %1.2f\n\nFixation window radius: %1.0f°\nEccentricity: %1.0f°\n[%s]\nFixation time: %1.1f seconds\n\nStimulus size: %i pixels\n\nBuffer length: %1.0f samples\n\nSignals: %s (in EyeDataX)\n              %s (in EyeDataY)',Xgain,Ygain,Xoffset,Yoffset,FixationWindowRadius,eccentricity,str_msg,time4fix,StimSize,BufferLength,AnalogSignalsSource{1},AnalogSignalsSource{2}),'fontsize',13);
reminder = text(22,-15,'Press "q" to quit task at ITI end','fontsize',15,'color','r','visible','off');
%% PRE-ALLOCATION AND PSYCHTOOLBOX INTITIALIZATION
% PsychToolbox initialization ---------------------------------------------------------------------
[window] = Screen('OpenWindow',2);
% Blank screen
b = Screen('OpenOffscreenWindow',window);
% Central fixation spot
pf(1) = Screen('OpenOffscreenWindow',window);
	Screen('FillRect',pf(1),[0 0 0],fRect(1,:));
% Peripheral fixation spots
for i = 1:size(coors,1)
    pf(i+1) = Screen('OpenOffscreenWindow',window); %#ok<*AGROW>
        Screen('FillRect',pf(i+1),[0 0 0],fRect(i+1,:));
end
try %#ok<*TRYNC>
% Pre-allocation ----------------------------------------------------------------------------------
allData(1:totaltrials) = struct();
% Time and signals vector will be initialized with this many samples
AnalogSignalsPrealloctionLength = 1e4;

% Some fields are initialized with NaN so if that event does not occur you'll still find NaN during concatenation
[allData.Subject]             = deal(Subject);                 % monkey name
[allData.Task]                = deal('calibration_CRT');       % task name
[allData.Eye]                 = deal(Eye);                     % Recorded eye
[allData.Date]                = deal(NaN);                     % date
[allData.SampleRate]          = deal(ai.SampleRate);
[allData.TargetPos]           = deal(TargetPos);               % Coordinates of target positions
[allData.CurrentPosition]     = deal(NaN);                     % Current shown target
[allData.FixationWin]         = deal(FixationWindowRadius);
[allData.FixationTime]        = deal(time4fix);
[allData.StimulusSize_pix]    = deal(StimSize);
[allData.StimulusSize_deg]    = deal(DOTsize_deg);
[allData.Gain]                = deal([Xgain; Ygain]);
[allData.Offset]              = deal([Xoffset; Yoffset]);
[allData.BufferLength]        = deal(BufferLength);
[allData.FixPointOn]          = deal(NaN);                     % Time when FP was presented
[allData.FixStart]            = deal(NaN);                     % Time when fixation was acquired
[allData.FixEnd]              = deal(NaN);                     % Time when fixation was interrupted
[allData.FixPointOff]         = deal(NaN);                     % Time when FP waas set off
[allData.EndTrial]            = deal(NaN);                     % Time of trial end
[allData.Correct]             = deal(NaN);                     % -1: No fixation; 0: fixation broken; 1: Correct trial
[allData.Reward]              = deal(NaN);                     % Time when reward was delivered
[allData.AnalogSignalsSource] = deal([AnalogSignalsSource {'EyeDataX';'EyeDataY'}]);
[allData.Time]                = deal(NaN(AnalogSignalsPrealloctionLength,1));              % Time vector
[allData.EyeDataX]            = deal(NaN(AnalogSignalsPrealloctionLength,1));
[allData.EyeDataY]            = deal(NaN(AnalogSignalsPrealloctionLength,1));
        
% Initialize acquisition and go in streaming only mode
start(ai);
WaitSecs(.5);
clc; % Clear command window
for trialcounter = 1:totaltrials
    % Analog signals and time vector are initialized here so you don't move around the structure in for loops
    Time = NaN(AnalogSignalsPrealloctionLength,1);
        EyeDataX = Time; EyeDataY = Time;
        index = 1; % this is the row where to save the last sample's information; it's initialized here and increased every time the buffer is called and used
        
    CircBuffer = zeros(BufferLength,2); % Initialize buffer
    % print in command window the current trial info
    fprintf(['Trial ' num2str(trialcounter) ': '])
    for currtrial = true
        % Choose Fixation location and highlight it in red
        curpos = presentation_vec(trialcounter);
            allData(trialcounter).CurrentPosition = curpos;
            set(Htarget,'XData',TargetPos(curpos,1),'YData',TargetPos(curpos,2));
        % All acquired data of this trial are referenced to this time point
        allData(trialcounter).Date = clock; TrialStart = GetSecs;
        
        % INTERTRIAL INTERVAL *********************************************************************
        % Start queuing keypresses on keyboard
        set(reminder,'visible','on');
            KbQueueStart();
        % Update info on Experimenter Display
        set(htext(1),'String',['Intertrial Interval (' num2str(intertrial_interval) 's)']);
        set(Hfixwin,'XData',-1000,'YData',-1000); % Move fixation window outside of display range
        set(Hgaze,'Color','b'); % Reset to blue the color of gaze position's marker
        drawnow;
        % "Main loop" -----------------------------------------------------------------------------
        startLoop = GetSecs;
        while GetSecs - startLoop < intertrial_interval
            bufferizeSamples
        end
        % Check if user pressed "q" key only once, at ITI end -------------------------------------
        UserInvokedQuit = KbQueueCheck;
        KbQueueStop(); KbQueueFlush(); % From now on stop checking keypresses
            set(reminder,'visible','off');
        if UserInvokedQuit
            break
        end
        
        % FIXATION ACQUISITION ********************************************************************
        % Update info on Experimenter Display
        set(htext(1),'String','Waiting for fixation');
        set(Hfixwin,'XData',TargetPos(curpos,1),'YData',TargetPos(curpos,2)); % Show fixation window
        % Show fixation target
        Screen('WaitBlanking',window); Screen('CopyWindow',pf(curpos),window);
            [~,~,flipTS] = Screen('Flip', window);
            allData(trialcounter).FixPointOn = flipTS - TrialStart;
        AcquiredFixation = false; % Fixation is not yet acquired
        startLoop = GetSecs;
        while GetSecs - startLoop < wait4fix
            bufferizeSamples
            % Check for fixation (i.e. if the distance is less than fixation window radius, the subject is looking at the target)
            if sqrt((TargetPos(curpos,1)-eyeX)^2 + (TargetPos(curpos,2)-eyeY)^2) <= FixationWindowRadius
                % Fixation is started; store the event
                AcquiredFixation = true; 
                allData(trialcounter).FixStart = GetSecs - TrialStart;
                break
            end
        end
        if ~AcquiredFixation
            fprintf('No fixation\n'); set(htext(1),'String','...');
            % Show blank screen
            Screen('WaitBlanking',window); Screen('CopyWindow',b,window);
                [~,~,flipTS] = Screen('Flip', window); 
            allData(trialcounter).FixPointOff = flipTS - TrialStart;
            allData(trialcounter).Correct    = -1;
            break
        end

        % MAINTAIN FIXATION ***********************************************************************
        % Update info on Experimenter Display -----------------------------------------------------
        set(htext(1),'String','Maintain Fixation');
        set(Hgaze,'Color','r'); % Change color of gaze position's marker
        FixationHold = true; % Initialize fixation status
        startLoop = GetSecs;
        while GetSecs - startLoop < time4fix
            bufferizeSamples
            % Check for fixation (i.e. if the distance is more than the radius of the fixation window, the subject is not looking anymore at the target)
            if sqrt((TargetPos(curpos,1)-eyeX)^2 + (TargetPos(curpos,2)-eyeY)^2) > FixationWindowRadius
                % Fixation is lost; store the event
                FixationHold = false;                
                allData(trialcounter).Correct = 0;
                fprintf('Fixation broken\n');
                break
            end
        end
        % Save timestamp of fixation end ----------------------------------------------------------
        allData(trialcounter).FixEnd = GetSecs - TrialStart;
        % Show blank screen
        Screen('WaitBlanking',window); Screen('CopyWindow',b,window);
            [~,~,flipTS] = Screen('Flip', window);
            allData(trialcounter).FixPointOff = flipTS - TrialStart;
        % Check trial outcome
        if FixationHold
            allData(trialcounter).Correct = 1;
            fprintf('Good fixation\n')
            % Deliver reward (set digital state to "High" and then "Low")
            putvalue(dio.Line(1),1); pause(.1); putvalue(dio.Line(1),0);
            % Here you can add an auditory feedback for correct trials
        end
        % Update info on Experimenter Display
        set(htext(1),'String','Ending trial');
    end % of trial
    
    % Remove  green square from plot
    set(Htarget,'XData',NaN,'YData',NaN);
    % Mark end of trial
    allData(trialcounter).EndTrial = GetSecs - TrialStart;
    
    % Remove all NaN from pre-allocated fields ('index-1' because last 'index' is not associated with any sample)
    allData(trialcounter).EyeDataX = EyeDataX(1:index-1);
    allData(trialcounter).EyeDataY = EyeDataY(1:index-1);
    allData(trialcounter).Time     = Time((1:index-1)) - TrialStart;
    
    % If user pressed "q", quit task and save data
    if UserInvokedQuit
        break
    end
end
catch ME % in case of any error
    % Show error and store it in MATLAB workspace. Data are stored in any case
    clc;
    assignin('base','ERROR',ME)
    fprintf('Task aborted for at the line %i for the following error:\n%s\n',ME.stack.line,ME.message)
end

%% SAVE DATA **************************************************************************************
% Go to the folder and make a new directory there
save_dir = ['C:\',Subject];
    if ~exist(save_dir,'dir'); mkdir(save_dir); end
    cd(save_dir)
    new_dir = datestr(now,'yyyy-mm-dd');
    if ~exist([save_dir '\' new_dir],'dir')
        mkdir([save_dir '\' new_dir]);
    end
    cd(strcat(save_dir,'\',new_dir));
% Data are saved as "block_<number>"
list = dir(fullfile(strcat(save_dir,'\',new_dir),'block*'));
    blknms = {list.name};
    save([save_dir '\' new_dir '\' 'block_' num2str(numel(blknms)+1) '.mat'],'allData');    
% Check from MATLAB window if file is available in folder (i.e. was correctly saved); anyway store "allData" in MATLAB workspace
filebrowser;
    assignin('base','allData',allData);
% Stop whatever is still runing
stop(ai); daqreset;
Screen('CloseAll'); KbQueueRelease();
 close all force hidden;

% *************************************************************************************************
% CIRCULAR BUFFER *********************************************************************************
function bufferizeSamples
    % Put together information for this sample ----------------------------------------------------
    timestamp = GetSecs;
    thisSample = getsample(ai);
        EyeDataX(index)  = thisSample(1);
        EyeDataY(index)  = thisSample(2);
        Time(index)      = timestamp;
            index = index +1;
    % Drop the first data point in the buffer and add the last acquired sample --------------------
    CircBuffer = [CircBuffer(2:end,:); thisSample];
    avg_buff = mean(CircBuffer,1); % Average the buffer
    % Convert voltage values to degrees -----------------------------------------------------------
    eyeX = (avg_buff(1) - Xoffset) * Xgain;
    eyeY = (avg_buff(2) - Yoffset) * Ygain;
    % Update eye position -------------------------------------------------------------------------
    set(Hgaze,'XData',eyeX,'YData',eyeY); drawnow;
end % of "bufferizeSamples" function
end % of main function
