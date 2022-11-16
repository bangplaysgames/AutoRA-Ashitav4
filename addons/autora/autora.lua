--[[]
---MIT License---
Copyright 2022 Banggugyangu

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

addon.name    = 'AutoRA';
addon.author  = 'banggugyangu';
addon.version = '1.0.0';

--Dependencies--
require('common');
local chat = require('chat');
local settings = require('settings');

local default_settings = T{

        HaltOnTP = true,
        Delay = 0,
        DelayOffset = 0,
        verbose = true;
};

--Settings Variables--
local autora = T{
    auto = false;
    running = false;
    settings = settings.load(default_settings),
};

settings.register('settings', 'settings_update', function(s)
    if (s ~=nil) then
        autora.settings = s;
    end

    settings.save();
end)

local makeString = function(table, value)
    if (table[value] == nil) then
            return 'Nil';
    else
        return table[value];
    end
end

local StatusTable = T{
    [0] = 'Idle',
    [1] = 'Engaged',
    [2] = 'Dead',
    [3] = 'Dead',
    [4] = 'Zoning',
    [33] = 'Resting'
};


--Player Information Build--
local playerData = {};
local playerEntity = AshitaCore:GetMemoryManager():GetEntity();
local player = AshitaCore:GetMemoryManager():GetPlayer();
local party = AshitaCore:GetMemoryManager():GetParty();
local playerIndex = party:GetMemberTargetIndex(0);
playerData.status = makeString(StatusTable, playerEntity:GetStatus(playerIndex));
playerData.statusID = playerEntity:GetStatus(playerIndex);
playerData.TP = party:GetMemberTP(0);


--Send Shoot Command to Client--
local shoot = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/shoot <t>');
end

--Logic--
ashita.events.register('packet_in', 'packet_in_cb', function (e)
    --Player Information Build--
    playerEntity = AshitaCore:GetMemoryManager():GetEntity();
    player = AshitaCore:GetMemoryManager():GetPlayer();
    party = AshitaCore:GetMemoryManager():GetParty();
    playerIndex = party:GetMemberTargetIndex(0);
    playerData.status = makeString(StatusTable, playerEntity:GetStatus(playerIndex));
    playerData.statusID = playerEntity:GetStatus(playerIndex);
    playerData.TP = party:GetMemberTP(0);



    if(autora.auto and playerData.status == 'Engaged') then
        if(playerData.TP <= 1000 or not autora.settings.HaltOnTP) then
            if(not autora.running) then
                autora.running = true;
                print(chat.header('AutoRA:  Auto Fire Enabled'));
            elseif (autora.running) then
                wait((autora.settings.Delay + autora.settings.DelayOffset)/60);
            end
        else
            autora.auto = false;
            autora.running = false;
            if(autora.settings.verbose) then
                print(chat.header('AutoRA:  Auto Fire Disabled'));
                print(chat.message('Reason:  WS is Ready'));

            end
        end
    elseif(autora.auto and playerData.status == 'Idle') then
        autora.auto = false;
        autora.running = false;
        if(autora.settings.verbose) then
            print(chat.header('AutoRA:  Auto Fire Disabled'));
            print(chat.message('Reason:  Player disengaged'));

        end
    end
end);


function wait(seconds)
    local ostime_vari = os.clock() + seconds;
        shoot();
end

ashita.events.register('command', 'command_cb', function (e)
    --Parse Arguments
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/autora')) then
        return;
    end

    --Block all related commands
    e.blocked = true;

    --Handle Command
    if(#args == 1) then
        return;
    end

    if (#args >= 2 and args[2]:any('wait')) then
        wait(args[3]);
        return;
    end
    if (#args >= 2 and args[2]:any('start')) then
        if(playerData.status == 'Engaged') then
            autora.auto = true;
            shoot();
            print(chat.header(auto));

        else
            if(autora.settings.verbose) then
                print(chat.header('AutoRA:  Auto Fire Blocked'));
                print(chat.message('Reason:  Player Not Engaged with Target'));

            end
        end

    end
    if (#args >= 2 and args[2]:any('stop')) then
        autora.auto = false;
        if(autora.settings.verbose) then
            print(chat.header('AutoRA:  Auto Fire Disabled'));
            print(chat.message('Reason:  Player Manually Disabled'));
        end
    end

    if (#args >=2 and args[2]:any('delay')) then
        autora.settings.Delay = args[3];
        print(chat.header('Delay set to:  '..args[3]));
    end
    if (#args >=2 and args[2]:any('verbose')) then
        autora.settings.verbose = not autora.settings.verbose;
        print(chat.header('Verbose mode toggled to:  '..tostring(verbose)));
    end
    if(#args >=2 and args[2]:any('haltontp')) then
        autora.settings.HaltOnTP = not autora.settings.HaltOnTP;
        print(chat.header('Halt On TP toggled to:  '..tostring(HaltOnTP)));
    end

end);

ashita.events.register('load', 'load_cb', function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/bind ^D /autora start');
    AshitaCore:GetChatManager():QueueCommand(-1, '/bind !D /autora stop');
end)

ashita.events.register('unload', 'unload_cb', function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/unbind ^D');
    AshitaCore:GetChatManager():QueueCommand(-1, '/unbind !D');
    settings.save();
end)
