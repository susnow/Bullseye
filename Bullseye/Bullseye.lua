--susnow
--素雪@风暴之眼

local addon,ns = ...

--locales
local data = {
	enUS = {
		spellName = "Magic Wings",
		actionString = "Click!",
		ready = "Ready...",
	},
	zhCN = {
		spellName = "魔法双翼",
		actionString = "按!",
		ready = "准备...",
	},
	zhTW = {
		spellName = "魔法之翼",
		actionString = "按!",
		ready = "準備...",
	},
}
local L = GetLocale()

--init varirable
local interval = 0.001
local minThreshold = 0.975 
local maxThreshold = 1.5 
local correctionValue = 0.2
local spellTex = "Interface\\Icons\\misc_arrowdown"

--Custom func
local onUpdate = function(obj,elapsed,interval,expires,minV,maxV)
	obj.nextUpdate = obj.nextUpdate + elapsed
	if obj.nextUpdate > interval then
		if (expires - GetTime() >= 0) and (expires - GetTime() > (minV + correctionValue)) then
			obj.notice:SetText(data[L].ready)
			obj.Overlay:SetScript("OnKeyDown",function(self) end)
		elseif (expires - GetTime() > minV ) and (expires - GetTime() < maxV) then
			obj.notice:SetText(data[L].actionString)
			obj.sIcon:SetAlpha(1)
			obj.Overlay:SetScript("OnKeyDown",nil)	
			obj.Overlay:UnregisterAllEvents()
		elseif expires - GetTime() <= 0 then
			obj.notice:SetText("")
			obj.sIcon:SetAlpha(0)
			obj.Overlay:SetScript("OnKeyDown",nil)
			obj.Overlay:UnregisterAllEvents()
			obj:SetScript("OnUpdate",nil)
		end
	end
	obj.nextUpdate = 0
end

--objects
--frame
local Bullseye = CreateFrame("Frame")
Bullseye:SetSize(100,20)
Bullseye:SetPoint("CENTER",UIParent,0,150)

--text
local notice = Bullseye:CreateFontString(nil,"OVERLAY")
notice:SetFontObject(ChatFontNormal)
do
	local font,size,flag = notice:GetFont()
	notice:SetFont(font,20,"OUTLINE")
	notice:SetTextColor(1,1,0,1)
	notice:SetShadowOffset(2,-2)
end
notice:SetPoint("CENTER",Bullseye)
notice:SetText("")
Bullseye.notice = notice

--icon
local sIcon = Bullseye:CreateTexture(nil,"OVERLAY")
sIcon:SetSize(30,30)
sIcon:SetTexture(spellTex)
sIcon:SetPoint("RIGHT",Bullseye,"LEFT")
sIcon:SetAlpha(0)
Bullseye.sIcon = sIcon

--overlay
local Overlay = CreateFrame("Frame","Overlay",UIParent)
Overlay:EnableKeyboard(true)
Overlay:SetFrameStrata("TOOLTIP")
Overlay:SetAllPoints(UIParent)
Bullseye.Overlay = Overlay


--handler
Bullseye.nextUpdate = 0
Bullseye:RegisterEvent("UNIT_AURA")
Bullseye:HookScript("OnEvent",function(self)
		local name,_,_,_,_,_, expires = UnitBuff("player",data[L].spellName)		
		if name == data[L].spellName then 
			Bullseye:SetScript("OnUpdate",function(self,elapsed)
				onUpdate(self,elapsed,interval,expires,minThreshold,maxThreshold)
			end)
		end
end)

