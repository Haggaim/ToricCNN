function A = triangulation2adjacency_change(face,vertex)

% triangulation2adjacency - compute the adjacency matrix
%   of a given triangulation.
%
%   A = triangulation2adjacency(face);
% or for getting a weighted graph
%   A = triangulation2adjacency(face,vertex);
%
%   Copyright (c) 2005 Gabriel Peyr?




nvert = max(max(face));
nface = size(face,1);
A = spalloc(nvert,nvert,3*nface);

for i=1:nface
    for k=1:3
        kk = mod(k,3)+1;
        if nargin<2
            A(face(i,k),face(i,kk)) = 1;
        else
            v = vertex(:,face(i,k))-vertex(:,face(i,kk));
            A(face(i,k),face(i,kk)) = sqrt( sum(v.^2) );    % euclidean distance
        end
    end
end 
% make sure that all edges are symmetric
A = max(A,A');