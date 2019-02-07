function A = computeSurfAreas(X,tri)

A = zeros(size(tri,1),1);
for i=1:length(A)
    v1 = X(tri(i,2),:)-X(tri(i,1),:);
    v2 = X(tri(i,3),:)-X(tri(i,1),:);
    A(i) = 0.5*norm(cross(v1,v2));
end


end