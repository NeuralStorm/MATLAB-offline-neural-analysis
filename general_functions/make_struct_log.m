function [log_struct] = make_struct_log(config, log_vars)
    log_struct = struct;
    for struct_name = fieldnames(config)'
        if contains(struct_name, log_vars)
            log_struct.(struct_name{1}) = config.(struct_name{1});
        end
    end
end