setfenv(1, select(2, ...))

local soundQueue = VoiceOverSoundQueue:new()
local questOverlayUI = QuestOverlayUI:new(soundQueue)
local eventHandler = VoiceOverEventHandler:new(soundQueue, questOverlayUI)

VoiceOver = {}

VoiceOver.Mods = {}

local voiceOverModPrototype = {}

---------------------------------
--  VoiceOver Mod Constructor  --
---------------------------------
do
	local modsById = {}
	local mt = {__index = voiceOverModPrototype}

	function VoiceOver:NewMod(name, modId)
        name = tostring(name) -- the name should never be a number of something as it confuses sync handlers that just receive some string and try to get the mod from it
		if modsById[name] then error("VoiceOver:NewMod(): Mod names are used as IDs and must therefore be unique.", 2) end
		local obj = setmetatable(
			{
				id = name,
				modId = modId,
			},
			mt
		)

		tinsert(self.Mods, obj)
		modsById[name] = obj
		return obj
	end

	function VoiceOver:GetModByName(name)
		return modsById[tostring(name)]
	end

    function VoiceOver:CreatePlayableSound(soundData)
        for k, v in pairs(self.Mods) do
            local possibleSound = VoiceOverUtils:copyTable(soundData)

            k:addGossipFilePathToSoundData(possibleSound)
            if VoiceOverUtils:willSoundPlay(possibleSound) then
                return possibleSound
            end
        end
        
        return nil
    end
end

eventHandler:RegisterEvents()

