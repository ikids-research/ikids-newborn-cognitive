output = getSubjectInfoUI();
disp('New Format');
disp(output);
if isempty(output)
    error('Form was cancelled - quitting.');
end
disp('Old Format');
[subject, birthdate, birthtime, sex, age, experimentdate, ...
 experimenter_baby, experimenter_computer, place, session, ...
 condition, outputfile, outputfilesummary] = ...
    convertNewSubjectStructToOld(output);
disp(old_output);