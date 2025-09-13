local status = ngx.status
if status == 404 then
    return ngx.redirect("https://google.com")
end

