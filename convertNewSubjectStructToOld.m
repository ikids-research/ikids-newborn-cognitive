function [subject, birthdate, birthtime, sex, age, experimentdate, ...
          experimenter_baby, experimenter_computer, place, session, ...
          condition, outputfile, outputfilesummary] = ...
          convertNewSubjectStructToOld(newStruct)

% Get raw information from source new struct
subject = newStruct{1}; % string
experimenter_baby = newStruct{2}; % string
experimenter_computer = newStruct{3}; % string
birthdate = newStruct{4}; % string
experimentdate = newStruct{5}; % string
birthhour_num = newStruct{6}; % int
birthmin_num = newStruct{7} - 1; % int
birthampm_num = newStruct{8}; % int
currenthour_num = newStruct{9}; % int
currentmin_num = newStruct{10} - 1; % int
currentampm_num = newStruct{11}; % int
condition = newStruct{12}; % int
place = newStruct{13}; % int
sex_num = newStruct{13};

% Generate 'AM' and 'PM' strings for birth and current times
birthampm = '??';
if birthampm_num == 1
    birthampm = 'AM';
elseif birthampm_num == 2
    birthampm = 'PM';
end
currentampm = '??';
if currentampm_num == 1
    currentampm = 'AM';
elseif currentampm_num == 2
    currentampm = 'PM';
end

% Generate time strings in hh:mm am/pm
birthtime_str = strcat(num2str(birthhour_num), ':', ...
                       num2str(birthmin_num), ' ', ...
                       birthampm);
currenttime_str = strcat(num2str(currenthour_num), ':', ...
                         num2str(currentmin_num), ' ', ...
                         currentampm);
birthtime = birthtime_str;

% Generate birth and current date numbers and hour numbers and compare them
% to ensure the baby was not born in the future and calculate the age in
% hours.
birthdateDN = datenum(birthdate,'mm/dd/yy');
currentDN = datenum(experimentdate,'mm/dd/yy');
if strcmp(birthampm,'PM') ;birthhour_num = birthhour_num + 12; end
if strcmp(currentampm,'PM') ;currenthour_num = currenthour_num + 12; end
if currentDN < birthdateDN % Check date for future birth
    error(['There was a problem finding the age of the participant. ', ...
           'They appear to have been born in the future. ', ...
           '(birthdate = %s, current=%s)'], birthdate, experimentdate);
elseif birthdateDN == currentDN % If baby was born on current day
    if currenthour_num < birthhour_num % Check time for future birth
        error(['There was a problem finding the age of the ', ...
               'participant. They appear to have been born in the ', ...
               'future. (dates are equal, birthhour = %s, ', ...
               'current=%s)'], birthtime_str, currenttime_str);
    end
    if currenthour_num < birthhour_num
        error(['There was a problem finding the age of the ', ...
               'participant. They appear to have been born in ', ...
               'the future. (dates are equal, birthhour = %s, ', ...
               'current=%s)'], birthtime_str, currenttime_str);
    end
    if currenthour_num == birthhour_num
        if currentmin_num < birthmin_num
            error(['There was a problem finding the age of the ', ...
                   'participant. They appear to have been born in ', ...
                   'the future. (dates are equal, birthhour = %s, ', ...
                   'current=%s)'], birthtime_str, currenttime_str);
        end
    end
end
hour_diff = currenthour_num - birthhour_num;
diff_date = currentDN - birthdateDN;
age=strcat(num2str((24 * diff_date + hour_diff)));
sex = '?';
if sex_num == 1
    sex = 'm';
elseif sex_num == 2
    sex = 'f';
end

session = '1'; %???
outputfile = ''; %???
outputfilesummary = ''; %???

end