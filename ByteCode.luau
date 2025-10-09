local Module = (function(a, b)
	local _ENV = a

	local Configs = {}
	local Serialized = {}

	local function translate(en, th)
		if Configs['Language'] == "ไทย" then
			return tostring(th)
		end

		return tostring(en)
	end

	Serialized.html = function(text, color)
		if type(text) == "string" and typeof(color) == "Color3" then
			local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

			return string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text)
		end

		return text
	end

	Serialized.Utility = (function()
		local self = {}

		function self:reference(obj)
			return cloneref and cloneref(game:GetService(obj))
		end

		function self:clone(Function)
			return clonefunction and clonefunction(Function)
		end

		return self
	end)()

	Serialized.Configs = (function()
		local self = {
			HttpService = Serialized.Utility:reference('HttpService'),
			Base = "Visual/configs",
		}

		local Folder = self.Base
		local Path = Folder .. "/" .. game.PlaceId .. ".json"

		function self.def(key, value)
			if Configs[key] == nil then
				Configs[key] = value
			end
		end

		function self:Save(index, value)
			if index ~= nil then
				Configs[index] = value
			end

			if not isfolder("Visual") then
				makefolder("Visual")
			end

			if not isfolder(Folder) then
				makefolder(Folder)
			end

			writefile(Path, self.HttpService:JSONEncode(Configs))
		end

		function self:Load()
			if not isfile(Path) then
				self:Save()
			end

			local Files = readfile(Path)
			return self.HttpService:JSONDecode(Files)
		end

		return self
	end)()

	Serialized.Thread = (function()
		local self = {
			Smoothing = false
		}

		function self:SetSmoothing(value)
			self.Smoothing = value
		end

		function self:OnQueue(Queue)
			task.spawn(pcall, function() 
				while task.wait(self.Smoothing and 0.25 or 0) do
					for _, v in pairs(Queue) do
						local Name = v['Name']
						if Configs[Name] then
							local Struction = v["Thread"]()

							if Name and Struction then
								break
							end
						end
					end
				end
			end)
		end

		function self:OnRunning(Options)
			for _, v in pairs(Options) do
				task.spawn(function()
					while task.wait() do
						v['Function']()
					end
				end)
			end
		end

		function self:OnConnections(Options)
			for _, v in pairs(Options) do
				v['Signal']:Connect(v['Action'])
			end
		end

		Serialized.OnQueue = self.OnQueue
		Serialized.OnRunning = self.OnRunning
		Serialized.OnConnections = self.OnConnections

		return self
	end)()

	Serialized.Components = (function()
		local self = {}
		local _Server = loadstring(game:HttpGet('https://raw.githubusercontent.com/realkhaw/Visual/refs/heads/main/GenerateServer.luau', true))()

		function self.new(Visual, Versions)
			return Visual:app({
				Title = "Visual - " .. Versions,
				Footer = "Made by @96soul",
				Enums = Enum.KeyCode.RightControl
			})
		end

		function self:Tabs(Window, asset)
			return Window:Normal(asset)
		end

		function self:Section(Tabs, Title, Desc)
			return Tabs:Element(Title, Desc)
		end

		function self:Paragarp(Section, Title, Desc, Icon, Status)
			return Section:Paragarp({
				Title = Title,
				Icon = Icon,
				Status = Status or "None",
				Desc = Desc
			})
		end

		function self:Button(Section, Title, Desc, Icon, Call)
			return Section:Button({
				Title = Title,
				Icon = Icon,
				Desc = Desc,
				Call = Call,
			})
		end

		function self:Toggle(Section, Title, Desc, Icon, Setting, Call)
			return Section:Toggle({
				Title = Title,
				Desc = Desc,
				Icon = Icon,
				Value = Configs[Setting],
				Call = function(v)
					Configs[Setting] = v
					Serialized.Configs:Save(Setting, v)

					if Call then
						Call(v)
					end
				end,
			})
		end

		function self:Textfield(Section, Title, Desc, Icon , Setting, Call)
			return Section:Textfield({
				Title = Title,
				Icon = Icon,
				Desc = Desc,
				Value = Configs[Setting],
				Call = function(v)
					Configs[Setting] = v
					Serialized.Configs:Save(Setting, v)

					if Call then
						Call(v)
					end
				end,
			})
		end

		function self:Slider(Section, Title, Desc, Icon, Setting, Min, Max, Rounding, Call)
			return Section:Slider({
				Title = Title,
				Icon = Icon,
				Desc = Desc,
				Value = Configs[Setting],
				Min = Min,
				Max = Max,
				Rounding = Rounding,
				Call = function(v)
					Configs[Setting] = v
					Serialized.Configs:Save(Setting, v)

					if Call then
						Call(v)
					end
				end,
			})
		end

		function self:List(Section, Title, Desc, Icon, Setting, List, Type, Multi, Call)
			return Section:Dropdown({
				Title = Title,
				Icon = Icon,
				Type = Type or "Single",
				Advance = {
					['Select'] = translate("Selected", "เลือกแล้ว"),
					['Not Select'] = translate("Not Select", "ยังไม่ได้เลือก"),
					['Clear'] = translate("CLEAR", "เคลียร์"),
					['Select All'] = translate("ALL", "เลือกทั้งหมด"),
					['Search'] = translate("Search", "ค้นหา")
				},
				Multi = Multi,
				Desc = Desc,
				List = List,
				Value = Configs[Setting],
				Call = function(v)
					Configs[Setting] = v
					Serialized.Configs:Save(Setting, v)

					if Call then
						Call(v)
					end
				end,
			})
		end

		self.ServerModule = (function()
			local server = {}

			Serialized.Configs.def('Server List', {})

			function server:genarate(Dropdown)
				local CacheId, _ = _Server:Reserved(game.PlaceId)

				repeat task.wait(0.1) until CacheId ~= nil

				Configs['Server List'] = Configs['Server List'] or {}
				table.insert(Configs['Server List'], CacheId)
				Serialized.Configs:Save('Server List', Configs['Server List'])

				Dropdown:AddList(CacheId)

				return CacheId
			end

			function server:init(selects)
				return _Server:Iris(selects)
			end

			return server
		end)()

		function self:OnJoining(Window)
			local Welcome = self:Tabs(Window, 77072339158371) do
				local WelcomeText = translate("Welcome ", "ยินดีต้อนรับ ") .. b.Name .. translate(" How are you today?", ' วันนี้เป็นยังไงบ้าง?')

				local _1 = self:Section(Welcome, translate("Explore", "สำรวจ"), WelcomeText) do
					_1:Banner({ Size = 250 })
				end

				local _2 = self:Section(Welcome, translate("Social", "โซเชียล"), translate("Follow us on social media for updates and news.", "ติดตามเราในโซเชียลมีเดียเพื่อรับข่าวสารและอัปเดตล่าสุด")) do
					self:Button(_2, translate("Join our Discord", "เข้าร่วมเซิร์ฟเวอร์ Discord ของเรา"), translate("Copy the invite link to your clipboard.", "คัดลอกลิงก์เชิญไปยังคลิปบอร์ด"), nil, function()
						pcall(setclipboard, "https://discord.gg/G4WEysPj8t")
					end)

					self:Button(_2, translate("Contact Owner", "ติดต่อนักพัฒนา"), translate("Copy the link to your clipboard.", "คัดลอกลิงก์ไปยังคลิปบอร์ด"), nil, function()
						pcall(setclipboard, "https://guns.lol/real96soul_")
					end)
				end

				local ServerDropdown

				local _3 = self:Section(Welcome, translate("Free Private Server", "เซิร์ฟเวอร์ส่วนตัวฟรี"), translate("Generate a free private server to play alone or with friends. Use with caution — safety are not guaranteed.","สร้างเซิร์ฟเวอร์ส่วนตัวฟรีเพื่อเล่นคนเดียวหรือกับเพื่อน ใช้อย่างระมัดระวัง — ความปลอดภัยไม่สามารถรับประกันได้")) do
					Serialized.Configs.def('Select Server', "N/A")
					self:Button(_3, translate("Genarate", "สร้าง"), translate("Genarate the private server if you dont have we recommended only one server.", "สร้างเซิร์ฟเวอร์ส่วนตัว - พวกเราแนะนำให้สร้างแค่ 1 เซิร์ฟเวอร์"), nil, function()
						self.ServerModule:genarate(ServerDropdown)
					end)

					ServerDropdown = self:List(_3, translate('Select Server', "เลือกเซิร์ฟเวอร์"), translate("Select the server that you save.", "เลือกเซิร์ฟเวอร์ที่คุณบันทึกไว้"), nil, 'Select Server', Configs['Server List'], "Single", false, nil)
					self:Button(_3, translate("Teleport", "เทเลพอร์ต"), translate("Teleport to select server.", "เทเลพอร์ตไปยังเซิร์ฟเวอร์ที่เลือก"), nil, function()
						self.ServerModule:init(Configs['Select Server'])
					end)
					self:Button(_3, translate("Get Code", "คัดลอกโค้ด"), translate("Copy code for your friend execute and joined this server.", "คัดลอกโค้ดเซิร์ฟเวอร์เพื่อให้เพื่อนรันสคริปต์แล้วจอยเราได้"), nil, function()
						local Texts = 'game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(game.PlaceId, "", ' .. "'" .. Configs['Select Server'] .. "'" .. ")"
						setclipboard(Texts)
					end)
				end
			end
		end

		function self:OnLeaving(Window, queue)
			local RunService = Serialized.Utility:reference('RunService')
			local Lighting = Serialized.Utility:reference('Lighting')
			local TeleportService = Serialized.Utility:reference('TeleportService')
			local HttpService = Serialized.Utility:reference('HttpService')
			local Players = Serialized.Utility:reference('Players')

			local PlaceId = game.PlaceId

			local Utils = (function()
				local selfs = {}

				function selfs:Reserval(cursor)
					local url = `https://games.roblox.com/v1/games/{PlaceId}/servers/Public?sortOrder=Asc&limit=100`

					if cursor then
						url ..= `&cursor={cursor}`
					end

					return HttpService:JSONDecode(game:HttpGet(url))
				end

				function selfs:Rejoin()
					if #Players:GetPlayers() <= 1 then
						b:Kick("\nRejoining")
						wait()

						return TeleportService:Teleport(PlaceId, b)
					end

					return TeleportService:TeleportToPlaceInstance(PlaceId, game.JobId, b)
				end

				function selfs:Server()
					local Server, Next

					return (function(a)
						repeat
							local Servers = selfs:Reserval(a)

							Server = Servers and Servers.data and Servers.data[1]
							Next = Servers and Servers.nextPageCursor
						until Server

						if not Server or not Server.id then return end
						return TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, b)
					end)(Next)
				end

				function selfs:Join(id)
					return TeleportService:TeleportToPlaceInstance(PlaceId, id, b)
				end

				return selfs
			end)()

			local Setting = self:Tabs(Window, 132831270943713) do
				local _1 = self:Section(Setting, translate("Performance", "ประสิทธิภาพ"), translate("Adjust settings to improve game performance.", "ปรับการตั้งค่าเพื่อเพิ่มประสิทธิภาพของเกม")) do
					Serialized.Configs.def("FPS Capacity", 360)
					Serialized.Configs.def("Smoothing Mode", false)

					self:Toggle(_1, translate("Smoothing Mode", "โหมดทำให้ภาพลื่นไหล"), translate("Enable smoothing mode to reduce stutter and improve frame stability.", "เปิดโหมดทำให้ภาพลื่นไหลเพื่อลดการกระตุกและทำให้เฟรมเสถียรมากขึ้น"), nil, "Smoothing Mode", function(v)
						Serialized.Thread:SetSmoothing(v)
					end)

					self:Toggle(_1, translate("White Screen", "หน้าจอขาว"), translate("Enable white screen to stop rendering frames and reduce GPU usage.", "เปิดหน้าจอขาวเพื่อหยุดการเรนเดอร์เฟรมและลดการใช้ GPU"), nil, "White Screen", function(v)
						if v then
							RunService:Set3dRenderingEnabled(false)
						else
							RunService:Set3dRenderingEnabled(true)
						end
					end)

					self:Button(_1, translate("Low Graphic Quality", "กราฟิกคุณภาพต่ำ"), translate("Enable low graphics to improve performance.", "เปิดกราฟิกคุณภาพต่ำเพื่อเพิ่มประสิทธิภาพ"), nil, function() 
						local Terrain = workspace:FindFirstChildOfClass('Terrain') do
							Terrain.WaterWaveSize = 0
							Terrain.WaterWaveSpeed = 0
							Terrain.WaterReflectance = 0
							Terrain.WaterTransparency = 0
							game.Lighting.GlobalShadows = false
							game.Lighting.FogEnd = 9e9
							settings().Rendering.QualityLevel = 1
						end

						for _, v in game:GetDescendants() do
							if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
								v.Material = "Plastic"
								v.Reflectance = 0
							elseif v:IsA("Decal") then
								v.Transparency = 1
							elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
								v.Lifetime = NumberRange.new(0)
							elseif v:IsA("Explosion") then
								v.BlastPressure = 1
								v.BlastRadius = 1
							end
						end

					end)

					self:Button(_1, translate("RTX Mode", "โหมด RTX"), translate("Enable RTX mode for realistic lighting and reflections.", "เปิดโหมด RTX เพื่อแสงและการสะท้อนแบบสมจริง"), nil, function()
						local effectsToRemove = {
							"BloomEffect",
							"SunRaysEffect",
							"ColorCorrectionEffect",
							"BlurEffect",
							"Sky"
						} do
							for _, className in ipairs(effectsToRemove) do
								local obj = Lighting:FindFirstChildWhichIsA(className)
								if obj then
									obj:Destroy()
								end
							end
						end

						local blem = Instance.new("BloomEffect", Lighting)
						local sunray = Instance.new("SunRaysEffect", Lighting)
						local color = Instance.new("ColorCorrectionEffect", Lighting)
						local blur = Instance.new("BlurEffect", Lighting)

						Instance.new("Sky", Lighting) do
							local lighting = Lighting

							lighting.ExposureCompensation = 0.34
							lighting.ShadowSoftness = 1
							lighting.EnvironmentDiffuseScale = 0.343
							lighting.EnvironmentSpecularScale = 1
							lighting.Brightness = 2
							lighting.ColorShift_Top = Color3.fromRGB(118, 117, 108)
							lighting.OutdoorAmbient = Color3.fromRGB(141, 141, 141)
							lighting.GeographicLatitude = 100
							lighting.Ambient = Color3.fromRGB(112, 112, 112)

							blem.Intensity = 0.5
							blem.Size = 22
							blem.Threshold = 1.5

							sunray.Intensity = 0.117
							sunray.Spread = 1

							blur.Size = 2

							color.Contrast = 0.3
							color.Saturation = 0.2
							color.TintColor = Color3.fromRGB(255, 252, 224)
						end
					end)
				end

				local _2 = self:Section(Setting, translate("Server", "เซิร์ฟเวอร์"), translate("Adjust settings to improve game performance.", "ปรับการตั้งค่าเพื่อเพิ่มประสิทธิภาพของเกม")) do
					Serialized.Configs.def('JobId', "N/A")
					self:Textfield(_2, translate('JobId', "ไอดีเซิร์ฟเวอร์"), translate('Enter JobId to init.', "กำหนดไอดีเซิร์ฟเวอร์"), nil, 'JobId')

					self:Button(_2, translate("Join", "เข้าร่วม"), translate("Join the server using the JobId provided.", "เข้าร่วมเซิร์ฟเวอร์โดยใช้ไอดีที่กำหนด"), nil, function()
						Utils:Join(Configs['JobId'])
					end)

					self:Button(_2, translate("Rejoin", "รีจอยน์"), translate("Reconnect to your current server.", "ออกเข้าใหม่"), nil, function()
						Utils:Rejoin()
					end)

					self:Button(_2, translate("Clipboard JobId", "คัดลอกไอดีเซิร์ฟเวอร์"), tostring(game.JobId), nil, function()
						setclipboard(tostring(game.JobId))
					end)

					self:Button(_2, translate("Change Server", "เปลี่ยนเซิร์ฟเวอร์"), translate("Find a new one to join.", "ค้นหาเซิร์ฟเวอร์ใหม่เพื่อเข้าร่วม"), nil, function()
						Utils:Server()
					end)
				end

				local _3 = self:Section(Setting, translate("Language", "ภาษา"), translate("Adjust game language settings.", "ปรับเปลี่ยนภาษาต่างๆ")) do
					local LanguageList = {
						"ไทย",
						"English"
					}

					self:List(_3, translate('Select Language', "เลือกภาษา"), translate("Select the language you want to use.", "เลือกภาษาที่คุณต้องการใช้"), nil, 'Language', LanguageList, "Double", false, nil)

					self:Button(_3, translate("Change Language", "เปลี่ยนภาษา"), translate("Apply the selected language and rejoin the server.", "ใช้ภาษาที่เลือกและเข้าร่วมเซิร์ฟเวอร์ใหม่"), nil, function()
						Utils:Rejoin()
					end)

					self:Button(_3, translate("Default Language", "ตั้งค่าภาษาเริ่มต้น"), translate("Reset the language to default.", "ตั้งค่าภาษากลับเป็นเริ่มต้น"), nil, function()
						Configs['Language'] = "English"
						Serialized.Configs:Save('Language', "English")
					end)
				end

				local _4 = self:Section(Setting, translate("Configs", "คอนฟิก"), translate("Adjust and manage configurations file.", "ปรับและจัดการค่าการตั้งค่าไฟล์")) do
					self:Button(_4, translate("Cancel Rexecute", "ยกเลิกการรันอัตโนมัติ"), translate("Stop any queued automatic executions or teleports.", "หยุดการรันอัตโนมัติทั้งหมด"), nil, function()
						pcall(clearteleportqueue or clear_teleport_queue or clearqueuescript)
					end)

					self:Button(_4, translate("Delete Workspace", "ลบ Workspace"), translate("Delete the saved Visual configuration file.", "ลบไฟล์คอนฟิกที่บันทึกไว้"), nil, function()
						pcall(delfile, "Visual")
					end)
				end

				do
					pcall(queueonteleport, queue)
				end
			end
		end


		return self
	end)()

	do
		if tostring(b.LocaleId) == "th-th" then
			Serialized.Configs.def('Language', 'ไทย')
		else
			Serialized.Configs.def('Language', 'English')
		end
	end

	Configs = Serialized.Configs:Load()
	Serialized.Config = Configs

	return { Serialized, translate }
end)(getgenv(), game:GetService('Players').LocalPlayer)

local Deserialized, translate = table.unpack(Module)

--local Deserialized, translate = loadstring(game:HttpGet('https://github.com/realkhaw/Visual/blob/main/ByteCode.luau?raw=true',true))()
local Utility, Components  = Deserialized.Utility, Deserialized.Components
local Configs, ConfigsManager = Deserialized.Config, Deserialized.Configs

local Players = Utility:reference('Players')
local ReplicatedStorage = Utility:reference('ReplicatedStorage')
local RunService = Utility:reference('RunService')
local VirtualUser = Utility:reference('VirtualUser')
local MarketplaceService = Utility:reference('MarketplaceService')
local CollectionService= Utility:reference('CollectionService')

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character and Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character and Character:WaitForChild("Humanoid")

local Zone = workspace:WaitForChild("zones")
local PlayerStats = workspace:WaitForChild('PlayerStats')
local active = workspace:WaitForChild('active')

local fishing = Zone:WaitForChild('fishing')

local events = ReplicatedStorage:WaitForChild('events')
local packages = ReplicatedStorage:WaitForChild('packages')
local client = ReplicatedStorage:WaitForChild('client')

local Net = packages:WaitForChild('Net')
local legacyControllers = client:WaitForChild('legacyControllers')

local PlayerController = require(legacyControllers:WaitForChild('PlayerController'))

local Module = {} do
	function Module:IsAlive()
		return Character and HumanoidRootPart and Humanoid
	end

	function Module:Distance(Position)
		return Position and ((typeof(Position) == 'CFrame' and LocalPlayer:DistanceFromCharacter(Position.Position)) or LocalPlayer:DistanceFromCharacter(Position))
	end

	function Module:RemoteEvent()

	end

	Module.Rods = (function()
		local self = {}

		function self:GetRod(Parent)
			local Name = PlayerStats[LocalPlayer.Name].T[LocalPlayer.Name].Stats.rod.Value
			if not Name then return nil end

			return Parent and Parent:FindFirstChild(Name)
		end

		return self
	end)()

	Module.Position = (function()
		local self = {}

		ConfigsManager.def('Position List', {
			['Moosewood'] = "return CFrame.new(359.187622, 133.615952, 232.422897, 0.0273545235, -7.8372473e-09, 0.999625802, -1.73983813e-11, 1, 7.84065701e-09, -0.999625802, -2.31869315e-10, 0.0273545235)"
		})
		ConfigsManager.def('Position Data', {
			'Moosewood'
		})

		function self:GetPosition(Part)
			if not Part then return nil end
			return Part.CFrame
		end

		function self:tostring(Part)
			local CFrame = self:GetPosition(Part)
			if not CFrame then return end

			return "return CFrame.new(" .. tostring(CFrame) .. ")"
		end

		function self.new(Dropdown, name, Part)
			local _index = Configs['Position List'][name]
			if _index then return end

			Configs['Position List'][name] = self:tostring(Part)
			table.insert(Configs['Position Data'], name)
			Dropdown:AddList(name)
		end

		function self:clear(Dropdown, Name)
			local index = table.find(Name, Configs['Position Data'])
			if index then
				table.remove(Configs['Position Data'], index)
			end

			Configs['Position List'][Name] = nil

			Dropdown:Clear(Name)

			Module.save("Position List", Configs['Position List'])
			Module.save("Position Data", Configs['Position Data'])
		end

		function self:warp(name)
			if not HumanoidRootPart then return end
			local posString = Configs['Position List'][name]
			if not posString then return end

			local Position = loadstring(posString)()

			if Module:Distance(Position) > 1 then
				PlayerController:SetCFrame(Position)
			end
		end

		return self
	end)()
end


local Running = {
	{
		['Function'] = function()
			if not Module:IsAlive() then return end

			if not Configs['Equip and Cast'] then
				return
			end

			local Fishing = Character:GetAttribute('Fishing')
			if Fishing then return end

			local Backpack = LocalPlayer:FindFirstChildOfClass('Backpack')
			if not Backpack then return end

			local Equipped = Module.Rods:GetRod(Character)

			if not Equipped then
				local Rod = Module.Rods:GetRod(Backpack)

				if Rod then
					Humanoid:EquipTool(Rod)
				end

				return
			end

			local values = Equipped:FindFirstChild('values')
			if not values then return end

			local casted = values:FindFirstChild('casted')
			if casted and casted.Value then return end

			local event = Equipped:FindFirstChild('events')
			local castAsync = event and event:FindFirstChild('castAsync')
			if not castAsync then return end

			castAsync:InvokeServer(Configs["Cast"], 1)
		end
	},
	{
		['Function'] = function()
			pcall(function()
				if not Configs['Fast Cast'] then return end
				if not Module:IsAlive() then return end

				local Equipped = Module.Rods:GetRod(Character)
				local bobbers = Equipped and Equipped:FindFirstChild("bobber", true)

				if not bobbers then return end

				local Params = RaycastParams.new()
				Params.FilterType = Enum.RaycastFilterType.Include
				Params.FilterDescendantsInstances = { workspace.Terrain }

				local RaycastResult = workspace:Raycast(bobbers.Position, -Vector3.yAxis * 100, Params)

				if RaycastResult then
					if RaycastResult.Instance:IsA("Terrain") then
						bobbers:PivotTo(CFrame.new(RaycastResult.Position))
						bobbers:FindFirstChild('BodyVelocity').MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						bobbers:FindFirstChild('BodyVelocity').Velocity = Vector3.new(0, 0, 0)
						bobbers.Massless = true

						local Rope = bobbers:FindFirstChildOfClass("RopeConstraint")

						if Rope then
							Rope.Length = math.huge
						end
					end
				end
			end)
		end,
	},
	{
		['Function'] = function()
			if not Configs['Sell'] then return end

			events.SellAll:InvokeServer()
			task.wait(Configs["Delay Sell"])
		end,
	}
}

local Connections = {
	{
		['Signal'] = LocalPlayer.CharacterAdded,
		['Action'] = function(v)
			repeat
				wait()
			until v

			Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

			repeat 
				wait()
			until Character:FindFirstChild('HumanoidRootPart') and Character:FindFirstChild('Humanoid')

			Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		end,
	},
	{
		['Signal'] = PlayerGui.ChildAdded,
		['Action'] = function(v)
			pcall(function()
				if Configs['Reel'] == 'Instant' then
					events:WaitForChild("bindable_reel_finished"):Fire(true)
					events:WaitForChild("reelfinished"):FireServer(100, true)
				end

				local bar = v:WaitForChild('bar', 5)
				if not bar then return end

				local playerbar = bar:WaitForChild('playerbar', 5)
				if not playerbar then return end

				playerbar.Size = UDim2.new(1, 0, 1, 0)
			end)
		end
	},
	{
		['Signal'] = RunService.PreSimulation,
		['Action'] = function(v)
			pcall(function()
				if not Configs['Shake'] then return end

				local shakeui = PlayerGui:FindFirstChild('shakeui')
				if not shakeui or not shakeui.safezone.button then return end

				shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
				VirtualUser:Button1Down(Vector2.new(0, 0))
				VirtualUser:Button1Up(Vector2.new(0, 0))
			end)
		end
	},
}

local Title = "Fisch 0.0.01"

do
	local finalized, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)

	if finalized then
		Title = info.Name .. " 0.0.58"
	end
end

local Library = loadstring(game:HttpGet('https://github.com/realkhaw/Visual/blob/main/library.luau?raw=true',true))()
local Window = Components.new(Library, Title)
Components:OnJoining(Window)

local DropdownPosition

local General = Components:Tabs(Window, 103207517628191) do
	local _1 = Components:Section(General, translate("Fishing", "ตกปลา"), translate("Fishing Controller", "แผงควบคุมการตกปลา")) do
		ConfigsManager.def("Reel", "None")
		ConfigsManager.def("Shake", true)
		ConfigsManager.def("Cast", 100)

		Components:Paragarp(_1, Deserialized.html(translate('Anti Cheat', 'แอนตี้ชีท'), Color3.fromRGB(255, 85, 127)),  translate("Fisch now has an anti-cheat system, but it's unclear what it detects. Please use caution.\nDo not Stand on water and fishing - anti-cheat may detect you", "ตอนนี้ Fisch มีกันโปร แต่ยังไม่ทราบแน่ชัดว่ากันอะไรบ้าง โปรดใช้อย่างระมัดระวัง\nอย่ายืนตกปลาบนกลางน้ำ แอนตี้ชีทอาจจะตรวจจับคุณได้"), nil, "true"):SetColor(Color3.fromRGB(255, 85, 127))
		Components:Toggle(_1, translate("Equip and Cast", "ออโต้ถือเบ็ดและโยนเบ็ด"), translate("Equip current rods and cast.", "ถือเบ็ดที่คุณสวมใส่และโยนเบ็ด"), nil, "Equip and Cast")
		Components:Toggle(_1, translate("Fast Cast", "โยนเบ็ดเร็ว"), translate("Skip the casting process to increase speed.", "ข้ามขั้นตอนการโยนเพื่อเพิ่มความเร็ว"), nil, "Fast Cast")
		Components:Toggle(_1, translate("Shake", "ออโต้เขย่า"), translate("Auto click shake button mini game.", "กดปุ่มเขย่าหรือเล่นมินิเกม"), nil, "Shake")
		Components:List(_1, translate('Select Reel', "เลือกการดึง"), translate("Select the reel mode you want to use.", "เลือกโหมดคุณต้องการใช้"), nil, 'Reel', {
			"None", "Instant"
		}, "Double", false)
		Components:Slider(_1, translate('Cast Distance', 'ระยะการโยนเบ็ด'), translate('Modify cast distance', 'ปรับแต่งระยะการโยนเบ็ด'), nil, "Cast", 1, 100, 1)
	end

	local _2 = Components:Section(General, translate("Save Position", "ตำแหน่งที่บันทึกไว้"), translate("Position Controller", "แผงควบคุมตำแหน่ง")) do
		ConfigsManager.def('Select Position', "Moosewood")
		ConfigsManager.def("Name", "Moosewood")

		Components:Textfield(_2, translate('Position Name', "ชื่อตำแหน่ง"), translate('Enter name position.', "กำหนดชื่อของตำแหน่ง"), nil, 'Name')
		Components:Button(_2, translate("Save", "บันทึก"), translate("Save position to list, this position will not remove when you leave the game.", "บันทึกตำแหน่งไปยังรายชื่อ ถ้าออกเกมมันจะไม่หาย"), nil, function()
			if not HumanoidRootPart then return end
			Module.Position.new(DropdownPosition, Configs["Name"], HumanoidRootPart)
		end)
		DropdownPosition = Components:List(_2, translate('Select Save Position', "เลือกตำแหน่งที่บันทึกไว้"), translate("Select position that you save for quick access later, such as sea or shop.", "เลือกตำแหน่งที่คุณได้บันทึกไว้ เพื่อใช้กลับไปยังจุดนั้นได้อย่างรวดเร็ว เช่น ทะเลหรือร้านค้า"), nil, 'Select Position', Configs['Position Data'], "Double", false)
		Components:Button(_2, translate("Teleport ", "เทเลพอร์ต"), translate("Teleport to select position.", "เทเลพอร์ตไปยังตำแหน่งที่เลือก"), nil, function()
			Module.Position:warp(Configs['Select Position'])
		end)
		Components:Button(_2, translate("Remove", "ลบตำแหน่งที่เลือก"), translate("Remove select position form save list.", "ลบตำแหน่งที่เลือกจากรายชื่อที่บันทึกไว้"), nil, function()
			Module.Position:clear(DropdownPosition, Configs['Select Position'])
		end)
	end

	local _3 = Components:Section(General, translate("Utility", "ตัวช่วย"), translate("Utility Controller", "แผงควบคุมตัวช่วย")) do
		Components:Toggle(_3, translate("Freeze Ocean", "แช่เเข็งมหาสมุทร"), translate("Freeze ocean and you can walk on water.", "แช่เเข็งมหาสมุทรและสามารถเดินบนน้ำได้"), nil, "Freeze Ocean", function(v)
			for _, v in pairs(fishing:GetChildren()) do
				if v:IsA("Part") then
					v.CanCollide = v
				end
			end
		end)
		Components:Toggle(_3, translate("Fish Radar", "เครื่องตรวจจับปลา"), translate("Enabled the fish radar highlight.", "เปิดใช้งานการมองเห็นตำแหน่งปลา"), nil, "Fish Radar", function(v)
			for _, v in pairs(CollectionService:GetTagged("radarTag")) do
				if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
					v.Enabled = v
				end
			end
		end)
	end

	local _4 = Components:Section(General, translate("Selling", "การขาย"), translate("Selling Controller", "แผงควบคุมการขาย")) do
		ConfigsManager.def("Delay Sell", 25)

		Components:Slider(_4, translate('Time', 'เวลา'), translate('Delay to Sell', 'เวลาที่จะขายปลา'), nil, "Delay Sell", 1, 60, 1)
		Components:Toggle(_4, translate("Automatic Sell Any", "ออโต้ขายปลาทั้งหมด"), translate("Sell any fish in your inventory.", "ขายปลาทั้งหมดในระเป๋า"), nil, "Sell")
		Components:Button(_4, translate("Sell Holding Fish", "ขายปลาที่ถืออยู่"), nil, nil, function()
			events.Sell:InvokeServer()
		end)
		Components:Button(_4, translate("Sell Any", "ขายปลาทั้งหมด"), nil, nil, function()
			events.SellAll:InvokeServer()
		end)
	end
end

Components:OnLeaving(Window, "loadstring(game:HttpGet('https://xyns.xyz'))()")
Deserialized:OnRunning(Running)
Deserialized:OnConnections(Connections)
