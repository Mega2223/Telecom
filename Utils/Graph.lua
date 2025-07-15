require('Route')

local function findPath(self, from, to)
    return Route(from, to, nil) --TODO FIXME seila
end

function Node(name)
    return{
        name = name,
        connections = {}
    }
end

local function connectNodes(self, nameNodeA, nameNodeB)

end

function Graph()
    return {
        nodes = {},
        connectNodes = connectNodes,
        findPath = findPath,

        addNode = function(self,node)
            table.insert(self.nodes, node)
        end
    }
end

return Graph