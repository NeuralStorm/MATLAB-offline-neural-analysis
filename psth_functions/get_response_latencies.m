function [fl, ll, duration] = get_response_latencies(response_edges, fl_i, ll_i)
    fl = response_edges(fl_i);
    ll = response_edges(ll_i + 1); % +1 to ll_i to give "right" edge of bin
    duration = abs(abs(ll) - abs(fl));
end