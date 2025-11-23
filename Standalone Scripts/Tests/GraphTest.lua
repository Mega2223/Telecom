require('Utils.Graph')

local graph = Graph()

graph:addNode('A')
graph:addNode('B')
graph:addNode('C')
graph:addNode('D')
graph:addNode('E')
graph:addNode('F')

print(graph:toString() .. "\n")

graph:addConnection('A','B',2,true)
graph:addConnection('A','C',3,true)
graph:addConnection('B','D',4,true)
graph:addConnection('E','F',10,true)
graph:addConnection('D','E',5,true)
graph:addConnection('D','X',5)

print(graph:toString() .. "\n")

local path = graph:findPath('A','F')
local path_str = ""

if not path then error('no path >:(') end

for key, value in pairs(path) do
    path_str = path_str .. value.name .. " -> "
end

print(path_str)