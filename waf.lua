local content_length=tonumber(ngx.req.get_headers()['content-length'])
local method=ngx.req.get_method()
if whiteip() then
elseif blockip() then
elseif denycc() then
elseif ngx.var.http_Acunetix_Aspect then
    ngx.exit(444)
elseif ngx.var.http_X_Scan_Memo then
    ngx.exit(444)
elseif whiteurl() then
elseif ua() then
elseif url() then
elseif args() then
elseif cookie() then
elseif PostCheck then
    if method=="POST" then   
            local boundary = get_boundary()
	    if boundary then
	    local len = string.len
            local sock, err = ngx.req.socket()
    	    if not sock then
					return
            end
	    ngx.req.init_body(128 * 1024)
            sock:settimeout(0)
	    local content_length = nil
    	    content_length=tonumber(ngx.req.get_headers()['content-length'])
    	    local chunk_size = 4096
            if content_length < chunk_size then
					chunk_size = content_length
	    end
            local size = 0
	    while size < content_length do
		local data, err, partial = sock:receive(chunk_size)
		data = data or partial
		if not data then
			return
		end
		ngx.req.append_body(data)
        	if body(data) then
	   	        return true
    	    	end
		size = size + len(data)
		local less = content_length - size
		if less < chunk_size then
			chunk_size = less
		end
	 end
	 ngx.req.finish_body()
    else
			ngx.req.read_body()
			if ngx.req.get_body_file() then
				return
			end
			local args = ngx.req.get_post_args()
			if not args then
				return
			end
			for key, val in pairs(args) do
				if type(val) == "table" or val == false then
					data=table.concat(val, ", ")
				else
					data=val
				end
				if data and type(data) ~= "boolean" and body(data) then
                  return true
				end
			end
		end
    end
else
    return
end
