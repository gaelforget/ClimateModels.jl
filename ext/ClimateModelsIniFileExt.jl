module ClimateModelsIniFileExt

    using IniFile
    import ClimateModels: read_IniFile, HectorConfig

    function read_IniFile(MC::HectorConfig)
        pth=pathof(MC)
        fil=joinpath(pth,"hector/inst/input/",MC.configuration)
        read(Inifile(), fil)
    end
    
end
