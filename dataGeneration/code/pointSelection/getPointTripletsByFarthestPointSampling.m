function [triplets,AGD] = getPointTripletsByFarthestPointSampling(V,F,params)
% V,F mesh representation
% n number of points to choose from (e.g. 5 for human)
%params
params.null = [];
n = getoptions(params, 'n', 5);% n number of points to choose from (e.g. 5 for human)
nFarthest = getoptions(params, 'nFarthest', 20);% n number of points to choose from (e.g. 5 for human)

numTriplets = getoptions(params, 'numTriplets', 300);
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
if n>3
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
    
    % choose AGD maxima
    farthestPointInitialization = [];
    ii = 1;
    while numel(farthestPointInitialization)<n
        cidx = AGD_max_idx(idx(ii));
        if ~isempty(farthestPointInitialization) && min(min(dist(farthestPointInitialization,cidx)))<T*diameter
            ii = ii+1;
            continue
        else
            farthestPointInitialization = [farthestPointInitialization cidx];
        end
    end
else
    tempidx =1;
    minDistanceToV = min(dist(tempidx,:),[],1);
    [~,farthestIdx] =  max(minDistanceToV);    
    farthestPointInitialization = [farthestIdx];
end

% add farthert point sampling until we get to nFarthest
final_idx = farthestPointInitialization';
while numel(final_idx)<nFarthest
    minDistanceToV = min(dist(final_idx,:),[],1);
    [~,farthestIdx] =  max(minDistanceToV);
    final_idx =[final_idx; farthestIdx];
end



if doplot
    figure;
    hold on
    patch('vertices',V,'faces',F,'FaceVertexCData',AGD,'FaceColor','interp','EdgeColor','none','FaceAlpha',1);
    axis equal, axis off, addRot3D;
    scatter3(V(final_idx,1),V(final_idx,2),V(final_idx,3),'r')
    
end

if n>3
    % get extrimities triplets
    triplets = nchoosek(farthestPointInitialization,3);
    
    % choose all triplets of farthest point
    farthesttriplets = nchoosek(final_idx,3);
    % augment triplets from farthest
    triplets = [triplets; farthesttriplets(randperm(size(farthesttriplets,1),numTriplets-size(triplets,1)),:)];
else
    % choose all triplets of farthest point
    farthesttriplets = nchoosek(final_idx,3);
    % augment triplets from farthest
    triplets = [ farthesttriplets(randperm(size(farthesttriplets,1),numTriplets),:)];
end

end