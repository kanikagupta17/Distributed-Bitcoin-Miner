defmodule Parallel do
    def findCore(lzero,tzero) do
        c=:erlang.system_info(:logical_processors_available)          
        IO.puts "cores #{c}"
        eachCore(c,lzero,tzero)    
    end
    def eachCore(cores_count, lzero,tzero) when cores_count <= 1 do
        spawn(Project1,:findBitCoin,[lzero,tzero])
      end
    
     def eachCore(cores_count, lzero,tzero) do
        spawn(Project1,:findBitCoin,[lzero,tzero])
        eachCore(cores_count - 1,lzero,tzero)
     end
end