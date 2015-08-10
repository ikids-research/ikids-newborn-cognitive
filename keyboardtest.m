clear all;
FlushEvents('keyDown');
keyIsDown = 0;
while keyIsDown == 0
    [keyIsDown, secs, keyCode] = KbCheck;
end

keyCode;
keyIsDown