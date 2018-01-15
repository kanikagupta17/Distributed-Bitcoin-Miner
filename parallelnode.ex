defmodule ParallelNode do
    def each(lzero, tzero) do
        IO.puts "inside parallelnode EACH"
        nlist=Node.list 
        nlist=nlist++[Node.self()]
        Enum.each(nlist,fn x -> eachNode(x,lzero,tzero) end)
    end

    def eachNode(x,lzero,tzero) do
        IO.puts "inside parallelnode EACHNODE"
        IO.puts"lzero are #{lzero}"
        IO.puts"tzero are #{tzero}"
        Node.spawn(x,Parallel,:findCore,[lzero, tzero])
    end
end