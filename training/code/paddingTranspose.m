function output = paddingTranspose(image,pad)

[m n d b]=size(image);
sm=m-2*pad;
sn=n-2*pad;
%upper
image(pad+1:2*pad,pad+1:pad+sn,:,:)=image(pad+1:2*pad,pad+1:pad+sn,:,:)+image(pad+sm+1:end,pad+1:pad+sn,:,:);
%lower
image(sm+1:pad+sm,pad+1:pad+sn,:,:)=image(sm+1:pad+sm,pad+1:pad+sn,:,:)+image(1:pad,pad+1:pad+sn,:,:);
%left
image(pad+1:pad+sm,pad+1:2*pad,:,:)=image(pad+1:pad+sm,pad+1:2*pad,:,:)+image(pad+1:pad+sm,pad+sn+1:end,:,:);
%right
image(pad+1:pad+sm,sn+1:pad+sn,:,:)=image(pad+1:pad+sm,sn+1:pad+sn,:,:)+image(pad+1:pad+sm,1:pad,:,:);
 
% upper left corner
image(pad+1:2*pad,pad+1:2*pad,:,:)=image(pad+1:2*pad,pad+1:2*pad,:,:)+image(sm+pad+1:end,sn+pad+1:end,:,:);

% lower right corner
image(sm+1:sm+pad,sm+1:sm+pad,:,:)=image(sm+1:sm+pad,sm+1:sm+pad,:,:)+image(1:pad,1:pad,:,:);

% upper right corner
image(pad+1:2*pad,sm+1:sm+pad,:,:) = image(pad+1:2*pad,sm+1:sm+pad,:,:) + image(sm+pad+1:end,1:pad,:,:);
% lower left  corner
image(sm+1:sm+pad,pad+1:2*pad,:,:) = image(sm+1:sm+pad,pad+1:2*pad,:,:) + image(1:pad,sm+pad+1:end,:,:);




output = image(pad+1:pad+sm, pad+1:pad+sn,:,:);
end