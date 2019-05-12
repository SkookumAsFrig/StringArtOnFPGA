function [A, x] = stringArt_custom(varargin)
% Set Default Values
invertInput = true;
invertOutput = true;
numPins = 256;
threadThickness = 0.15;
frameDiameter = 614.4;
pinSideLength = 2;
superSamplingWindowWidth = 8;
minAngle = 0;
importanceMapPath = '';
range = 0.7;
dataPath = './data';

% Parse Input Parameters
for i = 1 : 2 : numel(varargin)
    switch varargin{i}
        case 'inputFilePath'
            fileName = varargin{i + 1};
        case 'outputDirPath'
            outputPath = varargin{i + 1};
        case 'outputFileNamePrefix'
            outputFileNamePrefix = varargin{i + 1};
        case 'invertInput'
            invertInput = varargin{i + 1};
        case 'invertOutput'
            invertOutput = varargin{i + 1};
        case 'numPins'
            numPins = varargin{i + 1};
        case 'threadThickness'
            threadThickness = varargin{i + 1};
        case 'frameDiameter'
            frameDiameter = varargin{i + 1};
        case 'pinSideLength'
            pinSideLength = varargin{i + 1};
        case 'superSamplingWindowWidth'
            superSamplingWindowWidth = varargin{i + 1};
        case 'minAngle'
            minAngle = varargin{i + 1};
        case 'importanceMapPath'
            importanceMapPath = varargin{i + 1};
        case 'dataPath'
            dataPath = varargin{i + 1};
    end
end

% Super Sampling Window Width must be power of 2
assert(mod(superSamplingWindowWidth, 2) == 0);

% Adapt Thread Thickness to allow a domain width that is power of 2
threadThickness = adaptThreadThickness(threadThickness, frameDiameter);

imOrig = double(imread(fileName)) / 255;

highRes = round(frameDiameter / threadThickness);
lowRes = highRes / superSamplingWindowWidth;

%Resize image, loses aspect ratio if not square
if size(imOrig, 1) ~= lowRes
    imOrig = imresize(imOrig, [lowRes, lowRes]);
end

% Stretch Histogram of input image to enhance contrast
imOrig = stretchHistogram(imOrig);

% Shorten range of input image to remove pure white regions
imOrig = imOrig * range;

img = imOrig;

targetFilePath = [outputPath '/' outputFileNamePrefix '-target.png'];

[targetImage, mask] = maskImage(imOrig, 0.5 * size(imOrig, 1));

if xor(invertInput, invertOutput) == true
    targetImage = 1 - targetImage;
end

targetImage(mask) = 1;

% Write Target Image
filepath = fileparts(targetFilePath);
if ~(exist(filepath, 'dir') == 7)
    mkdir(filepath);
end

imwrite(targetImage, targetFilePath);

mask = ~mask;

if (invertInput)
    img = imcomplement(img);
end

importanceMap = ones(size(img));

% Flip image upside down to accout for different coordinate systems of
% Matlab (left-handed) and robot (right-handed)
img = flipud(img);

[pinPos, angles] = pinPosDeterm(numPins, lowRes/2-1);

pinPos = pinPos + [lowRes/2 lowRes/2];

stringstruct = findstrings(pinPos);
currimage = zeros(lowRes, lowRes);
add_rem = 1;
plot(pinPos(:,1),pinPos(:,2))
hold on
axis equal

% Write Real Image
targetFilePath = [outputPath '/' outputFileNamePrefix '-inter-result.png'];
filepath = fileparts(targetFilePath);
if ~(exist(filepath, 'dir') == 7)
    mkdir(filepath);
end

[reduction, finalimage, points] = addremove_oneiter(targetImage, numPins, stringstruct, currimage, add_rem);
tic
idx = 0;
%for i=1:9
while reduction>0
    [reduction, finalimage, points] = addremove_oneiter(targetImage, numPins, stringstruct, finalimage, add_rem);
    idx = idx+1;
    if mod(idx,5)==0
        realimage = finalimage==0;
        imwrite(realimage, targetFilePath);
    end
end
t = toc
realimage = finalimage==0;
imwrite(realimage, targetFilePath);
end