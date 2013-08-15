function [ pos ] = data_pos( clspos,numTrainPos )
%clspos: path of pos data
%numTrainPos: number of pos data
pos = [];
numpos = 0;
[a,b,c,d,e]=textread(clspos,'%d%d%d%d%s');
for i = 1:numTrainPos;
  numpos = numpos+1;
  pos(numpos).im = [e{numpos}];
  pos(numpos).x1 = a(numpos);
  pos(numpos).y1 = b(numpos);
  pos(numpos).x2 = c(numpos);
  pos(numpos).y2 = d(numpos);
  pos(numpos).flip = false;
  pos(numpos).trunc = 0;
end

