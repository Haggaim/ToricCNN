function out = doMaxProjectionForward(in)
[m,n,~] = size(in);
nextDim = numel(size(in))+1;
assert(m==n,'image is non-square');

t90 =   rot90(in);
t180 =  rot90(t90);
t270 =  rot90(t180);
combinedData = cat(nextDim,in,t90,t180,t270);
out = max(combinedData,[],nextDim);

end