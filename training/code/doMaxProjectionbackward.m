function out = doMaxProjectionbackward(input,der)

m = size(der,1);
n = size(der,2);
assert(m==n,'image is non-square');


input_forwarded = doMaxProjectionForward(input);
der_forwarded = 4* doProjection(der);
% special case for odd size
if mod(m,2)==1
    der_forwarded(ceil(m/2),ceil(n/2),:,:) = der(ceil(m/2),ceil(n/2),:,:);
end
mask = (input_forwarded==input);
out = zeros(size(der),'single');
out = gpuArray(out);
out(mask)= der_forwarded(mask);


