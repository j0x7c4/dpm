function [ neg ] = data_neg( clsneg,numTrainNeg )
%clsneg: path of neg data
%numTrainNeg: number of neg data
[e]=textread(clsneg,'%s');
neg = [];
numneg = 0;
for i = 1:numTrainNeg;
  numneg = numneg+1;
  neg(numneg).im = e{numneg};
  neg(numneg).flip = false;
end

