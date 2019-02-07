function [V,F] =  orgenizeFV(V,F)
[m,n] = size(V);
if m<n
   V = V' ;
end
[m,n] = size(F);
if m<n
   F = F' ;
end

end