--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L     = {}
local UIS     = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lp      = Players.LocalPlayer

-- =============================================
--         VARIÁVEIS DE CONTROLE
-- =============================================
local espAtivo         = false
local autoGunAtivo     = false
local flingEmAndamento = false
local espConexoes      = {}

-- =============================================
--   PROTEÇÃO CONTRA RESET / MORTE
--   Coloca a GUI na CoreGui: ela nunca é
--   destruída quando o personagem morre/reseta.
-- =============================================

-- Remove instância antiga se existir (evita duplicatas ao re-executar)
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("MM2Script")
    if old then old:Destroy() end
end)
pcall(function()
    local old = lp:WaitForChild("PlayerGui"):FindFirstChild("MM2Script")
    if old then old:Destroy() end
end)

-- Cria a ScreenGui
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
G2L["1"].ResetOnSpawn   = false
G2L["1"].IgnoreGuiInset = true
G2L["1"].Name           = "MM2Script"

-- Tenta colocar na CoreGui (persiste 100% mesmo com reset/morte)
local colocouNaCoreGui = pcall(function()
    G2L["1"].Parent = game:GetService("CoreGui")
end)

-- Fallback: PlayerGui com ResetOnSpawn = false
if not colocouNaCoreGui or G2L["1"].Parent ~= game:GetService("CoreGui") then
    G2L["1"].Parent = lp:WaitForChild("PlayerGui")
end

-- Segurança extra: se a GUI for removida, recria o parent
task.spawn(function()
    while task.wait(2) do
        if not G2L["1"] then break end
        if not G2L["1"].Parent then
            pcall(function() G2L["1"].Parent = game:GetService("CoreGui") end)
            if not G2L["1"].Parent then
                pcall(function() G2L["1"].Parent = lp:WaitForChild("PlayerGui") end)
            end
        end
    end
end)

-- =============================================
--   HELPER: drag genérico (funciona em qualquer GuiObject)
-- =============================================
local function makeDraggable(obj)
    local dragging  = false
    local dragInput = nil
    local dragStart = nil
    local startPos  = nil

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =============================================
--    BOTÃO REABRIR — visível e arrastável quando minimizado
-- =============================================
local reabrirBtn = Instance.new("TextButton", G2L["1"])
reabrirBtn.Name             = "ReopenButton"
reabrirBtn.Size             = UDim2.new(0, 120, 0, 36)
reabrirBtn.Position         = UDim2.new(0.37434, 0, 0.21622, 0)
reabrirBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
reabrirBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
reabrirBtn.Text             = "▲  SCRIPT MM2"
reabrirBtn.TextSize         = 13
reabrirBtn.BorderSizePixel  = 0
reabrirBtn.FontFace         = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold)
reabrirBtn.Visible          = false
reabrirBtn.ZIndex           = 15
reabrirBtn.Active           = true
Instance.new("UICorner", reabrirBtn).CornerRadius = UDim.new(0, 8)

-- Drag habilitado no botão minimizado
makeDraggable(reabrirBtn)

-- =============================================
--         MENU PRINCIPAL
-- =============================================
G2L["2"] = Instance.new("Frame", G2L["1"])
G2L["2"].BorderSizePixel  = 0
G2L["2"].BackgroundColor3 = Color3.fromRGB(174, 174, 174)
G2L["2"].Size             = UDim2.new(0, 389, 0, 272)
G2L["2"].Position         = UDim2.new(0.37434, 0, 0.21622, 0)
G2L["2"].Name             = "Menu"
Instance.new("UICorner", G2L["2"])

-- =============================================
--     BOTÃO FECHAR (X) — destroi toda a GUI
-- =============================================
local btnFechar = Instance.new("TextButton", G2L["2"])
btnFechar.Name             = "BtnFechar"
btnFechar.Size             = UDim2.new(0, 28, 0, 28)
btnFechar.Position         = UDim2.new(1, -32, 0, 4)
btnFechar.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
btnFechar.TextColor3       = Color3.fromRGB(255, 255, 255)
btnFechar.Text             = "X"
btnFechar.TextSize         = 16
btnFechar.BorderSizePixel  = 0
btnFechar.FontFace         = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold)
btnFechar.ZIndex           = 10
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 6)

btnFechar.MouseButton1Click:Connect(function()
    G2L["1"]:Destroy()
end)

-- =============================================
--     BOTÃO MINIMIZAR (-) — esconde e mostra reabrirBtn
-- =============================================
local btnMinimizar = Instance.new("TextButton", G2L["2"])
btnMinimizar.Name             = "BtnMinimizar"
btnMinimizar.Size             = UDim2.new(0, 28, 0, 28)
btnMinimizar.Position         = UDim2.new(1, -64, 0, 4)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
btnMinimizar.TextColor3       = Color3.fromRGB(255, 255, 255)
btnMinimizar.Text             = "─"
btnMinimizar.TextSize         = 18
btnMinimizar.BorderSizePixel  = 0
btnMinimizar.FontFace         = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold)
btnMinimizar.ZIndex           = 10
Instance.new("UICorner", btnMinimizar).CornerRadius = UDim.new(0, 6)

btnMinimizar.MouseButton1Click:Connect(function()
    -- Coloca o botão reabrir na mesma posição que o menu está agora
    reabrirBtn.Position = G2L["2"].Position
    G2L["2"].Visible    = false
    G2L["17"].Visible   = false
    reabrirBtn.Visible  = true
end)

reabrirBtn.MouseButton1Click:Connect(function()
    -- Restaura menu onde o botão reabrir foi largado
    G2L["2"].Position  = reabrirBtn.Position
    G2L["17"].Position = reabrirBtn.Position
    G2L["2"].Visible   = true
    G2L["17"].Visible  = true
    reabrirBtn.Visible = false
end)

-- =============================================
--         TÍTULO
-- =============================================
G2L["4"] = Instance.new("TextLabel", G2L["2"])
G2L["4"].BorderSizePixel  = 0
G2L["4"].TextSize         = 44
G2L["4"].TextXAlignment   = Enum.TextXAlignment.Left
G2L["4"].BackgroundColor3 = Color3.fromRGB(82, 82, 82)
G2L["4"].FontFace         = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["4"].TextColor3       = Color3.fromRGB(0, 0, 0)
G2L["4"].Size             = UDim2.new(0, 230, 0, 50)
G2L["4"].Text             = "SCRIPT"
G2L["4"].Name             = "titulo"
G2L["4"].Position         = UDim2.new(0.30591, 0, 0, 0)
Instance.new("UICorner", G2L["4"]).Name = "UICorner1"

G2L["6"] = Instance.new("TextLabel", G2L["4"])
G2L["6"].BorderSizePixel      = 0
G2L["6"].TextSize             = 44
G2L["6"].BackgroundTransparency = 1
G2L["6"].FontFace             = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["6"].TextColor3           = Color3.fromRGB(255, 0, 0)
G2L["6"].Size                 = UDim2.new(0, 200, 0, 50)
G2L["6"].Text                 = "MM2"
G2L["6"].Position             = UDim2.new(0.2, 0, 0, 0)

-- =============================================
--         PART HOME
-- =============================================
G2L["7"] = Instance.new("Folder", G2L["2"])
G2L["7"].Name = "part home"

G2L["8"] = Instance.new("ImageLabel", G2L["7"])
G2L["8"].BorderSizePixel      = 0
G2L["8"].Image                = "rbxassetid://94403382997032"
G2L["8"].Size                 = UDim2.new(0, 122, 0, 122)
G2L["8"].BackgroundTransparency = 1
G2L["8"].Position             = UDim2.new(0.30567, 0, 0.55072, 0)

G2L["9"] = Instance.new("TextLabel", G2L["7"])
G2L["9"].BorderSizePixel      = 0
G2L["9"].TextSize             = 31
G2L["9"].BackgroundTransparency = 1
G2L["9"].FontFace             = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["9"].TextColor3           = Color3.fromRGB(0, 0, 0)
G2L["9"].Size                 = UDim2.new(0, 200, 0, 50)
G2L["9"].Text                 = "Creator: ByteBandit_Ofici"
G2L["9"].Position             = UDim2.new(0.39589, 0, 0.27206, 0)

-- =============================================
--         PART ESP
-- =============================================
G2L["a"] = Instance.new("Folder", G2L["2"])
G2L["a"].Name = "part Esp"

G2L["b"] = Instance.new("TextLabel", G2L["a"])
G2L["b"].TextWrapped          = true
G2L["b"].BorderSizePixel      = 0
G2L["b"].TextScaled           = true
G2L["b"].TextXAlignment       = Enum.TextXAlignment.Left
G2L["b"].BackgroundColor3     = Color3.fromRGB(92, 92, 92)
G2L["b"].FontFace             = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["b"].TextColor3           = Color3.fromRGB(0, 0, 0)
G2L["b"].BackgroundTransparency = 0.25
G2L["b"].Size                 = UDim2.new(0, 270, 0, 26)
G2L["b"].Text                 = "ESP - sees all the players and shows if they are murder, sheriff, or innocent."
G2L["b"].Position             = UDim2.new(0.30334, 0, 0.31618, 0)
Instance.new("UICorner", G2L["b"])

G2L["d"] = Instance.new("TextButton", G2L["b"])
G2L["d"].BorderSizePixel      = 0
G2L["d"].TextSize             = 21
G2L["d"].TextColor3           = Color3.fromRGB(255, 255, 255)
G2L["d"].BackgroundColor3     = Color3.fromRGB(200, 0, 0)
G2L["d"].FontFace             = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["d"].BackgroundTransparency = 0.2
G2L["d"].Size                 = UDim2.new(0, 144, 0, 13)
G2L["d"].Text                 = "ESP: OFF"
G2L["d"].Position             = UDim2.new(0.37037, 0, 0.5, 0)

-- ESP lógica
local function limparESP()
    for _, c in pairs(espConexoes) do c:Disconnect() end
    espConexoes = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local h = p.Character:FindFirstChild("ESPHighlight")
            if h then h:Destroy() end
            local bb = p.Character:FindFirstChild("ESPLabel")
            if bb then bb:Destroy() end
        end
    end
end

-- =============================================
--   DETECÇÃO DE ROLE
--   murder  = tem Tool "Knife"  na Backpack ou equipada
--   sheriff = tem Tool "Gun"    na Backpack ou equipada
-- =============================================
local function getRolePlayer(player)
    -- Checa na Backpack e no próprio personagem (Tool equipada)
    local function temTool(name)
        local bp = player:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild(name) then return true end
        local ch = player.Character
        if ch and ch:FindFirstChild(name) then return true end
        return false
    end
    if temTool("Knife") then return "murder" end
    if temTool("Gun")   then return "sheriff" end
    return "innocent"
end

local function getCorESP(player)
    local role = getRolePlayer(player)
    if role == "murder"   then return Color3.fromRGB(255, 50, 50)  end
    if role == "sheriff"  then return Color3.fromRGB(50, 150, 255) end
    return Color3.fromRGB(50, 255, 100)
end

local function aplicarESP(player)
    if player == lp then return end
    local char = player.Character or player.CharacterAdded:Wait()
    local h = Instance.new("Highlight", char)
    h.Name              = "ESPHighlight"
    h.FillTransparency  = 0.6
    h.OutlineTransparency = 0
    h.FillColor         = getCorESP(player)
    h.OutlineColor      = getCorESP(player)
    local bb = Instance.new("BillboardGui", char)
    bb.Name        = "ESPLabel"
    bb.Size        = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.Text                   = player.Name
    lbl.TextSize               = 14
    lbl.FontFace               = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold)
end

local function ativarESP()
    for _, p in pairs(Players:GetPlayers()) do aplicarESP(p) end
    local c = Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(1)
            if espAtivo then aplicarESP(p) end
        end)
    end)
    table.insert(espConexoes, c)
end

-- Reconecta o ESP nos outros jogadores sempre que o personagem local respawna
lp.CharacterAdded:Connect(function()
    task.wait(1.5)
    if espAtivo then
        -- Remove highlights antigos dos outros jogadores
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local h  = p.Character:FindFirstChild("ESPHighlight")
                local bb = p.Character:FindFirstChild("ESPLabel")
                if h  then h:Destroy()  end
                if bb then bb:Destroy() end
            end
        end
        -- Reaplicar ESP em todos
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp then task.spawn(function() aplicarESP(p) end) end
        end
    end
end)

G2L["d"].MouseButton1Click:Connect(function()
    espAtivo = not espAtivo
    if espAtivo then
        G2L["d"].Text             = "ESP: ON"
        G2L["d"].BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        ativarESP()
    else
        G2L["d"].Text             = "ESP: OFF"
        G2L["d"].BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        limparESP()
    end
end)

-- =============================================
--   PART FLING — botão ativa por 5 segundos com countdown
-- =============================================
G2L["e"] = Instance.new("Folder", G2L["2"])
G2L["e"].Name = "Part Fling"

-- Label Fling ao Murder
G2L["f"] = Instance.new("TextLabel", G2L["e"])
G2L["f"].TextWrapped          = true
G2L["f"].BorderSizePixel      = 0
G2L["f"].TextScaled           = true
G2L["f"].TextXAlignment       = Enum.TextXAlignment.Left
G2L["f"].BackgroundColor3     = Color3.fromRGB(92, 92, 92)
G2L["f"].FontFace             = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["f"].TextColor3           = Color3.fromRGB(0, 0, 0)
G2L["f"].BackgroundTransparency = 0.25
G2L["f"].Size                 = UDim2.new(0, 270, 0, 26)
G2L["f"].Text                 = "Fling ao Murder"
G2L["f"].Position             = UDim2.new(0.30591, 0, 0.31985, 0)
Instance.new("UICorner", G2L["f"])

-- Botão Fling Murder
G2L["11"] = Instance.new("TextButton", G2L["f"])
G2L["11"].BorderSizePixel     = 0
G2L["11"].TextSize            = 12
G2L["11"].TextColor3          = Color3.fromRGB(255, 255, 255)
G2L["11"].BackgroundColor3    = Color3.fromRGB(180, 60, 0)
G2L["11"].FontFace            = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold)
G2L["11"].Size                = UDim2.new(0, 55, 0, 26)
G2L["11"].Text                = "FLING"
G2L["11"].Position            = UDim2.new(0.58, 0, -0.03846, 0)

-- Label Fling ao Sheriff
G2L["12"] = Instance.new("TextLabel", G2L["e"])
G2L["12"].TextWrapped         = true
G2L["12"].BorderSizePixel     = 0
G2L["12"].TextScaled          = true
G2L["12"].TextXAlignment      = Enum.TextXAlignment.Left
G2L["12"].BackgroundColor3    = Color3.fromRGB(92, 92, 92)
G2L["12"].FontFace            = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["12"].TextColor3          = Color3.fromRGB(0, 0, 0)
G2L["12"].BackgroundTransparency = 0.25
G2L["12"].Size                = UDim2.new(0, 270, 0, 26)
G2L["12"].Text                = "Fling ao Sheriff"
G2L["12"].Name                = "TextLabel1"
G2L["12"].Position            = UDim2.new(0.30591, 0, 0.41544, 0)
Instance.new("UICorner", G2L["12"])

-- Botão Fling Sheriff
G2L["14"] = Instance.new("TextButton", G2L["12"])
G2L["14"].BorderSizePixel     = 0
G2L["14"].TextSize            = 12
G2L["14"].TextColor3          = Color3.fromRGB(255, 255, 255)
G2L["14"].BackgroundColor3    = Color3.fromRGB(0, 80, 180)
G2L["14"].FontFace            = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold)
G2L["14"].Size                = UDim2.new(0, 55, 0, 26)
G2L["14"].Text                = "FLING"
G2L["14"].Position            = UDim2.new(0.58, 0, -0.03846, 0)

-- =============================================
--     LÓGICA FLING — 5 segundos com countdown no botão
-- =============================================
local function flingPlayer(target)
    local char = lp.Character
    if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tc   = target.Character
    if not tc then return end
    local thrp = tc:FindFirstChild("HumanoidRootPart")
    if not thrp then return end
    hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, -2)
    task.wait(0.05)
    local vel = Instance.new("BodyVelocity", thrp)
    vel.Velocity  = Vector3.new(math.random(-100, 100), 150, math.random(-100, 100))
    vel.MaxForce  = Vector3.new(1e6, 1e6, 1e6)
    game:GetService("Debris"):AddItem(vel, 0.25)
end

local function getFlingTarget(role)
    -- role: "murder" ou "sheriff"
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            if getRolePlayer(p) == role then return p end
        end
    end
    return nil
end

--[[
    executarFling5s:
    - Ativa fling por 5 segundos
    - Exibe countdown no botão: "5s" → "4s" → ... → "1s" → "FLING"
    - Durante esse tempo faz fling a cada segundo
    - Só um fling pode rodar por vez (flingEmAndamento)
]]
local function executarFling5s(btn, role, corAtiva, corBase)
    if flingEmAndamento then return end
    flingEmAndamento     = true
    btn.BackgroundColor3 = corAtiva

    task.spawn(function()
        for t = 5, 1, -1 do
            btn.Text = t .. "s"
            local target = getFlingTarget(role)
            if target then flingPlayer(target) end
            task.wait(1)
        end
        -- Resetar botão
        btn.Text             = "FLING"
        btn.BackgroundColor3 = corBase
        flingEmAndamento     = false
    end)
end

G2L["11"].MouseButton1Click:Connect(function()
    executarFling5s(
        G2L["11"], "murder",
        Color3.fromRGB(255, 140, 0),
        Color3.fromRGB(180, 60, 0)
    )
end)

G2L["14"].MouseButton1Click:Connect(function()
    executarFling5s(
        G2L["14"], "sheriff",
        Color3.fromRGB(0, 180, 255),
        Color3.fromRGB(0, 80, 180)
    )
end)

-- =============================================
--         PART GUN (AUTO GUN)
-- =============================================
G2L["15"] = Instance.new("Folder", G2L["2"])
G2L["15"].Name = "part Gun"

G2L["16"] = Instance.new("TextButton", G2L["15"])
G2L["16"].BorderSizePixel     = 0
G2L["16"].TextSize            = 42
G2L["16"].TextColor3          = Color3.fromRGB(255, 255, 255)
G2L["16"].BackgroundColor3    = Color3.fromRGB(180, 0, 0)
G2L["16"].FontFace            = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold)
G2L["16"].Size                = UDim2.new(0, 217, 0, 110)
G2L["16"].Text                = "AUTO GUN\nOFF"
G2L["16"].Position            = UDim2.new(0.35219, 0, 0.27206, 0)
Instance.new("UICorner", G2L["16"]).CornerRadius = UDim.new(0, 8)

-- =============================================
--   AUTO GUN — Pega arma automaticamente quando alguém morre
--   Lógica:
--     1. Detecta quando qualquer jogador morre (Humanoid.Died)
--     2. Salva a posição atual do nosso HumanoidRootPart
--     3. Teleporta até o HumanoidRootPart do morto
--     4. Aguarda a Tool "Gun" cair no chão (DropTool do MM2)
--     5. Toca/equipa a tool
--     6. Volta para a posição original
-- =============================================

local autoGunConexoes = {}

local function monitorarMortes()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local conn
                conn = hum.Died:Connect(function()
                    conn:Disconnect()
                    if not autoGunAtivo then return end

                    local char = lp.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    -- Salva posição original
                    local posOriginal = hrp.CFrame

                    -- Posição onde o jogador morreu
                    local charMorto = p.Character
                    if not charMorto then return end
                    local hrpMorto = charMorto:FindFirstChild("HumanoidRootPart")
                    if not hrpMorto then return end
                    local posMorto = hrpMorto.CFrame

                    -- Teleporta até o morto
                    hrp.CFrame = posMorto * CFrame.new(0, 0, -1.5)
                    task.wait(0.3)

                    -- Procura a tool "Gun" caída no workspace (DropTool vira Tool no workspace)
                    local gunTool = nil
                    for tentativa = 1, 15 do
                        for _, obj in pairs(game.Workspace:GetDescendants()) do
                            if obj:IsA("Tool") and obj.Name == "Gun" and obj.Parent ~= lp.Character then
                                -- Verifica se está próxima do local onde o jogador morreu
                                local handle = obj:FindFirstChild("Handle")
                                if handle then
                                    local dist = (handle.Position - posMorto.Position).Magnitude
                                    if dist < 20 then
                                        gunTool = obj
                                        break
                                    end
                                end
                            end
                        end
                        if gunTool then break end
                        task.wait(0.2)
                    end

                    if gunTool then
                        -- Equipa a tool (método nativo do Roblox)
                        local hum2 = char:FindFirstChildOfClass("Humanoid")
                        if hum2 then
                            hum2:EquipTool(gunTool)
                        end
                        task.wait(0.2)
                    end

                    -- Volta para a posição original
                    if hrp and hrp.Parent then
                        hrp.CFrame = posOriginal
                    end
                end)
                table.insert(autoGunConexoes, conn)
            end
        end
    end
end

local function iniciarAutoGun()
    -- Monitora jogadores que já estão no jogo
    monitorarMortes()

    -- Monitora novos personagens que spawnam
    local c = Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            task.wait(1)
            if autoGunAtivo then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local conn
                    conn = hum.Died:Connect(function()
                        conn:Disconnect()
                        -- reusar a lógica acima
                        if not autoGunAtivo then return end
                        local myChar = lp.Character
                        if not myChar then return end
                        local hrp = myChar:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        local posOriginal = hrp.CFrame
                        local hrpMorto = char:FindFirstChild("HumanoidRootPart")
                        if not hrpMorto then return end
                        local posMorto = hrpMorto.CFrame
                        hrp.CFrame = posMorto * CFrame.new(0, 0, -1.5)
                        task.wait(0.3)
                        local gunTool = nil
                        for tentativa = 1, 15 do
                            for _, obj in pairs(game.Workspace:GetDescendants()) do
                                if obj:IsA("Tool") and obj.Name == "Gun" and obj.Parent ~= lp.Character then
                                    local handle = obj:FindFirstChild("Handle")
                                    if handle and (handle.Position - posMorto.Position).Magnitude < 20 then
                                        gunTool = obj; break
                                    end
                                end
                            end
                            if gunTool then break end
                            task.wait(0.2)
                        end
                        if gunTool then
                            local hum2 = myChar:FindFirstChildOfClass("Humanoid")
                            if hum2 then hum2:EquipTool(gunTool) end
                            task.wait(0.2)
                        end
                        if hrp and hrp.Parent then hrp.CFrame = posOriginal end
                    end)
                    table.insert(autoGunConexoes, conn)
                end
            end
        end)
    end)
    table.insert(autoGunConexoes, c)

    -- Quando os chars existentes respawnam, remonitorar
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then
            local cc = p.CharacterAdded:Connect(function(char)
                task.wait(1)
                if not autoGunAtivo then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local conn
                    conn = hum.Died:Connect(function()
                        conn:Disconnect()
                        if not autoGunAtivo then return end
                        local myChar = lp.Character
                        if not myChar then return end
                        local hrp = myChar:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        local posOriginal = hrp.CFrame
                        local hrpMorto = char:FindFirstChild("HumanoidRootPart")
                        if not hrpMorto then return end
                        local posMorto = hrpMorto.CFrame
                        hrp.CFrame = posMorto * CFrame.new(0, 0, -1.5)
                        task.wait(0.3)
                        local gunTool = nil
                        for tentativa = 1, 15 do
                            for _, obj in pairs(game.Workspace:GetDescendants()) do
                                if obj:IsA("Tool") and obj.Name == "Gun" and obj.Parent ~= lp.Character then
                                    local handle = obj:FindFirstChild("Handle")
                                    if handle and (handle.Position - posMorto.Position).Magnitude < 20 then
                                        gunTool = obj; break
                                    end
                                end
                            end
                            if gunTool then break end
                            task.wait(0.2)
                        end
                        if gunTool then
                            local hum2 = myChar:FindFirstChildOfClass("Humanoid")
                            if hum2 then hum2:EquipTool(gunTool) end
                            task.wait(0.2)
                        end
                        if hrp and hrp.Parent then hrp.CFrame = posOriginal end
                    end)
                    table.insert(autoGunConexoes, conn)
                end
            end)
            table.insert(autoGunConexoes, cc)
        end
    end
end

local function pararAutoGun()
    for _, c in pairs(autoGunConexoes) do pcall(function() c:Disconnect() end) end
    autoGunConexoes = {}
end

G2L["16"].MouseButton1Click:Connect(function()
    autoGunAtivo = not autoGunAtivo
    if autoGunAtivo then
        G2L["16"].Text             = "AUTO GUN\nON"
        G2L["16"].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        iniciarAutoGun()
    else
        G2L["16"].Text             = "AUTO GUN\nOFF"
        G2L["16"].BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        pararAutoGun()
    end
end)

-- =============================================
--         PAINEL LATERAL DE BOTÕES
-- =============================================
G2L["17"] = Instance.new("ScrollingFrame", G2L["1"])
G2L["17"].Active           = true
G2L["17"].BorderSizePixel  = 0
G2L["17"].Name             = "buttons"
G2L["17"].BackgroundColor3 = Color3.fromRGB(107, 107, 107)
G2L["17"].Size             = UDim2.new(0, 119, 0, 272)
G2L["17"].Position         = UDim2.new(0.37434, 0, 0.21622, 0)
Instance.new("UICorner", G2L["17"]).Name = "UICorner1"

local function criarBotaoLateral(nome, posY, imgId)
    local btn = Instance.new("TextButton", G2L["17"])
    btn.BorderSizePixel  = 0
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.TextSize         = 41
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.FontFace         = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
    btn.Size             = UDim2.new(0, 107, 0, 50)
    btn.Text             = nome
    btn.Name             = nome
    btn.Position         = UDim2.new(0, 0, posY, 0)
    Instance.new("UICorner", btn).Name = "UICorner2"
    local img = Instance.new("ImageLabel", btn)
    img.BorderSizePixel      = 0
    img.BackgroundTransparency = 1
    img.Image                = "rbxassetid://" .. imgId
    img.Size                 = UDim2.new(0, 24, 0, 24)
    img.Position             = UDim2.new(0.7757, 0, 0.26, 0)
    return btn
end

G2L["19"] = criarBotaoLateral("Home",  0,       "13060262529")
G2L["1c"] = criarBotaoLateral("Esp",   0.04826, "13005394944")
G2L["1f"] = criarBotaoLateral("Fling", 0.09653, "17360939501")
G2L["23"] = criarBotaoLateral("Gun",   0.14382, "72113894373892")

-- Beta label
G2L["22"] = Instance.new("TextLabel", G2L["17"])
G2L["22"].BorderSizePixel      = 0
G2L["22"].TextSize             = 21
G2L["22"].TextTransparency     = 0.33
G2L["22"].BackgroundTransparency = 1
G2L["22"].FontFace             = Font.new([[rbxasset://fonts/families/SourceSansPro.json]])
G2L["22"].TextColor3           = Color3.fromRGB(0, 0, 0)
G2L["22"].Size                 = UDim2.new(0, 107, 0, 50)
G2L["22"].Text                 = "Beta update"
G2L["22"].Name                 = ":/"
G2L["22"].Position             = UDim2.new(0, 0, 0.19788, 0)

-- =============================================
--         NAVEGAÇÃO ENTRE ABAS
-- =============================================
local function mostrarAba(nome)
    G2L["7"].Parent  = (nome == "Home")  and G2L["2"] or game:GetService("CoreGui")
    G2L["a"].Parent  = (nome == "Esp")   and G2L["2"] or game:GetService("CoreGui")
    G2L["e"].Parent  = (nome == "Fling") and G2L["2"] or game:GetService("CoreGui")
    G2L["15"].Parent = (nome == "Gun")   and G2L["2"] or game:GetService("CoreGui")
end

G2L["7"].Parent  = G2L["2"]
G2L["a"].Parent  = game:GetService("CoreGui")
G2L["e"].Parent  = game:GetService("CoreGui")
G2L["15"].Parent = game:GetService("CoreGui")

G2L["19"].MouseButton1Click:Connect(function() mostrarAba("Home") end)
G2L["1c"].MouseButton1Click:Connect(function() mostrarAba("Esp") end)
G2L["1f"].MouseButton1Click:Connect(function() mostrarAba("Fling") end)
G2L["23"].MouseButton1Click:Connect(function() mostrarAba("Gun") end)

-- =============================================
--   ARRASTAR MENU PRINCIPAL (sincroniza painel lateral)
-- =============================================
local dragging  = false
local dragInput = nil
local dragStart = nil
local startPos  = nil

G2L["2"].InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = G2L["2"].Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

G2L["2"].InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta  = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        G2L["2"].Position  = newPos
        G2L["17"].Position = newPos
    end
end)

-- =============================================
--         GRADIENTE
-- =============================================
G2L["26"] = Instance.new("UIGradient", G2L["1"])
G2L["26"].Name  = "roxo"
G2L["26"].Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.486, Color3.fromRGB(134, 15, 158)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(7, 255, 255))
}

-- =============================================
return G2L["1"], require