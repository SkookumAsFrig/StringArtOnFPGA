function stringstruct = findstrings(pinPos)

numPins = length(pinPos(:,1));

stringstruct = cell(numPins,numPins);

for i = 1:length(pinPos(:,1))-1
    for j = i+1:length(pinPos(:,1))
        currpin = pinPos(i,:);
        nextpin = pinPos(j,:);
        
        [x, y]=bresenham(currpin(1),currpin(2),nextpin(1),nextpin(2));
        stringstruct{i,j} = [x y];
        %         [x, y, c]=XiaolinWu(currpin(1),currpin(2),nextpin(1),nextpin(2));
        %         stringstruct{i,j} = [x y c];
        
    end
end

end