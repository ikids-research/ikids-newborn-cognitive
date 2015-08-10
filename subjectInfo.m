function [subject, birthdate, birthtime, sex, age, experimentdate, experimenter_baby, experimenter_computer, place, session, condition, outputfile, outputfilesummary] = subjectInfo()
% This function asks the user for the basic info on the subject and if necessary loads previous data to restore a session
% Ask for
%     1) Participant ID
subject = input('Participant ID? \n', 's');

%     1a) If you find a file with this ID then ask if the program should
%     recover the file.
if exist(['data/' subject],'dir')
    while 1
        recovery = input('Recover previous session? (y,n) \n', 's');
        if strcmp(recovery, 'n')
            break
        elseif strcmp(recovery, 'y')
            break
        end
    end
else
    % otherwise ask all the questions below
    recovery = 'n';
end

if strcmp(recovery, 'n')
    % 2) Birthday & Time
    birthdate = input('Baby''s Birth DATE (such as 7/25/2014): \n', 's');
    birthtime = input('Baby''s Birth TIME (such as 7:05 AM): \n', 's');
    % 3) Sex
    sex = input('Baby''s sex (m or f): \n', 's');
    % 4) Age (hours)
    age = input('Age (in hours): \n', 's');
    % 5) Testing Date & Time
    experimentdate = datestr(now);
    while 1
        check = input(['Is ', char(experimentdate), ' the correct time? (y/n) \n'], 's');
        if strcmp(check,'y')
            break;
        elseif strcmp(check,'n')
            break;
        end
    end
    if strcmp(check,'n')
        experimentdate = input('Experiment date/time: \n', 's');
    end
    % 6) Researchers at computer and baby
    experimenter_baby = input('Researcher holding baby: \n','s');
    experimenter_computer = input('Researcher running computer: \n', 's');
    % 7) Condition
    if exist(['conditionFile',sex,'.txt'])
        conditionNameFile = ['conditionFile',sex,'.txt'];
        conditionFile = fopen(conditionNameFile, 'r');
        line = fgetl(conditionFile);
        splitline = strsplit(line,',');
        condition = str2num(splitline{1});
        % here the program looks up what the last condition was and
        % increments by one
        if condition < 8
            condition = condition + 1;
        else
            condition = 1;
        end
        fprintf('Conditions\n');
        fprintf('which first?  ; which is familiar stim     ; novel side\n');
        fprintf('________________________________________________________\n');
        fprintf('1 = face      ; older woman & original geo ; baby''s left\n');
        fprintf('2 = face      ; young girl & new geo       ; baby''s right\n');
        fprintf('3 = face      ; older woman & oringial geo ; baby''s right\n');
        fprintf('4 = face      ; young girl & new geo       ; baby''s left\n');
        fprintf('5 = geo       ; older woman & orignial geo ; baby''s left\n');
        fprintf('6 = geo       ; young girl & new geo       ; baby''s right\n');
        fprintf('7 = geo       ; older woman & orignial geo ; baby''s right\n');
        fprintf('8 = geo       ; young girl & new geo       ; baby''s left\n');
        conditionqeustion = input(['Based on last baby, this baby should be in condition ', num2str(condition),'.  Is this correct(y,n)? '],'s');
        if strcmp(conditionqeustion,'y')
            % then just leave condition as is.
        else
            while 1
                con = input('What condition should baby be in (1-8)?,','s');
                condition = str2num(con);
                if any(condition == 1:8)
                    break;
                end
            end
        end
        conditionNameFile = ['conditionFile',sex,'.txt'];
        conditionFile = fopen(conditionNameFile, 'w');
        fprintf(conditionFile, ['',num2str(condition),'\n']);
    else
        fprintf('Conditions\n');
        fprintf('which first?  ; which is familiar stim     ; novel side\n');
        fprintf('________________________________________________________\n');
        fprintf('1 = face      ; older woman & original geo ; baby''s left\n');
        fprintf('2 = face      ; young girl & new geo       ; baby''s right\n');
        fprintf('3 = face      ; older woman & oringial geo ; baby''s right\n');
        fprintf('4 = face      ; young girl & new geo       ; baby''s left\n');
        fprintf('5 = geo       ; older woman & orignial geo ; baby''s left\n');
        fprintf('6 = geo       ; young girl & new geo       ; baby''s right\n');
        fprintf('7 = geo       ; older woman & orignial geo ; baby''s right\n');
        fprintf('8 = geo       ; young girl & new geo       ; baby''s left\n');
        while 1
            con = input('What condition should this baby be in? \n','s');
            condition = str2num(con);
            if any(condition == 1:8)
                break;
            end
        end
        conditionNameFile = ['conditionFile',sex,'.txt'];
        conditionFile = fopen(conditionNameFile, 'w');
        fprintf(conditionFile, ['',num2str(condition),'\n']);
    end
    
    
    % place
    while 1
        beginning = input('Start at the beginning? (y,n)\n','s');
        if strcmp(beginning,'y')
            place = 1;
            break;
        elseif strcmp(beginning,'n')
            fprintf('Place Positions to Choose From\n');
            fprintf('1 = block 1, fam \n');
            fprintf('2 = block 1, test1 \n');
            fprintf('3 = block 1, test2 \n');
            fprintf('4 = block 2, fam \n');
            fprintf('5 = block 2, test1 \n');
            fprintf('6 = block 2, test2 \n');
            while 1
                pl = input('Place: \n', 's');
                place = str2num(pl);
                if any(place == 1:6)
                    break;
                end
            end
            break;
        end
    end
    
    session = '1';
    % [subject,age,gender, date, session,startTrial] = deal(answer{:});
    
    
    %create a folder for the new subject
    if ~exist(['data/', subject],'dir')
        mkdir('data/',subject);
    end
    fclose('all');
    
    
elseif strcmp(recovery, 'y')
    % recover position in recovery data file
    recoveryNameFile = ['data/',subject,'/',subject,'_recovery.txt'];
    %         if ~exist(recoveryNameFile, 'file')
    %             fprintf('Error encountered trying to recover data.  The data recovery file does not exist.  Recovery isn''t possible for this subject.\n');
    %         else
    recoveryFile = fopen(recoveryNameFile, 'r');
    % seek to the end of the line and then recover the position of that
    % last line
    line = fgetl(recoveryFile);
    while ischar(line);
        previousline = line;
        line = fgetl(recoveryFile);
    end
    splitline = strsplit(previousline,',');
    % assign components to the relevant variables
    subject = splitline{1};
    age = splitline{2};
    sex = splitline{3};
    experimentdate = splitline{4};
    session = num2str(str2num(splitline{5})+1);
    birthdate = splitline{6};
    birthtime = splitline{7};
    place = str2num(splitline{8});
    experimenter_baby = splitline{9};
    experimenter_computer = splitline{10};
    condition = splitline{11};
    
    % change date to correct new date and time
    experimentdate = datestr(now);
    while 1
        check = input(['Is ', char(experimentdate), ' the correct time? (y/n) \n'], 's');
        if strcmp(check,'y')
            break;
        elseif strcmp(check,'n')
            break;
        end
    end
    if strcmp(check,'n')
        experimentdate = input('Experiment date/time: \n', 's');
    end
    
    fclose('all');
    
    % place
    while 1
        
        fprintf('Place Positions for Reference\n');
        fprintf('1 = block 1, fam \n');
        fprintf('2 = block 1, test1 \n');
        fprintf('3 = block 1, test2 \n');
        fprintf('4 = block 2, fam \n');
        fprintf('5 = block 2, test1 \n');
        fprintf('6 = block 2, test2 \n');
        recoverstart = input(['You last ended/aborted at ', num2str(place),' previously.  Would you like to start here again?'],'s');
        if strcmp(recoverstart,'y')
            place = place;
            break;
        else
%             beginning = input('Start at the beginning? (y,n)\n','s');
%             if strcmp(beginning,'y')
%                 place = 1;
%                 break;
%             elseif strcmp(beginning,'n')
                fprintf('Place Positions to Choose From\n');
                fprintf('1 = block 1, fam \n');
                fprintf('2 = block 1, test1 \n');
                fprintf('3 = block 1, test2 \n');
                fprintf('4 = block 2, fam \n');
                fprintf('5 = block 2, test1 \n');
                fprintf('6 = block 2, test2 \n');
                while 1
                    pl = input('Place: \n', 's');
                    place = str2num(pl);
                    if any(place == 1:6)
                        break;
                    end
                end
                break;
           % end
        end
    end
end

% append subject master list or create if needed
formatString = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n'; % this is for data output

dataFileName = ['SubjectInformation.txt'];
if exist(dataFileName, 'file') == 0
    dataFile = fopen(dataFileName, 'a');
    fprintf(dataFile, 'Participant ID ,Age ,Sex ,Date of Test ,Session # , Birthdate ,Birthtime ,Place ,Experimenter_Baby ,Experimenter_Computer ,Condition\n');
    fclose(dataFile);
end

dataFile = fopen(dataFileName, 'a');
fprintf(dataFile,formatString, subject, age, sex, experimentdate, session, birthdate, birthtime, num2str(place), experimenter_baby,experimenter_computer,num2str(condition));
fclose(dataFile);


% make a recovery file
formatString = '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
recoveryNameFile = ['data/',subject,'/',subject,'_recovery.txt'];
recoveryFile = fopen(recoveryNameFile, 'a');
fprintf(recoveryFile, formatString, subject, age, sex, experimentdate, session, birthdate, birthtime, num2str(place),experimenter_baby,experimenter_computer,num2str(condition));

fprintf('Subject Info Loaded.\n');

fclose(recoveryFile);


fclose('all');

outputfile = fopen(['data/',subject,'/',subject,'_Raw_Data.csv'], 'a');

outputfilesummary = fopen(['data/',subject,'/',subject,'_Summary_Data.csv'], 'a');


end