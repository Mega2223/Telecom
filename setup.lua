---@diagnostic disable-next-line: different-requires
require('init')
require('Install.paths')

for url, loc in string.gmatch(PATHS, "([^\n]+)%-%->([^\n]+)\n") do
    loc = "Telecom/" .. loc
    print(string.format("installing %s at %s", url, loc))
    shell.run(string("wget \"%s\" \"%s\""))
end