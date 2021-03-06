function [MUc,OMGc,LB,UB]=ConditionalDistributionOfEndogenousAndShocks(DYbar,OMG,EndoCond,ShocksCond)

%=============================
[MUy,OMGy,LBy,UBy,ncv,ncp]=deal(EndoCond{:});
[MUx,OMGx,LBx,UBx,ncvx,ncpx]=deal(ShocksCond{:});
% Replace the conditional mean by its theoretical counterpart for the
% conditioning variables that do not have a mean at all conditioning
% horizons. If there is at least one non-nan element, the conditional mean
% is unchanged
ncvcp=ncv*ncp;
MUy=ReplaceFullVectorIfMissing(MUy,DYbar(1:ncvcp),LBy,UBy,ncv,ncp);
MUx=ReplaceFullVectorIfMissing(MUx,DYbar(ncvcp+1:end),LBx,UBx,ncvx,ncpx);
%=============================

MUc=[MUy;MUx];
OMGc=OMG;
TotalNumberOfRestrictions=size(OMG,1);
nendo=size(MUy,1);
yrest=1:nendo;
xrest=nendo+1:TotalNumberOfRestrictions;
if ~isempty(OMGy)
    OMGc(yrest,yrest)=OMGy;
end
if ~isempty(OMGx)
    OMGc(xrest,xrest)=OMGx;
end

LB=[LBy;LBx];
UB=[UBy;UBx];

[junk,PositiveDefiniteness]=chol(OMGc); %#ok<ASGLU>
if PositiveDefiniteness
    warning([mfilename,':: Implied covariance matrix not positive definite, reverting to theoretical']) %#ok<WNTAG>
    OMGc=OMG;
end

end

function MU=ReplaceFullVectorIfMissing(MU,TheoMean,LB,UB,ncv,ncp)
if ~any(any(isfinite([LB,UB])))
    % replace the mean only when at least one element in the bounds is
    % finite
    return
end
if ~isequal(size(MU),size(TheoMean))
    error([mfilename,':: conditional and theoretical mean should have the same length'])
end
index=(0:ncp-1)*ncv;
for j=1:ncv
    if all(isnan(MU(index+j))) % then we assume the mean is not distorted
        MU(index+j)=TheoMean(index+j);
    end
end
end
