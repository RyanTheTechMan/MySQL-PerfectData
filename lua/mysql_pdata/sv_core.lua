require("mysqloo")
local PLAYER = FindMetaTable("Player")
for k,v in pairs(MySQLPData.Config.Databases) do
    local database = MySQLPData.Config.Databases[k]
    function database:InitializeDatabase()
        if !self.CONN then 
            if MySQLPData.Config.Debug then 
                print("[MySQL Data] Connection doesn't exist!") 
            end
            return 
        end
    end

    function database:SetupTable(tableName)
        local query = self.CONN:query([[CREATE TABLE IF NOT EXISTS ]] .. tableName .. [[ (
            steamid CHAR(17) NOT NULL UNIQUE
        );]])

        function query:onSuccess()
            if MySQLPData.Config.Debug then
                print("[MySQL Data] Successfully created SQL table!")
            end
        end

        function query:onError(strError)
            if MySQLPData.Config.Debug then 
                for i = 1, 5 do 
                    print("[MySQL Data] Unsuccessfully created SQL table, error: "..strError)
                end
            end
        end
        
        query:start()
    end

    function database:ConnectDatabase()
        if self.CONN then 
            if MySQLPData.Config.Debug then 
                print("[MySQL Data] Connection already exists!") 
            end
            self:InitializeDatabase(self)
            self.CONN:ping() 
            return 
        end

        local db = mysqloo.connect(database.ip, database.user, database.password, database.db, database.port)

        function db:onConnected()
            if MySQLPData.Config.Debug then
                print("[MySQL Data] Successfully connected to Database!")
            end

            MySQLPData.Config.Databases[k].CONN = db
            database:InitializeDatabase()
        end

        function db:onConnectionFailed(strError)
            if MySQLPData.Config.Debug then
                for i = 1, 5 do 
                    print("[MySQL Data] Unsuccessfully connected to database, error: "..strError)
                end
            end
        end

        db:connect()
    end
    MySQLPData.Config.Databases[k]:ConnectDatabase()
end

function PLAYER:SetData(column, database, tableName, data, type)
    local nick = self:Nick()

    column = istable(column) and column or {column}
    if type then type = istable(type) and type or {type} end
    data = istable(data) and data or {data}
    database = MySQLPData.Config.Databases[database]
    
    --database:SetupTable(tableName)

    local formattedColumn, formattedData, formattedOnDupe, formattedTypes = "","","",""

    for i = 1, #column do
        formattedOnDupe = formattedOnDupe .. column[i] .. "='" .. data[i] .. "', "
        if type then formattedTypes = formattedTypes .. column[i] .. " " .. type[i] .. ", " end
    end

    for _,v in ipairs(column) do
        formattedColumn = formattedColumn .. v .. ", "
    end

    for _,v in ipairs(data) do
        formattedData = formattedData .. "'".. v .. "', "
    end

    formattedColumn = string.sub(formattedColumn, 1, #formattedColumn - 2)
    formattedData = string.sub(formattedData, 1, #formattedData - 2)
    formattedOnDupe = string.sub(formattedOnDupe, 1, #formattedOnDupe - 2)
    if type then formattedTypes = string.sub(formattedTypes, 1, #formattedTypes - 2) end

    local query = ""
    if type then query = "ALTER TABLE " .. tableName .. " ADD COLUMN IF NOT EXISTS (" .. formattedTypes .. ")" .. ";" end
    query = database.CONN:query(query .. "INSERT INTO " .. tableName .. " (" .. formattedColumn .. ") VALUES (" .. formattedData .. ") ON DUPLICATE KEY UPDATE " .. formattedOnDupe)

    function query:onSuccess()
        if MySQLPData.Config.Debug then
            print("[MySQL Data] Successfully set data " .. formattedColumn .. " for player " .. nick .. "!")
        end
    end
    function query:onError(strError)
        if MySQLPData.Config.Debug then
            print(string.format("[MySQL Data] Unsuccessfully set data %s for player %s, error: %s", formattedColumn, nick, strError))
        end
    end
    query:start()
end

function PLAYER:GetData(column, database, tableName, funcCallback, customIdentifier, customTest)
    local nick = self:Nick()

    local steamID

    if not customIdentifier then customIdentifier = "steamid64" end
    if customIdentifier == "steamid64" then steamID = self:SteamID64() end
    if customIdentifier == "steamid" then steamID = self:SteamID() end

    database = MySQLPData.Config.Databases[database]
    column = istable(column) and column or {column}

    local formattedColumn = ""
    for _,v in ipairs(column) do
        formattedColumn = formattedColumn .. v .. ", "
    end

    formattedColumn = string.sub(formattedColumn, 1, #formattedColumn - 2)

    local query = database.CONN:query("SELECT " .. formattedColumn .. " FROM ".. tableName .." WHERE " .. customIdentifier .. " = '" .. (customTest or steamID) .. "'")
    function query:onSuccess(tblData)
        if MySQLPData.Config.Debug then
            print(string.format("[MySQL Data] Successfully received data %s for player %s!", formattedColumn, nick))
        end

        if #tblData == 0 then 
            funcCallback(nil)
        else
            funcCallback(tblData)
        end
    end

    function query:onError(strError)
        if MySQLPData.Config.Debug then
            print(string.format("[MySQL Data] Unsuccessfully received data %s for player %s, error: %s", formattedColumn, nick, strError))
        end
    end

    query:start()
end

function MySQLPData:GetData(column, database, tableName, funcCallback, whereCol, whereData)
    database = MySQLPData.Config.Databases[database]
    column = istable(column) and column or {column}
    whereCol = istable(whereCol) and whereCol or {whereCol}
    whereData = istable(whereData) and whereData or {whereData}

    local formattedColumn,formattedWhere = "",""
    for _,v in ipairs(column) do
        formattedColumn = formattedColumn .. v .. ", "
    end

    for i = 1, #whereCol do
        formattedWhere = formattedWhere .. whereCol[i] .. "='" .. whereData[i] .. "', "
    end

    formattedColumn = string.sub(formattedColumn, 1, #formattedColumn - 2)  

    if #formattedWhere > 1 then formattedWhere = string.sub(formattedWhere, 1, #formattedWhere - 2) end

    local query = database.CONN:query("SELECT " .. formattedColumn .. " FROM ".. tableName .. (#formattedWhere < 1 and "" or (" WHERE " .. formattedWhere)))
    function query:onSuccess(tblData)
        if MySQLPData.Config.Debug then
            print(string.format("[MySQL Data] Successfully received data %s!", formattedColumn))
        end

        if #tblData == 0 then 
            funcCallback(nil)
        else
            funcCallback(tblData)
        end
    end

    function query:onError(strError)
        if MySQLPData.Config.Debug then
            print(string.format("[MySQL Data] Unsuccessfully received data %s, error: %s", formattedColumn, strError))
        end
    end

    query:start()
end

function MySQLPData:SetData(column, database, tableName, data, whereCol, whereData, type)
    column = istable(column) and column or {column}
    whereCol = istable(whereCol) and whereCol or {whereCol}
    whereData = istable(whereData) and whereData or {whereData}
    if type then type = istable(type) and type or {type} end
    data = istable(data) and data or {data}
    database = MySQLPData.Config.Databases[database]
    
    database:SetupTable(tableName)

    local formattedColumn, formattedData, formattedOnDupe, formattedTypes,formattedWhere = "","","","",""

    for i = 1, #column do
        formattedOnDupe = formattedOnDupe .. column[i] .. "='" .. data[i] .. "', "
        if type then formattedTypes = formattedTypes .. column[i] .. " " .. type[i] .. ", " end
    end

    for i = 1, #whereCol do
        formattedWhere = formattedWhere .. whereCol[i] .. "='" .. whereData[i] .. "', "
    end

    for _,v in ipairs(column) do
        formattedColumn = formattedColumn .. v .. ", "
    end

    for _,v in ipairs(data) do
        formattedData = formattedData .. "'".. v .. "', "
    end

    formattedColumn = string.sub(formattedColumn, 1, #formattedColumn - 2)
    formattedData = string.sub(formattedData, 1, #formattedData - 2)
    formattedOnDupe = string.sub(formattedOnDupe, 1, #formattedOnDupe - 2)
    if #formattedWhere > 1 then formattedWhere = string.sub(formattedWhere, 1, #formattedWhere - 2) end
    if type then formattedTypes = string.sub(formattedTypes, 1, #formattedTypes - 2) end

    local query = ""
    if type then query = "ALTER TABLE " .. tableName .. " ADD COLUMN IF NOT EXISTS (" .. formattedTypes .. ")" .. ";" end
    if #formattedWhere > 1 then query = database.CONN:query("UPDATE " .. tableName .. " SET " .. formattedOnDupe .. " WHERE " .. formattedWhere)
    else query = database.CONN:query(query .. "INSERT INTO " .. tableName .. " (" .. formattedColumn .. ") VALUES (" .. formattedData .. ") ON DUPLICATE KEY UPDATE " .. formattedOnDupe) end

    function query:onSuccess()
        if MySQLPData.Config.Debug then
            print("[MySQL Data] Successfully set data " .. formattedColumn .. "!")
        end
    end
    function query:onError(strError)
        if MySQLPData.Config.Debug then
            print(string.format("[MySQL Data] Unsuccessfully set data %s, error: %s", formattedColumn, strError))
        end
    end
    query:start()
end