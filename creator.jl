using HttpServer

http = HttpHandler() do req::Request, res::Response
	d=UTF8String(req.data)
	println(d)
	if ismatch(r"^/create/",req.resource)
		t=URIParser.unescape(split(req.resource,'/')[3])
		#println(UTF8String(t))
		txt=t#UTF8String(t)
		f=open("profile.txt","w")
		write(f,txt)
		close(f)
		return Response("Wrote in profile.txt: $txt")
	elseif ismatch(r"^/wget/",req.resource)
		#println(`wget $(UTF8String(req.data))`)
		run(`wget $(UTF8String(req.data))`)
		Response("wgot")
	elseif ismatch(r".txt",req.resource)
		t=split(URIParser.unescape(req.resource),'/')
		if ismatch(r".txt",t[end-1]) && d==""
			d=t[end]
			pop!(t)
		end
		if ismatch(r".txt",t[end])
			path=req.resource[2:end]
			if ispath(path)
				if d!=""
					f=open(path,"a");write(f,d);close(f)
					return Response("Appended $d")
				else
					return Response(readall(path))
				end
			elseif d!=""
				mkpath(splitdir(path)[1])
				f=open(path,"w");write(f,d);close(f)
				return Response("Wrote $path")
			else
				return Response(404)
			end
		end
				
	else
		Response(404)
	end
end

http.events["error"]  = (client, err) -> println(err)
http.events["listen"] = (port)		-> println("Listening on $port...")

server = Server(http)
run(server, 9000)
