setfenv(1, select(2, ...))
VoiceOverUtils = {}

local SOUNDS_BASE_DIR = "Interface\\AddOns\\VoiceOver\\generated\\sounds\\"
local QUEST_SOUNDS_BASE_DIR = SOUNDS_BASE_DIR .. "quests\\"
local GOSSIP_SOUNDS_BASE_DIR = SOUNDS_BASE_DIR .. "gossip\\"

function VoiceOverUtils:addGossipFilePathToSoundData(soundData)
    if soundData["questId"] == nil then
        soundData.filePath = GOSSIP_SOUNDS_BASE_DIR .. soundData.fileName .. ".mp3"
    else
        soundData.filePath = QUEST_SOUNDS_BASE_DIR .. soundData.fileName .. ".mp3"
    end
end

function VoiceOverUtils:addGossipFileName(soundData)
    local npcId = VoiceOverUtils:getIdFromGuid(soundData.unitGuid)
    local fileNameHash = VoiceOverUtils:getClosestTextHash(npcId, soundData.text)
    if fileNameHash == nil then
        soundData.fileName = "missingSound"
    else
        soundData.fileName = fileNameHash
    end
end

function VoiceOverUtils:getClosestTextHash(npcId, query_text)
    local npc_gossip_table = NPCToTextToTemplateHash[npcId]
    if not npc_gossip_table then
        return nil
    end

    local text_entries = {}
    for text, _ in pairs(npc_gossip_table) do
        table.insert(text_entries, text)
    end

    local best_result = VOICEOVER_fuzzySearchBest(query_text, text_entries)

    if best_result then
        local closest_text = best_result.text
        return npc_gossip_table[closest_text]
    else
        return nil
    end
end

function VoiceOverUtils:getIdFromGuid(guid)
    return guid and tonumber((select(6, strsplit("-", guid))))
end

function VoiceOverUtils:getGuidFromId(id)
    return format("Creature-%d-%d-%d-%d-%d-%d", 0, 0, 0, 0, id, 0)
end

function VoiceOverUtils:willSoundPlay(soundData)
    local willPlay, handle = PlaySoundFile(soundData.filePath)
    if willPlay then
        StopSound(handle)
    end
    return willPlay
end

function VoiceOverUtils:getQuestLogScrollOffset()
    return FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
end

function VoiceOverUtils:getQuestLogTitleFrame(index)
    return _G["QuestLogTitle" .. index]
end

function VoiceOverUtils:copyTable(t)
    local u = {}
    for k, v in pairs(t) do u[k] = v end
    return setmetatable(u, getmetatable(t))
end