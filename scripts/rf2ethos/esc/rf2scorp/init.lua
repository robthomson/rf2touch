local toolName = "Scorpion"
moduleName = "RF2SCORP"
moduleTitle = "Scorpion ESC v0.42"

mspSignature = 0x53
mspHeaderBytes = 2
mspBytes = 84

apiVersion = 0
mcuId = nil
-- runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu"

function getEscType(page)
    -- esc type
    local tt = {}
    for i = 1, 32 do
        local v = page.values[i + mspHeaderBytes]
        if v == 0 then
            break
        end
        table.insert(tt, string.char(v))
    end
    return table.concat(tt)
end

function getUInt(page, vals)
    local v = 0
    for idx = 1, #vals do
        local raw_val = page.values[vals[idx] + mspHeaderBytes] or 0

        -- raw_val = bit32.lshift(raw_val, (idx-1)*8)
        -- v = bit32.bor(v, raw_val)

        raw_val = raw_val << (idx - 1) * 8
        v = (v | raw_val) << 0

        print(v)

    end
    return v
end

return {toolName = toolName, powerCycle = true, mspSignature = mspSignature, mspHeaderBytes = mspHeaderBytes, mspBytes = mspBytes}
