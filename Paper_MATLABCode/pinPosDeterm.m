function [pinPos, angles] = pinPosDeterm(numPins, Radius)
    
    if nargin == 0
        numPins = 512;
    end
    
    sliceAngle = 2 * pi /numPins;
    angles = sliceAngle*ones(numPins, 1);
    angles = cumsum(angles);
    
    pinPos = Radius*[cos(angles) sin(angles)];
end