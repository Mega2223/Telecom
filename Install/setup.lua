PATHS = PATHS or -1

if PATHS == -1 then print("Could not find url paths, try running ./gen_paths.sh") return end

for url, loc in string.gmatch(PATHS, "([^\n]+)%-%->([^\n]+)\n") do
    loc = "Telecom/" .. loc
    print(string.format("installing %s at %s", url, loc))
    shell.run(string.format("wget \"%s\" \"%s\"",url,loc))
end

print("Library installed successfully :)")

--- E literalmente so copiar o bglh da pasta startup lol

[[ print("Do you wish to setup a [router] module or a [endpoint]?")
local mode = read()

if mode == "router" then
    print("what name should this router have? (leave empty for generating name)")
    ---@type string | nil
    local name = read()
    if name == "" then name = nil end

    print("which router firmware module should be implemented?")
    require('Network.RouterLogic.Firmware.RouterFirmware')
    for key, value in pairs(ROUTER_FIRMWARE_WRAPPERS) do
        print(string.format("[%d]: %s",key,value.firmware_type_name))
    end
    local firmware_id = tonumber(read())
    if firmware_id == nil or ROUTER_FIRMWARE_WRAPPERS[firmware_id] == nil then print("invalid option") return end
    local firmware = ROUTER_FIRMWARE_WRAPPERS[firmware_id]

    --TODO o que eu faço a partir daqui lmao

    print("setting up startup module for router")
    shell.run("cp ./Startup")
    os.reboot()
end
]]