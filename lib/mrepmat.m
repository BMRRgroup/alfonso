function [ A ] = mrepmat( A, B )
%MREPMAT replicates array A to match array B.
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Mar 22, 2018
%
% Revisions: 
%   Wednesday, 18. April 2018
%       Added mechanism that allows to fill up dimensions which are not a
%       multiple integer value. The difference in that dimension (B-A) has 
%       to be smaller than the length of this dimension in A. 
%
% Authors: 
%
%   stefan.ruschke@tum.de
% 
% --------------------------------
%
% Body Magnetic Resonance Research Group
% Department of Diagnostic and Interventional Radiology
% Technical University of Munich
% Klinikum rechts der Isar
% 22 Ismaninger St., 81675 Munich
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


sizAtmp = size(A);
sizB = size(B);

if length(sizAtmp) > length(sizB)
    warning('A has more dimensions than B!');
end

sizA = ones(1,ndims(B));
sizA(1:ndims(A)) = sizAtmp;

rpm = sizB ./ sizA;

if sum(floor(rpm) < 1)
    error('A has non fitting dimensions!');
end

rpm_cut_idx = [];
rpm_cut = []; 

if (sum(floor(rpm) == rpm) < length(rpm))
    warning('A has non fitting dimensions! Lets try get it done anyways...');
   
    % get non fitting dimensions
    nfd = find( (floor(rpm) == rpm) == 0 );
    % try to solve by 
    for i = 1:length(nfd)
       dimdiff = sizB(nfd(i)) - sizA(nfd(i));
       if dimdiff > 0
           if dimdiff < sizA(nfd(i))
               
               % remember which dimension to cut down after repmat to match B
               rpm_cut_idx(end + 1) = nfd(i);
               rpm_cut(end + 1) = dimdiff;
               
               % update rpm in nfd(i) dimension
               rpm(nfd(i)) = ceil(rpm(nfd(i)));
               
               warning('A has non fitting dimensions (non integer multiple dimension) and I try to fix this! ...')
           else
               error('A has non fitting dimensions and I wasn''t able to fix this! But it maybe possible in the future, if some implements a fillup functions...');
           end
       else
           error('A has non fitting dimensions and I wasn''t able to fix this!');
       end
    end
end

A = repmat( A, rpm );

% cut down dimensions if required
if ~isempty(rpm_cut_idx)
    for i=1:length(rpm_cut_idx)
        sizA = size( A );
        sizAnew = sizA;
        sizAnew(rpm_cut_idx(i)) = sizAnew(rpm_cut_idx(i)) - rpm_cut(i);
        
        % get permute order 
        perm_order = 1:length( sizA );
        perm_order = circshift( perm_order, - (rpm_cut_idx(i) -1) );

        % perform cut
        A =  permute( A,       perm_order );
        A(end-(rpm_cut(i)-1):end,:) = [];
        A =  reshape( A, sizAnew(perm_order) );
        A = ipermute( A,       perm_order );
    end
end

end

