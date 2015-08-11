function [globalPauseState, state, timeoutRemaining] = ...
                                       getGlobalPauseState(prevGlobalState)
    timeoutAllowed = 3; % Magic Number - 3s timeout is allowed
    % Flush and get keyboard state
    FlushEvents('keyDown');
    [keyIsDown, ~, keyCode] = KbCheck;
    % Populate previous call state variables
    pauseState = prevGlobalState{1};
    spaceKeyState = prevGlobalState{2};
    pauseStart = prevGlobalState{3};
    % Get timer variable
    curSecs = GetSecs;
    % Determine falling edge state (pause/release happens on key up)
    prevState = spaceKeyState;
    spaceKeyState = ((keyIsDown==1) & (keyCode(32)==1));
    fallingEdge = ((prevState == 1) & (spaceKeyState == 0));
    if(fallingEdge)
        pauseState = ~pauseState;
        if pauseState
            % Set the initial pause time when first starting
            pauseStart = curSecs;
        end
    end
    % Calculate the remaining timout and abort program if exceeded
    timeoutRemaining = timeoutAllowed - (curSecs - pauseStart);
    if(pauseState && timeoutRemaining <= 0)
        error('Maximum Global Pause Timeout Exceeded - Program Terminating...');
    end
    % Return new previous call variables
    globalPauseState = pauseState;
    state = {pauseState, spaceKeyState, pauseStart};