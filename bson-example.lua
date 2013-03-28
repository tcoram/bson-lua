bson=require'bson'
epoch=os.time({year=1970, month=1, day=1, hour=0})
bsondoc1=bson.encode{year=2013,
		     month="April",
		     day=2
		    }
bsondoc2=bson.encode{username="maroc", 
		     info={first="todd",
			     last="coram",
			     age=46,
			     signature1=bson.binary("\000\001\002\003",bson.B_GENERIC),
			     signature2=bson.binary("\000\001\002\003"),
			     saved=true,
			     now=bson.utc_datetime(),
			     past=bson.utc_datetime(epoch * 1000),
			     colors={"Red","Green","Blue"}
		     }}

f=io.open("/tmp/test.bson", "wb")
f:write(bsondoc1)
f:write(bsondoc2)
f:close()

function print_table(t)
    function printTableHelper(t, spacing)
        for k,v in pairs(t) do
	   print(spacing..tostring(k), v)
	   if type(v) == "table" then 
	      printTableHelper(v, spacing.."\t")
	   end
	end
    end
    printTableHelper(t, "");
end

-- print_table(bson.decode(bsondoc1))
-- print_table(bson.decode(bsondoc2))

f=io.open("/tmp/test.bson", "rb")
while true do
   local btab = bson.decode_next_io(f)
   if not btab then break end
   print("--Doc--")
   print_table(btab)
   print()
end
f:close()