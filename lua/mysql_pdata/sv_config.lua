if !SERVER then return end

MySQLPData = MySQLPData || {}
MySQLPData.Config = MySQLPData.Config || {}

-- Which database should be used?
MySQLPData.Config.Databases = {
    ["sv1"] = {
        db = "",
        user = "",
        password = "",
        port = 3306,
        ip = ""
    },
    ["sv2"] = {
        db = "",
        user = "",
        password = "",
        port = 3306,
        ip = ""
    }
}

-- Should debug prints be enabled? 
MySQLPData.Config.Debug = false
