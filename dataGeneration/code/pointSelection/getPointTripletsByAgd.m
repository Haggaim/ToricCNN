function [triplets,AGD] = getPointTripletsByAgd(V,F,params)
% V,F mesh representation
% n number of points to choose from (e.g. 5 for human)
%params
n = getoptions(params, 'n', 5);% n number of points to choose from (e.g. 5 for human)
T = getoptions(params, 'T', 0.4);% Threshold for proximity of local maxima
smoothing_n_itersAGD = getoptions(params, 'smoothing_n_itersAGD', 10); % number of smoothing iterations for AGD
doplot = getoptions(params,'doplot',0);

nV = max(size(V));
% calculate AGD
disp('Calculating pairwise distances...')
adj = triangulation2adjacency_change(F,V');
dist = graphallshortestpaths(adj,'directed',false);
diameter = max(dist(:));
% dist = rand(nV);
disp('Calculating face areas...')
% calculate triangle areas
faceAreas = computeSurfAreas(V,F);

% calculate 1-ring areas
disp('Calculating 1-ring areas...')
oneRingAreas = zeros(nV,1);
for ii = 1:nV
    ff = any(F'==ii); % indices of faces in the ii'th vertex 1-ring
    oneRingAreas(ii) = (1/3)*sum(faceAreas(ff));
end

% calculate AGD (average geodesic distance)
disp('Calculating and smooth AGD...')
AGD_raw = dist*oneRingAreas;
% smoothing
AGD = perform_mesh_smoothing(F,V,AGD_raw,struct('niter_averaging',smoothing_n_itersAGD));
% find critical points
vring = compute_vertex_ring(F);
AGD_minima = false(nV,1);
AGD_maxima = false(nV,1);
disp('Find maxima...')

for ii = 1:nV
    %currNeighborhood = vring{ii}; % one ring
    currNeighborhood = setdiff([vring{ii} vring{vring{ii}}], ii); % two ring
    AGD_maxima(ii) = all(AGD(ii)>=AGD(currNeighborhood));
    AGD_minima(ii) = all(AGD(ii)<=AGD(currNeighborhood));
    
end

AGD_max_idx = find(AGD_maxima);
AGD_max_vals = AGD(AGD_max_idx);
[~,idx] = sort(AGD_max_vals,'descend');
if doplot
   figure;
    hold on
    patch('vertices',V,'faces',F,'FaceVertexCData',AGD,'FaceColor','interp','EdgeColor','none','FaceAlpha',1);
    axis equal, axis off, addRot3D;
    scatter3(V(AGD_max_idx,1),V(AGD_max_idx,2),V(AGD_max_idx,3),'r') 
    
end 
% choose AGD maxima
final_idx = [];
ii = 1;
while numel(final_idx)<n
    cidx = AGD_max_idx(idx(ii));
    if ~isempty(final_idx) && min(min(dist(final_idx,cidx)))<T*diameter
        ii = ii+1;
        continue
    else
      final_idx = [final_idx cidx];  
    end
end
% choose all triplets
triplets = nchoosek(final_idx,3);

% close all


end