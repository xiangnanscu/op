local encode_args = ngx.encode_args
local decode_args = ngx.decode_args
local decode = require"cjson.safe".decode
local http = require"resty.http"
local match = ngx.re.match

local function caller(t, opts) 
    return t:new(opts):initialize() 
end

local qq = setmetatable({
        client_id = '101337042', 
        client_secret = '46310704a4a3295844bf397dd7a3807f', 
        redirect_uri = 'http://www.httper.cn/oauth2/qq',  
        authorize_uri = 'https://graph.qq.com/oauth2.0/authorize', 
        token_uri = 'https://graph.qq.com/oauth2.0/token', 
        me_uri = 'https://graph.qq.com/oauth2.0/me', 
        info_uri = 'https://graph.qq.com/user/get_user_info', 
        user_info_uri = 'https://graph.qq.com/user/get_user_info', 
    }, {__call=caller})
function qq.new(self, init)
    init = init or {}
    self.__index = self
    self.__call = caller
    return setmetatable(init, self)
end
function qq.initialize(self)
    self.login_redirect_uri = self:get_login_redirect_uri()
    return self
end
function qq.get_login_redirect_uri(self)
    return self.authorize_uri..'?'..encode_args{response_type='code', 
        client_id=self.client_id, redirect_uri=self.redirect_uri}
end
qq.initialize(qq)
-- {
--   "body"    : "access_token=5A7E1A50ED8FF900A58BDBD283C0AE3D&expires_in=7776000&refresh_token=AA851E53744FA5CE43A24722B4FB78D1",
--   "body_reader": "function: 0x40f92d60",
--   "has_body": "true",
--   "headers" : {\\table: 0x40f922d8
--                  "Cache-Control": "no-cache",
--                  "Connection": "keep-alive",
--                  "Content-Length": "111",
--                  "Content-Type": "text/html",
--                  "Date"    : "Thu, 21 Jul 2016 08:13:33 GMT",
--                  "Keep-Alive": "timeout=50",
--                  "Server"  : "tws",
--                },
--   "read_body": "function: 0x40f91058",
--   "read_trailers": "function: 0x40f910c0",
--   "reason"  : "OK",
--   "status"  : 200,
-- }
function qq.get_access_token(self, code)
    local client = http:new()
    local uri = self.token_uri..'?'..encode_args{grant_type='authorization_code', 
        client_id=self.client_id, client_secret=self.client_secret, 
        code=code, redirect_uri=self.redirect_uri}
    local res, err = client:request_uri(uri, {ssl_verify = false})
    local body = decode_args(res.body)
    return body.access_token
end
-- callback( {"client_id":"101337042","openid":"2137B3472EE5068BABF950D73669821F"} );
function qq.get_openid(self, access_token)
    local client = http:new()
    local uri = self.me_uri..'?access_token='..access_token
    local res, err = client:request_uri(uri, {ssl_verify = false})
    local openid = match(res.body, [["openid":"(.+?)"]])[1]
    --log('openid', openid)
    return openid
end

function qq.get_user_info(self, openid, access_token)
    local client = http:new()
    local uri = self.user_info_uri..'?'..encode_args{openid=openid, 
        access_token=access_token, oauth_consumer_key=self.client_id}
    local res, err = client:request_uri(uri, {ssl_verify = false})
    --log('user info:', res, err)
    return decode(res.body)
end

local github = setmetatable({
        client_id = '35350283921fce581eb6', 
        client_secret = '75f3157ee95cd436b37ce484b9733beedcfcad66', 
        redirect_uri = 'http://www.httper.cn/oauth2/git',  
        authorize_uri = 'https://github.com/login/oauth/authorize', 
        token_uri = 'https://github.com/login/oauth/access_token', 
        me_uri = 'https://api.github.com/user', 
        user_info_uri = 'https://graph.qq.com/user/get_user_info', 
    }, {__call=caller})
function github.new(self, init)
    init = init or {}
    self.__index = self
    self.__call = caller
    return setmetatable(init, self)
end
function github.initialize(self)
    self.login_redirect_uri = self:get_login_redirect_uri()
    return self
end
function github.get_login_redirect_uri(self)
    return self.authorize_uri..'?'..encode_args{response_type='code', 
        client_id=self.client_id, redirect_uri=self.redirect_uri}
end
github.initialize(github)
function github.get_access_token(self, code)
    local client = http:new()
    local uri = self.token_uri..'?'..encode_args{grant_type='authorization_code', 
        client_id=self.client_id, client_secret=self.client_secret, 
        code=code, redirect_uri=self.redirect_uri}
    local res, err = client:request_uri(uri, {ssl_verify = false})
    local body = decode_args(res.body)
    return body.access_token
end
-- callback( {"client_id":"101337042","openid":"2137B3472EE5068BABF950D73669821F"} );
function github.get_openid(self, access_token)
    local client = http:new()
    local uri = self.me_uri..'?access_token='..access_token
    local res, err = client:request_uri(uri, {ssl_verify = false})
    log('res:', res, 'err:', err)
    local openid = match(res.body, [["openid":"(.+?)"]])[1]
    --log('openid', openid)
    return openid
end

function github.get_user_info(self, openid, access_token)
    local client = http:new()
    local uri = self.user_info_uri..'?'..encode_args{openid=openid, 
        access_token=access_token, oauth_consumer_key=self.client_id}
    local res, err = client:request_uri(uri, {ssl_verify = false})
    --log('user info:', res, err)
    return decode(res.body)
end

return {
    qq = qq, 
    github = github, 
}