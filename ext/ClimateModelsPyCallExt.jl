module ClimateModelsPyCallExt

using PyCall, ClimateModels

function ClimateModels.pyimport(flag=:fair)
    if flag==:fair
        fair=pyimport("fair")
        forward=pyimport("fair.forward")
        RCPs=pyimport("fair.RCPs")
        fair,forward,RCPs
    elseif flag==:seaduck
        sd=pyimport("seaduck")
    else
        @warn "unknown flag value   "
    end
end

end
