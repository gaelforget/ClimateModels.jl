module ClimateModelsCondaExt

using Conda, ClimateModels

function ClimateModels.conda(flag=:fair)
    if flag==:fair
        Conda.pip_interop(true)
        Conda.pip("install", "fair==1.6.4")
    end
end

end
