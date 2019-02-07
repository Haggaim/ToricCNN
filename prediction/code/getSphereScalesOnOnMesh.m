function scale1OnMesh2 = getSphereScalesOnOnMesh(V_flat1,cutMesh1,f1,V_flat2,cutMesh2)
% mesh1 sphere, mesh2 other surface

% calc sphere scale
scale1 = f1.valsOnUncutMesh(f1.vertexScale());

BC1to2=compute_map_from_sphere_embeddings( V_flat2,V_flat1,cutMesh2,cutMesh1 );
scale1OnMesh2 = BC1to2*scale1;
end