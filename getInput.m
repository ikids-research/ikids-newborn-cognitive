function [response,responseText,abort,fixationReport,lefttime,centertime,righttime,offtime,tempofftime] = getInput(vid,fixationReport,t2,lefttime,centertime,righttime,offtime,tempofftime,trialtype,triallabel,place,dt,outputfile,outputfilesummary)

abort = 0;


% look for keypresses
FlushEvents('keyDown');
[keyIsDown, secs, keyCode] = KbCheck;
if keyIsDown==1
%     % older code for control, option, buttons
%     if keyCode(227)==1
%         response = 'r';
%     elseif keyCode(226)==1
%         response = 'c';
%     elseif keyCode(224)==1
%         response = 'l';
%     elseif keyCode(4)==1
%         response = 'a';
%     else
%         response = 'n';
%     end
    % Whitney's computer
%     if keyCode(79)==1 % right arrow
%         response = 'l';
%         responseText = 'Baby''s Left';
%     elseif keyCode(81)==1 % down arrow  (up arrow = 82)
%         response = 'c';
%         responseText = 'Center';
%     elseif keyCode(82)==1 % up arrow  (up arrow = 82)
%         response = 'c';
%         responseText = 'Center';
%     elseif keyCode(80)==1 % left arrow
%         response = 'r';
%         responseText = 'Baby''s Right';
%     elseif keyCode(4)==1 % 'a' key for abort
%         response = 'a';
%         responseText = 'Abort';
%     else
%         response = 'n';
%         responseText = 'No Key';
%     end

% testing computer
    if keyCode(39)==1 % right arrow
        response = 'l';
        responseText = 'Baby''s Left';
    elseif keyCode(40)==1 % down arrow  
        response = 'n';
        responseText = 'No Key';
	elseif keyCode(38)==1 % up arrow 
        response = 'c';
        responseText = 'Center';
    elseif keyCode(37)==1 % left arrow
        response = 'r';
        responseText = 'Baby''s Right';
    elseif keyCode(65)==1 % 'a' key for abort
        response = 'a';
        responseText = 'Abort';
    else
        response = 'n';
        responseText = 'No Key';
    end
else
    response = 'n';
    responseText = 'No Key';
    % there was no keypress so look for eye tracking using vid (eventually
    % do this
end

% now classify the input
if strcmp(response,'r')
    fprintf('Baby''s Left\n')
    fixationReport=[fixationReport;{t2, [trialtype,triallabel],'-', 'baby_left',dt}];
    fprintf(outputfile, [num2str(t2),',', trialtype ,',',triallabel ,'-', ', baby_left,',num2str(dt),'\n']);
    righttime = righttime + dt;
    tempofftime = 0;
elseif strcmp(response,'c')
    fprintf('         CENTER\n')
    fixationReport=[fixationReport;{t2, [trialtype,triallabel],'-', 'center',dt}];
    fprintf(outputfile, [num2str(t2),',', trialtype ,',',triallabel ,'-', ', center,',num2str(dt),'\n']);
    centertime = centertime + dt;
    tempofftime = 0;
elseif strcmp(response,'l')
    fprintf('               Baby''s Right\n')
    fixationReport=[fixationReport;{t2, [trialtype,triallabel],'-', 'baby_right',dt}];
    fprintf(outputfile, [num2str(t2),',', trialtype ,',',triallabel ,'-', ', baby_right,',num2str(dt),'\n']);
    lefttime = lefttime + dt;
    tempofftime = 0;
elseif strcmp(response,'a')
    fprintf('aborting experiment\n')
    inst =['stop at ' num2str(place) '.  You should start here again if possible.'];
    fprintf(inst)
    fixationReport=[fixationReport;{t2, [trialtype,triallabel],'-', 'abort',dt}];
    fprintf(outputfile, [num2str(t2),',', trialtype ,',',triallabel ,'-', ', abort,',num2str(dt),'\n']);
    abort=1;
else
    fprintf('         No Key\n')
    fixationReport=[fixationReport;{t2, [trialtype,triallabel],'-', 'NoKey',dt}];
    fprintf(outputfile, [num2str(t2),',', trialtype ,',',triallabel ,'-', ', NoKey,',num2str(dt),'\n']);
    offtime = offtime + dt;
    tempofftime = tempofftime + dt;
end

