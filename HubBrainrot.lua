local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local Jugador = game.Players.LocalPlayer

-- ==========================================
-- 1. CREACIÓN DE LA INTERFAZ (MENÚ PRO)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HubBrainrotHopper"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999

if gethui then
    ScreenGui.Parent = gethui()
else
    local success = pcall(function() ScreenGui.Parent = game.CoreGui end)
    if not success then ScreenGui.Parent = Jugador:WaitForChild("PlayerGui") end
end

-- Marco Principal (Ajustado para el medidor de ping)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.5, -100, 0.2, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚙️ Server Hopper Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local TitleBlock = Instance.new("Frame")
TitleBlock.Parent = Title
TitleBlock.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
TitleBlock.Position = UDim2.new(0, 0, 0.5, 0)
TitleBlock.Size = UDim2.new(1, 0, 0.5, 0)
TitleBlock.BorderSizePixel = 0

-- Contenedor de Botones
local Contenedor = Instance.new("Frame")
Contenedor.Parent = MainFrame
Contenedor.BackgroundTransparency = 1
Contenedor.Position = UDim2.new(0, 0, 0, 35)
Contenedor.Size = UDim2.new(1, 0, 1, -35)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Contenedor
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local Spacer = Instance.new("Frame")
Spacer.Parent = Contenedor
Spacer.BackgroundTransparency = 1
Spacer.Size = UDim2.new(1, 0, 0, 2)

-- Etiqueta de Estado
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Contenedor
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(0, 200, 0, 15)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Estado: Esperando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true

-- Etiqueta de Ping Actual (NUEVO)
local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = Contenedor
PingLabel.BackgroundTransparency = 1
PingLabel.Size = UDim2.new(0, 200, 0, 15)
PingLabel.Font = Enum.Font.GothamBold
PingLabel.Text = "📡 Ping Actual: Calculando..."
PingLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
PingLabel.TextSize = 12

-- Botones
local BotonHop = Instance.new("TextButton")
BotonHop.Parent = Contenedor
BotonHop.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
BotonHop.Size = UDim2.new(0, 190, 0, 35)
BotonHop.Font = Enum.Font.GothamBold
BotonHop.Text = "🎲 Saltar de Servidor"
BotonHop.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonHop.TextSize = 14
Instance.new("UICorner", BotonHop).CornerRadius = UDim.new(0, 6)

local BotonFiltro = Instance.new("TextButton")
BotonFiltro.Parent = Contenedor
BotonFiltro.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
BotonFiltro.Size = UDim2.new(0, 190, 0, 30)
BotonFiltro.Font = Enum.Font.GothamSemibold
BotonFiltro.Text = "👥 Jugadores: 1-2"
BotonFiltro.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonFiltro.TextSize = 12
Instance.new("UICorner", BotonFiltro).CornerRadius = UDim.new(0, 6)

local BotonPing = Instance.new("TextButton")
BotonPing.Parent = Contenedor
BotonPing.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
BotonPing.Size = UDim2.new(0, 190, 0, 30)
BotonPing.Font = Enum.Font.GothamSemibold
BotonPing.Text = "📶 Ping: Mejor a 150ms"
BotonPing.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonPing.TextSize = 12
Instance.new("UICorner", BotonPing).CornerRadius = UDim.new(0, 6)

local BotonRecargar = Instance.new("TextButton")
BotonRecargar.Parent = Contenedor
BotonRecargar.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
BotonRecargar.Size = UDim2.new(0, 190, 0, 30)
BotonRecargar.Font = Enum.Font.GothamSemibold
BotonRecargar.Text = "🔄 Limpiar Caché"
BotonRecargar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonRecargar.TextSize = 12
Instance.new("UICorner", BotonRecargar).CornerRadius = UDim.new(0, 6)


-- ==========================================
-- 2. LÓGICA DEL SCRIPT
-- ==========================================

-- Sistema de actualización de Ping en tiempo real
task.spawn(function()
    while task.wait(1) do
        local success, pingValor = pcall(function()
            -- Lee los datos de red internos de Roblox
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        
        if success and pingValor then
            local pingFormateado = math.floor(pingValor)
            PingLabel.Text = "📡 Ping Actual: " .. pingFormateado .. " ms"
            
            -- Cambia el color dependiendo de si el ping es bueno o malo
            if pingFormateado <= 100 then
                PingLabel.TextColor3 = Color3.fromRGB(0, 255, 128) -- Verde
            elseif pingFormateado <= 200 then
                PingLabel.TextColor3 = Color3.fromRGB(255, 170, 0) -- Naranja
            else
                PingLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Rojo
            end
        else
            PingLabel.Text = "📡 Ping Actual: N/A"
            PingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)


local fileName = "CacheBrainrot_Pro_V3.json"
local usarFiltroEstricto = true
local usarFiltroPing = true

-- Lógica Filtro de Jugadores
BotonFiltro.MouseButton1Click:Connect(function()
    usarFiltroEstricto = not usarFiltroEstricto
    if usarFiltroEstricto then
        BotonFiltro.Text = "👥 Jugadores: 1-2"
        BotonFiltro.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
    else
        BotonFiltro.Text = "👥 Jugadores: Cualquiera"
        BotonFiltro.BackgroundColor3 = Color3.fromRGB(160, 100, 40)
    end
    if isfile and isfile(fileName) and delfile then pcall(function() delfile(fileName) end) end
    StatusLabel.Text = "Estado: Filtro actualizado."
end)

-- Lógica Filtro de Ping
BotonPing.MouseButton1Click:Connect(function()
    usarFiltroPing = not usarFiltroPing
    if usarFiltroPing then
        BotonPing.Text = "📶 Ping: Mejor a 150ms"
        BotonPing.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
    else
        BotonPing.Text = "📶 Ping: Cualquiera"
        BotonPing.BackgroundColor3 = Color3.fromRGB(160, 100, 40)
    end
    if isfile and isfile(fileName) and delfile then pcall(function() delfile(fileName) end) end
    StatusLabel.Text = "Estado: Filtro actualizado."
end)

-- Lógica Limpiar Caché
BotonRecargar.MouseButton1Click:Connect(function()
    if isfile and isfile(fileName) and delfile then pcall(function() delfile(fileName) end) end
    StatusLabel.Text = "Estado: Lista vieja borrada."
    BotonRecargar.Text = "¡Limpiado!"
    task.wait(1)
    BotonRecargar.Text = "🔄 Limpiar Caché"
end)

-- Función de Salto
local function saltarServidor()
    StatusLabel.Text = "Estado: Iniciando salto..."
    local servers = {}
    
    if isfile and isfile(fileName) then
        local success, content = pcall(function() return readfile(fileName) end)
        if success and content then
            local successJSON, decoded = pcall(function() return HttpService:JSONDecode(content) end)
            if successJSON and type(decoded) == "table" then servers = decoded end
        end
    end
    
    if #servers == 0 then
        StatusLabel.Text = "Estado: Descargando de Roblox..."
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?limit=100&excludeFullGames=true"
        if usarFiltroEstricto then url = url .. "&sortOrder=Asc" else url = url .. "&sortOrder=Desc" end
        
        local successApi, resultado = pcall(function() return game:HttpGet(url) end)
        
        if successApi and resultado then
            local successJSON, datos = pcall(function() return HttpService:JSONDecode(resultado) end)
            if successJSON and datos and datos.data then
                for _, server in ipairs(datos.data) do
                    if server.playing and server.id ~= game.JobId then
                        
                        local pasaJugadores = false
                        local pasaPing = false
                        
                        if usarFiltroEstricto then
                            if server.playing <= 2 then pasaJugadores = true end
                        else
                            if server.playing < server.maxPlayers then pasaJugadores = true end
                        end
                        
                        if usarFiltroPing then
                            if type(server.ping) == "number" and server.ping <= 150 then
                                pasaPing = true
                            end
                        else
                            pasaPing = true
                        end
                        
                        if pasaJugadores and pasaPing then
                            table.insert(servers, server.id)
                        end
                    end
                end
            end
        end
    end
    
    if #servers > 0 then
        local randomIndex = math.random(1, #servers)
        local serverRandom = servers[randomIndex]
        
        table.remove(servers, randomIndex) 
        
        if writefile then pcall(function() writefile(fileName, HttpService:JSONEncode(servers)) end) end
        
        StatusLabel.Text = "Estado: Teletransportando... (".. #servers .." en reserva)"
        BotonHop.Text = "¡Conectando!"
        BotonHop.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverRandom, Jugador)
    else
        StatusLabel.Text = "Estado: 0 servidores coinciden."
        BotonHop.Text = "No hay Servidores"
        BotonHop.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        if isfile and isfile(fileName) and delfile then pcall(function() delfile(fileName) end) end
        task.wait(2)
        BotonHop.Text = "🎲 Saltar de Servidor"
        BotonHop.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end
end

BotonHop.MouseButton1Click:Connect(function()
    BotonHop.Text = "Buscando..."
    BotonHop.BackgroundColor3 = Color3.fromRGB(200, 150, 20)
    saltarServidor()
end)

TeleportService.TeleportInitFailed:Connect(function()
    StatusLabel.Text = "Estado: Error al entrar. Reintentando..."
    saltarServidor()
end)
