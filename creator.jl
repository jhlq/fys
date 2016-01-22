using HttpServer

http = HttpHandler() do req::Request, res::Response
	if ismatch(r"^/create/",req.resource)
		f=open("profile.txt","w")
		txt=URIParser.unescape(split(req.resource,'/')[3])
		write(f,txt)
		return Response("Wrote in profile.txt: $txt")
	else
		Response(404)
	end
end

http.events["error"]  = (client, err) -> println(err)
http.events["listen"] = (port)		-> println("Listening on $port...")

server = Server(http)
run(server, 9000)
