local openssl = require 'openssl'
local helper = require('helper')
local dh = openssl.dh
local pkey = openssl.pkey
local unpack = table.unpack or unpack

TestDH = {}
function TestDH:testDH()
  local bits = 1024

  local p = dh.generate_parameters(bits)
  local k = p:generate_key()

  assert(k:check())
  assert(k:check(true))
  assert(k:check(false))

  local t = k:parse()
  assert(t.bits == bits)
  assert(t.size == bits/8)
  assert(t.g)
  assert(t.p)
  assert(t.pub_key)
  assert(t.priv_key)
  assert(k:check(t.pub_key))

  if helper.openssl3 then
    return
  end
  local dh= {'dh',  bits}
  dh = pkey.new(unpack(dh))

  local k1 = pkey.get_public(dh)
  assert(not k1:is_private())
  local t = dh:parse()
  assert(t.bits == bits)
  assert(t.type == 'DH')
  assert(t.size)

  local r = t.dh
  t = r:parse()

  t.alg = 'dh'
  local r2 = pkey.new(t)
  assert(r2:is_private())
  r2 = openssl.pkey.new(r)
  assert(r2:is_private())

  local pem = assert(dh:export('pem'))
  assert(openssl.pkey.read(pem, true))
  pem = assert(dh:get_public():export('pem'))
  assert(openssl.pkey.read(pem, false))
end
