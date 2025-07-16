require('Utils.Graph')

local graph = Graph()

graph:addNode('A')
graph:addNode('B')
graph:addNode('C')
graph:addNode('D')

print(graph:toString() .. "\n")

graph:addConnection('A','B',2,true)
graph:addConnection('A','C',3,true)
graph:addConnection('B','D',4,true)
graph:addConnection('D','X',5)

print(graph:toString() .. "\n")

local path = graph:findPath('A','D')
local path_str = ""

for key, value in pairs(path) do
    path_str = path_str .. value.name .. " -> "
end

print(path_str)