PATHS = PATHS or -1

if PATHS == -1 then print("Could not find url paths, try running ./gen_paths.sh") return end

for url, loc in string.gmatch(PATHS, "([^\n]+)%-%->([^\n]+)\n") do
    loc = "Telecom/" .. loc
    print(string.format("installing %s at %s", url, loc))
    shell.run(string.format("wget \"%s\" \"%s\"",url,loc))
end

print("Library installed successfully :), check the Startup folder for startup profiles")
