function out = doProjection(in)
[m,n,~] = size(in);
assert(m==n,'image is non-square');

%old Haggai code
% hm = m/2; hn = n/2;
% t11 =  in(1:hm,1:hn,:);
% t12 =   rot90(in(1:hm,hn+1:n,:));
% t21 =  rot90(rot90(in(hm+1:m,1:hn,:)));
% t22 =  rot90(rot90(rot90(in(hm+1:m,hn+1:n,:))));
% t = (t11+t12+t21+t22)/4;
% out = repmat(t,[2 2]);

t90 =   rot90(in);
t180 =  rot90(t90);
t270 =  rot90(t180);
out = (in +t90 + t180 +t270)/ 4;

end