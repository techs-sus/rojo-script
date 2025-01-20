-- TODO: Actually parse output from generator.rs
-- note you can also use zbase64 instead of base64 (zstd compress then base64 the buffer)

local payload = [[{"m":null,"t":"buffer","base64":"aGVsbG8gd29ybGQgOik="}]]

print("payload: " .. payload)

local buf = game:GetService("HttpService"):JSONDecode(payload)
