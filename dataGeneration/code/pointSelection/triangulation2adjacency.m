    function A = triangulation2adjacency(face,vertex)

% triangulation2adjacency - compute the adjacency matrix
%   of a given triangulation.
%
%   A = triangulation2adjacency(face);
% or for getting a weighted graph
%   A = triangulation2adjacency(face,vertex);
%
%   Copyright (c) 2005 Gabriel Peyré


%[~,face] = check_face_vertex([],face);
f = double(face);

if size(f,2)==3,
    A = sparse([f(:,1); f(:,1); f(:,2); f(:,2); f(:,3); f(:,3)], ...
               [f(:,2); f(:,3); f(:,1); f(:,3); f(:,1); f(:,2)], ...
                1.0);
elseif size(f,2)==4,
    A = sparse([f(:,1); f(:,1); f(:,1); f(:,2); f(:,2); f(:,3)], ...
               [f(:,2); f(:,3); f(:,4); f(:,3); f(:,4); f(:,4)], ...
               1.0,size(vertex,1),size(vertex,1));
    A = A+A';
else
    error('incompatible triangulation dimensions');
end
% avoid double links
A = double(A>0);

if nargin==2
    ff = find(A);
    [ffr,ffc]=ind2sub(size(A),ff);
    A(ff) = sqrt(sum((vertex(ffr,:)-vertex(ffc,:)).^2,2));
end