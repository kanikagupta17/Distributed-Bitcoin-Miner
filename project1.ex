

defmodule Project1 do
  @moduledoc """
  Documentation for Project1.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project1.hello
      :world

  """
  
  def main(args) do
    input=Enum.at(args, 0)
    if input=~"." do 
      pid = spawn(Project1 ,:setup_client, [input])
      send pid, {:starting_client, "ok to start client"}
       receive do
        {:stop_client, msg} -> "stop"
      end 
    else
      setup_server(input)
    end
  end

  def setup_client(input) do 
    unless Node.alive?() do
      local_node_name = generate_name_client("client")
      {:ok, _} = Node.start(local_node_name)
    end
    #cookie = Application.get_env("server", :cookie)
    Node.set_cookie(:"Nikhil-Kanika-cookie")
    
    Node.connect(String.to_atom("server@#{input}"))
    IO.puts "Client connected to Server IP #{input}"
  end 

  def setup_server(input) do
    lzero=String.to_integer(input)
    unless Node.alive?() do
      local_node_name = generate_name_server("server")
      {:ok, _} = Node.start(local_node_name)
    end
    Node.set_cookie(:"Nikhil-Kanika-cookie")
    #cookie = Application.get_env("server", :cookie)
    
    IO.puts "Server Started"
    serverstart(lzero)
  end



  def generate_name_server(appname) do
    {:ok,host}= :inet.gethostname
    {:ok,{a,b,c,d}} = :inet.getaddr(host, :inet)
    if a==127 do 
      {:ok, list_ips} = :inet.getif()
      ip=list_ips
      |> Enum.at(0) 
      |> elem(0) 
      |> :inet_parse.ntoa 
      |> IO.iodata_to_binary
    else
      ip=Integer.to_string(a)<>"."<>Integer.to_string(b)<>"."<>Integer.to_string(c)<>"."<>Integer.to_string(d)
    end
      IO.puts "Server IP #{ip}"
    String.to_atom("#{appname}1@#{ip}")
  end

  def generate_name_client(appname) do
    {:ok,host}= :inet.gethostname
    {:ok,{a,b,c,d}} = :inet.getaddr(host, :inet)
    if a==127 do 
      {:ok, list_ips} = :inet.getif()
      ip=list_ips
      |> Enum.at(0) 
      |> elem(0) 
      |> :inet_parse.ntoa 
      |> IO.iodata_to_binary
    else
      ip=Integer.to_string(a)<>"."<>Integer.to_string(b)<>"."<>Integer.to_string(c)<>"."<>Integer.to_string(d)
    end
    hex = :erlang.monotonic_time() |>
      :erlang.phash2(256) |>
      Integer.to_string(16)
    IO.puts "Client started with IP Address: #{ip}"  
    #String.to_atom("#{appname}-#{hex}@#{machine}")
    String.to_atom("#{appname}-#{hex}@#{ip}")
  end
  
  def serverstart(lzero) do
    tzero="0"
    tzero=generateZeroStr(tzero,lzero)
    nodeList = Project1.iterateNodesList(lzero,tzero)
    Project1.parentReceiver(nodeList,lzero,tzero)
  end

  def parentReceiver(prevNodeList,lzero,tzero) do 
    receive do 
      {:parentOk, x} -> 
        pid = Node.spawn(x,Project1,:intermediate,[self(),x,lzero,tzero])
        global_counter_length= :ets.update_counter(:countTable,"Length_counter",{2,1})
        #IO.puts "im global counter when new node added #{global_counter_length}"#<>inspect global_counter_length
        send pid, {:ok, global_counter_length}
    after 
    2_000 ->
      presentList=Node.list ++ [Node.self()]
      if prevNodeList === presentList do 
      else 
        newlyAddedNodeList = presentList -- prevNodeList
        prevNodeList = prevNodeList ++ newlyAddedNodeList
        Enum.each(newlyAddedNodeList,fn x -> eachNode(x,lzero,tzero) end)
      end
    end
    parentReceiver(prevNodeList,lzero,tzero)
  end 

  def iterateNodesList(lzero, tzero) do
    nlist=Node.list 
    nlist=nlist++[Node.self()]
    count_table = :ets.new(:countTable, [:named_table])
    :ets.insert(:countTable,{"Length_counter",0})
    Enum.each(nlist,fn x -> eachNode(x,lzero,tzero) end)
    nlist
  end

  def findCore(x) do 
   pid = Node.spawn(x,Project1,:getCoresCount,[self()])
   send pid, {:start, "find cores"}
  tempCore=0
   receive do
      {:noOfCores, c} -> tempCore= c
      #IO.puts "im getting cores #{c}"
   end
   tempCore
  end

  def getCoresCount(parentProcessID) do 
    receive do
      {:start, msg} ->
        c = :erlang.system_info(:logical_processors_available) 
        send parentProcessID, {:noOfCores, c}
    end
  end


  def eachNode(x,lzero,tzero) do
    parentProcessID=self()
    

    cores_count= findCore(x)
    Enum.each(1..cores_count, fn(k) ->

      pid = Node.spawn(x,Project1,:intermediate,[parentProcessID,x,lzero,tzero])
      global_counter_length= :ets.update_counter(:countTable,"Length_counter",{2,1})
      #IO.puts "im global counter on server start  #{global_counter_length}"#<>inspect global_counter_length
      send pid, {:ok, global_counter_length}#########
      #global_counter_length=global_counter_length+1
  end)
  end

  def intermediate(parentProcessID,x,lzero,tzero) do
    receive do
      {:ok,length} ->
        workUnit=length * 200000
        findBitCoin(length, lzero,tzero,workUnit)
        send parentProcessID, {:parentOk,x}
    end
  end  

  def findBitCoin(length,lzero,tzero,workUnit)  when workUnit <= 1 do
   
  end

  def findBitCoin(length,lzero,tzero,workUnit)  do
    randInput = Project1.generateInput(length)
    hashInput = Project1.calculateHash(randInput)
    if Project1.check_leading_zeros(hashInput,tzero,lzero) ==true do
      IO.puts randInput<>"  "<>hashInput
    else
      #IO.puts "not a match"
    end
    findBitCoin(length,lzero,tzero,workUnit-1)
  end

  def generateZeroStr(msg, n) when n <= 1 do
    msg
  end

  def generateZeroStr(msg, n) do
    msg=msg<>"0"
    generateZeroStr(msg, n - 1)
  end

  def base62(num_bytes \\16) do
    Project1.random_bytes(num_bytes)
    |> Base.encode64(padding: false)
    |> String.replace(~r/[+\/]/, Project1.random_char())
  end

  def random_bytes(num) do
    :crypto.strong_rand_bytes(num)
  end

  @base62_alphabet 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  
  def random_char do
    Enum.random(@base62_alphabet) |> to_string
  end

  def generateInput(length) do
    "kanikagupta" <> Project1.base62(length)
  end

  def calculateHash(input) do
    #IO.puts "gererating random hash inside hash"
    :crypto.hash(:sha256, input) |> Base.encode16
  end

  
  def check_leading_zeros(input, tzero,lzero) do
    #IO.puts "Checking leading zeroes"
    linput=String.slice(input,0..lzero-1)
    #IO.puts "Checking leading zeroes linput = " <> linput
    if tzero==linput do
      true
    else
      false 
    end
  end



  def generateInputString(length, type \\ :all) do
    #IO.puts "Node is alive #{Node.alive?}"
    #IO.puts "Im before alphas"
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"
    #characters = "!@#$%^&*(){}[]\|;:\'\'.,<>?/+="
    lists =
      cond do
        type == :alpha -> alphabets <> String.downcase(alphabets)
        type == :numeric -> numbers
        type == :upcase -> alphabets
        type == :downcase -> String.downcase(alphabets)
        true -> alphabets <> String.downcase(alphabets) <> numbers
      end
      |> String.split("", trim: true)

    do_generateInputString(length, lists)
  end

  @doc false
  defp get_range(length) when length > 1, do: (1..length)
  defp get_range(length), do: [1]

  @doc false
  defp do_generateInputString(length, lists) do
    IO.puts "Im before random"
    get_range(length)
    |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end

end
