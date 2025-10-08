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
			end
		end

		function self:OnLeaving(Window, queue)
			local Notification = loadstring(game:HttpGet('https://raw.githubusercontent.com/java3210/opensource.md/refs/heads/main/notify', true))()
			
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
						
						Notification.new("success", translate("Success", "สำเร็จ"), translate("Boosted is success.", "บูสต์สำเร็จ"), true, 3) 
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
						
						Notification.new("success", translate("Success", "สำเร็จ"), translate("RTX is enabled.", "RTX เปิดแล้ว"), true, 3) 
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
						Notification.new("warning", translate("Change Server", "เปลี่ยนเซิร์ฟเวอร์"), translate("while wait ...", "โปรดรอ ..."), true, 3)
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
						pcall(clearteleportqueue or clear_teleport_queue)
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

return table.unpack(Module)
