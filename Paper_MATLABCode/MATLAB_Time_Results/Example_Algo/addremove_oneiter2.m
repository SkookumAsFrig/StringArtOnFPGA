function [reduction, finalimage, points] = addremove_oneiter2(refimage, numPins, stringstruct, currimage, add_rem)

reduction = 0;
points = zeros(1,2);
finalimage = currimage;

if add_rem
    incval = 255;
else
    incval = -255;
end

for i = 1:numPins-1
    for j = i+1:numPins
        lastdiff = 0;
        currdiff = 0;
        currimagetemp = currimage;
        
        pixels = stringstruct{i,j};
        
        %a = plot(pixels(:,1),pixels(:,2),'k','Linewidth',2);
        
        szp = length(pixels(:,1));
        
        for k = 1:szp
            currimagetemp(pixels(k,1),pixels(k,2)) = currimagetemp(pixels(k,1),pixels(k,2)) + incval;
            lastdiff = lastdiff + abs(double(refimage(pixels(k,1),pixels(k,2))) - (currimage(pixels(k,1),pixels(k,2)) == 0)* 255);
            currdiff = currdiff + abs(double(refimage(pixels(k,1),pixels(k,2))) - ((currimagetemp(pixels(k,1),pixels(k,2)) == 0)*0));
        end
        
        redtemp = lastdiff-currdiff;
        if redtemp>reduction
            points = [i j];
            reduction = redtemp;
            finalimage = currimagetemp;
        end
        %delete(a);
        
    end
end

end