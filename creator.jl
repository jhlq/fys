using HttpServer

http = HttpHandler() do req::Request, res::Response
	println(UTF8String(req.data))
	if ismatch(r"^/create/",req.resource)
		t=URIParser.unescape(split(req.resource,'/')[3])
		println(UTF8String(t))
		txt=UTF8String(t)
		f=open("profile.txt","w")
		write(f,txt)
		close(f)
		return Response("Wrote in profile.txt: $txt")
	else
		Response(404)
	end
end

http.events["error"]  = (client, err) -> println(err)
http.events["listen"] = (port)		-> println("Listening on $port...")

server = Server(http)
run(server, 9000)
