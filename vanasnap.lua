--[[
* Ashita - Copyright (c) 2014 - 2023 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

_addon.author   = 'Almavivaconte';
_addon.name     = 'Vana\'diel Snap';
_addon.version  = '0.0.3';

require 'common'

local SOULTRAPPER = 18721;
local SOULTRAPPER_2K = 18724;
local soultrapperCounting = false;
local soultrapperCooldown = nil;
local soultrapperTimeRemain = 10;
local soultrapper2KCounting = false;
local soultrapper2KCooldown = nil;
local soultrapper2KTimeRemain = 10;

local vanasnap_config =
{
    font =
    {
        family      = 'Arial',
        size        = 7,
        color       = 0xFFFFFFFF,
        position    = { 640, 360 },
        bgcolor     = 0xC8000000,
        bgvisible   = true
    },
};

ashita.register_event('render', function()
    
    local f = AshitaCore:GetFontManager():Get('__vanasnap_addon');
    
    local rangedIndex, rangedID;
   
    if AshitaCore:GetDataManager():GetInventory():GetEquippedItem(2) ~= nil then
        rangedIndex = AshitaCore:GetDataManager():GetInventory():GetEquippedItem(2).ItemIndex;
        local rangedBag = math.floor(rangedIndex/256);
        local rangedIdx = math.floor(rangedIndex%256);
        rangedID = AshitaCore:GetDataManager():GetInventory():GetItem(rangedBag, rangedIdx).Id;
    end
    
    if rangedID ~= SOULTRAPPER and rangedID ~= SOULTRAPPER_2K then
        f:SetVisibility(false)
    else
        f:SetVisibility(true)
    end
    
    currentTime = os.time(os.date("!*t"));
    
    if rangedID == SOULTRAPPER and not soultrapperCounting and soultrapperTimeRemain ~= "Ready!" then
        soultrapperCounting = true;
        soultrapperCooldown = currentTime + 10;
    end
    
    if (soultrapperTimeRemain == "Ready!" or (type(soultrapperTimeRemain) == 'number' and soultrapperTimeRemain < 10)) and rangedID ~= SOULTRAPPER then
        soultrapperTimeRemain = 10;
        soultrapperCounting = false;
    end
    
    if rangedID == SOULTRAPPER_2K and not soultrapper2KCounting and soultrapper2KTimeRemain ~= "Ready!" then
        soultrapper2KCounting = true;
        soultrapper2KCooldown = currentTime + 10;
    end
    
    if (soultrapper2KTimeRemain == "Ready!" or (type(soultrapper2KTimeRemain) == 'number' and soultrapper2KTimeRemain < 10)) and rangedID ~= SOULTRAPPER_2K then
        soultrapper2KTimeRemain = 10;
        soultrapper2KCounting = false;
    end
    
    if soultrapperCounting then
        soultrapperTimeRemain = soultrapperCooldown - currentTime;
        if soultrapperTimeRemain < 0 then
            soultrapperCounting = false;
            if rangedID == SOULTRAPPER then
                soultrapperTimeRemain = "Ready!";
            else
                soultrapperTimeRemain = 10;
            end
        end
    end
    
    if soultrapper2KCounting then
        soultrapper2KTimeRemain = soultrapper2KCooldown - currentTime;
        if soultrapper2KTimeRemain < 0 then
            soultrapper2KCounting = false;
            if rangedID == SOULTRAPPER_2K then
                soultrapper2KTimeRemain = "Ready!";
            else
                soultrapper2KTimeRemain = 10;
            end
        end
    end
    
    local DisplayString = "Soultrapper: " .. soultrapperTimeRemain .. "\n" .. "Soultrapper 2000: " .. soultrapper2KTimeRemain;
    f:SetText(DisplayString);

    return;
end);


----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the configuration..
    vanasnap_config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', vanasnap_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():Create('__vanasnap_addon');
    f:SetColor(vanasnap_config.font.color);
    f:SetFontFamily(vanasnap_config.font.family);
    f:SetFontHeight(vanasnap_config.font.size);
    f:SetBold(true);
    f:SetPositionX(vanasnap_config.font.position[1]);
    f:SetPositionY(vanasnap_config.font.position[2]);
    f:SetVisibility(true);
    f:GetBackground():SetColor(vanasnap_config.font.bgcolor);
    f:GetBackground():SetVisibility(vanasnap_config.font.bgvisible);
end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    local f = AshitaCore:GetFontManager():Get('__vanasnap_addon');
    vanasnap_config.font.position = { f:GetPositionX(), f:GetPositionY() };
    vanasnap_config.party_on = party_on;
    vanasnap_config.call_on = call_on;
    -- Save the configuration..
    ashita.settings.save(_addon.path .. 'settings/settings.json', vanasnap_config);
    
    -- Unload the font object..
    AshitaCore:GetFontManager():Delete('__vanasnap_addon');
end );

ashita.register_event('outgoing_packet', function(id, size, packet)
	-- Used Item
	if (id == 0x037) then
        itemIndexVal = struct.unpack('b', packet, 0x0F);
        itemId = AshitaCore:GetDataManager():GetInventory():GetItem(0, itemIndexVal).Id;
        if itemId == SOULTRAPPER then
            soultrapperCounting = true;
            soultrapperCooldown = os.time(os.date("!*t")) + 60;
        elseif itemId == SOULTRAPPER_2K then
            soultrapper2KCounting = true;
            soultrapper2KCooldown = os.time(os.date("!*t")) + 30;
        end
    end
	return false;
end);
