function MNTS = PEM_to_MNTS(PEM,unit_key)
%PEM_TO_MNTS Convert perievent matrix to multineuron timeseries format
%   The perievent matrix format and multineuron timeseries format are both
%   described in Laubach et al., 1999

num_units = numel(unique(unit_key));
num_bins = size(PEM,2)/num_units;
MNTS_size = size(PEM);
MNTS_size(1) = MNTS_size(1)*num_bins;
MNTS_size(2) = MNTS_size(2)/num_bins;
MNTS = zeros(MNTS_size);

for i = unique(unit_key)
    unit_PEM = PEM(:,unit_key==i);
    unit_PEM = unit_PEM';
    newcol = unit_PEM(:);
    MNTS(:,i) = newcol;
end

end

