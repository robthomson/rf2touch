-- CRSF Devices
local CRSF_ADDRESS_BETAFLIGHT = 0xC8
local CRSF_ADDRESS_RADIO_TRANSMITTER = 0xEA

-- CRSF Frame Types
local CRSF_FRAMETYPE_msp_REQ = 0x7A -- response request using msp sequence as command
local CRSF_FRAMETYPE_msp_RESP = 0x7B -- reply with 60 byte chunked binary
local CRSF_FRAMETYPE_msp_WRITE = 0x7C -- write with 60 byte chunked binary

local crsfMspCmd = 0

protocol.mspSend = function(payload)
    local payloadOut = {CRSF_ADDRESS_BETAFLIGHT, CRSF_ADDRESS_RADIO_TRANSMITTER}
    for i = 1, #(payload) do
        payloadOut[i + 2] = payload[i]
    end
    return crsf.pushFrame(crsfMspCmd, payloadOut)
end

protocol.mspRead = function(cmd)
    crsfMspCmd = CRSF_FRAMETYPE_msp_REQ
    return mspSendRequest(cmd, {})
end

protocol.mspWrite = function(cmd, payload)
    crsfMspCmd = CRSF_FRAMETYPE_msp_WRITE
    return mspSendRequest(cmd, payload)
end

protocol.mspPoll = function()
    while true do
        local cmd, data = crsf.popFrame()
        if cmd == CRSF_FRAMETYPE_msp_RESP and data[1] == CRSF_ADDRESS_RADIO_TRANSMITTER and data[2] == CRSF_ADDRESS_BETAFLIGHT then
            --[[
            print("cmd:0x"..string.format("%X", cmd))
            print("  data length: "..string.format("%u", #data))
            for i=1,#data do
                print("  ["..string.format("%u", i).."]:  0x"..string.format("%X", data[i]))
            end
--]]
            local mspData = {}
            for i = 3, #data do
                mspData[i - 2] = data[i]
            end
            return mspData
        elseif cmd == nil then
            return nil
        end
    end
end
