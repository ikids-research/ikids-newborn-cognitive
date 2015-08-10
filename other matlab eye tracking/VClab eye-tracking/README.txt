*************************************************************************
BEFORE STARTING
Before using the script, check if the following requirements are
satisfied:
1) MATLAB 2010a or later. 
   Some earlier releases could be incompatible with some functions or may
   not work properly.
2) MATLAB DAQ toolbox. 
   Usually it's installed by default with MATLAB; if you are not
   sure, use the command "which daqhwinfo -all" (without quotation marks)
   for checking.
3) PsychToolbox (PTB) version 3.0.
   Please follow the instructions at
   http://psychtoolbox.org/PsychtoolboxDownload; be sure that its folders
   are in MATLAB search path.
4) KbQueueCheck function.
   To quit the task during the execution of the script, the function
   KbQueueCheck is called. To properly work, you have to copy a file from
   PTB in a Windows folder. Please run the command "KbCheck(-1)" (without
   quotation marks) and carefully follow the instructions. At the end
   run the command again and check that you will not have any warning or error.
5) Two Monitors.
   The scripts assumes that you are using Windows and the main display is
   extended on two monitors ("Extend these displays" in Windows7). If you
   use other configurations please read the help for PTB function Screen('OpenWindow')
   and accordingly modify the line 158 in the script to change on which
   display visual stimuli will be presented.
6) National Instruments PCI-6221 acquisition board.
   The script was written to function with a National Instruments PCI-6221
   acquisition board with analog/digital input/output.
   Please check that your card is properly recognized by MATLAB (run
   "daqhwinfo" and if necessary modify lines 10 and 19), that the eye signal are
   input to the board on 1st and 2nd channel for respectively horizontal and
   vertical axes, and that the reward is delivered by a digital output on
   [channel 1, line 0].
   
*************************************************************************
USER-DEFINED SETTINGS
On the following lines you will find the instructions about what you have
to set to run the script with your setup and experiment. The code
provides several comments for almost every command. For any comments or suggestion,
please feel free to write an email either to:

prof. Gregor Rainer, PhD (gregor.rainer@unifr.ch)   or 
Mr. Paolo De Luna        (paolo.deluna@unifr.ch)

Lines         Comments

10 and 19  - DAQ board info.
11 and 20  - respectively, analog input and digital output channels on DAQ board.
30 to 55   - insert here all parameters of the task.
58 to 60   - screen resolution (in pixels), size (in cm), and distance
             from subject's eyes (in cm).
176 to 200 - data to store are initialized here.
173 	   - eye signals samples and their timestamps are pre-allocated
             here with 10'000 data points; in our setup with 4 ms delay
			 between samples you can acquire ~40 seconds of data. Increase
			 this number if you record longer trials.
304        - if you want to add a feedback for reward delivery, like 
			 a pure tone, this is the place.
334        - path on PC where to store the data

************************************************************************
HOW THE GUI WORKS
The graphical interface (Experimenter's display) shows useful information
about the current trial and block of trials:

1) On the right, you'll find information about the block like subject's
name, number of trials, gain and offset of eye signal, buffer length,
fixation window, radius and so on; moreover MATLAB will tell you if
fixation windows for all the targets are mutually exclusive, i.e.
non-overlapping, or not.

2) On the left side, the current gaze position [in degrees] is shown as a
blue cross; the large rectangle represents the monitor and the  small
squares are the fixation targets. During each trial, one of the little
square becomes green warning you about the position of the next fixation
target; when the target is presented the fixation window will appear on
this screen only (a circle around green square) and MATLAB will compare
gaze position with target position for fixation acquisition and holding.

3) On bottom right, a red text will remind you when you can press the "q"
key on the keyboard (only during the inter-trial interval) to quit the
recording (at the end of the inter-trial interval), save the data and give
you back MATLAB control.